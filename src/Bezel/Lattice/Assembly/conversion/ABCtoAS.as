package Bezel.Lattice.Assembly.conversion
{
    import Bezel.Lattice.Assembly.ABCFile;
    import Bezel.Lattice.Assembly.ABCInstruction;
    import Bezel.Lattice.Assembly.ABCTrait;
    import Bezel.Lattice.Assembly.ASClass;
    import Bezel.Lattice.Assembly.ASException;
    import Bezel.Lattice.Assembly.ASInstance;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.ASMetadata;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.ASValue;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;
    import Bezel.Lattice.Assembly.multiname.*;
    import Bezel.Lattice.Assembly.trait.ABCTraitClass;
    import Bezel.Lattice.Assembly.trait.ABCTraitFunction;
    import Bezel.Lattice.Assembly.trait.ABCTraitMethod;
    import Bezel.Lattice.Assembly.trait.ABCTraitSlot;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.values.TraitType;

    /**
     * ...
     * @author Chris
     */
    public class ABCtoAS
    {
        public var asp:ASProgram;
        public var abc:ABCFile;
        
        public var namespaces:Vector.<ASNamespace>;
        public var namespaceSets:Vector.<Vector.<ASNamespace>>;
        public var multinames:Vector.<ASMultiname>;
        public var methods:Vector.<ASMethod>;
        public var metadata:Vector.<ASMetadata>;
        public var instances:Vector.<ASInstance>;
        public var classes:Vector.<ASClass>;

        public var methodsAdded:Vector.<Boolean>;
        public var classesAdded:Vector.<Boolean>;
        
        public function ABCtoAS(abc:ABCFile)
        {
            this.abc = abc;
            asp = new ASProgram();

            namespaces = new Vector.<ASNamespace>(abc.namespaces.length, true);
            namespaceSets = new Vector.<Vector.<ASNamespace>>(abc.ns_sets.length, true);
            multinames = new Vector.<ASMultiname>(abc.multinames.length, true);
            methods = new Vector.<ASMethod>(abc.methods.length, true);
            metadata = new Vector.<ASMetadata>(abc.metadata.length, true);
            instances = new Vector.<ASInstance>(abc.instances.length, true);
            classes = new Vector.<ASClass>(abc.classes.length, true);

            methodsAdded = new Vector.<Boolean>(methods.length, true);
            classesAdded = new Vector.<Boolean>(classes.length, true);

            asp.minorVersion = abc.minorVersion;
            asp.majorVersion = abc.majorVersion;

            asp.scripts.length = abc.scripts.length;
            asp.scripts.fixed = true;
            
            for (var i:int = 1; i < abc.namespaces.length; i++)
            {
                namespaces[i] = new ASNamespace(abc.namespaces[i].type, abc.strings[abc.namespaces[i].name], i);
            }

            for (i = 1; i < abc.ns_sets.length; i++)
            {
                namespaceSets[i] = new Vector.<ASNamespace>(abc.ns_sets[i].length, true);
                for (var j:int = 0; j < namespaceSets[i].length; j++)
                {
                    namespaceSets[i][j] = namespaces[abc.ns_sets[i][j]];
                }
            }

            for (i = 1; i < abc.multinames.length; i++)
            {
                switch (abc.multinames[i].type)
                {
                    case ABCType.QName:
                    case ABCType.QNameA:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, new ASQName(namespaces[(abc.multinames[i].subdata as ABCQName).ns], abc.strings[(abc.multinames[i].subdata as ABCQName).name]));
                        break;
                    case ABCType.RTQName:
                    case ABCType.RTQNameA:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, new ASRTQName(abc.strings[(abc.multinames[i].subdata as ABCRTQName).name]));
                        break;
                    case ABCType.RTQNameL:
                    case ABCType.RTQNameLA:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, new ASRTQNameL());
                        break;
                    case ABCType.Multiname:
			        case ABCType.MultinameA:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, new ASMultinameSubdata(abc.strings[(abc.multinames[i].subdata as ABCMultinameSubdata).name], namespaceSets[(abc.multinames[i].subdata as ABCMultinameSubdata).ns_set]));
                        break;
                    case ABCType.MultinameL:
                    case ABCType.MultinameLA:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, new ASMultinameL(namespaceSets[(abc.multinames[i].subdata as ABCMultinameL).ns_set]));
                        break;
                    case ABCType.TypeName:
                        multinames[i] = new ASMultiname(abc.multinames[i].type, null);
                        break;
                    default:
                        throw new Error("Unknown multiname type");
                }
            }

            // Second pass for TypeNames
            for (i = 1; i < abc.multinames.length; i++)
            {
                if (abc.multinames[i].type == ABCType.TypeName)
                {
                    var tn:ABCTypeName = abc.multinames[i].subdata as ABCTypeName;
                    multinames[i].subdata = new ASTypeName(multinames[tn.name], new Vector.<ASMultiname>(tn.params.length, true));
                    for (j = 0; j < tn.params.length; j++)
                    {
                        (multinames[i].subdata as ASTypeName).params[j] = multinames[tn.params[j]];
                    }
                }
            }

            for (i = 0; i < methods.length; i++)
            {
                methods[i] = new ASMethod();
                methods[i].paramTypes = new Vector.<ASMultiname>(abc.methods[i].parameterTypes.length, true);
                for (j = 0; j < methods[i].paramTypes.length; j++)
                {
                    methods[i].paramTypes[j] = multinames[abc.methods[i].parameterTypes[j]];
                }
                methods[i].returnType = multinames[abc.methods[i].returnType];
                methods[i].name = abc.strings[abc.methods[i].name];
                methods[i].flags = abc.methods[i].flags;
                methods[i].options = new Vector.<ASValue>(abc.methods[i].defaultOptions.length, true);
                for (j = 0; j < methods[i].options.length; j++)
                {
                    methods[i].options[j] = convertValue(abc.methods[i].defaultOptions[j].type, abc.methods[i].defaultOptions[j].index);
                }
                methods[i].paramNames = new Vector.<String>(abc.methods[i].parameterNames.length, true);
                for (j = 0; j < methods[i].paramNames.length; j++)
                {
                    methods[i].paramNames[j] = abc.strings[abc.methods[i].parameterNames[j]];
                }
            }

            for (i = 0; i < metadata.length; i++)
            {
                metadata[i] = new ASMetadata();
                metadata[i].name = abc.strings[abc.metadata[i].name];
                metadata[i].keys = new Vector.<String>(abc.metadata[i].keys.length, true);
                for (j = 0; j < metadata[i].keys.length; j++)
                {
                    metadata[i].keys[j] = abc.strings[abc.metadata[i].keys[j]];
                }
                metadata[i].values = new Vector.<String>(abc.metadata[i].values.length, true);
                for (j = 0; j < metadata[i].values.length; j++)
                {
                    metadata[i].values[j] = abc.strings[abc.metadata[i].values[j]];
                }
            }

            for (i = 0; i < instances.length; i++)
            {
                instances[i] = new ASInstance();
                instances[i].name = multinames[abc.instances[i].name];
                instances[i].superName = multinames[abc.instances[i].superclassName];
                instances[i].flags = abc.instances[i].flags;
                instances[i].protectedNs = namespaces[abc.instances[i].protectedNs];
                instances[i].interfaces = new Vector.<ASMultiname>(abc.instances[i].interfaces.length, true);
                for (j = 0; j < instances[i].interfaces.length; j++)
                {
                    instances[i].interfaces[j] = multinames[abc.instances[i].interfaces[j]];
                }
                instances[i].iinit = methods[abc.instances[i].iinit];
                methodsAdded[abc.instances[i].iinit] = true;
                instances[i].traits = convertTraits(abc.instances[i].traits);
            }

            for (i = 0; i < classes.length; i++)
            {
                classes[i] = new ASClass();
                classes[i].cinit = methods[abc.classes[i].cinit];
                methodsAdded[abc.classes[i].cinit] = true;
                classes[i].traits = convertTraits(abc.classes[i].traits);
                classes[i].instance = instances[i];
            }

            for (i = 0; i < asp.scripts.length; i++)
            {
                asp.scripts[i] = new ASScript();
                asp.scripts[i].sinit = methods[abc.scripts[i].sinit];
                methodsAdded[abc.scripts[i].sinit] = true;
                asp.scripts[i].traits = convertTraits(abc.scripts[i].traits);
            }

            for (i = 0; i < abc.methodBodies.length; i++)
            {
                var body:ASMethodBody = new ASMethodBody();
                body.method = methods[abc.methodBodies[i].method];
                body.maxStack = abc.methodBodies[i].maxStack;
                body.localCount = abc.methodBodies[i].localCount;
                body.initScopeDepth = abc.methodBodies[i].initScopeDepth;
                body.maxScopeDepth = abc.methodBodies[i].maxScopeDepth;
                body.instructions = new Vector.<ASInstruction>(abc.methodBodies[i].instructions.length, true);
                for (j = 0; j < body.instructions.length; j++)
                {
                    body.instructions[j] = convertInstruction(abc.methodBodies[i].instructions[j]);
                }
                body.exceptions = new Vector.<ASException>(abc.methodBodies[i].exceptions.length, true);
                for (j = 0; j < body.exceptions.length; j++)
                {
                    body.exceptions[j] = new ASException(abc.methodBodies[i].exceptions[j].from, abc.methodBodies[i].exceptions[j].to, abc.methodBodies[i].exceptions[j].target, multinames[abc.methodBodies[i].exceptions[j].exceptionType], multinames[abc.methodBodies[i].exceptions[j].varName]);
                }
                body.traits = convertTraits(abc.methodBodies[i].traits);
                body.method.body = body;
            }

            for (i = 0; i < classesAdded.length; i++)
            {
                if (!classesAdded[i])
                {
                    asp.orphanClasses.push(classes[i]);
                }
            }
            asp.orphanClasses.fixed = true;

            for (i = 0; i < methodsAdded.length; i++)
            {
                if (!methodsAdded[i])
                {
                    asp.orphanMethods.push(methods[i]);
                }
            }
            asp.orphanMethods.fixed = true;
        }

        public function convertValue(type:ABCType, index:int):ASValue
        {
            var ret:ASValue = new ASValue();
            ret.type = type;
            switch (type)
            {
                    case ABCType.Integer:
                    ret.data = abc.integers[index];
                    break;
                case ABCType.UInteger:
                    ret.data = abc.uintegers[index];
                    break;
                case ABCType.Double:
                    ret.data = abc.doubles[index];
                    break;
                case ABCType.Utf8:
                    ret.data = abc.strings[index];
                    break;
                case ABCType.Namespace:
                case ABCType.PackageNamespace:
                case ABCType.PackageInternalNs:
                case ABCType.ProtectedNamespace:
                case ABCType.ExplicitNamespace:
                case ABCType.StaticProtectedNs:
                case ABCType.PrivateNamespace:
                    ret.data = namespaces[index];
                    break;
                case ABCType.True:
                case ABCType.False:
                case ABCType.Null:
                case ABCType.Undefined:
                    break;
                default:
                    throw new Error("Unknown type");
            }

            return ret;
        }

        public function convertTraits(traits:Vector.<ABCTrait>):Vector.<ASTrait>
        {
            var ret:Vector.<ASTrait> = new Vector.<ASTrait>(traits.length, true);
            for (var i:int = 0; i < ret.length; i++)
            {
                ret[i] = new ASTrait();
                ret[i].name = multinames[traits[i].name];
                ret[i].type = traits[i].type;
                ret[i].attributes = traits[i].attributes;
                switch (ret[i].type)
                {
                    case TraitType.Slot:
                    case TraitType.Const:
                    {
                        var slot:ABCTraitSlot = traits[i].extraData as ABCTraitSlot;
                        ret[i].extraData = new ASTraitSlot(slot.slotId, multinames[slot.typeName], convertValue(slot.valueType, slot.valueIndex));
                    }
                    break;
                    case TraitType.Class:
                    {
                        var clazz:ABCTraitClass = traits[i].extraData as ABCTraitClass;
                        ret[i].extraData = new ASTraitClass(clazz.slotId, classes[clazz.classi]);
                        classesAdded[clazz.classi] = true;
                    }
                    break;
                    case TraitType.Function:
                    {
                        var func:ABCTraitFunction = traits[i].extraData as ABCTraitFunction;
                        ret[i].extraData = new ASTraitFunction(func.slotId, methods[func.functioni]);
                        methodsAdded[func.functioni] = true;
                    }
                    break;
                    case TraitType.Method:
                    case TraitType.Getter:
                    case TraitType.Setter:
                    {
                        var method:ABCTraitMethod = traits[i].extraData as ABCTraitMethod;
                        ret[i].extraData = new ASTraitMethod(method.slotId, methods[method.methodi]);
                        methodsAdded[method.methodi] = true;
                    }
                    break;
                    default:
                        throw new Error("Unknown trait type");
                }
                ret[i].metadata = new Vector.<ASMetadata>(traits[i].metadata.length, true);
                for (var j:int = 0; j < ret[i].metadata.length; j++)
                {
                    ret[i].metadata[j] = metadata[traits[i].metadata[j]];
                }
            }

            return ret;
        }

        public function convertInstruction(instruction:ABCInstruction):ASInstruction
        {
            var ret:ASInstruction = new ASInstruction();
            ret.opcode = instruction.opcode;
            ret.arguments = new Array();
            for (var i:int = 0; i < instruction.arguments.length; i++)
            {
                switch (instruction.opcode.arguments[i])
                {
                    case OpcodeArgumentType.Unknown:
                    default:
                        throw new Error("Cannot convert instruction " + instruction.opcode.name);
                    
                    case OpcodeArgumentType.ByteLiteral:
                    case OpcodeArgumentType.UByteLiteral:
                    case OpcodeArgumentType.IntLiteral:
                    case OpcodeArgumentType.UIntLiteral:
                    case OpcodeArgumentType.JumpTarget:
                    case OpcodeArgumentType.SwitchDefaultTarget:
                    case OpcodeArgumentType.SwitchTargets:
                        ret.arguments[i] = instruction.arguments[i];
                        break;
                    
                    case OpcodeArgumentType.Int:
                        ret.arguments[i] = abc.integers[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.UInt:
                        ret.arguments[i] = abc.uintegers[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.Double:
                        ret.arguments[i] = abc.doubles[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.String:
                        ret.arguments[i] = abc.strings[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.Namespace:
                        ret.arguments[i] = namespaces[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.Multiname:
                        ret.arguments[i] = multinames[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.Class:
                        ret.arguments[i] = classes[instruction.arguments[i]];
                        break;
                    case OpcodeArgumentType.Method:
                        ret.arguments[i] = methods[instruction.arguments[i]];
                        break;
                }
            }

            return ret;
        }
    }
}
