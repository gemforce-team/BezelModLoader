package Bezel.GCFW
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.namespaces.PrivateNamespace;
    import com.cff.anebe.ir.traits.TraitMethod;
    import com.cff.anebe.ir.traits.TraitSlot;

    internal class GCFWMainPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchConstructor(clazz);
            addBezelVar(clazz);
            editUncaughtErrorHandler(clazz);
        }

        // Both moves constructor logic to a new method and patches usage of uncaughtErrorHandler
        private function patchConstructor(clazz:ASClass):void
        {
            var constructor:ASMethod = clazz.getConstructor();
            var initFromBezel:ASMethod = new ASMethod(null, ASQName(PackageNamespace(""), "void"), "com.giab.games.gcfw:Main/initFromBezel", constructor.flags, null, null, constructor.body);

            constructor.flags = new <String>[];
            constructor.body = new ASMethodBody(1, 1, 0, 1, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.ConstructSuper(0),
                    ASInstruction.ReturnVoid(),
                ]);
            clazz.setConstructor(constructor);

            var instructions:Vector.<ASInstruction> = initFromBezel.body.instructions;
            for (var i:int = 0; i < instructions.length; i++)
            {
                var instruction:ASInstruction = instructions[i];
                if (instruction.opcode == ASInstruction.OP_constructsuper)
                {
                    var deleteFrom:int = GCFWCoreMod.prevNotDebug(instructions, i);
                    instructions.splice(deleteFrom, i - deleteFrom + 1);
                    i = deleteFrom - 1;
                }
                if (instruction.opcode == ASInstruction.OP_getproperty && (instruction.args[0] as ASMultiname).name == "uncaughtErrorHandler")
                {
                    (instruction.args[0] as ASMultiname).ns = PackageNamespace("");
                }
            }
            clazz.setInstanceTrait(TraitMethod(ASQName(PackageNamespace(""), "initFromBezel"), initFromBezel));
        }

        private function addBezelVar(clazz:ASClass):void
        {
            clazz.setInstanceTrait(TraitSlot(ASQName(PackageNamespace(""), "bezel"), ASQName(PackageNamespace("Bezel"), "Bezel")));
        }

        private function editUncaughtErrorHandler(clazz:ASClass):void
        {
            var handler:ASTrait = clazz.getInstanceTrait(ASQName(PrivateNamespace("com.giab.games.gcfw:Main"), "uncaughtErrorHandler"));
            clazz.deleteInstanceTrait(handler.name);
            handler.name.ns = PackageNamespace("");
            handler.funcOrMethod.name = "com.giab.games.gcfw:Main/uncaughtErrorHandler";

            for each (var instr:ASInstruction in handler.funcOrMethod.body.instructions)
            {
                if (instr.opcode == ASInstruction.OP_pushstring)
                {
                    if ((instr.args[0] as String).search("an error has occurred") != -1)
                    {
                        instr.args[0] = "Unfortunately, an error has occured in the game:\n(game version stamp: ";
                    }
                    else if ((instr.args[0] as String).search("Could you please copy this message") != -1)
                    {
                        instr.args[0] = "\n\nTHE GAME IS MODDED!\n\nPlease check the log in \"%AppData%/Roaming/com.giab.games.gcfw.steam/Local Store/Bezel Mod Loader\" for additional info!\n\nYou can ask for help in GemCraft's discord #modding channel.\n\nThank you for your help and sorry for the inconvenience!";
                    }
                }
            }

            clazz.setInstanceTrait(handler);
        }
    }
}
