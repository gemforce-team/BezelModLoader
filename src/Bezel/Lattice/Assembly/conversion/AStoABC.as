package Bezel.Lattice.Assembly.conversion {
    import Bezel.Lattice.Assembly.ABCFile;
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.ASMetadata;
    import Bezel.Lattice.Assembly.ASInstance;
    import Bezel.Lattice.Assembly.ASClass;
    import Bezel.Lattice.Assembly.ASValue;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.ABCTrait;
    import flash.utils.Dictionary;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.ABCNamespace;
    import Bezel.Lattice.Assembly.ABCMultiname;
    import Bezel.Lattice.Assembly.multiname.ABCQName;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.multiname.ABCRTQName;
    import Bezel.Lattice.Assembly.multiname.ABCRTQNameL;
    import Bezel.Lattice.Assembly.multiname.ABCMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ABCMultinameL;
    import Bezel.Lattice.Assembly.multiname.ABCTypeName;
    import Bezel.Lattice.Assembly.ABCMetadata;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ABCMethodInfo;
    import Bezel.Lattice.Assembly.ABCDefaultOption;
    import Bezel.Lattice.Assembly.ABCInstance;
    import Bezel.Lattice.Assembly.ABCClass;
    import Bezel.Lattice.Assembly.ABCScript;
    import Bezel.Lattice.Assembly.ABCMethodBody;
    import Bezel.Lattice.Assembly.ABCInstruction;
    import Bezel.Lattice.Assembly.ABCException;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;

    /**
     * ...
     * @author Chris
     */
    public class AStoABC extends ASVisitor {
        public var abc:ABCFile;

        public var ints:DataPool;
        public var uints:DataPool;
        public var doubles:DataPool;
        public var strings:DataPool;

        public var namespaces:DataPool; //Vector.<ASNamespace>;
        public var namespaceSets:DataPool; //Vector.<Vector.<ASNamespace>>;
        public var multinames:DataPool; //Vector.<ASMultiname>;
        public var methods:DataPool; //Vector.<ASMethod>;
        public var metadata:DataPool; //Vector.<ASMetadata>;
        public var classes:DataPool; //Vector.<ASClass>;

        public function AStoABC(asp:ASProgram) {
            super(asp);

            abc = new ABCFile();

            abc.minorVersion = asp.minorVersion;
            abc.majorVersion = asp.majorVersion;

            ints = new DataPool(int, true);
            uints = new DataPool(uint, true);
            doubles = new DataPool(Number, true);
            strings = new DataPool(String, true);
            namespaces = new DataPool(ASNamespace, true);
            namespaceSets = new DataPool(Vector.<ASNamespace>, true);
            multinames = new DataPool(ASMultiname, true);
            metadata = new DataPool(ASMetadata, false);
            classes = new DataPool(ASClass, false);
            methods = new DataPool(ASMethod, false);

            super.run();

            registerClassDependencies();
            registerMultinameDependencies();

            // dependencies get moved behind what they depend upon
            ints.finalize();
            uints.finalize();
            doubles.finalize();
            strings.finalize();
            namespaces.finalize();
            namespaceSets.finalize();
            multinames.finalize();
            metadata.finalize();
            classes.finalize();
            methods.finalize();

            abc.integers = Vector.<int>(ints.values);
            abc.uintegers = Vector.<uint>(uints.values);
            abc.doubles = Vector.<Number>(doubles.values);
            abc.strings = Vector.<String>(strings.values);

            for (var i:int = 1; i < namespaces.values.length; i++) {
                abc.namespaces[i] = new ABCNamespace((namespaces.values[i] as ASNamespace).type, strings.get((namespaces.values[i] as ASNamespace).name));
            }

            for (i = 1; i < namespaceSets.values.length; i++) {
                abc.ns_sets[i] = new Vector.<uint>();
                for (var j:int = 0; j < (namespaceSets.values[i] as Vector.<ASNamespace>).length; j++) {
                    abc.ns_sets[i][j] = namespaces.get((namespaceSets.values[i] as Vector.<ASNamespace>)[j]);
                }
            }

            for (i = 1; i < multinames.values.length; i++) {
                var multiname:ASMultiname = multinames.values[i] as ASMultiname;
                abc.multinames[i] = new ABCMultiname(multiname.type);
                switch (multiname.type) {
                    case ABCType.QName:
                    case ABCType.QNameA:
                        abc.multinames[i].subdata = new ABCQName(namespaces.get((multiname.subdata as ASQName).ns), strings.get((multiname.subdata as ASQName).name));
                        break;
                    case ABCType.RTQName:
                    case ABCType.RTQNameA:
                        abc.multinames[i].subdata = new ABCRTQName(strings.get((multiname.subdata as ASQName).name));
                        break;
                    case ABCType.RTQNameL:
                    case ABCType.RTQNameLA:
                        abc.multinames[i].subdata = new ABCRTQNameL();
                        break;
                    case ABCType.Multiname:
                    case ABCType.MultinameA:
                        abc.multinames[i].subdata = new ABCMultinameSubdata(strings.get((multiname.subdata as ASMultinameSubdata).name), namespaceSets.get((multiname.subdata as ASMultinameSubdata).ns_set));
                        break;
                    case ABCType.MultinameL:
                    case ABCType.MultinameLA:
                        abc.multinames[i].subdata = new ABCMultinameL(namespaceSets.get((multiname.subdata as ASMultinameSubdata).ns_set));
                        break;
                    case ABCType.TypeName:
                        abc.multinames[i].subdata = new ABCTypeName(multinames.get((multiname.subdata as ASTypeName).name), new Vector.<int>());
                        for (j = 0; j < (multiname.subdata as ASTypeName).params.length; j++) {
                            (abc.multinames[i].subdata as ABCTypeName).params[j] = multinames.get((multiname.subdata as ASTypeName).params[j]);
                        }
                        break;
                    default:
                        throw new Error("Unknown multiname type");
                }
            }

            for (i = 0; i < metadata.values.length; i++) {
                var data:ASMetadata = metadata.values[i] as ASMetadata;
                abc.metadata[i] = new ABCMetadata(strings.get(data.name), new Vector.<int>(), new Vector.<int>());
                for (j = 0; j < data.keys.length; j++) {
                    abc.metadata[i].keys.push(data.keys[j]);
                    abc.metadata[i].values.push(data.values[j]);
                }
            }

            var bodies:Vector.<ASMethodBody> = new Vector.<ASMethodBody>();

            for (i = 0; i < methods.values.length; i++) {
                var method:ASMethod = methods.values[i] as ASMethod;
                abc.methods[i] = new ABCMethodInfo(new Vector.<int>(), 0, 0, 0, new Vector.<ABCDefaultOption>(), new Vector.<int>());
                for (j = 0; j < method.paramTypes.length; j++) {
                    abc.methods[i][j] = multinames.get(method.paramTypes[j]);
                }
                abc.methods[i].returnType = multinames.get(method.returnType);
                abc.methods[i].name = strings.get(method.name);
                abc.methods[i].flags = method.flags;
                for (j = 0; j < method.options.length; j++) {
                    abc.methods[i].defaultOptions[j] = new ABCDefaultOption(getValueIndex(method.options[j]), method.options[j].type);
                }
                for (j = 0; j < method.paramNames.length; j++) {
                    abc.methods[i].parameterNames[j] = strings.get(method.paramNames[j]);
                }

                if (method.body != null) {
                    bodies.push(method.body);
                }
            }

            for (i = 0; i < classes.values.length; i++) {
                var instance:ASInstance = (classes.values[i] as ASClass).instance;

                abc.instances[i] = new ABCInstance(multinames.get(instance.name), multinames.get(instance.superName), instance.flags, namespaces.get(instance.protectedNs), new Vector.<int>(), methods.get(instance.iinit), convertTraits(instance.traits));
                for (j = 0; j < instance.interfaces.length; j++) {
                    abc.instances[i].interfaces[j] = multinames.get(instance.interfaces[j]);
                }
            }

            for (i = 0; i < classes.values.length; i++) {
                abc.classes[i] = new ABCClass(methods.get((classes.values[i] as ASClass).cinit), convertTraits((classes.values[i] as ASClass).traits));
            }

            for (i = 0; i < asp.scripts.length; i++) {
                abc.scripts[i] = new ABCScript(methods.get(asp.scripts[i].sinit), convertTraits(asp.scripts[i].traits));
            }

            for (i = 0; i < bodies.length; i++) {
                abc.methodBodies[i] = new ABCMethodBody(methods.get(bodies[i].method), bodies[i].maxStack, bodies[i].localCount, bodies[i].initScopeDepth, bodies[i].maxScopeDepth, new Vector.<ABCInstruction>(), new Vector.<ABCException>(), convertTraits(bodies[i].traits));

                for (j = 0; j < bodies[i].instructions.length; j++) {
                    abc.methodBodies[i].instructions[j] = convertInstruction(bodies[i].instructions[j]);
                }

                for (j = 0; j < bodies[i].exceptions.length; j++) {
                    abc.methodBodies[i].exceptions[j] = new ABCException(bodies[i].exceptions[j].from, bodies[i].exceptions[j].to, bodies[i].exceptions[j].target, multinames.get(bodies[i].exceptions[j].exceptionType), multinames.get(bodies[i].exceptions[j].varName));
                }
            }
        }

        public override function visitInt(v:int):void {
            ints.add(v);
        }

        public override function visitUint(v:uint):void {
            uints.add(v);
        }

        public override function visitDouble(v:Number):void {
            doubles.add(v);
        }

        public override function visitString(v:String):void {
            strings.add(v);
        }

        public override function visitNamespace(v:ASNamespace):void {
            if (namespaces.add(v)) {
                super.visitNamespace(v);
            }
        }

        public override function visitNamespaceSet(v:Vector.<ASNamespace>):void {
            if (namespaceSets.add(v)) {
                super.visitNamespaceSet(v);
            }
        }

        public override function visitMultiname(v:ASMultiname):void {
            if (multinames.notAdded(v)) {
                super.visitMultiname(v);
                if (!multinames.add(v)) {
                    throw new Error("Recursive multiname reference");
                }
            }
        }

        public override function visitMetadata(v:ASMetadata):void {
            if (metadata.add(v)) {
                super.visitMetadata(v);
            }
        }

        public override function visitClass(v:ASClass):void {
            if (classes.add(v)) {
                super.visitClass(v);
            }
        }

        public override function visitMethod(v:ASMethod):void {
            if (methods.add(v)) {
                super.visitMethod(v);
            }
        }

        public function getValueIndex(v:ASValue):uint {
            switch (v.type) {
                case ABCType.Integer:
                    return ints.get(v.data as int);
                case ABCType.UInteger:
                    return uints.get(v.data as uint);
                case ABCType.Double:
                    return doubles.get(v.data as Number);
                case ABCType.Utf8:
                    return strings.get(v.data as String);
                case ABCType.Namespace:
                case ABCType.PackageNamespace:
                case ABCType.PackageInternalNs:
                case ABCType.ProtectedNamespace:
                case ABCType.ExplicitNamespace:
                case ABCType.StaticProtectedNs:
                case ABCType.PrivateNamespace:
                    return namespaces.get(v.data as ASNamespace);
                case ABCType.True:
                case ABCType.False:
                case ABCType.Null:
                case ABCType.Undefined:
                    return v.type.val; // must be non-zero for True/False/Null
                default:
                    throw new Error("Unknown type");
            }
        }

        private function registerClassDependencies():void {
            var classesByName:Dictionary = new Dictionary();

            var origs:Array = classes.getPreliminaryValues();
            for each (var c:ASClass in origs) {
                classesByName[c.instance.name] = c;
            }

            for each (c in origs) {
                for each (var dependency:ASMultiname in new Array(c.instance.superName).concat(c.instance.interfaces)) {
                    if (dependency != null) {
                        for each (var dependencyName:ASMultiname in dependency.toQNames()) {
                            for (var i:ASMultiname in classesByName) {
                                if (i != null && i.equals(dependencyName)) {
                                    classes.registerDependency(c, classesByName[i]);
                                }
                            }
                        }
                    }
                }
            }
        }

        private function registerMultinameDependencies():void {
            for each (var m:ASMultiname in multinames.getPreliminaryValues()) {
                if (m.type == ABCType.TypeName) {
                    multinames.registerDependency(m, (m.subdata as ASTypeName).name);
                    for each (var t:ASMultiname in(m.subdata as ASTypeName).params) {
                        if (t != null) {
                            multinames.registerDependency(m, t);
                        }
                    }
                }
            }
        }

        private function convertTraits(traits:Vector.<ASTrait>):Vector.<ABCTrait> {
            var ret:Vector.<ABCTrait> = new Vector.<ABCTrait>();

            for each (var trait:ASTrait in traits) {
                var abcTrait:ABCTrait = new ABCTrait();
            }

            return ret;
        }

        private function convertInstruction(instruction:ASInstruction):ABCInstruction {
            var ret:ABCInstruction = new ABCInstruction(instruction.opcode, new Array());

            for (var i:int = 0; i < instruction.opcode.arguments.length; i++) {
                switch (instruction.opcode.arguments[i]) {
                    case OpcodeArgumentType.Unknown:
                        throw new Error("Don't know how to convert OP_" + instruction.opcode.name);

                    case OpcodeArgumentType.ByteLiteral:
                    case OpcodeArgumentType.UByteLiteral:
                    case OpcodeArgumentType.IntLiteral:
                    case OpcodeArgumentType.UIntLiteral:
                        ret.arguments[i] = instruction.arguments[i];
                        break;

                    case OpcodeArgumentType.Int:
                        ret.arguments[i] = ints.get(instruction.arguments[i]);
                        break;
                    case OpcodeArgumentType.UInt:
                        ret.arguments[i] = uints.get(instruction.arguments[i]);
                        break;
                    case OpcodeArgumentType.Double:
                        ret.arguments[i] = doubles.get(instruction.arguments[i]);
                        break;
                    case OpcodeArgumentType.String:
                        ret.arguments[i] = strings.get(instruction.arguments[i]);
                        break;
                    case OpcodeArgumentType.Namespace:
                        ret.arguments[i] = namespaces.get(instruction.arguments[i]);
                        break;
                    case OpcodeArgumentType.Class:
                        if (instruction.arguments[i] == null) {
                            ret.arguments[i] = abc.classes.length;
                        } else {
                            ret.arguments[i] = classes.get(instruction.arguments[i]);
                        }
                        break;
                    case OpcodeArgumentType.Method:
                        if (instruction.arguments[i] == null) {
                            ret.arguments[i] = abc.methods.length;
                        } else {
                            ret.arguments[i] = methods.get(instruction.arguments[i]);
                        }
                        break;
                    case OpcodeArgumentType.JumpTarget:
                    case OpcodeArgumentType.SwitchDefaultTarget:
                    case OpcodeArgumentType.SwitchTargets:
                        ret.arguments[i] = instruction.arguments[i];
                        break;
                }
            }

            return ret;
        }
    }
}
