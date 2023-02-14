package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCCSInfoPanelRendererPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            addPreRenderPanelHookAndRemoveHotkeys(clazz);
        }

        private function replaceHotkeyRenderCall(body:ASMethodBody, keybind:String, keybindName:String):void
        {
            var hotkeyFirstIdx:int;
            var hotkeyLastIdx:int;
            var re:RegExp = new RegExp("hot key: " + keybind, "i");

            var origHotkeyString:String;
            var hotkeyEndString:String;

            body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushstring && re.test(instr.args[0] as String);
            })
                .then(function (instr:ASInstruction):void
            {
                hotkeyFirstIdx = (instr.args[0] as String).search(re) + 9;
                hotkeyLastIdx = hotkeyFirstIdx + keybind.length;

                origHotkeyString = instr.args[0] as String;
                instr.args[0] = origHotkeyString.slice(0, hotkeyFirstIdx);
                hotkeyEndString = origHotkeyString.slice(hotkeyLastIdx);
            })
                .backtrack(1)
                .insert(
                ASInstruction.GetLex(ASQName(PackageNamespace("Bezel"), "Bezel")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "instance")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "keybindManager")),
                ASInstruction.PushString(keybindName),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "getHotkeyValue"), 1),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toString"), 0),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toUpperCase"), 0),
                ASInstruction.Add(),
                ASInstruction.PushString(origHotkeyString.slice(hotkeyLastIdx)),
                ASInstruction.Add()
                );
        }

        private function addPreRenderPanelHookAndRemoveHotkeys(clazz:ASClass):void
        {
            var infoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanel"));
            var body:ASMethodBody = infoPanelTrait.funcOrMethod.body;

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers"));
            var editInstr:ASInstruction;

            body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                var ret:Boolean = instr.opcode == ASInstruction.OP_ifne;
                return ret;
            })
                .then(function (instr:ASInstruction):void
            {
                editInstr = instr;
            })
                .advance(2)
                .then(function (instr:ASInstruction):void
            {
                if (editInstr.args[0] == instr)
                {
                    body.redirectJumps(instr, firstInstr);
                }
            })
                .insert(
                firstInstr,
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingamePreRenderInfoPanel"), 0),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            replaceHotkeyRenderCall(body, "space", "Pause time");
            replaceHotkeyRenderCall(body, "space", "Pause time");
            replaceHotkeyRenderCall(body, "space", "Pause time");
            replaceHotkeyRenderCall(body, "space", "Pause time");

            replaceHotkeyRenderCall(body, "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "q", "Switch time speed");

            replaceHotkeyRenderCall(body, "x", "Destroy gem for mana");

            replaceHotkeyRenderCall(body, "1", "Cast freeze strike spell");
            replaceHotkeyRenderCall(body, "2", "Cast curse strike spell");
            replaceHotkeyRenderCall(body, "3", "Cast wake of eternity strike spell");
            replaceHotkeyRenderCall(body, "4", "Cast bolt enhancement spell");
            replaceHotkeyRenderCall(body, "5", "Cast beam enhancement spell");
            replaceHotkeyRenderCall(body, "6", "Cast barrage enhancement spell");

            replaceHotkeyRenderCall(body, "b", "Throw gem bombs");
            replaceHotkeyRenderCall(body, "g", "Combine gems");

            replaceHotkeyRenderCall(body, "numpad 1", "Create Bloodbound gem");
            replaceHotkeyRenderCall(body, "numpad 2", "Create Slowing gem");
            replaceHotkeyRenderCall(body, "numpad 3", "Create Armor Tearing gem");
            replaceHotkeyRenderCall(body, "numpad 4", "Create Chain Hit gem");
            replaceHotkeyRenderCall(body, "numpad 5", "Create Poison gem");
            replaceHotkeyRenderCall(body, "numpad 6", "Create Suppression gem");
            replaceHotkeyRenderCall(body, "numpad 7", "Create Mana Leeching gem");
            replaceHotkeyRenderCall(body, "numpad 8", "Create Critical Hit gem");
            replaceHotkeyRenderCall(body, "numpad 9", "Create Poolbound gem");

            replaceHotkeyRenderCall(body, "w", "Build wall");
            replaceHotkeyRenderCall(body, "t", "Build tower");
            replaceHotkeyRenderCall(body, "a", "Build amplifier");
            replaceHotkeyRenderCall(body, "r", "Build trap");

            clazz.setInstanceTrait(infoPanelTrait);
        }
    }
}
