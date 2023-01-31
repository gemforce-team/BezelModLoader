package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
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

        private function replaceHotkeyRenderCall(instructions:Vector.<ASInstruction>, keybind:String, keybindName:String):void
        {
            var hotkeyFirstIdx:int;
            var hotkeyLastIdx:int;
            var re:RegExp = new RegExp("hot key: " + keybind, "i");
            var hotkeyLoc:uint = 0xFFFFFFFF;
            for (var i:uint = instructions.length; i > 0; i--)
            {
                var instr:ASInstruction = instructions[i - 1];

                if (instr.opcode == ASInstruction.OP_pushstring && re.test(instr.args[0] as String))
                {
                    hotkeyLoc = i - 1;
                    hotkeyFirstIdx = (instr.args[0] as String).search(re) + 9;
                    hotkeyLastIdx = hotkeyFirstIdx + keybind.length;
                    break;
                }
            }

            if (hotkeyLoc == 0xFFFFFFFF)
            {
                throw new Error("Could not find hotkey string 'hot key: " + keybind + "'");
            }

            var origHotkeyString:String = instr.args[0] as String;

            instr.args[0] = origHotkeyString.slice(0, hotkeyFirstIdx);

            var hotkeyEndString:String = origHotkeyString.slice(hotkeyLastIdx);

            instructions.splice(hotkeyLoc + 1, 0,
                ASInstruction.GetLex(ASQName(PackageNamespace("Bezel"), "Bezel")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "instance")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "keybindManager")),
                ASInstruction.PushString(keybindName),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "getHotkeyValue"), 1),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toString"), 0),
                ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toUpperCase"), 0),
                ASInstruction.Add(),
                ASInstruction.PushString(origHotkeyString.slice(hotkeyLastIdx)),
                ASInstruction.Add());
        }

        private function addPreRenderPanelHookAndRemoveHotkeys(clazz:ASClass):void
        {
            var infoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanel"));
            var instructions:Vector.<ASInstruction> = infoPanelTrait.funcOrMethod.body.instructions;

            var insertIndex:uint = 0xFFFFFFFF;
            var editInstr:ASInstruction;

            for (var i:int = 0; i < instructions.length; i++)
            {
                if (instructions[i].opcode == ASInstruction.OP_ifne)
                {
                    insertIndex = GCCSCoreMod.nextNotDebug(instructions, GCCSCoreMod.nextNotDebug(instructions, i)); // Insert after this instruction and the returnvoid with it
                    if (instructions[i].args[0] == instructions[insertIndex])
                    {
                        editInstr = instructions[i];
                    }
                    break;
                }
            }

            if (insertIndex == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ingamePreRenderInfoPanel");
            }

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCCS"), "GCCSEventHandlers"));

            if (editInstr != null)
            {
                editInstr.args[0] = firstInstr;
            }

            instructions.splice(insertIndex, 0,
                firstInstr,
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCCS"), "ingamePreRenderInfoPanel"), 0),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            replaceHotkeyRenderCall(instructions, "space", "Pause time");
            replaceHotkeyRenderCall(instructions, "space", "Pause time");
            replaceHotkeyRenderCall(instructions, "space", "Pause time");
            replaceHotkeyRenderCall(instructions, "space", "Pause time");

            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");
            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");
            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");
            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");
            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");
            replaceHotkeyRenderCall(instructions, "q", "Switch time speed");

            replaceHotkeyRenderCall(instructions, "x", "Destroy gem for mana");

            replaceHotkeyRenderCall(instructions, "1", "Cast freeze strike spell");
            replaceHotkeyRenderCall(instructions, "2", "Cast curse strike spell");
            replaceHotkeyRenderCall(instructions, "3", "Cast wake of eternity strike spell");
            replaceHotkeyRenderCall(instructions, "4", "Cast bolt enhancement spell");
            replaceHotkeyRenderCall(instructions, "5", "Cast beam enhancement spell");
            replaceHotkeyRenderCall(instructions, "6", "Cast barrage enhancement spell");

            replaceHotkeyRenderCall(instructions, "b", "Throw gem bombs");
            replaceHotkeyRenderCall(instructions, "g", "Combine gems");

            replaceHotkeyRenderCall(instructions, "numpad 1", "Create Bloodbound gem");
            replaceHotkeyRenderCall(instructions, "numpad 2", "Create Slowing gem");
            replaceHotkeyRenderCall(instructions, "numpad 3", "Create Armor Tearing gem");
            replaceHotkeyRenderCall(instructions, "numpad 4", "Create Chain Hit gem");
            replaceHotkeyRenderCall(instructions, "numpad 5", "Create Poison gem");
            replaceHotkeyRenderCall(instructions, "numpad 6", "Create Suppression gem");
            replaceHotkeyRenderCall(instructions, "numpad 7", "Create Mana Leeching gem");
            replaceHotkeyRenderCall(instructions, "numpad 8", "Create Critical Hit gem");
            replaceHotkeyRenderCall(instructions, "numpad 9", "Create Poolbound gem");

            replaceHotkeyRenderCall(instructions, "w", "Build wall");
            replaceHotkeyRenderCall(instructions, "t", "Build tower");
            replaceHotkeyRenderCall(instructions, "a", "Build amplifier");
            replaceHotkeyRenderCall(instructions, "r", "Build trap");

            clazz.setInstanceTrait(infoPanelTrait);
        }
    }
}
