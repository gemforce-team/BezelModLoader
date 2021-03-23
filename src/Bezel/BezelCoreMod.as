package Bezel
{
	/**
	 * ...
	 * @author piepie62
	 */
    import Bezel.Lattice.Lattice;

    internal class BezelCoreMod
    {
        public static const VERSION:String = "5";

        private static const files:Array = [
            "com/giab/games/gcfw/Main.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer2.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInputHandler2.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer.class.asasm",
            "com/giab/games/gcfw/utils/LoaderSaver.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInitializer.class.asasm"];
        private static const matches:Array = [
            [
                "\".*an error has occured.*\"",
                "\".*Could you please copy this message.*\"",
                "trait.*method.*com.giab.games.gcfw.*frame3",
                "constructsuper",
                "trait.*_cm"
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
                    "method.*startNewGame2",
                    "returnvoid"
                ]
            ],
            [
                [
                    "method.*setScene3Initiate",
                    "returnvoid"
                ]
            ]
        ];
        private static const replaceNums:Array = [
            [ 1, 1, 0, 0, 0 ],
            [ 0 ],
            [ 0, 0, 0, 1 ],
            [ 0 ],
            [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
            [ 0 ]
        ];
		private static const offsetFromMatches:Array = [
            [ 0, 0, 20, 0, 0 ],
            [ -15 ],
            [ -4, 37, -5, 16 ],
            [ 5 ],
            [ 0, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
            [ -1 ]
        ];
        private static const contents:Array = [
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
                'end'
            ],
            [
                // renderInfoPanelGem
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    getlocal            8 \n \
                    getlocal            1 \n \
                    getlex              QName(PackageNamespace("com.giab.common.utils"), "NumberFormatter") \n \
                    callpropvoid        QName(PackageNamespace(""), "ingameGemInfoPanelFormed"), 3 \n \
                '
            ],
            [
                // clickOnScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    getlocal1 \n \
                    getlocal            2 \n \
                    getlocal            3 \n \
                    getlocal            4 \n \
                    getlocal            5 \n \
                    callproperty        QName(PackageNamespace(""), "ingameClickOnScene"), 5 \n \
                    not \n \
                    iffalse             L86 \n \
                        returnvoid \n \
                    L86: \n \
                        label \n \
                ',
                // rightClickOnScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    getlocal1 \n \
                    getlocal            2 \n \
                    getlocal            3 \n \
                    getlocal            4 \n \
                    getlocal            5 \n \
                    callproperty        QName(PackageNamespace(""), "ingameRightClickOnScene"), 5 \n \
                    not \n \
                    iffalse             L28 \n \
                        returnvoid \n \
                    L28: \n \
                        label \n \
                ',
                // ehKeyDown
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    getlocal1 \n \
                    callproperty        QName(PackageNamespace(""), "ingameKeyDown"), 1 \n \
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
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callproperty        QName(PackageNamespace(""), "ingamePreRenderInfoPanel"), 0 \n \
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
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "saveSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                ',
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                '
            ],
            [
                // newScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "ingameNewScene"), 0 \n \
                '
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
