package Bezel.Lattice.Assembly.conversion {
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.multiname.ASRTQName;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameL;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Lattice.Assembly.ASMetadata;
    import Bezel.Lattice.Assembly.ASValue;
    import Bezel.Lattice.Assembly.ASClass;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;
    import Bezel.Lattice.Assembly.ASException;
    import Bezel.Lattice.Assembly.ASInstance;

    /**
     * ...
     * @author Chris
     */
    public class ASVisitor extends ASTraitsVisitor {
        public function ASVisitor(asp:ASProgram) {
            super(asp);
        }

        public function visitInt(v:int):void {
        }

        public function visitUint(v:uint):void {
        }

        public function visitDouble(v:Number):void {
        }

        public function visitString(v:String):void {
        }

        public function visitNamespace(ns:ASNamespace):void {
            if (ns != null) {
                visitString(ns.name);
            }
        }

        public function visitNamespaceSet(nsSet:Vector.<ASNamespace>):void {
            for each (var ns:ASNamespace in nsSet) {
                visitNamespace(ns);
            }
        }

        public function visitMultiname(multiname:ASMultiname):void {
            if (multiname != null) {
                switch (multiname.type) {
                    case ABCType.QName:
                    case ABCType.QNameA:
                        visitNamespace((multiname.subdata as ASQName).ns);
                        visitString((multiname.subdata as ASQName).name);
                        break;
                    case ABCType.RTQName:
                    case ABCType.RTQNameA:
                        visitString((multiname.subdata as ASRTQName).name);
                        break;
                    case ABCType.RTQNameL:
                    case ABCType.RTQNameLA:
                        break;
                    case ABCType.Multiname:
                    case ABCType.MultinameA:
                        visitString((multiname.subdata as ASMultinameSubdata).name);
                        visitNamespaceSet((multiname.subdata as ASMultinameSubdata).ns_set);
                        break;
                    case ABCType.MultinameL:
                    case ABCType.MultinameLA:
                        visitNamespaceSet((multiname.subdata as ASMultinameL).ns_set);
                        break;
                    case ABCType.TypeName:
                        visitMultiname((multiname.subdata as ASTypeName).name);
                        for each (var param:ASMultiname in(multiname.subdata as ASTypeName).params) {
                            visitMultiname(param);
                        }
                        break;
                    default:
                        throw new Error("Unknown multiname type");
                }
            }
        }

        public function visitScript(script:ASScript):void {
            if (script != null) {
                visitTraits(script.traits);
                visitMethod(script.sinit);
            }
        }

        public override function visitTrait(trait:ASTrait):void {
            visitMultiname(trait.name);
            switch (trait.type) {
                case TraitType.Slot:
                case TraitType.Const:
                    visitMultiname((trait.extraData as ASTraitSlot).typeName);
                    if ((trait.extraData as ASTraitSlot).value != null) {
                        visitValue((trait.extraData as ASTraitSlot).value);
                    }
                    break;
                case TraitType.Class:
                    visitClass((trait.extraData as ASTraitClass).classv);
                    break;
                case TraitType.Function:
                    visitMethod((trait.extraData as ASTraitFunction).functionv);
                    break;
                case TraitType.Method:
                case TraitType.Getter:
                case TraitType.Setter:
                    visitMethod((trait.extraData as ASTraitMethod).method);
                    break;
                default:
                    throw new Error("Unknown trait type");
            }
            for each (var metadata:ASMetadata in trait.metadata) {
                visitMetadata(metadata);
            }
        }

        public function visitMetadata(metadata:ASMetadata):void {
            if (metadata != null) {
                visitString(metadata.name);
                for (var i:int = 0; i < metadata.keys.length; i++) {
                    visitString(metadata.keys[i]);
                    visitString(metadata.values[i]);
                }
            }
        }

        public function visitValue(value:ASValue):void {
            switch (value.type) {
                case ABCType.Integer:
                    visitInt(value.data as int);
                    break;
                case ABCType.UInteger:
                    visitUint(value.data as uint);
                    break;
                case ABCType.Double:
                    visitDouble(value.data as Number);
                    break;
                case ABCType.Utf8:
                    visitString(value.data as String);
                    break;
                case ABCType.Namespace:
                case ABCType.PackageNamespace:
                case ABCType.PackageInternalNs:
                case ABCType.ProtectedNamespace:
                case ABCType.ExplicitNamespace:
                case ABCType.StaticProtectedNs:
                case ABCType.PrivateNamespace:
                    visitNamespace(value.data as ASNamespace);
                    break;
                case ABCType.True:
                case ABCType.False:
                case ABCType.Null:
                case ABCType.Undefined:
                    break;
                default:
                    throw new Error("Unknown value type");
            }
        }

        public function visitClass(clazz:ASClass):void {
            if (clazz != null) {
                visitMethod(clazz.cinit);
                visitTraits(clazz.traits);
                visitInstance(clazz.instance);
            }
        }

        public function visitMethod(method:ASMethod):void {
            if (method != null) {
                for each (var paramType:ASMultiname in method.paramTypes) {
                    visitMultiname(paramType);
                }
                visitMultiname(method.returnType);
                visitString(method.name);
                for each (var option:ASValue in method.options) {
                    visitValue(option);
                }
                for each (var name:String in method.paramNames) {
                    visitString(name);
                }

                if (method.body != null) {
                    visitMethodBody(method.body);
                }
            }
        }

        public function visitMethodBody(body:ASMethodBody):void {
            if (body != null) {
                for each (var instruction:ASInstruction in body.instructions) {
                    for (var i:int = 0; i < instruction.arguments.length; i++) {
                        switch (instruction.opcode.arguments[i]) {
                            case OpcodeArgumentType.Unknown:
                                throw new Error("Don't know how to visit instruction OP_" + instruction.opcode.name);

                            case OpcodeArgumentType.ByteLiteral:
                            case OpcodeArgumentType.UByteLiteral:
                            case OpcodeArgumentType.IntLiteral:
                            case OpcodeArgumentType.UIntLiteral:
                                break;

                            case OpcodeArgumentType.Int:
                                visitInt(instruction.arguments[i] as int);
                                break;
                            case OpcodeArgumentType.UInt:
                                visitUint(instruction.arguments[i] as uint);
                                break;
                            case OpcodeArgumentType.Double:
                                visitDouble(instruction.arguments[i] as Number);
                                break;
                            case OpcodeArgumentType.String:
                                visitString(instruction.arguments[i] as String);
                                break;
                            case OpcodeArgumentType.Namespace:
                                visitNamespace(instruction.arguments[i] as ASNamespace);
                                break;
                            case OpcodeArgumentType.Multiname:
                                visitMultiname(instruction.arguments[i] as ASMultiname);
                                break;
                            case OpcodeArgumentType.Class:
                                visitClass(instruction.arguments[i] as ASClass);
                                break;
                            case OpcodeArgumentType.Method:
                                visitMethod(instruction.arguments[i] as ASMethod);
                                break;

                            case OpcodeArgumentType.JumpTarget:
                            case OpcodeArgumentType.SwitchDefaultTarget:
                            case OpcodeArgumentType.SwitchTargets:
                                break;
                        }
                    }
                }

                for each (var exception:ASException in body.exceptions) {
                    visitMultiname(exception.exceptionType);
                    visitMultiname(exception.varName);
                }

                visitMethod(body.method);
                visitTraits(body.traits);
            }
        }

        public function visitInstance(instance:ASInstance):void {
            if (instance != null) {
                visitMultiname(instance.name);
                visitMultiname(instance.superName);
                visitNamespace(instance.protectedNs);
                for each (var iface:ASMultiname in instance.interfaces) {
                    visitMultiname(iface);
                }
                visitMethod(instance.iinit);
                visitTraits(instance.traits);
            }
        }

        public override function run():void {
            for each (var script:ASScript in asp.scripts) {
                visitScript(script);
            }
            for each (var clazz:ASClass in asp.orphanClasses) {
                visitClass(clazz);
            }
            for each (var method:ASMethod in asp.orphanMethods) {
                visitMethod(method);
            }
        }
    }
}
