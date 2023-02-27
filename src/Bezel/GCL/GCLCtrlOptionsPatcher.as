package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCLCtrlOptionsPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchSwitchOptions(clazz);
        }

        private function patchSwitchOptions(clazz:ASClass):void
        {
            var switchOptionsTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "switchOptions"));

            switchOptionsTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushscope;
            })
                .advance(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLSettingsHandler")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "toggleCustomSettingsFromGame"), 0)
                );

            clazz.setInstanceTrait(switchOptionsTrait);
        }
    }
}
