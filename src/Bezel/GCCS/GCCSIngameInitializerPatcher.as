package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCCSIngameInitializerPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var newSceneTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "setScene3Initiate"));
            var instructions:Vector.<ASInstruction> = newSceneTrait.funcOrMethod.body.instructions;

            instructions.splice(instructions.length - 1, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCCS"), "ingameNewScene"), 0)
                );

            for (var i:int = instructions.length - 1; i >= 0; i--)
            {
                var instr:ASInstruction = instructions[i];
                if (instr.args != null && instr.args.length > 0 && instr.args[0] is ASInstruction && instr.args[0] == instructions[instructions.length - 1])
                {
                    instr.args[0] = instructions[instructions.length - 3];
                }
            }

            clazz.setInstanceTrait(newSceneTrait);
        }
    }
}
