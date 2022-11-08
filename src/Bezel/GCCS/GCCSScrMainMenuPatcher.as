package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;

    internal class GCCSScrMainMenuPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            var constructor:ASMethod = clazz.getConstructor();
            constructor.body.instructions.splice(constructor.body.instructions.length - 1, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers")),
                ASInstruction.GetLocal1(),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCCS"), "setVersion"), 1)
                );
            
            clazz.setConstructor(constructor);
        }
    }
}
