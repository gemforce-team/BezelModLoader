package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.traits.TraitMethod;
    import com.cff.anebe.ir.traits.TraitSlot;

    internal class GCCSMainPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchConstructor(clazz);
            addBezelVar(clazz);
        }

        // Both moves constructor logic to a new method
        private function patchConstructor(clazz:ASClass):void
        {
            var oldConstructor:ASMethod = clazz.getConstructor();
            var oldBody:ASMethodBody = oldConstructor.body;
            oldConstructor.body = new ASMethodBody(2, 2, 12, 14, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.FindPropStrict(ASQName(PackageNamespace("com.amanitadesign.steam"), "FRESteamWorks")),
                    ASInstruction.ConstructProp(ASQName(PackageNamespace("com.amanitadesign.steam"), "FRESteamWorks"), 0),
                    ASInstruction.InitProperty(ASQName(PackageNamespace(""), "steamworks")),
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

            var newConstructor:ASMethod = new ASMethod(null, ASQName(PackageNamespace(""), "void"), "com.giab.games.gcfw:Main/initFromBezel", new <String>["NEED_ACTIVATION"], null, null, null);

            instructionsToKeep.splice(0, 0, ASInstruction.GetLocal0(),
                ASInstruction.PushScope(),
                ASInstruction.NewActivation(),
                ASInstruction.Dup(),
                ASInstruction.SetLocal1(),
                ASInstruction.PushScope()
                );
            instructionsToKeep.splice(instructionsToKeep.length - 1, 0,
                ASInstruction.GetLocal0(),
                ASInstruction.PushNull(),
                ASInstruction.CallPropVoid(ASQName(PackageNamespace(""), "doEnterFramePreloader"), 1)
                );

            newConstructor.body = new ASMethodBody(oldBody.maxStack, oldBody.localCount, 11, 13, instructionsToKeep, oldBody.exceptions, oldBody.traits, oldBody.errors);

            clazz.setConstructor(oldConstructor);
            clazz.setInstanceTrait(TraitMethod(ASQName(PackageNamespace(""), "initFromBezel"), newConstructor));
        }

        private function addBezelVar(clazz:ASClass):void
        {
            clazz.setInstanceTrait(TraitSlot(ASQName(PackageNamespace(""), "bezel"), ASQName(PackageNamespace("Bezel"), "Bezel")));
        }
    }
}
