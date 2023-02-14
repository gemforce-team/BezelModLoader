package Bezel.GCFW
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASNamespace;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.multinames.MultinameL;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCFWScrOptionsPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchSwitchOptions(clazz);
            patchRenderInfoPanel(clazz);
            patchEnterFrame(clazz);
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
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCFW"), "toggleCustomSettingsFromGame"), 0)
                );

            clazz.setInstanceTrait(switchOptionsTrait);
        }

        private function removeHotkeyRenderCall(body:ASMethodBody, searchString:String):void
        {
            body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushstring && instr.args[0] == searchString;
            })
                .reverse()
                .backtrack(2)
                .deleteUntil(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "addTextfield";
            })
                .deleteNext(1);
        }

        private function patchRenderInfoPanel(clazz:ASClass):void
        {
            var renderInfoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderPanelInfoPanel"));
            var body:ASMethodBody = renderInfoPanelTrait.funcOrMethod.body;

            // Find the location to put in the new info panel stuff
            var replaceLoc:uint = 0xFFFFFFFF;
            var fixupLoc:uint = 0xFFFFFFFF;

            var defaultTarget:ASInstruction;

            var newLabel:ASInstruction = ASInstruction.Label();

            body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_lookupswitch;
            })
                .then(function (instr:ASInstruction):void
            {
                defaultTarget = instr.args[0];
                instr.args[0] = newLabel;
            })
                .backtrack(0xFFFFFFFF)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return defaultTarget == instr;
            })
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushfalse;
            })
                .deleteNext(1)
                .insert(
                newLabel,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.games.gcfw"), "GV")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mcInfoPanel")),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "renderInfoPanel"), 2)
                );

            // Get rid of the two hot key functions
            removeHotkeyRenderCall(body, "Hot key: . (dot)");
            removeHotkeyRenderCall(body, "Hot key: , (comma)");

            clazz.setInstanceTrait(renderInfoPanelTrait);
        }

        private function patchEnterFrame(clazz:ASClass):void
        {
            var enterFrameTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "doEnterFrame"));

            var iLocal:uint = 0xFFFFFFFF;

            var newDup:ASInstruction = ASInstruction.Dup();
            var ifFalseDoNotColorPlate:ASInstruction;

            var nextIfFalse:ASInstruction;

            enterFrameTrait.funcOrMethod.body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushbyte;
            })
                .advance(1)
                .then(function (instr:ASInstruction):void
            {
                iLocal = instr.localIndex();
            })
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "height";
            })
                .reverse()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_iffalse;
            })
                .then(function (instr:ASInstruction):void
            {
                instr.args[0] = newDup;
            })
                .reverse()
                .advance(1)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_iffalse;
            })
                .then(function (instr:ASInstruction):void
            {
                nextIfFalse = ASInstruction.IfFalse(instr);
            })
                .insert(
                newDup,
                nextIfFalse,
                ASInstruction.Pop(),
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                ASInstruction.GetProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "IS_CHOOSING_KEYBIND")),
                ASInstruction.Not()
                )
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "gotoAndStop";
            })
                .advance(1)
                .then(function (instr:ASInstruction):void
            {
                ifFalseDoNotColorPlate = ASInstruction.IfFalse(instr);
            })
                .reverse()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "IS_CHOOSING_KEYBIND";
            })
                .reverse()
                .advance(3)
                .insert(
                ASInstruction.GetLocal0(),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mc")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "arrCntContents")),
                ASInstruction.EfficientGetLocal(iLocal),
                ASInstruction.GetProperty(MultinameL(new <ASNamespace>[PackageNamespace("")])),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "btn")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "parent")),
                ASInstruction.PushNull(),
                ASInstruction.Equals(),
                ASInstruction.Not(),
                ASInstruction.Dup(),
                ASInstruction.IfTrue(ifFalseDoNotColorPlate),
                ASInstruction.Pop(),
                ASInstruction.GetLocal0(),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mc")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "arrCntContents")),
                ASInstruction.EfficientGetLocal(iLocal),
                ASInstruction.GetProperty(MultinameL(new <ASNamespace>[PackageNamespace("")])),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "knob")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "parent")),
                ASInstruction.PushNull(),
                ASInstruction.Equals(),
                ASInstruction.Not(),
                ASInstruction.Dup(),
                ASInstruction.IfTrue(ifFalseDoNotColorPlate),
                ASInstruction.Pop(),
                ASInstruction.GetLocal0(),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mc")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "arrCntContents")),
                ASInstruction.EfficientGetLocal(iLocal),
                ASInstruction.GetProperty(MultinameL(new <ASNamespace>[PackageNamespace("")])),
                ASInstruction.GetLocal0(),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mc")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "pnlDefaultSize")),
                ASInstruction.Equals(),
                ifFalseDoNotColorPlate
                );

            clazz.setInstanceTrait(enterFrameTrait);
        }
    }
}
