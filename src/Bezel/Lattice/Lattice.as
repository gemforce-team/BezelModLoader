package Bezel.Lattice
{
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

        private var doneDisassembling:Boolean = false;

        public static var gameSwf:File = File.applicationDirectory.resolvePath("GemCraft Frostborn Wrath Backup.swf");
        public static var moddedSwf:File = File.applicationDirectory.resolvePath("gcfw-modded.swf");
        public static var asm:File = File.applicationStorageDirectory.resolvePath("gcfw.basasm");
        public static var cleanAsm:File = File.applicationStorageDirectory.resolvePath("gcfw-clean.basasm");
        public static var coremods:File = File.applicationStorageDirectory.resolvePath("coremods.lttc");

        public function Lattice(bezel:Bezel)
        {
            logger = bezel.getLogger("Lattice");

            this.patches = new Vector.<LatticePatch>();
            this.expectedPatches = new Vector.<LatticePatch>();
        }

        private function callTool(tool:String, argument:Vector.<String>): void
        {
            logger.log("callTool", "Starting " + tool);
            this.process = new NativeProcess();
            this.processInfo = new NativeProcessStartupInfo();
            this.currentTool = tool;
            processInfo.executable = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/tools/" + tool + ".exe");
            if (!processInfo.executable.exists)
            {
                processInfo.executable = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/tools/" + tool);
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

        // Returns whether coremods should be reloaded, regardless of if they've changed or not
        public function init(): Boolean
        {
            var ret:Boolean = false;

            if (!asm.exists || !cleanAsm.exists || !coremods.exists || !moddedSwf.exists)
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

                callTool("disassemble", new <String>[gameSwf.nativePath, cleanAsm.nativePath]);
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
                stream.open(File.applicationStorageDirectory.resolvePath("coremods.lttc"), FileMode.WRITE);
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
                callTool("reassemble", new <String>[gameSwf.nativePath, asm.nativePath, moddedSwf.nativePath]);
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

                for (var i:uint = 0; i < patch.overwritten; ++i)
                {
                    dataAsStrings.removeAt(patch.offset);
                }
                dataAsStrings.insertAt(patch.offset, patch.contents);

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

        public function patchFile(filename:String, offset:int, replaceLines:int, contents:String): void
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }
            this.patches[this.patches.length] = new LatticePatch(filename, offset, replaceLines, contents);
        }

        public function findPattern(filename:String, searchFrom:int, pattern:RegExp): int
        {
            if (!(filename in this.asasmFiles))
            {
                throw new Error("File '" + filename + "' not in disassembly");
            }

            var searchString:String = this.asasmFiles[filename].split('\n').slice(searchFrom).join('\n');

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
