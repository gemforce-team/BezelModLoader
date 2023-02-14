package Bezel.GCFW
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCFWInputHandlerPatcher implements LatticePatcher
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
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal3(),
                ASInstruction.GetLocal(4),
                ASInstruction.GetLocal(5),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "ingameClickOnScene"), 5),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(onClickTrait);
        }

        private function patchRightClick(clazz:ASClass):void
        {
            var onRightClickTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "rightClickOnScene"));
            onRightClickTrait.funcOrMethod.body.maxStack += 3;

            var jumpLabel:ASInstruction = ASInstruction.Label();

            onRightClickTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_ifne;
            })
                .advance(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal3(),
                ASInstruction.GetLocal(4),
                ASInstruction.GetLocal(5),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "ingameRightClickOnScene"), 5),
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
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers"));

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
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "ingameKeyDown"), 1),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(keyDownTrait);
        }
    }
}
