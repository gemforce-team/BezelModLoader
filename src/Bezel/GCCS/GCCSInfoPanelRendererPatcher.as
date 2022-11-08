package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCCSInfoPanelRendererPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var infoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanel"));
            var instructions:Vector.<ASInstruction> = infoPanelTrait.funcOrMethod.body.instructions;

            var insertIndex:uint = 0xFFFFFFFF;
            var editInstr:ASInstruction;

            for (var i:int = 0; i < instructions.length; i++)
            {
                if (instructions[i].opcode == ASInstruction.OP_ifne)
                {
                    insertIndex = GCCSCoreMod.nextNotDebug(instructions, GCCSCoreMod.nextNotDebug(instructions, i)); // Insert after this instruction and the returnvoid with it
                    if (instructions[i].args[0] == instructions[insertIndex])
                    {
                        editInstr = instructions[i];
                    }
                    break;
                }
            }

            if (insertIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ingamePreRenderInfoPanel");
            }

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers"));

            if (editInstr != null)
            {
                editInstr.args[0] = firstInstr;
            }

            instructions.splice(insertIndex, 0,
                firstInstr,
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingamePreRenderInfoPanel"), 0),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            clazz.setInstanceTrait(infoPanelTrait);
        }
    }
}
