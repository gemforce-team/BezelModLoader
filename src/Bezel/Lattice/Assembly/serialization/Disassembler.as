package Bezel.Lattice.Assembly.serialization
{
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.serialization.context.RefBuilder;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.multiname.ASRTQName;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameL;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.values.TraitAttributes;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Lattice.Assembly.ASMetadata;
    import Bezel.Lattice.Assembly.ASValue;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.values.MethodFlags;
    import Bezel.Lattice.Assembly.ASClass;
    import Bezel.Lattice.Assembly.ASInstance;
    import Bezel.Lattice.Assembly.values.InstanceFlags;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.InstructionLabel;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ASException;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;
    import Bezel.Lattice.Assembly.Opcode;

    /**
     * ...
     * @author Chris
     */
    public class Disassembler
    {
        private var strings:Object;
        private var asp:ASProgram;
        private var refs:RefBuilder;

        public function Disassembler(asp:ASProgram)
        {
            this.strings = new Object();
            this.asp = asp;
        }

        public function newInclude(mainsb:StringBuilder, filename:String, callback:Function, doInline:Boolean = true):void
        {
            if (doInline)
            {
                var sb:StringBuilder = new StringBuilder(filename);
                callback(sb);
                sb.save(strings);

                mainsb.put("#include ");
                dumpString(mainsb, filename);
                mainsb.newLine();
            }
            else
            {
                callback(mainsb);
            }
        }

        // String[string]
        public function disassemble():Object
        {
            refs = new RefBuilder(asp);
            refs.run();

            var sb:StringBuilder = new StringBuilder("main.asasm");

            sb.put("#version 4");
            sb.newLine();

            sb.put("program");
            sb.newLine();

            sb.put("minorversion " + asp.minorVersion);
            sb.newLine();
            sb.put("majorversion " + asp.majorVersion);
            sb.newLine();
            sb.newLine();

            for (var i:int = 0; i < asp.scripts.length; i++)
            {
                newInclude(sb, refs.scripts.getFilename(asp.scripts[i], "script"), function(sb:StringBuilder):void {
                    dumpScript(sb, asp.scripts[i], i);
                });
            }
            sb.newLine();

            if (asp.orphanClasses.length != 0)
            {
                sb.put("; ============================= Orphan classes ==============================");
                sb.newLine();
                sb.newLine();

                for (i = 0; i < asp.orphanClasses.length; i++)
                {
                    newInclude(sb, refs.objects.getFilename(asp.orphanClasses[i], "class"), function(sb:StringBuilder):void {
                        dumpClass(sb, asp.orphanClasses[i]);
                    });
                }

                sb.newLine();
            }

            if (asp.orphanMethods.length != 0)
            {
                sb.put("; ============================= Orphan methods ==============================");
                sb.newLine();
                sb.newLine();

                for (i = 0; i < asp.orphanMethods.length; i++)
                {
                    newInclude(sb, refs.objects.getFilename(asp.orphanMethods[i], "method"), function(sb:StringBuilder):void {
                        dumpMethod(sb, asp.orphanMethods[i], "method");
                    });
                }

                sb.newLine();
            }

            sb.put("end ; program");
            sb.newLine();

            sb.save(strings);

            return this.strings;
        }

        private function dumpInt(sb:StringBuilder, v:int):void
        {
            sb.put(v.toString());
        }

        private function dumpUInt(sb:StringBuilder, v:uint):void
        {
            sb.put(v.toString());
        }

        private function dumpDouble(sb:StringBuilder, v:Number):void
        {
            if (isNaN(v))
            {
                sb.put("nan");
            }
            else if (v == Number.NEGATIVE_INFINITY)
            {
                sb.put("-inf");
            }
            else if (v == Number.POSITIVE_INFINITY)
            {
                sb.put("inf");
            }
            else
            {
                // TODO: check that this doesn't have issues
                sb.put(v.toString());
            }
        }

        private function dumpString(sb:StringBuilder, str:String):void
        {
            if (str == null)
            {
                sb.put("null");
            }
            else
            {
                sb.put("\"");
                
                for (var i:int = 0; i < str.length; i++)
                {
                    if (str.charAt(i) == "\n")
                    {
                        sb.put("\\n");
                    }
                    else if (str.charAt(i) == "\r")
                    {
                        sb.put("\\r");
                    }
                    else if (str.charAt(i) == "\\")
                    {
                        sb.put("\\\\");
                    }
                    else if (str.charAt(i) == "\"")
                    {
                        sb.put("\\\"");
                    }
                    else if (str.charCodeAt(i) < 0x20)
                    {
                        var addMe:String = str.charCodeAt(i).toString(16);
                        if (addMe.length < 2)
                        {
                            addMe = "0" + addMe;
                        }
                        sb.put("\\x" + addMe);
                    }
                    else
                    {
                        sb.put(str.charAt(i));
                    }
                }

                sb.put("\"");
            }
        }

        private function dumpNamespace(sb:StringBuilder, ns:ASNamespace):void
        {
            if (ns == null)
            {
                sb.put("null");
            }
            else
            {
                sb.put(ns.type.name);
                sb.put("(");
                dumpString(sb, ns.name);
                if (refs.hasHomonyms(ns))
                {
                    sb.put(", ");
                    dumpString(sb, refs.namespaces[ns.type.val].getName(ns.uniqueId));
                }
                sb.put(")");
            }
        }

        private function dumpNamespaceSet(sb:StringBuilder, set:Vector.<ASNamespace>):void
        {
            if (set == null)
            {
                sb.put("null");
            }
            else
            {
                sb.put("[");
                for (var i:int = 0; i < set.length; i++)
                {
                    dumpNamespace(sb, set[i]);
                    if (i < set.length-1)
                    {
                        sb.put(", ");
                    }
                }
                sb.put("]");
            }
        }

        private function dumpMultiname(sb:StringBuilder, multiname:ASMultiname):void
        {
            if (multiname == null)
            {
                sb.put("null");
            }
            else
            {
                sb.put(multiname.type.name);
                sb.put("(");
                switch (multiname.type)
                {
                    case ABCType.QName:
                    case ABCType.QNameA:
                        dumpNamespace(sb, (multiname.subdata as ASQName).ns);
                        sb.put(", ");
                        dumpString(sb, (multiname.subdata as ASQName).name);
                        break;
                    case ABCType.RTQName:
                    case ABCType.RTQNameA:
                        dumpString(sb, (multiname.subdata as ASRTQName).name);
                        break;
                    case ABCType.RTQNameL:
                    case ABCType.RTQNameLA:
                        break;
                    case ABCType.Multiname:
                    case ABCType.MultinameA:
                        dumpString(sb, (multiname.subdata as ASMultinameSubdata).name);
                        sb.put(", ");
                        dumpNamespaceSet(sb, (multiname.subdata as ASMultinameSubdata).ns_set);
                        break;
                    case ABCType.MultinameL:
                    case ABCType.MultinameLA:
                        dumpNamespaceSet(sb, (multiname.subdata as ASMultinameL).ns_set);
                        break;
                    case ABCType.TypeName:
                        var typename:ASTypeName = multiname.subdata as ASTypeName;
                        dumpMultiname(sb, typename.name);
                        sb.put("<");
                        for (var i:int = 0; i < typename.params.length; i++)
                        {
                            dumpMultiname(sb, typename.params[i]);
                            if (i < typename.params.length - 1)
                            {
                                sb.put(", ");
                            }
                        }
                        sb.put(">");
                        break;
                    default:
                        throw new Error("Unknown multiname type");
                }
                sb.put(")");
            }
        }

        private function dumpTraits(sb:StringBuilder, traits:Vector.<ASTrait>, inScript:Boolean = false):void
        {
            for each (var trait:ASTrait in traits)
            {
                sb.put("trait ");
                sb.put(trait.type.name);
                sb.put(" ");
                dumpMultiname(sb, trait.name);
                if (trait.attributes != 0)
                {
                    dumpFlags(true, sb, trait.attributes, TraitAttributes.names);
                }
                var inLine:Boolean = false;
                switch (trait.type)
                {
                    case TraitType.Slot:
                    case TraitType.Const:
                        var slot:ASTraitSlot = trait.extraData as ASTraitSlot;
                        if (slot.slotId != 0)
                        {
                            sb.put(" slotid ");
                            dumpUInt(sb, slot.slotId);
                        }
                        if (slot.typeName != null)
                        {
                            sb.put(" type ");
                            dumpMultiname(sb, slot.typeName);
                        }
                        if (slot.value.type != ABCType.Undefined)
                        {
                            sb.put(" value ");
                            dumpValue(sb, slot.value);
                        }
                        inLine = true;
                        break;
                    case TraitType.Class:
                        var clazz:ASTraitClass = trait.extraData as ASTraitClass;
                        if (clazz.slotId != 0)
                        {
                            sb.put(" slotid ");
                            dumpUInt(sb, clazz.slotId);
                        }
                        sb.newLine();

                        newInclude(sb, refs.objects.getFilename(clazz.classv, "class"), function(sb:StringBuilder):void {
                            dumpClass(sb, clazz.classv);
                        });
                        break;
                    case TraitType.Function:
                        var func:ASTraitFunction = trait.extraData as ASTraitFunction;
                        if (func.slotId != 0)
                        {
                            sb.put(" slotid ");
                            dumpUInt(sb, func.slotId);
                        }
                        sb.newLine();
                        newInclude(sb, refs.objects.getFilename(func.functionv, "method"), function(sb:StringBuilder):void {
                            dumpMethod(sb, func.functionv, "method");
                        }, inScript);
                        break;
                    case TraitType.Method:
                    case TraitType.Getter:
                    case TraitType.Setter:
                        var method:ASTraitMethod = trait.extraData as ASTraitMethod;
                        if (method.slotId != 0)
                        {
                            sb.put(" dispid ");
                            dumpUInt(sb, method.slotId);
                        }
                        sb.newLine();
                        newInclude(sb, refs.objects.getFilename(method.method, "method"), function(sb:StringBuilder):void {
                            dumpMethod(sb, method.method, "method");
                        }, inScript);
                        break;
                    default:
                        throw new Error("Unknown trait type");
                }

                for each (var metadata:ASMetadata in trait.metadata)
                {
                    if (inLine)
                    {
                        sb.newLine();
                        inLine = false;
                    }
                    dumpMetadata(sb, metadata);
                }

                if (inLine)
                {
                    sb.put(" end");
                    sb.newLine();
                }
                else
                {
                    sb.put("end ; trait");
                    sb.newLine();
                }
            }
        }

        private function dumpMetadata(sb:StringBuilder, metadata:ASMetadata):void
        {
            sb.put("metadata ");
            dumpString(sb, metadata.name);
            sb.newLine();
            if (metadata.keys.length != metadata.values.length) throw new Error("Metadata key/value numbers do not match");
            for (var i:int = 0; i < metadata.keys.length; i++)
            {
                sb.put("item ");
                dumpString(sb, metadata.keys[i]);
                sb.put(" ");
                dumpString(sb, metadata.values[i]);
                sb.newLine();
            }
            sb.put("end ; metadata");
            sb.newLine();
        }

        private function dumpFlags(oneLine:Boolean, sb:StringBuilder, flags:uint, names:Vector.<String>):void
        {
            for (var i:int = 0; flags != 0; i++, flags >>= 1)
            {
                if ((flags & 1) != 0)
                {
                    if (oneLine)
                    {
                        sb.put(" flag ");
                    }
                    else
                    {
                        sb.put("flag ");
                    }
                    sb.put(names[i]);
                    if (!oneLine)
                    sb.newLine();
                }
            }
        }

        private function dumpValue(sb:StringBuilder, value:ASValue):void
        {
            sb.put(value.type.name);
            sb.put("(");
            switch (value.type)
            {
                case ABCType.Integer:
                    dumpInt(sb, value.data as int);
                    break;
                case ABCType.UInteger:
                    dumpUInt(sb, value.data as uint);
                    break;
                case ABCType.Double:
                    dumpDouble(sb, value.data as Number);
                    break;
                case ABCType.Utf8:
                    dumpString(sb, value.data as String);
                    break;
                case ABCType.Namespace:
                case ABCType.PackageNamespace:
                case ABCType.PackageInternalNs:
                case ABCType.ProtectedNamespace:
                case ABCType.ExplicitNamespace:
                case ABCType.StaticProtectedNs:
                case ABCType.PrivateNamespace:
                    dumpNamespace(sb, value.data as ASNamespace);
                    break;
                case ABCType.True:
                case ABCType.False:
                case ABCType.Null:
                case ABCType.Undefined:
                    break;
                default:
                    throw new Error("Unknown value type");
            }

            sb.put(")");
        }

        private function dumpMethod(sb:StringBuilder, method:ASMethod, label:String):void
        {
            sb.put(label);
            sb.newLine();
            if (method.name != null)
            {
                sb.put("name ");
                dumpString(sb, method.name);
                sb.newLine();
            }
            var refName:String = refs.objects.getName(method);
            if (refName != null)
            {
                sb.put("refid ");
                dumpString(sb, refName);
                sb.newLine();
            }
            for each (var m:ASMultiname in method.paramTypes)
            {
                sb.put("param ");
                dumpMultiname(sb, m);
                sb.newLine();
            }
            if (method.returnType != null)
            {
                sb.put("returns ");
                dumpMultiname(sb, method.returnType);
                sb.newLine();
            }
            dumpFlags(false, sb, method.flags, MethodFlags.names);
            for each (var value:ASValue in method.options)
            {
                sb.put("optional ");
                dumpValue(sb, value);
                sb.newLine();
            }
            for each (var name:String in method.paramNames)
            {
                sb.put("paramname ");
                dumpString(sb, name);
                sb.newLine();
            }
            if (method.body != null)
            {
                dumpMethodBody(sb, method.body);
            }
            sb.put("end ; method");
            sb.newLine();
        }

        private function dumpClass(sb:StringBuilder, clazz:ASClass):void
        {
            sb.put("class");
            sb.newLine();

            var refName:String = refs.objects.getName(clazz);
            if (refName != null)
            {
                sb.put("refid ");
                dumpString(sb, refName);
                sb.newLine();
            }
            sb.put("instance ");
            dumpInstance(sb, clazz.instance);
            dumpMethod(sb, clazz.cinit, "cinit");
            dumpTraits(sb, clazz.traits);

            sb.put("end ; class");
            sb.newLine();
        }

        private function dumpInstance(sb:StringBuilder, instance:ASInstance):void
        {
            dumpMultiname(sb, instance.name);
            sb.newLine();
            if (instance.superName != null)
            {
                sb.put("extends ");
                dumpMultiname(sb, instance.superName);
                sb.newLine();
            }
            for each (var iface:ASMultiname in instance.interfaces)
            {
                sb.put("implements ");
                dumpMultiname(sb, iface);
                sb.newLine();
            }
            dumpFlags(false, sb, instance.flags, InstanceFlags.names);
            if (instance.protectedNs != null)
            {
                sb.put("protectedns ");
                dumpNamespace(sb, instance.protectedNs);
                sb.newLine();
            }
            dumpMethod(sb, instance.iinit, "iinit");
            dumpTraits(sb, instance.traits);
            sb.put("end ; instance");
            sb.newLine();
        }

        private function dumpScript(sb:StringBuilder, script:ASScript, index:uint):void
        {
            sb.put("script");
            sb.newLine();
            dumpMethod(sb, script.sinit, "sinit");
            dumpTraits(sb, script.traits, true);
            sb.put("end ; script");
            sb.newLine();
        }

        private function dumpUIntField(sb:StringBuilder, name:String, value:uint):void
        {
            sb.put(name);
            sb.put(" ");
            dumpUInt(sb, value);
            sb.newLine();
        }

        private function dumpLabel(sb:StringBuilder, label:InstructionLabel):void
        {
            sb.put("L");
            sb.put(label.index.toString());
            if (label.offset != 0)
            {
                if (label.offset > 0)
                {
                    sb.put("+");
                }
                sb.put(label.offset.toString());
            }
        }

        private function dumpMethodBody(sb:StringBuilder, body:ASMethodBody):void
        {
            sb.put("body");
            sb.newLine();
            dumpUIntField(sb, "maxstack", body.maxStack);
            dumpUIntField(sb, "localcount", body.localCount);
            dumpUIntField(sb, "initscopedepth", body.initScopeDepth);
            dumpUIntField(sb, "maxscopedepth", body.maxScopeDepth);
            sb.put("code");
            sb.newLine();

            var labels:Vector.<Boolean> = new Vector.<Boolean>(body.instructions.length + 1, true);
            for each (var exception:ASException in body.exceptions)
            {
                labels[exception.from.index] = labels[exception.to.index] = labels[exception.target.index] = true;
            }

            dumpInstructions(sb, body.instructions, labels);

            sb.put("end ; code");
            sb.newLine();
            for each (exception in body.exceptions)
            {
                sb.put("try from ");
                dumpLabel(sb, exception.from);
                sb.put(" to ");
                dumpLabel(sb, exception.to);
                sb.put(" target ");
                dumpLabel(sb, exception.target);
                sb.put(" type ");
                dumpMultiname(sb, exception.exceptionType);
                sb.put(" name ");
                dumpMultiname(sb, exception.varName);
                sb.put(" end");
                sb.newLine();
            }
            dumpTraits(sb, body.traits);
            sb.put("end ; body");
            sb.newLine();
        }

        private function dumpInstructions(sb:StringBuilder, instructions:Vector.<ASInstruction>, labels:Vector.<Boolean>):void
        {
            for each (var instruction:ASInstruction in instructions)
            {
                for (var i:int = 0; i < instruction.opcode.arguments.length; i++)
                {
                    switch (instruction.opcode.arguments[i])
                    {
                        case OpcodeArgumentType.JumpTarget:
                        case OpcodeArgumentType.SwitchDefaultTarget:
                            labels[(instruction.arguments[i] as InstructionLabel).index] = true;
                            break;
                        case OpcodeArgumentType.SwitchTargets:
                            for each (var label:InstructionLabel in (instruction.arguments[i] as Vector.<InstructionLabel>))
                            {
                                labels[label.index] = true;
                            }
                    }
                }
            }

            function checkLabel(ii:uint):void
            {
                if (labels[ii])
                {
                    sb.put("L");
                    sb.put(ii.toString());
                    sb.put(":");
                    sb.newLine();
                }
            }

            var extraNewLine:Boolean = false;
            for (i = 0; i < instructions.length; i++)
            {
                instruction = instructions[i];
                if (extraNewLine)
                {
                    sb.newLine();
                }
                checkLabel(i);

                if (instruction.opcode == Opcode.OP_db)
                {
                    continue;
                }

                sb.put(instruction.opcode.name);
                if (instruction.opcode.arguments.length != 0)
                {
                    sb.put(" ");
                    for (var j:int = 0; j < instruction.opcode.arguments.length; j++)
                    {
                        switch (instruction.opcode.arguments[j])
                        {
                            case OpcodeArgumentType.Unknown:
                                throw new Error("Not known how to disassemble OP_" + instruction.opcode.name);

                            case OpcodeArgumentType.ByteLiteral:
                                sb.put((instruction.arguments[j] as int).toString());
                                break;
                            case OpcodeArgumentType.UByteLiteral:
                                sb.put((instruction.arguments[j] as uint).toString());
                                break;
                            case OpcodeArgumentType.IntLiteral:
                                sb.put((instruction.arguments[j] as int).toString());
                                break;
                            case OpcodeArgumentType.UIntLiteral:
                                sb.put((instruction.arguments[j] as uint).toString());
                                break;
                            
                            case OpcodeArgumentType.Int:
                                dumpInt(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.UInt:
                                dumpUInt(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.Double:
                                dumpDouble(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.String:
                                dumpString(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.Namespace:
                                dumpNamespace(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.Multiname:
                                dumpMultiname(sb, instruction.arguments[j]);
                                break;
                            case OpcodeArgumentType.Class:
                            case OpcodeArgumentType.Method:
                                if (instruction.arguments[j] == null)
                                {
                                    sb.put("null");
                                }
                                else
                                {
                                    dumpString(sb, refs.objects.getName(instruction.arguments[j]));
                                }
                                break;

                            case OpcodeArgumentType.JumpTarget:
                            case OpcodeArgumentType.SwitchDefaultTarget:
                                dumpLabel(sb, instruction.arguments[j]);
                                break;
                            
                            case OpcodeArgumentType.SwitchTargets:
                                sb.put("[");
                                for (var k:int = 0; k < instruction.arguments[j].length; k++)
                                {
                                    dumpLabel(sb, instruction.arguments[j][k]);
                                    if (k < instruction.arguments[j].length - 1)
                                    {
                                        sb.put(", ");
                                    }
                                }
                                sb.put("]");
                                break;
                        }

                        if (j < instruction.opcode.arguments.length - 1)
                        {
                            sb.put(", ");
                        }
                    }
                }
                sb.newLine();
            }
            checkLabel(instructions.length);
        }
    }
}
