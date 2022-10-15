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

        private static const coremods:Vector.<GCCSFileCoreMod> = new <GCCSFileCoreMod>[
            new GCCSFileCoreMod("com/giab/games/gccs/steam/Main.class.asasm",
                [
                    "constructsuper",
                    "initproperty .*steamworks",
                    "trait.*_cm",
                    "trait.*_cm",
                    "trait slot.*steamworks"
                ],
                [ -2, -4, 0, -3, 0],
                [ 2, 0, 0, 0, 0],
                [
                    "",
                    '    getlocal0 \n \
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
                    ',
                    'end',
                    ' \
                        getlocal0 \n \
                        pushnull \n \
                        callpropvoid QName(PackageNamespace(""),"doEnterFramePreloader"), 1 \n \
                    ',
                    'trait slot QName(PackageNamespace(\"\"), \"bezel\") type QName(PackageNamespace(\"\"), \"Object\") end'
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer2.class.asasm",
                ["trait.*method.*renderMonsterInfoPanel"],
                [ -15 ],
                [ 0 ],
                [
                    // renderInfoPanelGem
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal            6 \n \
                        getlocal            1 \n \
                        getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "ingameGemInfoPanelFormed"), 3 \n \
                    '
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/ingame/IngameInputHandler2.class.asasm",
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
                    ',
                    // rightClickOnScene
                    ' \n \
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
                    ',
                    // ehKeyDown
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingameKeyDown"), 1 \n \
                        not \n \
                        iffalse             L55 \n \
                            returnvoid \n \
                        L55: \n \
                    ',
                    "maxstack 14"
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer.class.asasm",
                ["CHANGE_TARGET_TYPE_DRAGGING"],
                [ 5 ],
                [ 0 ],
                [
                    // renderInfoPanel
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "ingamePreRenderInfoPanel"), 0 \n \
                        pushtrue \n \
                        ifeq                L160 \n \
                            returnvoid \n \
                        L160: \n \
                            label \n \
                    '
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/utils/LoaderSaver.class.asasm",
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
                        "method.*ehNewGameSlotL1Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL2Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL3Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL4Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL5Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL6Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL7Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL8Clicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL1IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL2IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL3IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL4IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL5IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL6IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL7IronClicked",
                        "returnvoid"
                    ],
                    [
                        "method.*ehNewGameSlotL8IronClicked",
                        "returnvoid"
                    ]
                ],
                [ 0, -1, -1, -1, -1, -1, -1, -1, -1, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3 ],
                [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
                [
                    // saveSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "saveSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    ',
                    // loadSave
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "loadSave"), 0 \n \
                    '
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/ingame/IngameInitializer.class.asasm",
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
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "ingameNewScene"), 0 \n \
                    '
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/scr/ScrMainMenu.class.asasm",
                ["initproperty.*mc"],
                [ 0 ],
                [ 0 ],
                [
                    // Add Bezel version string
                    '\n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers") \n \
                        getlocal1 \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "setVersion"), 1 \n \
                    '
                ]),
            new GCCSFileCoreMod("com/giab/games/gccs/steam/scr/ScrOptions.class.asasm",
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
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        callpropvoid        QName(PackageInternalNs("Bezel.GCCS"), "toggleCustomSettingsFromGame"), 0 \n \
                    ',
                    ' \n \
                        getlex              QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        getlocal1 \n \
                        getlocal2 \n \
                        callproperty        QName(PackageInternalNs("Bezel.GCCS"), "renderInfoPanel"), 2 \n \
                    ',
                    ' \n \
                        dup \n \
                        iffalse AfterKeybindChoiceCheck \n \
                        pop \n \
                        getlex QName(PackageInternalNs("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                        getproperty QName(PackageInternalNs("Bezel.GCCS"), "IS_CHOOSING_KEYBIND") \n \
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
                ]),
            new GCCSFileCoreMod("com/giab/common/data/ENumber.class.asasm", 
                [
                    'name "com.giab.common.data:ENumber/g"',
                    [
                        'name "com.giab.common.data:ENumber/s"',
                        "throw"
                    ]
                ],
                [12, 1],
                [39, 134],
                [
                    'getlocal0\ngetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")',
                    'getlocal0\ngetlocal1\nsetproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'
                ])
        ];

        private static var EVERY_FILE_EVERY_LINE_PATCHES:Vector.<Vector.<String>> = new <Vector.<String>>[
            new <String>['callproperty.*\"g\"', 'getproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")'],
            new <String>['callproperty.*\"s\"', 'setproperty QName(PrivateNamespace("com.giab.common.data:ENumber"), "a")']
        ];

        internal static function installHooks(lattice:Lattice, doEnumberFix:Boolean): void
        {
            for each (var file:GCCSFileCoreMod in coremods)
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
