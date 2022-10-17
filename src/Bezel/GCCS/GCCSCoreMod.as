package Bezel.GCCS 
{
    import Bezel.Lattice.Lattice;
    import Bezel.mainloader_only;

    /**
     * ...
     * @author piepie62
     */
    internal class GCCSCoreMod
    {
        public static const VERSION:String = "11";

        private static const coremods:Object = {
            "com/giab/games/gccs/steam/Main.class.asasm": new <GCCSSingleCoreMod>[
                new GCCSSingleCoreMod("constructsuper", -2, 2, ""),
                new GCCSSingleCoreMod("initproperty .*steamworks", -4, 0, '    getlocal0 \n \
                        constructsuper 0 \n \
                        returnvoid \n \
                        end \n \
                        end \n \
                    end \n \
                    trait method QName(PackageNamespace(""), "initFromBezel") \n \
                        method \n \
                        name "com.giab.games.gccs.steam:Main/initFromBezel" \n \
                        refid "com.giab.games.gccs.steam:Main/instance/initFromBezel" \n \
                        returns QName(PackageNamespace(""), "void") \n \
                        flag NEED_ACTIVATION \n \
                        body \n \
                        maxstack 6 \n \
                        localcount 2 \n \
                        initscopedepth 12 \n \
                        maxscopedepth 14 \n \
                        code \n \
                        getlocal0 \n \
                        pushscope \n \
                        newactivation \n \
                        dup \n \
                        setlocal1 \n \
                        pushscope \n \
                    '),
                new GCCSSingleCoreMod("trait.*_cm", 0, 0, 'end'),
                new GCCSSingleCoreMod("trait.*_cm", -3, 0, ' \
                        getlocal0 \n \
                        pushnull \n \
                        callpropvoid QName(PackageNamespace(""),"doEnterFramePreloader"), 1 \n \
                    '),
                new GCCSSingleCoreMod("trait slot.*steamworks", 0, 0, 'trait slot QName(PackageNamespace(\"\"), \"bezel\") type QName(PackageNamespace(\"\"), \"Object\") end')
            ],
            "com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer2.class.asasm": new <GCCSSingleCoreMod>[
                // renderInfoPanelGem
                new GCCSSingleCoreMod("trait.*method.*renderMonsterInfoPanel", -15, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal            6 \n \
                        getlocal            1 \n \
                        getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "ingameGemInfoPanelFormed"), 3 \n \
                    ')
            ],
            "com/giab/games/gccs/steam/ingame/IngameInputHandler2.class.asasm": new <GCCSSingleCoreMod>[
                // clickOnScene
                new GCCSSingleCoreMod("CAST_STRIKESPELL_INITIATED", -5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        getlocal            2 \n \
                        getlocal            3 \n \
                        getlocal            4 \n \
                        getlocal            5 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingameClickOnScene"), 5 \n \
                        not \n \
                        iffalse             L86 \n \
                            returnvoid \n \
                        L86: \n \
                            label \n \
                    '),
                // rightClickOnScene
                new GCCSSingleCoreMod("trait.*method.*rightClickOnScene", 37, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        getlocal            2 \n \
                        getlocal            3 \n \
                        getlocal            4 \n \
                        getlocal            5 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingameRightClickOnScene"), 5 \n \
                        not \n \
                        iffalse             L28 \n \
                            returnvoid \n \
                        L28: \n \
                            label \n \
                    '),
                // ehKeyDown
                new GCCSSingleCoreMod("QName.*PackageNamespace.*\"\".*.*\"B\"", -5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingameKeyDown"), 1 \n \
                        not \n \
                        iffalse             L55 \n \
                            returnvoid \n \
                        L55: \n \
                    '),
                new GCCSSingleCoreMod("trait.*method.*rightClickOnScene", 16, 1, "maxstack 14")
            ],
            "com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer.class.asasm": new <GCCSSingleCoreMod>[
                // renderInfoPanel
                new GCCSSingleCoreMod("CHANGE_TARGET_TYPE_DRAGGING", 5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingamePreRenderInfoPanel"), 0 \n \
                        pushtrue \n \
                        ifeq                L160 \n \
                            returnvoid \n \
                        L160: \n \
                            label \n \
                    ')
            ],
            "com/giab/games/gccs/steam/utils/LoaderSaver.class.asasm": new <GCCSSingleCoreMod>[
                // saveSave
                new GCCSSingleCoreMod([ "method.*saveGameData", "callpropvoid.*close" ], 0, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "saveSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL1Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL2Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL3Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL4Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL5Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL6Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL7Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehContinueSlotL8Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL1Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL2Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL3Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL4Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL5Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL6Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL7Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL8Clicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL1IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL2IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL3IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL4IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL5IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL6IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL7IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCCSSingleCoreMod([ "method.*ehNewGameSlotL8IronClicked", "returnvoid" ], -3, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ')
            ],
            "com/giab/games/gccs/steam/ingame/IngameInitializer.class.asasm": new <GCCSSingleCoreMod>[
                // newScene
                new GCCSSingleCoreMod([ "method.*setScene3Initiate", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "ingameNewScene"), 0 \n \
                    ')
            ],
            "com/giab/games/gccs/steam/scr/ScrMainMenu.class.asasm": new <GCCSSingleCoreMod>[
                // add Bezel version string
                new GCCSSingleCoreMod("initproperty.*mc", 0, 0, '\n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "setVersion"), 1 \n \
                    ')
            ],
            "com/giab/games/gccs/steam/scr/ScrOptions.class.asasm": new <GCCSSingleCoreMod>[
                new GCCSSingleCoreMod([ "method.*switchOptions", "pushscope" ], 0, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "toggleCustomSettingsFromGame"), 0 \n \
                    '),
                new GCCSSingleCoreMod([ "method.*renderPanelInfoPanel", "setlocal3", "setlocal3" ], -2, 1, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        getlocal1 \n \
                        getlocal2 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "renderInfoPanel"), 2 \n \
                    '),
                new GCCSSingleCoreMod("getproperty.*height", 3, 0, ' \n \
                        dup \n \
                        iffalse AfterKeybindChoiceCheck \n \
                        pop \n \
                        getlex QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        getproperty QName(PackageInternalNs("Bezel.GCCS"), "IS_CHOOSING_KEYBIND") \n \
                        not \n \
                    AfterKeybindChoiceCheck: \n \
                    '),
                new GCCSSingleCoreMod("getproperty.*height", 5, 0, ' \n \
                        getlocal0 \n \
                        getproperty QName(PackageNamespace(""),"mc") \n \
                        getproperty QName(PackageNamespace(""),"arrCntContents") \n \
                        getlocal1 \n \
                        getproperty MultinameL([PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        getproperty Multiname("btn",[PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        getproperty Multiname("parent",[PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        pushnull \n \
                        equals \n \
                        not \n \
                        dup \n \
                        iftrue AfterFullVisibilityCheck \n \
                        pop \n \
                        getlocal0 \n \
                        getproperty QName(PackageNamespace(""),"mc") \n \
                        getproperty QName(PackageNamespace(""),"arrCntContents") \n \
                        getlocal1 \n \
                        getproperty MultinameL([PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        getproperty Multiname("knob",[PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        getproperty Multiname("parent",[PrivateNamespace("com.giab.games.gcfw.scr:ScrOptions"),PackageNamespace(""),PrivateNamespace("ScrOptions.as$615"),PackageNamespace("com.giab.games.gcfw.scr"),PackageInternalNs("com.giab.games.gcfw.scr"),Namespace("http://adobe.com/AS3/2006/builtin"),ProtectedNamespace("com.giab.games.gcfw.scr:ScrOptions"),StaticProtectedNs("com.giab.games.gcfw.scr:ScrOptions")]) \n \
                        pushnull \n \
                        equals \n \
                        not \n \
                    AfterFullVisibilityCheck: \n \
                        iffalse DoNotColorPlate \n \
                    '),
                new GCCSSingleCoreMod("getproperty.*height", 14, 0, "DoNotColorPlate:")
            ],
            "com/giab/common/data/ENumber.class.asasm": new <GCCSSingleCoreMod>[
                new GCCSSingleCoreMod('name "com.giab.common.data:ENumber/g"', 12, 39, 'getlocal0\ngetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'),
                new GCCSSingleCoreMod([ 'name "com.giab.common.data:ENumber/s"', "throw" ], 1, 134, 'getlocal0\ngetlocal1\nsetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")')
            ]
        }

        private static var EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
            new <String>['callproperty.*\"g\"', 'getproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'],
            new <String>['callproperty.*\"s\"', 'setproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")']
        ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean): void
        {
            for (var file:String in coremods)
            {
                for each (var coremod:GCCSSingleCoreMod in (coremods[file] as Vector.<GCCSSingleCoreMod>))
                {
                    var offset:int = 0;
                    for each (var regex:* in coremod.matches)
                    {
                        offset = lattice.findPattern(file, new RegExp(regex), offset);
                    }
                    lattice.patchFile(file, offset + coremod.offset, coremod.replacenum, coremod.contents);
                }
            }

            if (doEnumberFix)
            {
                var allfiles:Vector.<String> = lattice.listFiles();
                for each (var filename:String in allfiles)
                {
                    for each (var everylinepatch:Vector.<String> in EVERY_FILE_EVERY_LINE_PATCHES)
                    {
                        var re:RegExp = new RegExp(everylinepatch[0]);
                        offset = 0;
                        while (offset != -1)
                        {
                            offset = lattice.findPattern(filename, re, offset);
                            if (offset != -1)
                            {
                                lattice.mainloader_only::DANGEROUS_patchFile(filename, offset-1, 1, everylinepatch[1]);
                            }
                        }
                    }
                }
            }
        }
    }
}
