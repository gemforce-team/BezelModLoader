package Bezel.GCL
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.InstructionStream;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    internal class GCLRendererPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            addGemInfoPanelFormedHook(clazz);
            addPreRenderPanelHookAndRemoveHotkeys(clazz);
        }

        private function replaceHotkeyRenderCall(body:ASMethodBody, prefix:String, keybind:String, keybindName:String, keybindName2:String = null):void
        {
            var hotkeyFirstIdx:int;
            var hotkeyLastIdx:int;
            var re:RegExp = new RegExp(prefix + keybind, "i");

            var origHotkeyString:String;
            var hotkeyEndString:String;

            var stream:InstructionStream = body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushstring && re.test(instr.args[0] as String);
            })
                .then(function (instr:ASInstruction):void
            {
                hotkeyFirstIdx = (instr.args[0] as String).search(re) + prefix.length;
                hotkeyLastIdx = hotkeyFirstIdx + keybind.length;

                origHotkeyString = instr.args[0] as String;
                instr.args[0] = origHotkeyString.slice(0, hotkeyFirstIdx);
                hotkeyEndString = origHotkeyString.slice(hotkeyLastIdx);
            })
                .backtrack(1);

            if (keybindName2 == null)
            {
                stream.insert(
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
            else
            {
                stream.insert(
                    ASInstruction.GetLex(ASQName(PackageNamespace("Bezel"), "Bezel")),
                    ASInstruction.GetProperty(ASQName(PackageNamespace(""), "instance")),
                    ASInstruction.GetProperty(ASQName(PackageNamespace(""), "keybindManager")),
                    ASInstruction.PushString(keybindName),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "getHotkeyValue"), 1),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toString"), 0),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toUpperCase"), 0),
                    ASInstruction.Add(),
                    ASInstruction.PushString(" / "),
                    ASInstruction.Add(),
                    ASInstruction.GetLex(ASQName(PackageNamespace("Bezel"), "Bezel")),
                    ASInstruction.GetProperty(ASQName(PackageNamespace(""), "instance")),
                    ASInstruction.GetProperty(ASQName(PackageNamespace(""), "keybindManager")),
                    ASInstruction.PushString(keybindName2),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "getHotkeyValue"), 1),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toString"), 0),
                    ASInstruction.CallProperty(ASQName(PackageNamespace(""), "toUpperCase"), 0),
                    ASInstruction.Add(),
                    ASInstruction.PushString(origHotkeyString.slice(hotkeyLastIdx)),
                    ASInstruction.Add()
                    );
            }
        }

        private function addGemInfoPanelFormedHook(clazz:ASClass):void
        {
            var infoPanelGemTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanelGem"));
            var body:ASMethodBody = infoPanelGemTrait.funcOrMethod.body;

            var properLocalIndex:uint = 0xFFFFFFFF;
            var firstNewInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers"));

            infoPanelGemTrait.funcOrMethod.body.streamInstructions(true)
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "addChild";
            })
                .advance()
                .then(function (instr:ASInstruction):void
            {
                properLocalIndex = instr.localIndex();
            })
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "core";
            })
                .advance()
                .then(function (instr:ASInstruction):void
            {
                body.redirectJumps(instr, firstNewInstr);
            })
                .insert(
                firstNewInstr,
                ASInstruction.EfficientGetLocal(properLocalIndex),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.common.utils"), "NumberFormatter")),
                ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCL"), "ingameGemInfoPanelFormed"), 3)
                );

            clazz.setInstanceTrait(infoPanelGemTrait);
        }

        private function addPreRenderPanelHookAndRemoveHotkeys(clazz:ASClass):void
        {
            var infoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderInfoPanel"));
            var body:ASMethodBody = infoPanelTrait.funcOrMethod.body;

            var jumpLabel:ASInstruction = ASInstruction.Label();
            var firstInstr:ASInstruction = ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCL"), "GCLEventHandlers"));
            var editInstr:ASInstruction;

            body.streamInstructions()
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "renderApparitionInfoPanel";
            })
                .findNext(function (instr:ASInstruction):Boolean
            {
                return instr.opcode == ASInstruction.OP_pushfalse;
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
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCL"), "ingamePreRenderInfoPanel"), 0),
                ASInstruction.IfTrue(jumpLabel),
                ASInstruction.ReturnVoid(),
                jumpLabel
                );

            replaceHotkeyRenderCall(body, "shortcut key: ", "space", "Pause time");
            replaceHotkeyRenderCall(body, "shortcut key: ", "space", "Pause time");
            replaceHotkeyRenderCall(body, "shortcut key: ", "space", "Pause time");
            replaceHotkeyRenderCall(body, "shortcut key: ", "space", "Pause time");

            replaceHotkeyRenderCall(body, "shortcut key: ", "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "shortcut key: ", "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "shortcut key: ", "q", "Switch time speed");
            replaceHotkeyRenderCall(body, "shortcut key: ", "q", "Switch time speed");

            replaceHotkeyRenderCall(body, "hot key: ", "n", "Start next wave");

            replaceHotkeyRenderCall(body, "shortcut: point at gem and press ", "x", "Destroy gem for mana");
            replaceHotkeyRenderCall(body, "shortcut: point at gem and press ", "d", "Duplicate gem");
            replaceHotkeyRenderCall(body, "point at gem and press ", "u", "Upgrade gem");

            replaceHotkeyRenderCall(body, "hot key: ", "1 / numpad 1", "Create Shock gem", "Create Shock gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "2 / numpad 2", "Create Slow gem", "Create Slow gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "3 / numpad 3", "Create Armor Tearing gem", "Create Armor Tearing gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "4 / numpad 4", "Create Poison gem", "Create Poison gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "6 / numpad 6", "Create Bloodbound gem", "Create Bloodbound gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "7 / numpad 7", "Create Chain Hit gem", "Create Chain Hit gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "8 / numpad 8", "Create Multiple Damage gem", "Create Multiple Damage gem 2");
            replaceHotkeyRenderCall(body, "hot key: ", "9 / numpad 9", "Create Mana Gain gem", "Create Mana Gain gem 2");

            replaceHotkeyRenderCall(body, "hot key: ", "w", "Build wall");
            replaceHotkeyRenderCall(body, "hot key: ", "c", "Build charged bolt shrine");
            replaceHotkeyRenderCall(body, "hot key: ", "b", "Throw gem bombs");
            replaceHotkeyRenderCall(body, "hot key: ", "t", "Build tower");
            replaceHotkeyRenderCall(body, "hot key: ", "r", "Build trap");
            replaceHotkeyRenderCall(body, "hot key: ", "g", "Combine gems");
            replaceHotkeyRenderCall(body, "hot key: ", "a", "Build amplifier");
            replaceHotkeyRenderCall(body, "hot key: ", "l", "Build lightning shrine");
            replaceHotkeyRenderCall(body, "hot key: ", "m", "Expand mana pool");

            clazz.setInstanceTrait(infoPanelTrait);
        }
    }
}
