package Bezel.GCCS 
{
    import Bezel.Lattice.Lattice;

    /**
     * ...
     * @author piepie62
     */
    internal class GCCSCoreMod
    {
        public static const VERSION:String = "9";

        private static const files:Array = [
            "com/giab/games/gccs/steam/Main.class.asasm",
            "com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer2.class.asasm",
            "com/giab/games/gccs/steam/ingame/IngameInputHandler2.class.asasm",
            "com/giab/games/gccs/steam/ingame/IngameInfoPanelRenderer.class.asasm",
            "com/giab/games/gccs/steam/utils/LoaderSaver.class.asasm",
            "com/giab/games/gccs/steam/ingame/IngameInitializer.class.asasm",
			"com/giab/games/gccs/steam/scr/ScrMainMenu.class.asasm",
            "com/giab/games/gccs/steam/scr/ScrOptions.class.asasm"
		];

        private static const matches:Array = [
            ["constructsuper",
             "initproperty .*steamworks",
             "trait.*_cm",
             "trait.*_cm",
             "trait slot.*steamworks"
            ],
            ["trait.*method.*renderMonsterInfoPanel"],
            [
                "CAST_STRIKESPELL_INITIATED",
                "trait.*method.*rightClickOnScene",
                "QName.*PackageNamespace.*\"\".*.*\"B\"",
                "trait.*method.*rightClickOnScene"
            ],
            ["CHANGE_TARGET_TYPE_DRAGGING"],
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
            [
                [
                    "method.*setScene3Initiate",
                    "returnvoid"
                ]
            ],
			[
				"initproperty.*mc"
			],
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
            ]
        ];

        private static const replaceNums:Array = [
            [ 2, 0, 0, 0, 0],
			[ 0 ],
            [ 0, 0, 0, 1 ],
            [ 0 ],
            [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
            [ 0 ],
			[ 0 ],
            [ 0, 1, 0, 0, 0 ]
        ]

        private static const offsetFromMatches:Array = [
            [ -2, -4, 0, -3, 0],
			[ -15 ],
            [ -5, 37, -5, 16 ],
            [ 5 ],
            [ 0, -1, -1, -1, -1, -1, -1, -1, -1, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3 ],
            [ -1 ],
			[ 0 ],
            [ 0, -2, 3, 5, 14 ]
        ];

        private static const contents:Array = [
            ["",
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
            ],
            [
                // renderInfoPanelGem
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    getlocal            6 \n \
                    getlocal            1 \n \
                    getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "ingameGemInfoPanelFormed"), 3 \n \
                '
            ],
            [
                // clickOnScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    getlocal1 \n \
                    getlocal            2 \n \
                    getlocal            3 \n \
                    getlocal            4 \n \
                    getlocal            5 \n \
                    callproperty        QName(PackageInternalNs("Bezel:bezel_internal"), "ingameClickOnScene"), 5 \n \
                    not \n \
                    iffalse             L86 \n \
                        returnvoid \n \
                    L86: \n \
                        label \n \
                ',
                // rightClickOnScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    getlocal1 \n \
                    getlocal            2 \n \
                    getlocal            3 \n \
                    getlocal            4 \n \
                    getlocal            5 \n \
                    callproperty        QName(PackageInternalNs("Bezel:bezel_internal"), "ingameRightClickOnScene"), 5 \n \
                    not \n \
                    iffalse             L28 \n \
                        returnvoid \n \
                    L28: \n \
                        label \n \
                ',
                // ehKeyDown
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    getlocal1 \n \
                    callproperty        QName(PackageInternalNs("Bezel:bezel_internal"), "ingameKeyDown"), 1 \n \
                    not \n \
                    iffalse             L55 \n \
                        returnvoid \n \
                    L55: \n \
                ',
                "maxstack 14"
            ],
            [
                // renderInfoPanel
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callproperty        QName(PackageInternalNs("Bezel:bezel_internal"), "ingamePreRenderInfoPanel"), 0 \n \
                    pushtrue \n \
                    ifeq                L160 \n \
                        returnvoid \n \
                    L160: \n \
                        label \n \
                '
            ],
            [
                // saveSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "saveSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "loadSave"), 0 \n \
                '
            ],
            [
                // newScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "ingameNewScene"), 0 \n \
                '
            ],
			[
				// Add Bezel version string
				'\n \
					getlex              QName(PackageNamespace("com.giab.games.gccs.steam"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
					getproperty			QName(PackageNamespace(""), "mainLoader") \n \
					getlocal1 \n \
					callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "setVersion"), 1 \n \
				'
			],
            [
                ' \n \
                    getlex              QName(PackageNamespace("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                    getlocal0 \n \
                    callpropvoid        QName(PackageInternalNs("Bezel:bezel_internal"), "toggleCustomSettingsFromGame"), 1 \n \
                ',
                ' \n \
                    getlex              QName(PackageNamespace("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                    getlocal1 \n \
                    getlocal2 \n \
                    callproperty        QName(PackageInternalNs("Bezel:bezel_internal"), "renderInfoPanel"), 2 \n \
                ',
                ' \n \
                    dup \n \
                    iffalse AfterKeybindChoiceCheck \n \
                    pop \n \
                    getlex QName(PackageNamespace("Bezel.GCCS"), "GCCSSettingsHandler") \n \
                    getproperty QName(PackageInternalNs("Bezel:bezel_internal"), "IS_CHOOSING_KEYBIND") \n \
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
            ]
        ];

        internal static function installHooks(lattice:Lattice): void
        {
            for (var index:uint = 0; index < files.length; index++)
            {
                for (var filepatch:uint = 0; filepatch < matches[index].length; filepatch++)
                {
                    var offset:int = 0;
                    if (matches[index][filepatch] is Array)
                    {
                        for each (var regex:String in matches[index][filepatch])
                        {
                            offset = lattice.findPattern(files[index], new RegExp(regex), offset);
                            if (offset == -1)
                            {
                                throw new Error("Could not apply Bezel coremod for " + files[index] + ", patch number " + filepatch);
                            }
                        }
                        lattice.patchFile(files[index], offset + offsetFromMatches[index][filepatch], replaceNums[index][filepatch], contents[index][filepatch]);
                    }
                    else
                    {
                        offset = lattice.findPattern(files[index], new RegExp(matches[index][filepatch]));
                        if (offset == -1)
                        {
                            throw new Error("Could not apply Bezel coremod for " + files[index] + ", patch number " + filepatch);
                        }
                        lattice.patchFile(files[index], offset + offsetFromMatches[index][filepatch], replaceNums[index][filepatch], contents[index][filepatch]);
                    }
                }
            }
        }
    }
}
