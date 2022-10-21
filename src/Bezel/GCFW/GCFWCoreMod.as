package Bezel.GCFW
{
    import Bezel.Lattice.Lattice;
    import Bezel.mainloader_only;
    
    /**
     * ...
     * @author piepie62
     */
    internal class GCFWCoreMod
    {
        public static const VERSION:String = "10";

        private static const coremods:Object = {
            "com/giab/games/gcfw/Main.class.asasm": new <GCFWSingleCoreMod>[
                new GCFWSingleCoreMod("\".*an error has occured.*\"", -1, 1, "pushstring \"Unfortunately, an error has occured in the game:\\n(game version stamp: \""),
                new GCFWSingleCoreMod("\".*Could you please copy this message.*\"", -1, 1, "pushstring \"\\n\\nTHE GAME IS MODDED!\\n\\nPlease check the log in \\\"%AppData%/Roaming/com.giab.games.gcfw.steam/Local Store/Bezel Mod Loader\\\" for additional info!\\n\\nYou can ask for help in GemCraft's discord #modding channel.\\n\\nThank you for your help and sorry for the inconvenience!\""),
                new GCFWSingleCoreMod("trait.*method.*com.giab.games.gcfw.*frame3", 20, 0, "trait slot QName(PackageNamespace(\"\"), \"bezel\") type QName(PackageNamespace(\"\"), \"Object\") end"),
                new GCFWSingleCoreMod("constructsuper", 0, 0, ' \n \
                    returnvoid \n \
                    end \n \
                    end \n \
                    end \n \
                    trait method QName(PackageNamespace(""), "initFromBezel") \n \
                        method \n \
                            name "com.giab.games.gcfw:Main/initFromBezel" \n \
                            refid "com.giab.games.gcfw:Main/instance/initFromBezel" \n \
                            returns QName(PackageNamespace(""), "void") \n \
                            flag NEED_ACTIVATION \n \
                            body \n \
                                maxstack 6 \n \
                                localcount 2 \n \
                                initscopedepth 12 \n \
                                maxscopedepth 14 \n \
                                code \n \
                                    getlocal 0 \n \
                                    pushscope \n \
                                    newactivation \n \
                                    dup \n \
                                    setlocal 1 \n \
                                    pushscope \n \
                    '),
                new GCFWSingleCoreMod("trait.*_cm", 0, 0, 'end'),
                new GCFWSingleCoreMod("trait method.*uncaughtErrorHandler", -1, 1, 'trait method QName(PackageNamespace(""),"uncaughtErrorHandler")'),
                new GCFWSingleCoreMod("name.*uncaughtErrorHandler", -1, 1, 'name "com.giab.games.gcfw:Main/uncaughtErrorHandler"'),
                new GCFWSingleCoreMod("getproperty.*uncaughtErrorHandler", -1, 1, 'getproperty         QName(PackageNamespace(""),"uncaughtErrorHandler")')
            ],
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer2.class.asasm": new <GCFWSingleCoreMod>[
                // renderInfoPanelGem
                new GCFWSingleCoreMod("trait.*method.*renderMonsterInfoPanel", -15, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal            8 \n \
                        getlocal            1 \n \
                        getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "ingameGemInfoPanelFormed"), 3 \n \
                    ')
            ],
            "com/giab/games/gcfw/ingame/IngameInputHandler2.class.asasm": new <GCFWSingleCoreMod>[
                // clickOnScene
                new GCFWSingleCoreMod("CAST_STRIKESPELL_INITIATED", -5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal1 \n \
                        getlocal            2 \n \
                        getlocal            3 \n \
                        getlocal            4 \n \
                        getlocal            5 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingameClickOnScene"), 5 \n \
                        not \n \
                        iffalse             L86 \n \
                            returnvoid \n \
                        L86: \n \
                            label \n \
                    '),
                // rightClickOnScene
                new GCFWSingleCoreMod("trait.*method.*rightClickOnScene", 37, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal1 \n \
                        getlocal            2 \n \
                        getlocal            3 \n \
                        getlocal            4 \n \
                        getlocal            5 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingameRightClickOnScene"), 5 \n \
                        not \n \
                        iffalse             L28 \n \
                            returnvoid \n \
                        L28: \n \
                            label \n \
                    '),
                // ehKeyDown
                new GCFWSingleCoreMod("QName.*PackageNamespace.*\"\".*.*\"B\"", -5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal1 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingameKeyDown"), 1 \n \
                        not \n \
                        iffalse             L55 \n \
                            returnvoid \n \
                        L55: \n \
                    '),
                new GCFWSingleCoreMod("trait.*method.*rightClickOnScene", 16, 1, "maxstack 14")
            ],
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer.class.asasm": new <GCFWSingleCoreMod>[
                // renderInfoPanel
                new GCFWSingleCoreMod("CHANGE_TARGET_TYPE_DRAGGING", 5, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingamePreRenderInfoPanel"), 0 \n \
                        pushtrue \n \
                        ifeq                L160 \n \
                            returnvoid \n \
                        L160: \n \
                            label \n \
                    ')
            ],
            "com/giab/games/gcfw/utils/LoaderSaver.class.asasm": new <GCFWSingleCoreMod>[
                // saveSave
                new GCFWSingleCoreMod([ "method.*saveGameData", "callpropvoid.*close" ], 0, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "saveSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL1Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL2Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL3Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL4Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL5Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL6Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL7Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*ehContinueSlotL8Clicked", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '),
                // loadSave
                new GCFWSingleCoreMod([ "method.*startNewGame2", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ')
            ],
            "com/giab/games/gcfw/ingame/IngameInitializer.class.asasm": new <GCFWSingleCoreMod>[
                // newScene
                new GCFWSingleCoreMod([ "method.*setScene3Initiate", "returnvoid" ], -1, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "ingameNewScene"), 0 \n \
                    ')
            ],
            "com/giab/games/gcfw/scr/ScrOptions.class.asasm": new <GCFWSingleCoreMod>[
                new GCFWSingleCoreMod([ "method.*switchOptions", "pushscope" ], 0, 0, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "toggleCustomSettingsFromGame"), 0 \n \
                    '),
                new GCFWSingleCoreMod([ "method.*renderPanelInfoPanel", "setlocal3", "setlocal3" ], -2, 1, ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        getlocal1 \n \
                        getlocal2 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "renderInfoPanel"), 2 \n \
                    '),
                new GCFWSingleCoreMod("getproperty.*height", 3, 0, ' \n \
                        dup \n \
                        iffalse AfterKeybindChoiceCheck \n \
                        pop \n \
                        getlex QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        getproperty QName(PackageInternalNs("Bezel.GCFW"), "IS_CHOOSING_KEYBIND") \n \
                        not \n \
                    AfterKeybindChoiceCheck: \n \
                    '),
                new GCFWSingleCoreMod("getproperty.*height", 5, 0, ' \n \
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
                new GCFWSingleCoreMod("getproperty.*height", 14, 0, "DoNotColorPlate:")
            ],
            "com/giab/common/data/ENumber.class.asasm": new <GCFWSingleCoreMod>[
                new GCFWSingleCoreMod('name "com.giab.common.data:ENumber/g"', 12, 15, 'getlocal0\ngetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'),
                new GCFWSingleCoreMod([ 'name "com.giab.common.data:ENumber/s"', "throw" ], 1, 26, 'getlocal0\ngetlocal1\nsetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")')
            ]
        };

        private static var EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
                new <String>['callproperty.*"g"', 'getproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'],
                new <String>['callpropvoid.*"s"', 'setproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")']
            ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean):void
        {
            for (var file:String in coremods)
            {
                for each (var coremod:GCFWSingleCoreMod in (coremods[file] as Vector.<GCFWSingleCoreMod>))
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
                    var fileContents:String = lattice.retrieveFile(filename);
                    for each (var everylinepatch:Vector.<String> in EVERY_FILE_EVERY_LINE_PATCHES)
                    {
                        var re:RegExp = new RegExp(everylinepatch[0], "g");
                        var result:Object = re.exec(fileContents);
                        var previousOffset:int = 0;
                        var previousLineOffset:int = 0;
                        while (result != null)
                        {
                            offset = result.index;
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
