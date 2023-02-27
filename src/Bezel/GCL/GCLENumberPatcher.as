package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.namespaces.PrivateNamespace;
    import com.cff.anebe.ir.traits.TraitMethod;

    internal class GCLENumberPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchConstructor(clazz);
            patchG(clazz);
            patchS(clazz);
        }

        private function patchConstructor(clazz:ASClass):void
        {
            var newConstructor:ASMethod = new ASMethod(null, null, "", null, null, null,
                new ASMethodBody(2, 1, 4, 5, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.ConstructSuper(0),
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushByte(0),
                    ASInstruction.InitProperty(ASQName(PrivateNamespace(null, "com.giab.common.data:ENumber/instance"), "v")),
                    ASInstruction.ReturnVoid(),
                ]));

            clazz.setConstructor(newConstructor);
        }

        private function patchG(clazz:ASClass):void
        {
            var newG:ASTrait = TraitMethod(ASQName(PackageNamespace(""), "g"),
                new ASMethod(null, ASQName(PackageNamespace(""), "Number"), "com.giab.common.data:ENumber/g", null, null, null,
                new ASMethodBody(2, 1, 4, 5, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.GetProperty(ASQName(PrivateNamespace(null, "com.giab.common.data:ENumber/instance"), "v")),
                    ASInstruction.ReturnValue()
                ])));

            clazz.setInstanceTrait(newG);
        }

        private function patchS(clazz:ASClass):void
        {
            var newS:ASTrait = TraitMethod(ASQName(PackageNamespace(""), "s"),
                new ASMethod(new <ASMultiname>[ASQName(PackageNamespace(""), "Number")], ASQName(PackageNamespace(""), "void"), "com.giab.common.data:ENumber/s", null, null, null,
                new ASMethodBody(2, 2, 4, 5, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.GetLocal1(),
                    ASInstruction.SetProperty(ASQName(PrivateNamespace(null, "com.giab.common.data:ENumber/instance"), "v")),
                    ASInstruction.ReturnVoid()
                ])));

            clazz.setInstanceTrait(newS);
        }
    }
}
