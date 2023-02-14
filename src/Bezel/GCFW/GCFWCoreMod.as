package Bezel.GCFW
{
    import Bezel.Lattice.Lattice;
    import Bezel.mainloader_only;

    internal class GCFWCoreMod
    {
        public static const VERSION:String = "10";

        private static const EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
                new <String>['callproperty.*"g"', 'getproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'],
                new <String>['callpropvoid.*"s"', 'setproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")']
            ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean):void
        {
            lattice.submitPatcher(new GCFWMainPatcher(), "com.giab.games.gcfw.Main");
            lattice.submitPatcher(new GCFWInfoPanelRendererPatcher(), "com.giab.games.gcfw.ingame.IngameInfoPanelRenderer");
            lattice.submitPatcher(new GCFWInfoPanelRenderer2Patcher(), "com.giab.games.gcfw.ingame.IngameInfoPanelRenderer2");
            lattice.submitPatcher(new GCFWInputHandlerPatcher(), "com.giab.games.gcfw.ingame.IngameInputHandler2");
            lattice.submitPatcher(new GCFWLoaderSaverPatcher(), "com.giab.games.gcfw.utils.LoaderSaver");
            lattice.submitPatcher(new GCFWIngameInitializerPatcher(), "com.giab.games.gcfw.ingame.IngameInitializer");
            lattice.submitPatcher(new GCFWENumberPatcher(), "com.giab.common.data.ENumber");
            lattice.submitPatcher(new GCFWScrOptionsPatcher(), "com.giab.games.gcfw.scr.ScrOptions");

            if (doEnumberFix)
            {
                var allfiles:Vector.<String> = lattice.listFiles();
                for each (var filename:String in allfiles)
                {
                    var fileContents:String = lattice.retrieveFile(filename);
                    for each (var everylinepatch:Vector.<String> in EVERY_FILE_EVERY_LINE_PATCHES)
                    {
                        var re:RegExp = new RegExp(everylinepatch[0], "g");
                        var result:Object = re.exec(fileContents);
                        var previousOffset:int = 0;
                        var previousLineOffset:int = 0;
                        while (result != null)
                        {
                            var offset:int = result.index;
                            var lineOffset:int = previousLineOffset + fileContents.substr(previousOffset, offset - previousOffset).split('\n').length - 1;
                            lattice.mainloader_only::DANGEROUS_patchFile(filename, lineOffset, 1, everylinepatch[1]);
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
