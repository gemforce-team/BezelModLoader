package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCLLoadSavePatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchSave(clazz);
            for (var slot:int = 1; slot <= 3; slot++)
            {
                patchLoad(clazz, "ehNewGameSlot" + slot + "Clicked");
                patchLoad(clazz, "ehContinueSlot" + slot + "Clicked");
            }
        }

        private function patchSave(clazz:ASClass):void
        {
            var saveTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "saveSlotToLocal"));

            saveTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "close";
            })
                .advance()
                .insert(
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "saveSave"), 0)
                );

            clazz.setInstanceTrait(saveTrait);
        }

        private function patchLoad(clazz:ASClass, name:String):void
        {
            var loadTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), name));
            var instructions:Vector.<ASInstruction> = loadTrait.funcOrMethod.body.instructions;

            instructions.splice(instructions.length - 1, 0,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "loadSave"), 0)
                );

            clazz.setInstanceTrait(loadTrait);
        }
    }
}
