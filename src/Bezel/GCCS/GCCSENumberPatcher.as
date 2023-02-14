package Bezel.GCCS
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

    internal class GCCSENumberPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchG(clazz);
            patchS(clazz);
        }

        private function patchG(clazz:ASClass):void
        {
            var newG:ASTrait = TraitMethod(ASQName(PackageNamespace(""), "g"),
                new ASMethod(null, ASQName(PackageNamespace(""), "Number"), "com.giab.common.data:ENumber/g", null, null, null,
                new ASMethodBody(2, 1, 4, 5, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.GetProperty(ASQName(PrivateNamespace("com.giab.common.data:ENumber"), "a")),
                    ASInstruction.ReturnValue()
                ])));

            clazz.setInstanceTrait(newG);
        }

        private function patchS(clazz:ASClass):void
        {
            var sTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "s"));

            sTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "b";
            })
                .backtrack(1)
                .splice(-1, true,
                ASInstruction.GetLocal1(),
                ASInstruction.SetProperty(ASQName(PrivateNamespace("com.giab.common.data:ENumber"), "a")),
                ASInstruction.ReturnVoid()
                );

            clazz.setInstanceTrait(sTrait);
        }
    }
}
