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
    import flash.errors.IOError;
    import flash.events.Event;
    import flash.utils.Dictionary;

    public class Lattice extends EventDispatcher
    {
        private var currentTool:String;
        private var patches:Vector.<LatticePatch>;
        private var expectedPatches:Vector.<LatticePatch>;

        private var process:NativeProcess;
        private var processInfo:NativeProcessStartupInfo;

        private var logger:Logger;

        private var doneDisassembling:Boolean = false;

        public function Lattice(bezel:Bezel)
        {
            this.logger = bezel.getLogger("Lattice");

            this.patches = new Vector.<LatticePatch>();
            this.expectedPatches = new Vector.<LatticePatch>();
        }

        private function callTool(tool:String, argument:Array): void
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
            for each (var arg:String in argument)
            {
                processInfo.arguments.push(arg);
            }
            processInfo.workingDirectory = File.applicationStorageDirectory;
            process.addEventListener(NativeProcessExitEvent.EXIT, this.toolFinished);
            process.start(processInfo);
        }

        private function toolFinished(e:NativeProcessExitEvent): void
        {
            if (e.exitCode != 0)
            {
                logger.log("toolFinished", currentTool + " failed");
            }
            switch (currentTool)
            {
                case "abcexport":
                    logger.log("toolFinished", currentTool + " has finished");
                    callTool("rabcdasm", ["gcfw-0.abc"]);
                    break;
                case "rabcdasm":
                    logger.log("toolFinished", currentTool + " has finished");
                    File.applicationStorageDirectory.resolvePath("gcfw-0").copyTo(File.applicationStorageDirectory.resolvePath("gcfw-0-clean"));
                    dispatchEvent(new Event(LatticeEvent.DISASSEMBLY_DONE));
                    break;
                case "rabcasm":
                    logger.log("toolFinished", currentTool + " has finished");
                    callTool("abcreplace", ["gcfw-modded.swf", "0", "gcfw-0/gcfw-0.main.abc"]);
                    break;
                case "abcreplace":
                    logger.log("toolFinished", currentTool + " has finished");
                    dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
                    break;
            }
        }

        public function init(bezel:Bezel): void
        {
            if (!File.applicationStorageDirectory.resolvePath("gcfw-0.abc").exists ||
                !File.applicationStorageDirectory.resolvePath("gcfw-0-clean").exists ||
                !File.applicationStorageDirectory.resolvePath("gcfw-0").exists ||
                !File.applicationStorageDirectory.resolvePath("coremods.lttc").exists ||
                !File.applicationStorageDirectory.resolvePath("gcfw-modded.swf").exists)
            {
                if (File.applicationStorageDirectory.resolvePath("gcfw-0-clean").exists)
                {
                    File.applicationStorageDirectory.resolvePath("gcfw-0-clean").deleteDirectory(true);
                }
                if (File.applicationStorageDirectory.resolvePath("gcfw-0").exists)
                {
                    File.applicationStorageDirectory.resolvePath("gcfw-0").deleteDirectory(true);
                }
                if (File.applicationStorageDirectory.resolvePath("coremods.lttc").exists)
                {
                    File.applicationStorageDirectory.resolvePath("coremods.lttc").deleteFile();
                }
                if (File.applicationStorageDirectory.resolvePath("gcfw-modded.swf").exists)
                {
                    File.applicationStorageDirectory.resolvePath("gcfw-modded.swf").deleteFile();
                }

                if (!File.applicationStorageDirectory.resolvePath("gcfw.swf").exists)
                {
                    File.applicationDirectory.resolvePath("GemCraft Frostborn Wrath Backup.swf").copyTo(File.applicationStorageDirectory.resolvePath("gcfw.swf"));
                }
                if (!File.applicationStorageDirectory.resolvePath("gcfw-modded.swf").exists)
                {
                    File.applicationStorageDirectory.resolvePath("gcfw.swf").copyTo(File.applicationStorageDirectory.resolvePath("gcfw-modded.swf"));
                }

                callTool("abcexport", ["gcfw.swf"]);
            }

            var file:File = File.applicationStorageDirectory.resolvePath("coremods.lttc");
            if (file.exists)
            {
                logger.log("init", "Loading previous coremod info");
                var stream:FileStream = new FileStream();
                stream.open(file, FileMode.READ);
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

                File.applicationStorageDirectory.resolvePath("gcfw-0").deleteDirectory(true);
                File.applicationStorageDirectory.resolvePath("gcfw-0-clean").copyTo(File.applicationStorageDirectory.resolvePath("gcfw-0"));
                checkConflicts();
                doPatch();
                callTool("rabcasm", ["gcfw-0/gcfw-0.main.asasm"]);
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

                var file:File = File.applicationStorageDirectory.resolvePath("gcfw-0/" + patch.filename);
                var stream:FileStream = new FileStream();
                stream.open(file, FileMode.READ);
                var dataAsStrings:Array = stream.readUTFBytes(stream.bytesAvailable).split('\n');
                stream.close();

                for (var i:uint = 0; i < patch.overwritten; ++i)
                {
                    dataAsStrings.removeAt(patch.offset);
                }
                dataAsStrings.insertAt(patch.offset, patch.contents);

                stream.open(file, FileMode.WRITE);
                stream.writeUTFBytes(dataAsStrings.join('\n'));
                stream.close();
            }
        }

        public function patchFile(filename:String, offset:int, replaceLines:int, contents:String): void
        {
            if (!File.applicationStorageDirectory.resolvePath("gcfw-0/" + filename).exists)
            {
                throw new IOError("'" + filename + "'" + " does not exist");
            }
            this.patches[this.patches.length] = new LatticePatch(filename, offset, replaceLines, contents);
        }

        public function findPattern(filename:String, searchFrom:int, pattern:RegExp): int
        {
            var file:File = File.applicationStorageDirectory.resolvePath("gcfw-0-clean/" + filename);
            if (!file.exists)
            {
                throw new IOError("'" + filename + "'" + " does not exist");
            }

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var searchString:String = stream.readUTFBytes(stream.bytesAvailable).split('\n').slice(searchFrom).join('\n');
            stream.close();

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
    }
}
