package Bezel.Lattice
{
    import Bezel.Logger;
    import Bezel.Utils.FunctionDeferrer;
    import Bezel.mainloader_only;

    import com.cff.anebe.AssemblyDoneEvent;
    import com.cff.anebe.BytecodeEditor;
    import com.cff.anebe.DisassemblyDoneEvent;
    import com.cff.anebe.Events;
    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASNamespace;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    /**
     * Coremod handling system: accepts and applies changes to game assembly
     * @author piepie62
     */
    public class Lattice extends EventDispatcher
    {
        private var bytecodeEditor:BytecodeEditor = new BytecodeEditor();

        private var patches:Vector.<LatticePatch>;
        private var expectedPatches:Vector.<LatticePatch>;

        private var patchers:Vector.<LatticePatcherEntry>;

        private var _asasmFiles:Object;
        private var swfToLoad:ByteArray;

        private var wasDisassembled:Boolean;

        private function get requiresPartialAssembly():Boolean
        {
            return patchers.length != 0;
        }

        /** If an actual reassembly step was done, the resulting SWF data. Otherwise null. */
        public function get swfBytes():ByteArray
        {
            return swfToLoad;
        }

        private function get asasmFiles():Object
        {
            if (this._asasmFiles == null)
            {
                this._asasmFiles = new Object();

                var asmStream:FileStream = new FileStream();
                asmStream.open(cleanAsm, FileMode.READ);
                var bytes:ByteArray = new ByteArray();
                asmStream.readBytes(bytes);
                asmStream.close();

                while (bytes.bytesAvailable != 0)
                {
                    var name:String = readNTString(bytes);
                    this._asasmFiles[name] = readNTString(bytes);
                }
            }

            return _asasmFiles;
        }

        private static const logger:Logger = Logger.getLogger("Lattice");

        private var origSwf:File;
        private var newSwf:File;
        private var asm:File;
        private var cleanAsm:File;
        private var coremods:File;
        private var includeDebugInstructions:Boolean;

        /** Total number of patches and patchers submitted to this instance of Lattice */
        public function get numberOfPatches():int
        {
            return patches.length + patchers.length;
        }

        public function Lattice(origSwf:File, newSwf:File, asm:File, cleanAsm:File, coremods:File, includeDebugInstructions:Boolean)
        {
            if (origSwf == null || newSwf == null || asm == null || cleanAsm == null || coremods == null)
            {
                throw new ArgumentError("All arguments to Lattice::Lattice must be non-null.");
            }
            else
            {
                this.origSwf = origSwf;
                this.newSwf = newSwf;
                this.asm = asm;
                this.cleanAsm = cleanAsm;
                this.coremods = coremods;
                this.includeDebugInstructions = includeDebugInstructions;
            }

            this.patches = new Vector.<LatticePatch>();
            this.expectedPatches = new Vector.<LatticePatch>();
            this.patchers = new Vector.<LatticePatcherEntry>();

            bytecodeEditor.addEventListener(Events.DISASSEMBLY_DONE, this.onDisassemblyDone, false, 0, true);
            bytecodeEditor.addEventListener(Events.ASSEMBLY_DONE, this.onAssemblyDone, false, 0, true);
            bytecodeEditor.addEventListener(Events.PARTIAL_ASSEMBLY_DONE, this.onPartialAssemblyDone, false, 0, true);
        }

        /**
         * Disassembles the file passed in into a clean asm if necessary. Prepares Lattice patches.
         * Dispatches LatticeEvents.DISASSEMBLY_DONE when finished.
         * If this is the Lattice given by Bezel, this method SHOULD NOT be called by anything other than Bezel
         * @return Whether coremods should be reloaded, regardless of if they've changed versions or not.
         */
        public function init():Boolean
        {
            var ret:Boolean = false;
            var needsNotification:Boolean = true;

            if (!cleanAsm.exists || cleanAsm.modificationDate.getTime() < origSwf.modificationDate.getTime())
            {
                performDisassemble();
                needsNotification = false;
            }

            if (!asm.exists || !coremods.exists || !newSwf.exists || newSwf.modificationDate.getTime() < origSwf.modificationDate.getTime())
            {
                ret = true;
            }

            if (coremods.exists)
            {
                logger.log("init", "Loading previous coremod info");
                var stream:FileStream = new FileStream();
                try
                {
                    stream.open(coremods, FileMode.READ);
                    while (stream.bytesAvailable != 0)
                    {
                        var filename:String = stream.readUTF();
                        var offset:uint = stream.readUnsignedInt();
                        var contents:String = stream.readUTF();
                        var overwrite:uint = stream.readUnsignedInt();
                        var causesConflict:Boolean = stream.readBoolean();
                        this.expectedPatches[this.expectedPatches.length] = new LatticePatch(filename, offset, overwrite, contents, causesConflict);
                    }
                    stream.close();
                    dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
                }
                catch (e:Error)
                {
                    stream.close();
                    logger.log("init", "Previous coremod info not openable or corrupt. Removing and starting Lattice disassembly.");
                    performDisassemble();
                    ret = true;
                }
            }
            else
            {
                logger.log("init", "Previous coremod info not found. Starting Lattice disassembly.");
                if (needsNotification)
                {
                    dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
                }
            }

            return ret;
        }

        /**
         * Performs cleanup operations (such as deleting the newly-built SWF ByteArray) for post-load.
         */
        public function cleanup():void
        {
            swfToLoad = null;
        }

        private function performDisassemble():void
        {
            if (asm.exists)
            {
                asm.deleteFile();
            }
            if (cleanAsm.exists)
            {
                cleanAsm.deleteFile();
            }
            if (coremods.exists)
            {
                coremods.deleteFile();
            }
            if (newSwf.exists)
            {
                newSwf.deleteFile();
            }

            var swf:ByteArray = new ByteArray();

            var stream:FileStream = new FileStream();
            stream.open(origSwf, FileMode.READ);
            stream.readBytes(swf);
            stream.close();

            bytecodeEditor.DisassembleAsync(swf);
        }

        private function onDisassemblyDone(e:DisassemblyDoneEvent):void
        {
            _asasmFiles = e.strings;
            var stream:FileStream = new FileStream();
            stream.open(cleanAsm, FileMode.WRITE);
            for (var name:String in _asasmFiles)
            {
                writeNTString(stream, name);
                writeNTString(stream, _asasmFiles[name]);
            }
            stream.close();

            this.wasDisassembled = true;

            dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
        }

        /**
         * Actually applies the coremods and runs the reassembler. Dispatches LatticeEvents.REBUILD_DONE when finished.
         * If this is the Lattice given by Bezel, this method SHOULD NOT be called by anything other than Bezel
         */
        public function apply():void
        {
            var comp:Function = function (patch1:LatticePatch, patch2:LatticePatch):int
            {
                if (patch1.filename < patch2.filename)
                {
                    return -1;
                }
                else if (patch2.filename < patch1.filename)
                {
                    return 1;
                }
                else
                {
                    if (patch1.offset < patch2.offset)
                    {
                        return 1;
                    }
                    else if (patch2.offset < patch1.offset)
                    {
                        return -1;
                    }
                    else
                    {
                        if (!patch1.causesConflict && patch2.causesConflict)
                        {
                            return -1;
                        }
                        else if (patch1.causesConflict && !patch2.causesConflict)
                        {
                            return 1;
                        }
                        else
                        {
                            if (patch1.overwritten < patch2.overwritten)
                            {
                                return 1;
                            }
                            else if (patch2.overwritten < patch1.overwritten)
                            {
                                return -1;
                            }
                            else
                            {
                                if (patch1.contents < patch2.contents)
                                {
                                    return -1;
                                }
                                else if (patch2.contents < patch1.contents)
                                {
                                    return 1;
                                }
                                else
                                {
                                    return 0;
                                }
                            }
                        }
                    }
                }
            };

            expectedPatches.sort(comp);
            patches.sort(comp);

            var patchesChanged:Boolean = false;
            if (expectedPatches.length != patches.length)
            {
                patchesChanged = true;
            }
            else
            {
                for (var i:uint = 0; i < expectedPatches.length; ++i)
                {
                    if (expectedPatches[i].filename != patches[i].filename ||
                        expectedPatches[i].contents != patches[i].contents ||
                        expectedPatches[i].offset != patches[i].offset ||
                        expectedPatches[i].overwritten != patches[i].overwritten ||
                        expectedPatches[i].causesConflict != patches[i].causesConflict)
                    {
                        patchesChanged = true;
                        break;
                    }
                }
            }

            if (patchesChanged)
            {
                var stream:FileStream = new FileStream();
                stream.open(coremods, FileMode.WRITE);
                for each (var patch:LatticePatch in patches)
                {
                    stream.writeUTF(patch.filename);
                    stream.writeUnsignedInt(patch.offset);
                    stream.writeUTF(patch.contents);
                    stream.writeUnsignedInt(patch.overwritten);
                    stream.writeBoolean(patch.causesConflict);
                }
                stream.close();
            }

            if (patchesChanged || !newSwf.exists || !asm.exists)
            {
                checkConflicts();
                doTextPatchAndReassemble();
            }
            else if (requiresPartialAssembly)
            {
                doPatchersAndReassemble();
            }
            else
            {
                dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
            }
        }

        private function checkConflicts():void
        {
            var replaced:Object = new Object();
            for each (var patch:LatticePatch in patches)
            {
                if (patch.causesConflict && patch.overwritten != 0)
                {
                    var dict:Dictionary = replaced[patch.filename] || (replaced[patch.filename] = new Dictionary());
                    for (var i:int = patch.offset; i != patch.offset + patch.overwritten; ++i)
                    {
                        dict[i] = patch;
                    }
                }
            }

            var conflicts:uint = 0;

            for each (patch in patches)
            {
                dict = replaced[patch.filename];
                if (patch.filename in replaced && dict[patch.offset] != null && dict[patch.offset] != patch)
                {
                    if (patch.causesConflict && (patch.overwritten != 0 || (patch.offset != 0 && dict[patch.offset - 1] != null)))
                    {
                        logger.log("checkConflicts", "Lattice (for " + origSwf.nativePath + "): Modifications at line " + patch.offset + " conflict");
                        conflicts++;
                    }
                }
            }

            if (conflicts != 0)
            {
                throw new Error(conflicts + " Lattice patch conflict" + (conflicts == 1 ? "" : "s") + " occurred! Check Bezel log for details");
            }
        }

        private function doTextPatchAndReassemble():void
        {
            var dataAsStrings:Object = new Object();
            var doSinglePatch:Function = function (i:int):void
            {
                if (i < patches.length)
                {
                    var patch:LatticePatch = patches[i];
                    logger.log("doPatch", "Patching line " + patch.offset + " of " + patch.filename);

                    var strings:Array = dataAsStrings[patch.filename] || (dataAsStrings[patch.filename] = asasmFiles[patch.filename].split('\n'));

                    dataAsStrings[patch.filename] = strings.slice(0, patch.offset).concat(patch.contents.split('\n'), strings.slice(patch.offset + patch.overwritten));

                    dispatchEvent(new Event(LatticeEvent.SINGLE_PATCH_APPLIED));
                    FunctionDeferrer.deferFunction(doSinglePatch, [i + 1], null, true);
                }
                else
                {
                    for (var filename:String in dataAsStrings)
                    {
                        asasmFiles[filename] = dataAsStrings[filename].join('\n');
                    }

                    var stream:FileStream = new FileStream();
                    stream.open(asm, FileMode.WRITE);
                    for (var file:String in asasmFiles)
                    {
                        writeNTString(stream, file);
                        writeNTString(stream, asasmFiles[file]);
                    }
                    stream.close();

                    doPatchersAndReassemble();
                }
            };

            doSinglePatch(0);
        }

        private function doPatchersAndReassemble():void
        {
            var replaceBytes:ByteArray = null;

            if (!wasDisassembled)
            {
                replaceBytes = new ByteArray();
                var stream:FileStream = new FileStream();
                stream.open(origSwf, FileMode.READ);
                stream.readBytes(replaceBytes);
                stream.close();
            }

            if (requiresPartialAssembly)
            {
                bytecodeEditor.PartialAssembleAsync(_asasmFiles, includeDebugInstructions, replaceBytes);
            }
            else
            {
                bytecodeEditor.AssembleAsync(_asasmFiles, includeDebugInstructions, replaceBytes);
            }
        }

        private function onPartialAssemblyDone(e:Event):void
        {
            var types:Object = new Object();
            var doSinglePatcher:Function = function (i:uint):void
            {
                if (i < patchers.length)
                {
                    var name:ASMultiname = patchers[i].name;
                    var patcher:LatticePatcher = patchers[i].patcher;
                    logger.log("onPartialAssemblyDone", "Patching " + name.ns.name + "." + name.name + " with an instance of " + getQualifiedClassName(patcher));
                    var namespaces:Object = types[name.ns.type] || (types[name.ns.type] = new Object());
                    var classes:Object = namespaces[name.ns.name] || (namespaces[name.ns.name] = new Object());
                    var clazz:ASClass = classes[name.name] as ASClass || (classes[name.name] = bytecodeEditor.GetClass(name, patchers[i].idx));
                    if (clazz == null)
                    {
                        throw new Error("Class " + name.ns.name + "." + name.name + " does not exist in the partial reassembly to be patched by an instance of " + getQualifiedClassName(patcher));
                    }
                    patcher.patchClass(clazz);
                    dispatchEvent(new Event(LatticeEvent.SINGLE_PATCH_APPLIED));
                    FunctionDeferrer.deferFunction(doSinglePatcher, [i + 1], null, true);
                }
                else
                {
                    bytecodeEditor.FinishAssembleAsync();
                }
            };

            doSinglePatcher(0);
        }

        private function onAssemblyDone(e:AssemblyDoneEvent):void
        {
            swfToLoad = e.assembled;

            var out:FileStream = new FileStream();
            out.open(newSwf, FileMode.WRITE);
            out.writeBytes(swfToLoad);
            out.close();

            bytecodeEditor.Cleanup();

            dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
        }

        /**
         * Submits a patcher to be run after text-based coremods are changed
         * @param patcher Patcher class, which will have its patchClass function called with the found class.
         * @param className Name of class to be patched. If a string, it's interpreted as a qualified name that will look in PackageNamespaces.
         * If an ASMultiname, it's interpreted as a full identifier. Note that an ASMultiname passed in must be a QName.
         * @param indexIfMoreThanOne If there are multiple classes that match the name, disambiguates between them.
         */
        public function submitPatcher(patcher:LatticePatcher, className:*, indexIfMoreThanOne:uint = 0):void
        {
            if (className is String)
            {
                (className as String).replace("::", ".");
                var nsArr:Array = (className as String).split('.');
                var clazz:String = nsArr.pop();
                var ns:String = nsArr.join('.');
                patchers.push(new LatticePatcherEntry(patcher, new ASMultiname(ASMultiname.TYPE_QNAME, clazz, new ASNamespace(ASNamespace.TYPE_PACKAGE, ns)), indexIfMoreThanOne));
            }
            else if (className is ASMultiname)
            {
                if (className == null || (className as ASMultiname).type != ASMultiname.TYPE_QNAME)
                {
                    throw new ArgumentError("Class name must be a QName");
                }
                patchers.push(new LatticePatcherEntry(patcher, className, indexIfMoreThanOne));
            }
            else
            {
                throw new ArgumentError("Class name must be either a QName or a String");
            }
        }

        /**
         * Returns whether a file exists in the disassembly.
         * @param filename File to search for
         * @return Whether or not it exists
         */
        public function doesFileExist(filename:String):Boolean
        {
            return filename in this.asasmFiles;
        }

        /**
         * Inserts and optionally removes assembly at a given line offset within a passed-in GCFW assembly filename.
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset at which to insert the contents. Note that this is zero-indexed: value 1 will be inserted AFTER line 1
         * @param replaceLines Number of lines to remove at the specified offset. Note that this will delete with respect to zero-indexing:
         * if this is 1 and offset is 1, the second line will be removed
         * @param contents New lines of assembly to insert. Can be empty if only removal is necessary
         */
        public function patchFile(filename:String, offset:int, replaceLines:int, contents:String):void
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }
            this.patches[this.patches.length] = new LatticePatch(filename, offset, replaceLines, contents);
        }

        /**
         * Retrieves the contents of the passed-in GCFW assembly filename.
         * @param filename File to retrieve. If retrieving a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         */
        public function retrieveFile(filename:String):String
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }
            return asasmFiles[filename];
        }

        /**
         * Finds a regex within a passed-in GCFW assembly filename
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param pattern Pattern to search for. Can be a multiline regex
         * @param searchFrom Offset at which to start searching the contents. Note that this is zero-indexed: value 1 will search lines 2-end
         * @return The line index where the pattern matched. Zero-indexed, so can be passed directly into another findPattern or into patchFile
         */
        public function findPattern(filename:String, pattern:RegExp, searchFrom:int = 0):int
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            var searchString:String = searchFrom > 0 ? this.asasmFiles[filename].split('\n').slice(searchFrom).join('\n') : this.asasmFiles[filename];

            var ret:int = searchString.search(pattern);
            if (ret != -1)
            {
                var newlines:String = searchString.slice(0, ret);
                var newlineArray:Array = newlines.split('\n');
                if (newlines != null)
                {
                    ret = searchFrom + newlineArray.length;
                }
                else
                {
                    ret = searchFrom;
                }
            }

            return ret;
        }

        /**
         * Finds and replaces a regex within a passed-in GCFW assembly filename. Note that $ replacement codes can be used in the replacement string.
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param pattern Pattern to search for. Can be a multiline regex
         * @param replacement Object to use for replacement string. Passed into the second argument of String.replace
         * @param searchFrom Offset at which to start searching the contents. Note that this is zero-indexed: value 1 will search lines 2-end
         * @return Whether the find and replacement succeeded
         */
        public function replacePattern(filename:String, pattern:RegExp, replacement:*, searchFrom:int = 0):Boolean
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            var searchString:String = searchFrom > 0 ? this.asasmFiles[filename].split('\n').slice(searchFrom).join('\n') : this.asasmFiles[filename];

            var line:int = findPattern(filename, pattern, searchFrom);
            if (line != -1)
            {
                var result:Object = pattern.exec(searchString);

                var lines:Array = result[0].split('\n');
                searchString = searchString.split('\n').slice(0, lines.length).join('\n');

                var replaced:String = searchString.replace(pattern, replacement);

                this.patchFile(filename, line, lines.length, replaced);

                return true;
            }

            return false;
        }

        /**
         * Copies out code found via a regex within a passed-in GCFW assembly filename
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param pattern Pattern to search for. Can be a multiline regex
         * @param searchFrom Offset at which to start searching the contents. Note that this is zero-indexed: value 1 will search lines 2-end
         * @return The result of pattern.exec
         */
        public function retrievePattern(filename:String, pattern:RegExp, searchFrom:int = 0):Object
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            var searchString:String = searchFrom > 0 ? this.asasmFiles[filename].split('\n').slice(searchFrom).join('\n') : this.asasmFiles[filename];

            return pattern.exec(searchString);
        }

        /**
         * Copies out code from the passed-in GCFW assembly filename
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset from which to pull the contents. Note that this is zero-indexed: value 1 will retrieve lines 2-offset+lines
         * @param lines Number of lines to retrieve
         * @return A string containing the specified region of code
         */
        public function retrieveCode(filename:String, offset:int, lines:int):String
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            return this.asasmFiles[filename].split('\n').slice(offset, offset + lines).join('\n');
        }

        /**
         * Copies out code from the passed-in GCFW assembly filename, removing it from its original position.
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset from which to pull the contents. Note that this is zero-indexed: value 1 will retrieve lines 2-offset+lines
         * @param lines Number of lines to retrieve
         * @return A string containing the specified region of code
         */
        public function extractCode(filename:String, offset:int, lines:int):String
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            this.patchFile(filename, offset, lines, "");

            return retrieveCode(filename, offset, lines);
        }

        private static function readNTString(data:ByteArray):String
        {
            var position:uint = data.position;
            var length:uint = data.length;
            var num:uint = 0;
            while (num + position < length && data[num + position] != 0)
            {
                ++ num;
            }

            var ret:String = data.readUTFBytes(num);
            data.position++; // Consume the null terminator
            return ret;
        }

        private static function writeNTString(stream:FileStream, data:String):void
        {
            stream.writeUTFBytes(data);
            stream.writeByte(0);
        }

        /**
         * Gets a list of files available to edit in the currently loaded ABC.
         * @return List of filenames that can be passed to the code edit functions
         */
        public function listFiles():Vector.<String>
        {
            var ret:Vector.<String> = new <String>[];
            for (var file:String in asasmFiles)
            {
                ret[ret.length] = file;
            }
            return ret;
        }

        /**
         * This should ONLY be used if you are ABSOLUTELY SURE you know what you're doing!
         * Applies a Lattice patch WITHOUT causing conflicts with any other patches that might affect the same line.
         * Example use case: GemCraft Chasing Shadows ENumbers can be inlined with a single instruction change, which results in massive performance gains
         * Should almost certainly only be used by MainLoaders
         * Note: these patches must replace the exact number of lines that the contents have
         *
         * @param filename File to edit. If editing a class, this will be the fully qualified name of the class with periods replaced by /,
         * followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset at which to insert the contents. Note that this is zero-indexed: value 1 will be inserted AFTER line 1
         * @param replaceLines Number of lines to remove at the specified offset. Note that this will delete with respect to zero-indexing:
         * if this is 1 and offset is 1, the second line will be removed
         * @param contents New lines of assembly to insert. Can be empty if only removal is necessary
         */
        mainloader_only function DANGEROUS_patchFile(filename:String, offset:int, replaceLines:int, contents:String):void
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }
            if (contents.split('\n').length != replaceLines)
            {
                throw new Error("DANGEROUS_patchFile for file '" + filename + "' received a number of lines different from the amount to be replaced");
            }
            this.patches[this.patches.length] = new LatticePatch(filename, offset, replaceLines, contents, false);
        }
    }
}
