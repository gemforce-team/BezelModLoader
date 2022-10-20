package Bezel.Lattice
{
    /**
     * Coremod handling system: accepts and applies changes to game assembly
     * @author piepie62
     */

    import Bezel.Logger;
    import Bezel.mainloader_only;
    import Bezel.Utils.FunctionDeferrer;

    import com.cff.anebe.AssemblyDoneEvent;
    import com.cff.anebe.BytecodeEditor;
    import com.cff.anebe.DisassemblyDoneEvent;
    import com.cff.anebe.Events;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    public class Lattice extends EventDispatcher
    {
        private var bytecodeEditor:BytecodeEditor = new BytecodeEditor();

        private var patches:Vector.<LatticePatch>;
        private var expectedPatches:Vector.<LatticePatch>;

        private var _asasmFiles:Object;
        private var _asasmList:Vector.<String>;
        private var swfToLoad:ByteArray;

        private var wasDisassembled:Boolean;

        // May be populated, if an actual reassembly step was done. Check before using.
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

        public function get numberOfPatches():int
        {
            return patches.length;
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

            bytecodeEditor.addEventListener(Events.DISASSEMBLY_DONE, this.onDisassemblyDone);
            bytecodeEditor.addEventListener(Events.ASSEMBLY_DONE, this.onAssemblyDone);
        }

        // Disassembles the file passed in into a clean asm if necessary. Prepares Lattice patches.
        // Returns whether coremods should be reloaded, regardless of if they've changed or not.
        // Dispatches LatticeEvents.DISASSEMBLY_DONE when finished.
        // If this is the Lattice given by Bezel, this method SHOULD NOT be called by anything other than Bezel
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
                        this.expectedPatches[this.expectedPatches.length] = new LatticePatch(filename, offset, overwrite, contents);
                    }
                    stream.close();
                    dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
                }
                catch (e:Error)
                {
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

        // Actually applies the coremods and runs the reassembler. Dispatches LatticeEvents.REBUILD_DONE when finished.
        // If this is the Lattice given by Bezel, this method SHOULD NOT be called by anything other than Bezel
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

            var unchangedPatches:Boolean = true;
            if (expectedPatches.length != patches.length)
            {
                unchangedPatches = false;
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
                        unchangedPatches = false;
                        break;
                    }
                }
            }

            if (!unchangedPatches)
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

                checkConflicts();
                doPatchAndReassemble();
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
                    if (!(patch.filename in replaced))
                    {
                        replaced[patch.filename] = new Dictionary();
                    }
                    for (var i:int = patch.offset; i != patch.offset + patch.overwritten; ++i)
                    {
                        replaced[patch.filename][i] = patch;
                    }
                }
            }

            for each (patch in patches)
            {
                if (patch.filename in replaced && Dictionary(replaced[patch.filename])[patch.offset] != null && Dictionary(replaced[patch.filename])[patch.offset] != patch)
                {
                    if (patch.causesConflict && (patch.overwritten != 0 || (patch.offset != 0 && Dictionary(replaced[patch.filename])[patch.offset - 1] != null)))
                    {
                        throw new Error("Lattice (for " + origSwf.nativePath + "): Modifications at line " + patch.offset + " conflict");
                    }
                }
            }
        }

        private function doPatchAndReassemble():void
        {
            var doSinglePatch:Function = function (i:int):void
            {
                var patch:LatticePatch = patches[i];
                logger.log("doPatch", "Patching line " + patch.offset + " of " + patch.filename);

                var dataAsStrings:Array = asasmFiles[patch.filename].split('\n');

                dataAsStrings.splice(patch.offset, patch.overwritten, patch.contents);

                // dataAsStrings.insertAt(patch.offset, patch.contents);

                asasmFiles[patch.filename] = dataAsStrings.join('\n');
                dispatchEvent(new Event(LatticeEvent.SINGLE_PATCH_APPLIED));

                if (i + 1 < patches.length)
                {
                    FunctionDeferrer.deferFunction(doSinglePatch, [i + 1], null, true);
                }
                else
                {
                    var stream:FileStream = new FileStream();
                    stream.open(asm, FileMode.WRITE);
                    for (var file:String in asasmFiles)
                    {
                        writeNTString(stream, file);
                        writeNTString(stream, asasmFiles[file]);
                    }
                    stream.close();

                    var replaceBytes:ByteArray = null;

                    if (!wasDisassembled)
                    {
                        replaceBytes = new ByteArray();
                        stream.open(origSwf, FileMode.READ);
                        stream.readBytes(replaceBytes);
                        stream.close();
                    }

                    bytecodeEditor.AssembleAsync(_asasmFiles, includeDebugInstructions, replaceBytes);
                }
            };

            doSinglePatch(0);
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset at which to insert the contents. Note that this is zero-indexed: value 1 will be inserted AFTER line 1
         * @param replaceLines Number of lines to remove at the specified offset. Note that this will delete with respect to zero-indexing:
         *                     if this is 1 and offset is 1, the second line will be removed
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
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
         *                 followed by ".class.asasm". Example: com.giab.games.gcfw.Main becomes "com/giab/games/gcfw/Main.class.asasm"
         * @param offset Offset at which to insert the contents. Note that this is zero-indexed: value 1 will be inserted AFTER line 1
         * @param replaceLines Number of lines to remove at the specified offset. Note that this will delete with respect to zero-indexing:
         *                     if this is 1 and offset is 1, the second line will be removed
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
