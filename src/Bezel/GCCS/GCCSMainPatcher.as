package Bezel.GCCS
{
    import Bezel.Lattice.LatticePatcher;

    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMethod;
    import com.cff.anebe.ir.ASMethodBody;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageNamespace;
    import com.cff.anebe.ir.traits.TraitMethod;
    import com.cff.anebe.ir.traits.TraitSlot;

    internal class GCCSMainPatcher implements LatticePatcher
    {
        public function patchClass(clazz:ASClass):void
        {
            patchConstructor(clazz);
            addBezelVar(clazz);
        }

        // Both moves constructor logic to a new method
        private function patchConstructor(clazz:ASClass):void
        {
            var constructor:ASMethod = clazz.getConstructor();
            var initFromBezel:ASMethod = new ASMethod(null, ASQName(PackageNamespace(""), "void"), "com.giab.games.gccs.steam:Main/initFromBezel", constructor.flags, null, null, constructor.body);

            constructor.flags = new <String>[];
            constructor.body = new ASMethodBody(2, 1, 0, 1, new <ASInstruction>[
                    ASInstruction.GetLocal0(),
                    ASInstruction.PushScope(),
                    ASInstruction.GetLocal0(),
                    ASInstruction.FindPropStrict(ASQName(PackageNamespace("com.amanitadesign.steam"), "FRESteamWorks")),
                    ASInstruction.ConstructProp(ASQName(PackageNamespace("com.amanitadesign.steam"), "FRESteamWorks"), 0),
                    ASInstruction.InitProperty(ASQName(PackageNamespace(""), "steamworks")),
                    ASInstruction.GetLocal0(),
                    ASInstruction.ConstructSuper(0),
                    ASInstruction.ReturnVoid(),
                ]);
            clazz.setConstructor(constructor);

            var instructions:Vector.<ASInstruction> = initFromBezel.body.instructions;
            for (var i:int = 0; i < instructions.length; i++)
            {
                var instruction:ASInstruction = instructions[i];
                var deleteFrom:int;
                if (instruction.opcode == ASInstruction.OP_constructsuper)
                {
                    deleteFrom = GCCSCoreMod.prevNotDebug(instructions, i);
                    instructions.splice(deleteFrom, i - deleteFrom + 1);
                    i = deleteFrom - 1;
                }
                if (instruction.opcode == ASInstruction.OP_initproperty && (instruction.args[0] as ASMultiname).name == "steamworks")
                {
                    deleteFrom = GCCSCoreMod.prevNotDebug(instructions, GCCSCoreMod.prevNotDebug(instructions, GCCSCoreMod.prevNotDebug(instructions, i)));
                    instructions.splice(deleteFrom, i - deleteFrom + 1);
                    i = deleteFrom - 1;
                }
            }
            instructions.splice(instructions.length - 1, 0,
                ASInstruction.GetLocal0(),
                ASInstruction.PushNull(),
                ASInstruction.CallPropVoid(ASQName(PackageNamespace(""), "doEnterFramePreloader"), 1)
                );
            clazz.setInstanceTrait(TraitMethod(ASQName(PackageNamespace(""), "initFromBezel"), initFromBezel));
        }

        private function addBezelVar(clazz:ASClass):void
        {
            clazz.setInstanceTrait(TraitSlot(ASQName(PackageNamespace(""), "bezel"), ASQName(PackageNamespace("Bezel"), "Bezel")));
        }
    }
}
