package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;

    internal class GCLMainMenuPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var constructor:ASMethod = clazz.getConstructor();
            constructor.body.maxStack += 1;
            constructor.body.instructions.splice(constructor.body.instructions.length - 1, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.GetLocal0(),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "setVersion"), 1)
                );

            clazz.setConstructor(constructor);
        }
    }
}
