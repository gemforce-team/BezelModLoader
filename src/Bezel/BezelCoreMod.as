package Bezel
{
    internal class BezelCoreMod
    {
        private static const files:Array = [
            "com/giab/games/gcfw/Main.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer2.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInputHandler2.class.asasm",
            "com/giab/games/gcfw/ingame/IngameInfoPanelRenderer.class.asasm",
            "com/giab/games/gcfw/Mods.class.asasm",
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
            ["setproperty.*deepLearningGems"],
            ["callpropvoid.*addFloaterPanel"],
            ["monsterEggHunt"]
        ];
        private static const replaceNums:Array = [
            [ 1, 1, 0, 0, 0 ],
            [ 0 ],
            [ 0, 0, 0, 1 ],
            [ 0 ],
            [ 0 ],
            [ 0 ],
            [ 0 ]
        ];
        private static const offsetFromMatches:Array = [
            [ 0, 0, 22, 0, 0 ],
            [ -17 ],
            [ -5, 39, -5, 17 ],
            [ 7 ],
            [ 1 ],
            [ 3 ],
            [ -2 ]
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
                    getproperty         QName(PackageNamespace(""), "bezel")                                                                                                                  getlocal1 \n \
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
                    callproperty        QName(PackageNamespace(""), "eh_ingameKeyDown"), 1 \n \
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
                // loadSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "loadSave"), 0 \n \
                '
            ],
            [
                // saveSave
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "saveSave"), 0 \n \
                '
            ],
            [
                // newScene
                ' \n \
                    getlex              QName(PackageNamespace("com.giab.games.gcfw"), "GV") \n \
                    getproperty         QName(PackageNamespace(""), "main") \n \
                    getproperty         QName(PackageNamespace(""), "bezel") \n \
                    callpropvoid        QName(PackageNamespace(""), "saveSave"), 0 \n \
                '
            ]
        ];

        internal static function installHooks(bezel:Bezel): void
        {
            // for in loops loop the indices for some godforsaken reason. Oh well, at least it works
            for (var index:uint in files)
            {
                for (var filepatch:uint in matches[index])
                {
                    var offset:int = bezel.lattice.findPattern(files[index], 0, new RegExp(matches[index][filepatch]));
                    bezel.getLogger("Bezel").log("installHooks", "Offset within " + files[index] + " is " + offset);
                    bezel.lattice.patchFile(files[index], offset + offsetFromMatches[index][filepatch], replaceNums[index][filepatch], contents[index][filepatch]);
                }
            }
        }
    }
}
