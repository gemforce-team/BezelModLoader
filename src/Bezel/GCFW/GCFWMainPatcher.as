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
            var oldConstructor:ASMethod = clazz.getConstructor();
            var oldBody:ASMethodBody = oldConstructor.body;
            oldConstructor.body = new ASMethodBody(2, 2, 12, 14, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.ConstructSuper(0),
                    ASInstruction.ReturnVoid(),
                ]);
            oldConstructor.flags = new <String>[];

            var instructionsToKeep:Vector.<ASInstruction> = oldBody.instructions;
            while (instructionsToKeep[0].opcode != ASInstruction.OP_constructsuper)
            {
                instructionsToKeep.shift();
            }
            instructionsToKeep.shift();

            for each (var instr:ASInstruction in instructionsToKeep)
            {
                if (instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "uncaughtErrorHandler")
                {
                    (instr.args[0] as ASMultiname).ns = PackageNamespace("");
                }
            }

            var newConstructor:ASMethod = new ASMethod(null, ASQName(PackageNamespace(""), "void"), "com.giab.games.gcfw:Main/initFromBezel", new <String>["NEED_ACTIVATION"], null, null, null);

            newConstructor.body = new ASMethodBody(oldBody.maxStack, oldBody.localCount, 11, 13, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.NewActivation(),
                    ASInstruction.Dup(),
                    ASInstruction.SetLocal1(),
                    ASInstruction.PushScope(),
                ].concat(instructionsToKeep), oldBody.exceptions, oldBody.traits, oldBody.errors);

            clazz.setConstructor(oldConstructor);
            clazz.setInstanceTrait(TraitMethod(ASQName(PackageNamespace(""), "initFromBezel"), newConstructor));
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
