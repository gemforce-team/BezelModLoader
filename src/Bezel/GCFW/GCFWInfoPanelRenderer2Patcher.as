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
            addGemInfoPanelFormedHook(clazz);
            removeWaveStoneHotkey(clazz);
        }

        private function removeWaveStoneHotkey(clazz:ASClass):void
        {
            var infoPanelGemTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderWaveStoneInfoPanel"));
            var instructions:Vector.<ASInstruction> = infoPanelGemTrait.funcOrMethod.body.instructions;

            var hotkeyLoc:uint = 0xFFFFFFFF;
            for (var i:uint = instructions.length; i > 0; i--)
            {
                var instr:ASInstruction = instructions[i - 1];

                if (instr.opcode == ASInstruction.OP_pushstring && instr.args[0] == "(Hot key: N)")
                {
                    hotkeyLoc = i - 1;
                    break;
                }
            }

            if (hotkeyLoc == 0xFFFFFFFF)
            {
                throw new Error("Could not find hotkey string '(Hot key: N)'");
            }

            var removeLoc:uint = GCFWCoreMod.prevNotDebug(instructions, GCFWCoreMod.prevNotDebug(instructions, hotkeyLoc));

            var removeEnd:uint = 0xFFFFFFFF;

            for (i = removeLoc; i < instructions.length; i++)
            {
                instr = instructions[i];
                if (instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "addTextfield")
                {
                    removeEnd = i;
                    break;
                }
            }

            instructions.splice(removeLoc, removeEnd - removeLoc + 1);
        }

        private function addGemInfoPanelFormedHook(clazz:ASClass):void
        {
            var infoPanelGemTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanelGem"));
            var instructions:Vector.<ASInstruction> = infoPanelGemTrait.funcOrMethod.body.instructions;
            var properLocalIndex:uint = 0xFFFFFFFF;
            var insertAfterInstruction:uint = 0xFFFFFFFF;
            var fixJumpsTo:ASInstruction;
            for (var i:int = instructions.length - 1; i >= 0; i--)
            {
                var instruction:ASInstruction = instructions[i];
                if (properLocalIndex == 0xFFFFFFFF && instruction.opcode == ASInstruction.OP_callpropvoid && (instruction.args[0] as ASMultiname).name == "addChild")
                {
                    properLocalIndex = instructions[GCFWCoreMod.prevNotDebug(instructions, i)].localIndex();
                }

                if (properLocalIndex != 0xFFFFFFFF && instruction.opcode == ASInstruction.OP_getlex && (instruction.args[0] as ASMultiname).name == "GV")
                {
                    fixJumpsTo = instruction;
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

            var firstNewInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWEventHandlers"));

            instructions.splice(insertAfterInstruction, 0,
                firstNewInstr,
                ASInstruction.EfficientGetLocal(properLocalIndex),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.common.utils"), "NumberFormatter")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCFW"), "ingameGemInfoPanelFormed"), 3)
                );

            for each (instruction in instructions)
            {
                if (instruction.args != null && instruction.args.length > 0 && instruction.args[0] == fixJumpsTo)
                {
                    instruction.args[0] = firstNewInstr;
                }
            }

            clazz.setInstanceTrait(infoPanelGemTrait);
        }
    }
}
