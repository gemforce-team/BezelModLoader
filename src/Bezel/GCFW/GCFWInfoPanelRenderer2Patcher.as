package Bezel.GCFW
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCFWInfoPanelRenderer2Patcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var infoPanelGemTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanelGem"));
            var instructions:Vector.<ASInstruction> = infoPanelGemTrait.funcOrMethod.body.instructions;
            var properLocalIndex:uint = 0xFFFFFFFF;
            var insertAfterInstruction:uint = 0xFFFFFFFF;
            for (var i:int = instructions.length - 1; i >= 0; i--)
            {
                var instruction:ASInstruction = instructions[i];
                if (properLocalIndex == 0xFFFFFFFF && instruction.opcode == ASInstruction.OP_callpropvoid && (instruction.args[0] as ASMultiname).name == "addChild")
                {
                    properLocalIndex = instructions[GCFWCoreMod.prevNotDebug(instructions, i)].localIndex();
                }

                if (properLocalIndex != 0xFFFFFFFF && instruction.opcode == ASInstruction.OP_getlex && (instruction.args[0] as ASMultiname).name == "GV")
                {
                    insertAfterInstruction = i;
                    break;
                }
            }

            if (properLocalIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not find the proper index for info panel object");
            }

            if (insertAfterInstruction == 0xFFFFFFFF)
            {
                throw new Error("Could not find the proper instruction to insert after");
            }

            instructions.splice(insertAfterInstruction, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers")),
                ASInstruction.EfficientGetLocal(properLocalIndex),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.common.utils"), "NumberFormatter")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCFW"), "ingameGemInfoPanelFormed"), 3)
                );

            clazz.setInstanceTrait(infoPanelGemTrait);
        }
    }
}
