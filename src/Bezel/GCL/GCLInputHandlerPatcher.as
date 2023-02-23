package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCLInputHandlerPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchClick(clazz);
            // No right click in the game to patch
            patchKeyDown(clazz);
        }

        private function patchClick(clazz:ASClass):void
        {
            var onClickTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "clickOnScene"));

            var jumpLabel:ASInstruction = ASInstruction.Label();

            onClickTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_ifne;
            })
                .advance(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal3(),
                ASInstruction.GetLocal(4),
                ASInstruction.GetLocal(5),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCL"), "ingameClickOnScene"), 5),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(onClickTrait);
        }

        private function patchKeyDown(clazz:ASClass):void
        {
            var keyDownTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "ehKeyDown"));

            var jumpLabel:ASInstruction = ASInstruction.Label();

            keyDownTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushscope;
            })
                .advance(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCL"), "ingameKeyDown"), 1),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(keyDownTrait);
        }
    }
}
