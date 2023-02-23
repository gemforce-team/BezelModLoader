package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCLIngameInitializerPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var newSceneTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "initiate"));
            var body:ASMethodBody = newSceneTrait.funcOrMethod.body;
            var instructions:Vector.<ASInstruction> = body.instructions;

            instructions.splice(instructions.length - 1, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "ingameNewScene"), 0)
                );

            body.redirectJumps(instructions[instructions.length - 1], instructions[instructions.length - 3]);

            clazz.setInstanceTrait(newSceneTrait);
        }
    }
}
