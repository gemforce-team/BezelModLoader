package Bezel.GCFW
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageInternalNs;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.multinames.RTQNameL;
    import com.cff.anebe.ir.namespaces.NormalNamespace;
    import com.cff.anebe.ir.multinames.MultinameL;
    import com.cff.anebe.ir.namespaces.PrivateNamespace;
    import com.cff.anebe.ir.ASNamespace;
    import com.cff.anebe.ir.namespaces.ProtectedNamespace;

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
            var instructions:Vector.<ASInstruction> = switchOptionsTrait.funcOrMethod.body.instructions;

            for (var i:int = 0; i < instructions.length; i++)
            {
                var instr:ASInstruction = instructions[i];
                if (instr.opcode == ASInstruction.OP_pushscope)
                {
                    instructions.splice(GCFWCoreMod.nextNotDebug(instructions, i), 0,
                        ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                        ASInstruction.CallPropVoid(ASQName(PackageInternalNs("Bezel.GCFW"), "toggleCustomSettingsFromGame"), 0)
                        );

                    clazz.setInstanceTrait(switchOptionsTrait);
                    return;
                }
            }

            throw new Error("Could not patch ScrOptions::switchOptions");
        }

        private function patchRenderInfoPanel(clazz:ASClass):void
        {
            var renderInfoPanelTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "renderPanelInfoPanel"));
            var instructions:Vector.<ASInstruction> = renderInfoPanelTrait.funcOrMethod.body.instructions;

            // Find the location to put in the new info panel stuff
            var replaceLoc:uint = 0xFFFFFFFF;
            var fixupLoc:uint = 0xFFFFFFFF;

            for (var i:int = 0; i < instructions.length; i++)
            {
                var instr:ASInstruction = instructions[i];
                // Get the new location
                if (instr.opcode == ASInstruction.OP_lookupswitch)
                {
                    var def:ASInstruction = instr.args[0] as ASInstruction;
                    replaceLoc = GCFWCoreMod.nextNotDebug(instructions, instructions.indexOf(def)); // We want to remove the pushfalse afterwards
                    if (instructions[replaceLoc].opcode != ASInstruction.OP_pushfalse)
                    {
                        throw new Error("Could not find a pushfalse to overwrite in ScrOptions::renderPanelInfoPanel");
                    }
                    if (def.opcode != ASInstruction.OP_label) // But if we don't have a label instruction here we also need to fix it up
                    {
                        replaceLoc--;
                        fixupLoc = i;
                    }
                    break;
                }
            }

            if (replaceLoc == 0xFFFFFFFF)
            {
                throw new Error("Could not patch ScrOptions::renderPanelInfoPanel");
            }

            instructions.splice(replaceLoc, 1,
                ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                ASInstruction.GetLocal1(),
                ASInstruction.GetLex(ASQName(PackageNamespace("com.giab.games.gcfw"), "GV")),
                ASInstruction.GetProperty(ASQName(PackageNamespace(""), "mcInfoPanel")),
                ASInstruction.CallProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "renderInfoPanel"), 2)
                );

            if (fixupLoc != 0xFFFFFFFF)
            {
                instructions[fixupLoc].args[0] = instructions[replaceLoc];
            }

            clazz.setInstanceTrait(renderInfoPanelTrait);
        }

        private function patchEnterFrame(clazz:ASClass):void
        {
            var enterFrameTrait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), "doEnterFrame"));
            var instructions:Vector.<ASInstruction> = enterFrameTrait.funcOrMethod.body.instructions;

            var iLocal:uint = 0xFFFFFFFF;

            for (var i:uint = 0; i < instructions.length; i++)
            {
                var instr:ASInstruction = instructions[i];
                if (instructions[i].opcode == ASInstruction.OP_pushbyte)
                {
                    iLocal = instructions[GCFWCoreMod.nextNotDebug(instructions, i)].localIndex();
                    break;
                }
            }

            if (iLocal == 0xFFFFFFFF)
            {
                throw new Error("Could not find the index of the loop variable in doEnterFrame");
            }

            for (i = 0; i < instructions.length; i++)
            {
                instr = instructions[i];
                if (instr.opcode == ASInstruction.OP_getproperty && (instr.args[0] as ASMultiname).name == "height")
                {
                    // First, add the IS_CHOOSING_KEYBIND check
                    var nextIfFalse:uint = i;
                    do
                    {
                        nextIfFalse = GCFWCoreMod.nextNotDebug(instructions, nextIfFalse);
                    }
                    while (instructions[nextIfFalse].opcode != ASInstruction.OP_iffalse);

                    var newDup:ASInstruction = ASInstruction.Dup();
                    var origIfFalse:ASInstruction = instructions[nextIfFalse];

                    for (var j:uint = i; j > 0; j--)
                    {
                        instr = instructions[j];
                        if (instr.opcode == ASInstruction.OP_iffalse)
                        {
                            origIfFalse = instr;
                            instr.args[0] = newDup;
                            break;
                        }
                    }

                    instructions.splice(nextIfFalse, 0,
                        newDup,
                        ASInstruction.IfFalse(instructions[nextIfFalse]),
                        ASInstruction.Pop(),
                        ASInstruction.GetLex(ASQName(PackageInternalNs("Bezel.GCFW"), "GCFWSettingsHandler")),
                        ASInstruction.GetProperty(ASQName(PackageInternalNs("Bezel.GCFW"), "IS_CHOOSING_KEYBIND")),
                        ASInstruction.Not()
                        );

                    var afterCheckColor:uint = 0xFFFFFFFF;

                    for (j = nextIfFalse; j < instructions.length; j++)
                    {
                        instr = instructions[j];
                        if (instr.opcode == ASInstruction.OP_callpropvoid && (instr.args[0] as ASMultiname).name == "gotoAndStop")
                        {
                            afterCheckColor = GCFWCoreMod.nextNotDebug(instructions, j);
                            break;
                        }
                    }

                    if (afterCheckColor == 0xFFFFFFFF)
                    {
                        throw new Error("Could not find place to wait for after checking color");
                    }

                    var ifFalseDoNotColorPlate:ASInstruction = ASInstruction.IfFalse(instructions[afterCheckColor]);

                    // Next, add the button/knob visibility check - after the just added IS_CHOOSING_KEYBIND check and the original iffalse
                    instructions.splice(nextIfFalse + 1 + 6, 0,
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
                        ASInstruction.GetProperty(ASQName(PackageNamespace(""), "btn")),
                        ASInstruction.GetProperty(ASQName(PackageNamespace(""), "parent")),
                        ASInstruction.PushNull(),
                        ASInstruction.Equals(),
                        ASInstruction.Not(),
                        ifFalseDoNotColorPlate
                        );

                    clazz.setInstanceTrait(enterFrameTrait);

                    return;
                }
            }

            throw new Error("Could not patch ScrOptions::doEnterPatch");
        }
    }
}
