package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCCSInfoPanelRenderer2Patcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            addGemInfoPanelFormed(clazz);
            removeWaveStoneHotkey(clazz);
        }

        private function removeWaveStoneHotkeyImpl(body:ASMethodBody):void
        {
            body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushstring && instr.args[0] == "(Hot key: N)";
            })
                .reverse()
                .backtrack(2)
                .deleteUntil(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "addTextfield";
            })
                .deleteNext(1);
        }

        private function removeWaveStoneHotkey(clazz:ASClass):void
        {
            var infoPanelStoneTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderWarkStoneInfoPanel"));
            var body:ASMethodBody = infoPanelStoneTrait.funcOrMethod.body;

            removeWaveStoneHotkeyImpl(body);
            removeWaveStoneHotkeyImpl(body);

            clazz.setInstanceTrait(infoPanelStoneTrait);
        }

        private function addGemInfoPanelFormed(clazz:ASClass):void
        {
            var infoPanelGemTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanelGem"));

            var properLocalIndex:uint;
            var firstNewInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers"));

            infoPanelGemTrait.funcOrMethod.body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "addChild";
            })
                .backtrack(1)
                .then(function (instr:ASInstruction):void
            {
                properLocalIndex = instr.localIndex();
            })
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_getlex && (instr.args[0] as ASMultiname).name == "GV";
            })
                .then(function (instr:ASInstruction):void
            {
                infoPanelGemTrait.funcOrMethod.body.redirectJumps(instr, firstNewInstr);
            })
                .insert(
                firstNewInstr,
                ASInstruction.EfficientGetLocal(properLocalIndex),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.common.utils"), "NumberFormatter")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCCS"), "ingameGemInfoPanelFormed"), 3)
                );

            clazz.setInstanceTrait(infoPanelGemTrait);
        }
    }
}
