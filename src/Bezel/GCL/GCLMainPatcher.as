package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.traits.TraitMethod;
    import com.cff.anebe.ir.traits.TraitSlot;

    internal class GCLMainPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            addBezelVar(clazz);
            patchConstructor(clazz);
            patchInitiateApplication(clazz);
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

            clazz.setInstanceTrait(TraitMethod(ASQName(PackageNamespace(""), "initFromBezel"), initFromBezel));
        }

        private function addBezelVar(clazz:ASClass):void
        {
            clazz.setInstanceTrait(TraitSlot(ASQName(PackageNamespace(""), "bezel"), ASQName(PackageNamespace("Bezel"), "Bezel")));
        }

        private function patchInitiateApplication(clazz:ASClass):void
        {
            var initiateApplicationTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageInternalNs("com.giab.games.gcl.gs"), "initiateApplication"));

            initiateApplicationTrait.funcOrMethod.body.streamInstructions(true)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.GetLocal0(),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCL"), "postInitiate"), 1)
                );

            clazz.setInstanceTrait(initiateApplicationTrait);
        }
    }
}
