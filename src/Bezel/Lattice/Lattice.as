package Bezel.Lattice
{
	/**
	 * "Coremod" handling system: accepts and applies changes to GCFW assembly
	 * @author piepie62
	 */

    import flash.filesystem.File;
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.NativeProcessExitEvent;
    import flash.events.EventDispatcher;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import Bezel.Bezel;
    import Bezel.Logger;
    import flash.filesystem.FileMode;
    import flash.events.Event;
    import flash.utils.Dictionary;

    public class Lattice extends EventDispatcher
    {
        private var currentTool:String;
        private var patches:Vector.<LatticePatch>;
        private var expectedPatches:Vector.<LatticePatch>;

        private var _asasmFiles:Object;

        private function get asasmFiles(): Object
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
                    this.asasmFiles[name] = readNTString(bytes);
                }
            }

        	return _asasmFiles;
        }

        private var process:NativeProcess;
        private var processInfo:NativeProcessStartupInfo;
        private var processError:String;

        internal static var logger:Logger;
		internal var bezel:Bezel;

        private var doneDisassembling:Boolean = false;

        public static const asm:File = Bezel.Bezel.latticeFolder.resolvePath("game.basasm");
        public static const cleanAsm:File = Bezel.Bezel.latticeFolder.resolvePath("game-clean.basasm");
        public static const coremods:File = Bezel.Bezel.latticeFolder.resolvePath("coremods.lttc");

        public function Lattice(bezel:Bezel)
        {
            logger = bezel.getLogger("Lattice");
			this.bezel = bezel;

            this.patches = new Vector.<LatticePatch>();
            this.expectedPatches = new Vector.<LatticePatch>();
        }

        private function callTool(tool:String, argument:Vector.<String>): void
        {
            logger.log("callTool", "Starting " + tool);
            this.process = new NativeProcess();
            this.processInfo = new NativeProcessStartupInfo();
            this.currentTool = tool;
            processInfo.executable = Bezel.Bezel.toolsFolder.resolvePath(tool + ".exe");
            if (!processInfo.executable.exists)
            {
                processInfo.executable = Bezel.Bezel.toolsFolder.resolvePath(tool);
            }
            processInfo.arguments = argument;
            processInfo.workingDirectory = File.applicationStorageDirectory;
            process.addEventListener(NativeProcessExitEvent.EXIT, this.toolFinished);
            process.addEventListener("standardErrorData", this.onToolError);
            process.start(processInfo);
        }

        private function toolFinished(e:NativeProcessExitEvent): void
        {
            if (e.exitCode != 0)
            {
                logger.log("toolFinished", currentTool + " failed: " + this.processError);
				if (coremods.exists)
				{
					coremods.deleteFile();
				}
                throw new Error("Lattice patch tool " + currentTool + " failed. Check the log file for details");
            }

            logger.log("toolFinished", currentTool + " has finished");
            switch (currentTool)
            {
                case "disassemble":
                    cleanAsm.copyTo(asm);
                    dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
                    break;
                case "reassemble":
                    dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
                    break;
            }
        }

        private function onToolError(e:Event): void
        {
            this.processError += this.process.standardError.readUTFBytes(process.standardError.bytesAvailable);
        }

		// Disassembles the game into a clean asm. Prepares Lattice patches.
        // Returns whether coremods should be reloaded, regardless of if they've changed or not
        public function init(): Boolean
        {
            var ret:Boolean = false;

            if (!asm.exists || !cleanAsm.exists || !coremods.exists || !bezel.moddedSwf.exists || bezel.moddedSwf.modificationDate.getTime() < bezel.gameSwf.modificationDate.getTime())
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

                callTool("disassemble", new <String>[bezel.gameSwf.nativePath, cleanAsm.nativePath]);
                ret = true;
            }

            if (coremods.exists)
            {
                logger.log("init", "Loading previous coremod info");
                var stream:FileStream = new FileStream();
                stream.open(coremods, FileMode.READ);
                while (stream.bytesAvailable != 0)
                {
                    var filename:String = stream.readUTF();
                    var offset:uint = stream.readUnsignedInt();
                    var contents:String = stream.readUTF();
                    var overwrite:uint = stream.readUnsignedInt();
                    this.expectedPatches[this.expectedPatches.length] = new LatticePatch(filename, offset, overwrite, contents);
                }
                stream.close();
                dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
            }
            else
            {
                logger.log("init", "Previous coremod info not found");
            }

            return ret;
        }

        public function apply(): void
        {
            var comp:Function = function (patch1:LatticePatch, patch2:LatticePatch) : int {
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
                        return 0;
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
                        expectedPatches[i].overwritten != patches[i].overwritten)
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
                }
                stream.close();

                checkConflicts();
                doPatch();
                callTool("reassemble", new <String>[bezel.gameSwf.nativePath, asm.nativePath, bezel.moddedSwf.nativePath]);
            }
            else
            {
                dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
            }
        }

        private function checkConflicts(): void
        {
            var replaced:Object = new Object();
            for each (var patch:LatticePatch in patches)
            {
                if (patch.overwritten != 0)
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
                    throw new Error("Lattice: Modifications at line " + patch.offset + " conflict");
                }
            }
        }

        private function doPatch(): void
        {
            for each (var patch:LatticePatch in patches)
            {
                logger.log("doPatch", "Patching line " + patch.offset + " of " + patch.filename);

                var dataAsStrings:Array = this.asasmFiles[patch.filename].split('\n');

                dataAsStrings.splice(patch.offset, patch.overwritten, patch.contents);

                // dataAsStrings.insertAt(patch.offset, patch.contents);

                this.asasmFiles[patch.filename] = dataAsStrings.join('\n');
            }

            var stream:FileStream = new FileStream();
            stream.open(asm, FileMode.WRITE);
            for (var file:String in this.asasmFiles)
            {
                writeNTString(stream, file);
                writeNTString(stream, this.asasmFiles[file]);
            }
            stream.close();
        }
		
		/**
		 * Returns whether a file exists in the disassembly.
		 * @param filename File to search for
		 * @return Whether or not it exists
		 */
		public function doesFileExist(filename:String): Boolean
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
        public function patchFile(filename:String, offset:int, replaceLines:int, contents:String): void
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
        public function retrieveFile(filename:String): String
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
        public function findPattern(filename:String, pattern:RegExp, searchFrom:int = 0): int
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
        public function replacePattern(filename:String, pattern:RegExp, replacement:*, searchFrom:int = 0): Boolean
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
        public function retrievePattern(filename:String, pattern:RegExp, searchFrom:int = 0): Object
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
        public function retrieveCode(filename:String, offset:int, lines:int): String
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
        public function extractCode(filename:String, offset:int, lines:int): String
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            this.patchFile(filename, offset, lines, "");

            return retrieveCode(filename, offset, lines);
        }

        private static function readNTString(data:ByteArray): String
        {
            var num:uint = 0;
            while (num + data.position < data.length && data[num + data.position] != 0)
            {
                ++num;
            }

            var ret:String = data.readUTFBytes(num);
            data.position++; // Consume the null terminator
            return ret;
        }

        private static function writeNTString(stream:FileStream, data:String): void
        {
            stream.writeUTFBytes(data);
            stream.writeByte(0);
        }
    }
}
