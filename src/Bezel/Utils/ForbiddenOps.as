package Bezel.Utils {
    import Bezel.bezel_internal;
    import flash.filesystem.File;
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.NativeProcessExitEvent;

    public class ForbiddenOps {
        private static const cmdFile:File = new File("C:\\Windows\\System32\\cmd.exe");

        // onFinish: function(from:File, to:File):void
        bezel_internal static function forbiddenCopy(from:File, to:File, onFinish:Function):void {
            var newProcess:NativeProcess = new NativeProcess();
            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

            startupInfo.executable = cmdFile;
            startupInfo.arguments = new <String>["/c", "copy /y \"" + from.nativePath + "\" \"" + to.nativePath + "\""];

            newProcess.addEventListener(NativeProcessExitEvent.EXIT, function(e:NativeProcessExitEvent):void {
                if (e.exitCode != 0) {
                    throw new Error("Forbidden copy with command \'" + startupInfo.arguments[1] + "\' failed");
                }

                newProcess.closeInput();

                onFinish(from, to);
            });

            newProcess.start(startupInfo);
        }

        // onFinish: function(from:File, to:File):void
        bezel_internal static function forbiddenMove(from:File, to:File, onFinish:Function):void {
            var newProcess:NativeProcess = new NativeProcess();
            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

            startupInfo.executable = cmdFile;
            startupInfo.arguments = new <String>["/c", "move /y \"" + from.nativePath + "\" \"" + to.nativePath + "\""];

            newProcess.addEventListener(NativeProcessExitEvent.EXIT, function(e:NativeProcessExitEvent):void {
                if (e.exitCode != 0) {
                    throw new Error("Forbidden move with command \'" + startupInfo.arguments[1] + "\' failed");
                }

                newProcess.closeInput();

                onFinish(from, to);
            });

            newProcess.start(startupInfo);
        }

        // onFinish: function(deleteMe:File):void
        bezel_internal static function forbiddenDelete(deleteMe:File, onFinish:Function):void {
            var newProcess:NativeProcess = new NativeProcess();
            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

            startupInfo.executable = cmdFile;
            startupInfo.arguments = new <String>["/c", "del \"" + deleteMe.nativePath + "\""];

            newProcess.addEventListener(NativeProcessExitEvent.EXIT, function(e:NativeProcessExitEvent):void {
                if (e.exitCode != 0) {
                    throw new Error("Forbidden delete with command \'" + startupInfo.arguments[1] + "\' failed");
                }

                newProcess.closeInput();

                onFinish(deleteMe);
            });

            newProcess.start(startupInfo);
        }
    }
}
