package Bezel.GCCS
{
    import Bezel.Lattice.Lattice;
    import Bezel.mainloader_only;

    internal class GCCSCoreMod
    {
        public static const VERSION:String = "11";

        private static const EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
                new <String>['callproperty.*"g"', 'getproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'],
                new <String>['callproperty.*"s"', 'setproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")']
            ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean):void
        {
            lattice.submitPatcher(new GCCSENumberPatcher(), "com.giab.common.data.ENumber");
            lattice.submitPatcher(new GCCSLoaderSaverPatcher(), "com.giab.games.gccs.steam.utils.LoaderSaver");
            lattice.submitPatcher(new GCCSMainPatcher(), "com.giab.games.gccs.steam.Main");
            lattice.submitPatcher(new GCCSInfoPanelRenderer2Patcher(), "com.giab.games.gccs.steam.ingame.IngameInfoPanelRenderer2");
            lattice.submitPatcher(new GCCSInputHandlerPatcher(), "com.giab.games.gccs.steam.ingame.IngameInputHandler2");
            lattice.submitPatcher(new GCCSInfoPanelRendererPatcher(), "com.giab.games.gccs.steam.ingame.IngameInfoPanelRenderer");
            lattice.submitPatcher(new GCCSIngameInitializerPatcher(), "com.giab.games.gccs.steam.ingame.IngameInitializer");
            lattice.submitPatcher(new GCCSScrMainMenuPatcher(), "com.giab.games.gccs.steam.scr.ScrMainMenu");
            lattice.submitPatcher(new GCCSScrOptionsPatcher(), "com.giab.games.gccs.steam.scr.ScrOptions");

            if (doEnumberFix)
            {
                var allfiles:Vector.<String> = lattice.listFiles();
                for each (var filename:String in allfiles)
                {
                    // Note: this is honestly pretty disgusting logic and should probably not be replicated in any other coremods.
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
