package Bezel.GCL
{
    import Bezel.Lattice.Lattice;
    import Bezel.mainloader_only;

    public class GCLCoreMod
    {
        public static const VERSION:String = "1";

        private static const EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
                new <String>['getproperty.*\ncallproperty.*"g"', 'getproperty QName(PrivateNamespace("", "com.giab.common.data:ENumber/instance"), "v")'],
                new <String>['.*\ncallpropvoid.*"s"', 'setproperty QName(PrivateNamespace("", "com.giab.common.data:ENumber/instance"), "v")']
            ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean):void
        {
            lattice.submitPatcher(new GCLMainPatcher(), "com.giab.games.gcl.gs.Main");
            lattice.submitPatcher(new GCLRendererPatcher(), "com.giab.games.gcl.gs.ingame.IngameRenderer");
            lattice.submitPatcher(new GCLInputHandlerPatcher(), "com.giab.games.gcl.gs.ingame.IngameInputHandler");
            lattice.submitPatcher(new GCLLoadSavePatcher(), "com.giab.games.gcl.gs.ctrl.CtrlStorage");
            lattice.submitPatcher(new GCLIngameInitializerPatcher(), "com.giab.games.gcl.gs.ingame.IngameInitializer");
            lattice.submitPatcher(new GCLENumberPatcher(), "com.giab.common.data.ENumber");
            lattice.submitPatcher(new GCLMainMenuPatcher(), "com.giab.games.gcl.gs.mcStat.McMainMenu");
            lattice.submitPatcher(new GCLCtrlOptionsPatcher(), "com.giab.games.gcl.gs.ctrl.CtrlOptions");

            if (doEnumberFix)
            {
                var allfiles:Vector.<String> = lattice.listFiles();
                for each (var filename:String in allfiles)
                {
                    var fileContents:String = lattice.retrieveFile(filename);
                    for each (var everylinepatch:Vector.<String> in EVERY_FILE_EVERY_LINE_PATCHES)
                    {
                        var re:RegExp = new RegExp(everylinepatch[0], "gm");
                        var result:Object = re.exec(fileContents);
                        var previousOffset:int = 0;
                        var previousLineOffset:int = 0;
                        while (result != null)
                        {
                            var offset:int = result.index;
                            var lineOffset:int = previousLineOffset + fileContents.substr(previousOffset, offset - previousOffset).split('\n').length - 1;
                            lattice.mainloader_only::DANGEROUS_patchFile(filename, lineOffset + 1, 1, everylinepatch[1]);
                            previousOffset = offset;
                            previousLineOffset = lineOffset;
                            result = re.exec(fileContents);
                        }
                    }
                }
            }
        }
    }
}
