package Bezel.GCCS 
{
    import Bezel.Lattice.Lattice;

    /**
     * ...
     * @author piepie62
     */
    internal class GCCSCoreMod
    {
        public static const VERSION:String = "1";

        private static const files:Array = [
            "com/giab/games/gccs/steam/Main.class.asasm"
        ];

        private static const matches:Array = [
            ["constructsuper",
             "initproperty .*steamworks",
             "trait.*_cm",
             "trait slot.*steamworks"
            ]
        ];

        private static const replaceNums:Array = [
            [2, 0, 0, 0]
        ]

        private static const offsetFromMatches:Array = [
            [-2, -4, 0, 0]
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
             'trait slot QName(PackageNamespace(\"\"), \"bezel\") type QName(PackageNamespace(\"\"), \"Object\") end'
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
