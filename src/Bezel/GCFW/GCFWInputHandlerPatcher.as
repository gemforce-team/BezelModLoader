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
            var instructions:Vector.<ASInstruction> = onClickTrait.funcOrMethod.body.instructions;

            var insertIndex:uint = 0xFFFFFFFF;

            for (var i:int = 0; i < instructions.length; i++)
            {
                if (instructions[i].opcode == ASInstruction.OP_ifne)
                {
                    insertIndex = i + 1; // Insert after this instruction
                    break;
                }
            }

            if (insertIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ingameClickOnScene");
            }

            var jumpLabel:ASInstruction = ASInstruction.Label();

            instructions.splice(insertIndex, 0,
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
            var instructions:Vector.<ASInstruction> = onRightClickTrait.funcOrMethod.body.instructions;
            onRightClickTrait.funcOrMethod.body.localCount += 4;

            var insertIndex:uint = 0xFFFFFFFF;

            for (var i:int = 0; i < instructions.length; i++)
            {
                if (instructions[i].opcode == ASInstruction.OP_ifne)
                {
                    insertIndex = i + 1; // Insert after this instruction
                    break;
                }
            }

            if (insertIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ingameRightClickOnScene");
            }

            var jumpLabel:ASInstruction = ASInstruction.Label();

            instructions.splice(insertIndex, 0,
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
            var instructions:Vector.<ASInstruction> = keyDownTrait.funcOrMethod.body.instructions;

            var insertIndex:uint = 0xFFFFFFFF;
            var editInstr:ASInstruction;

            for (var i:int = 0; i < instructions.length; i++)
            {
                if (instructions[i].opcode == ASInstruction.OP_iffalse)
                {
                    editInstr = instructions[i];
                    insertIndex = i + 2; // Insert after this instruction and the returnvoid with it
                    break;
                }
            }

            if (insertIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ingameKeyDown");
            }

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers"));

            editInstr.args[0] = firstInstr;

            instructions.splice(insertIndex, 0,
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
