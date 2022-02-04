package Bezel.GCFW
{
	/**
	 * ...
	 * @author piepie62
	 */
    import Bezel.Lattice.Lattice;

    internal class GCFWCoreMod
    {
        public static const VERSION:String = "9";

        private static const coremods:Vector.<GCFWFileCoreMod> = new <GCFWFileCoreMod>[
            new GCFWFileCoreMod("com/giab/games/gcfw/Main.class.asasm",
                [
                    "\".*an error has occured.*\"",
                    "\".*Could you please copy this message.*\"",
                    "trait.*method.*com.giab.games.gcfw.*frame3",
                    "constructsuper",
                    "trait.*_cm",
                    "trait method.*uncaughtErrorHandler",
                    "name.*uncaughtErrorHandler",
                    "getproperty.*uncaughtErrorHandler"
                ],
                [ -1, -1, 20, 0, 0, -1, -1, -1 ],
                [ 1, 1, 0, 0, 0, 1, 1, 1 ],
                [
                    "pushstring \"Unfortunately, an error has occured in the game:\\n(game version stamp: \"",
                    "pushstring \"\\n\\nTHE GAME IS MODDED!\\n\\nPlease check the log in \\\"%AppData%/Roaming/com.giab.games.gcfw.steam/Local Store/Bezel Mod Loader\\\" for additional info!\\n\\nYou can ask for help in GemCraft's discord #modding channel.\\n\\nThank you for your help and sorry for the inconvenience!\"",
                    "trait slot QName(PackageNamespace(\"\"), \"bezel\") type QName(PackageNamespace(\"\"), \"Object\") end",
                    ' \n \
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
                    ',
                    'end',
                    'trait method QName(PackageNamespace(""),"uncaughtErrorHandler")',
                    'name "com.giab.games.gcfw:Main/uncaughtErrorHandler"',
                    'getproperty         QName(PackageNamespace(""),"uncaughtErrorHandler")'
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/ingame/IngameInfoPanelRenderer2.class.asasm",
                ["trait.*method.*renderMonsterInfoPanel"],
                [ -15 ],
                [ 0 ],
                [
                    // renderInfoPanelGem
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal            8 \n \
                        getlocal            1 \n \
                        getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "ingameGemInfoPanelFormed"), 3 \n \
                    '
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/ingame/IngameInputHandler2.class.asasm",
                [
                    "CAST_STRIKESPELL_INITIATED",
                    "trait.*method.*rightClickOnScene",
                    "QName.*PackageNamespace.*\"\".*.*\"B\"",
                    "trait.*method.*rightClickOnScene"
                ],
                [ -5, 37, -5, 16 ],
                [ 0, 0, 0, 1 ],
                [
                    // clickOnScene
                    ' \n \
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
                    ',
                    // rightClickOnScene
                    ' \n \
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
                    ',
                    // ehKeyDown
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        getlocal1 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingameKeyDown"), 1 \n \
                        not \n \
                        iffalse             L55 \n \
                            returnvoid \n \
                        L55: \n \
                    ',
                    "maxstack 14"
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/ingame/IngameInfoPanelRenderer.class.asasm",
                ["CHANGE_TARGET_TYPE_DRAGGING"],
                [ 5 ],
                [ 0 ],
                [
                    // renderInfoPanel
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "ingamePreRenderInfoPanel"), 0 \n \
                        pushtrue \n \
                        ifeq                L160 \n \
                            returnvoid \n \
                        L160: \n \
                            label \n \
                    '
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/utils/LoaderSaver.class.asasm",
                [
                    [
                        "method.*saveGameData",
                        "callpropvoid.*close"
                    ],
                    [
                        "method.*ehContinueSlotL1Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL2Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL3Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL4Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL5Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL6Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL7Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehContinueSlotL8Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*startNewGame2",
                        "returnvoid"
                    ]
                ],
                [ 0, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
                [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
                [
                    // saveSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "saveSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "loadSave"), 0 \n \
                    '
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/ingame/IngameInitializer.class.asasm",
                [
                    [
                        "method.*setScene3Initiate",
                        "returnvoid"
                    ]
                ],
                [ -1 ],
                [ 0 ],
                [
                    // newScene
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "ingameNewScene"), 0 \n \
                    '
                ]),
            new GCFWFileCoreMod("com/giab/games/gcfw/scr/ScrOptions.class.asasm",
                [
                    [
                        "method.*switchOptions",
                        "pushscope"
                    ],
                    [
                        "method.*renderPanelInfoPanel",
                        "setlocal3",
                        "setlocal3"
                    ],
                    "getproperty.*height",
                    "getproperty.*height",
                    "getproperty.*height"
                ],
                [ 0, -2, 3, 5, 14 ],
                [ 0, 1, 0, 0, 0 ],
                [
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCFW"), "toggleCustomSettingsFromGame"), 0 \n \
                    ',
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        getlocal1 \n \
                        getlocal2 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCFW"), "renderInfoPanel"), 2 \n \
                    ',
                    ' \n \
                        dup \n \
                        iffalse AfterKeybindChoiceCheck \n \
                        pop \n \
                        getlex QName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler") \n \
                        getproperty QName(PackageInternalNs("Bezel.GCFW"), "IS_CHOOSING_KEYBIND") \n \
                        not \n \
                    AfterKeybindChoiceCheck: \n \
                    ',
                    ' \n \
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
                    ',
                    "DoNotColorPlate:"
                ])
        ];

        private static const contents:Array = [
            ,
            ,
            ,
            ,
            ,
            ,
            
        ];

        internal static function installHooks(lattice:Lattice): void
        {
            for each (var file:GCFWFileCoreMod in coremods)
            {
                for (var filepatch:uint = 0; filepatch < file.matches.length; filepatch++)
                {
                    var offset:int = 0;
                    if (file.matches[filepatch] is Array)
                    {
                        for each (var regex:String in file.matches[filepatch])
                        {
                            offset = lattice.findPattern(file.filename, new RegExp(regex), offset);
                            if (offset == -1)
                            {
                                throw new Error("Could not apply Bezel coremod for " + file.filename + ", patch number " + filepatch);
                            }
                        }
                        lattice.patchFile(file.filename, offset + file.offsets[filepatch], file.replaceNums[filepatch], file.contents[filepatch]);
                    }
                    else
                    {
                        offset = lattice.findPattern(file.filename, new RegExp(file.matches[filepatch]));
                        if (offset == -1)
                        {
                            throw new Error("Could not apply Bezel coremod for " + file.filename + ", patch number " + filepatch);
                        }
                        lattice.patchFile(file.filename, offset + file.offsets[filepatch], file.replaceNums[filepatch], file.contents[filepatch]);
                    }
                }
            }
        }
    }
}
