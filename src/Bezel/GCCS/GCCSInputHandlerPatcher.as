package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.ASMethodBody;

    internal class GCCSInputHandlerPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchClick(clazz);
            patchRightClick(clazz);
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
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal3(),
                ASInstruction.GetLocal(4),
                ASInstruction.GetLocal(5),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingameClickOnScene"), 5),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(onClickTrait);
        }

        private function patchRightClick(clazz:ASClass):void
        {
            var onRightClickTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "rightClickOnScene"));
            var body:ASMethodBody = onRightClickTrait.funcOrMethod.body;
            body.localCount += 4;

            var jumpLabel:ASInstruction = ASInstruction.Label();

            body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_ifne;
            })
                .advance(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal3(),
                ASInstruction.GetLocal(4),
                ASInstruction.GetLocal(5),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingameRightClickOnScene"), 5),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(onRightClickTrait);
        }

        private function patchKeyDown(clazz:ASClass):void
        {
            var keyDownTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "ehKeyDown"));

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers"));

            keyDownTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_iffalse;
            })
                .then(function (instr:ASInstruction):void
            {
                instr.args[0] = firstInstr;
            })
                .advance(2)
                .insert(
                firstInstr,
                ASInstruction.GetLocal1(),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingameKeyDown"), 1),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(keyDownTrait);
        }
    }
}
