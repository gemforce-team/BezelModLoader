package Bezel.Lattice.Assembly.serialization.context
{
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.serialization.ASTraitsVisitor;
    import Bezel.Lattice.Assembly.ASClass;
    import flash.utils.Dictionary;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameL;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;
    import Bezel.Logger;

    /**
     * ...
     * @author Chris
     */
    public class RefBuilder extends ASTraitsVisitor
    {
        // bool[uint][string][uint] -> Vector<Object[Vector<uint>]>
        // No good way to do an associative array on Objects
        private var homonyms:Vector.<Object>;
        CONFIG::debug
        private var homonymsBuilt:Boolean;

        public var context:Vector.<ContextItem>;

        public var namespaces:Vector.<ContextSet>;
        public var objects:ContextSet;
        public var scripts:ContextSet;

        // bool[void*] -> Dictionary of Booleans
        public var orphans:Dictionary;
        // bool[uint] -> Array of Booleans
        public var possibleOrphanPrivateNamespaces:Array;

        public function RefBuilder(asp:ASProgram)
        {
            super(asp);
            homonyms = new Vector.<Object>(0x1E, true);
            for (var i:int = 0; i < homonyms.length; i++)
            {
                homonyms[i] = new Object();
            }

            namespaces = new Vector.<ContextSet>(0x1E, true);
            for (i = 0; i < namespaces.length; i++)
            {
                namespaces[i] = new ContextSet(true);
            }
            objects = new ContextSet(false);
            scripts = new ContextSet(false);

            orphans = new Dictionary();

            context = new <ContextItem>[];
            possibleOrphanPrivateNamespaces = new Array();
        }

        public function isOrphan(i:*):Boolean
        {
            return i in orphans;
        }

        public function addOrphan(i:*):void
        {
            orphans[i] = true;
        }

        public function hasHomonyms(ns:ASNamespace):Boolean
        {
            CONFIG::debug{if (!homonymsBuilt) throw new Error("Homonymns not built");}
            return ns.name in homonyms[ns.type.val] && (homonyms[ns.type.val][ns.name] as Vector.<uint>).length > 1;
        }

        public function addHomonym(ns:ASNamespace):void
        {
            CONFIG::debug{if (homonymsBuilt) throw new Error("Homonymns already built");}
            if (!(ns.name in homonyms[ns.type.val]))
            {
                homonyms[ns.type.val][ns.name] = new <uint>[];
            }

            if (!homonyms[ns.type.val][ns.name].some(function(argType:uint, index:int, array:Vector.<uint>):Boolean {return argType == ns.uniqueId;}))
            {
                homonyms[ns.type.val][ns.name].push(ns.uniqueId);
            }
        }

        public override function run():void
        {
            for each (var clazz:ASClass in asp.orphanClasses)
            {
                addOrphan(clazz);
            }
            for each (var method:ASMethod in asp.orphanMethods)
            {
                addOrphan(method);
            }

            super.run();

            for (var i:int = 0; i < asp.scripts.length; i++)
            {
                var classContexts:Vector.<ContextItem> = new <ContextItem>[];

                for each (var trait:ASTrait in asp.scripts[i].traits)
                {
                    if (trait.name.type == ABCType.QName && (trait.name.subdata as ASQName).ns.type != ABCType.PrivateNamespace)
                    {
                        classContexts.push(ContextItem.fromMultiname(trait.name));
                    }
                }

                if (classContexts.length == 0)
                {
                    for each (trait in asp.scripts[i].traits)
                    {
                        classContexts.push(ContextItem.fromMultiname(trait.name));
                    }
                }

                context = new <ContextItem>[ContextItem.fromGroup(classContexts, "script_" + i)];
                scripts.add(asp.scripts[i], context, ContextSet.PRIORITY_Declaration);
                this.context.push(ContextItem.fromString("init", true));
                addMethod(asp.scripts[i].sinit, ContextSet.PRIORITY_Declaration);
                context = new <ContextItem>[];
            }

            for (i = 0; i < asp.orphanClasses.length; i++)
            {
                if (!objects.isAdded(asp.orphanClasses[i]))
                {
                    this.context.push(ContextItem.fromString("orphan_class_" + i));
                    addClass(asp.orphanClasses[i], ContextSet.PRIORITY_Orphan);
                    this.context.pop(); // orphan_class_<i>
                }
            }
            for (i = 0; i < asp.orphanMethods.length; i++)
            {
                if (!objects.isAdded(asp.orphanMethods[i]))
                {
                    this.context.push(ContextItem.fromString("orphan_method_" + i));
                    addMethod(asp.orphanMethods[i], ContextSet.PRIORITY_Orphan);
                    this.context.pop(); // orphan_method_<i>
                }
            }

            scripts.coagulate(this);

            for each (var script:ASScript in asp.scripts)
            {
                for each (trait in script.traits)
                {
                    if (trait.name.type == ABCType.QName)
                    {
                        namespaces[(trait.name.subdata as ASQName).ns.type.val].addIfNew((trait.name.subdata as ASQName).ns.uniqueId, scripts.getContext(this, script), ContextSet.PRIORITY_Declaration);
                    }
                }
            }

            for each (var id:uint in possibleOrphanPrivateNamespaces)
            {
                if (!namespaces[ABCType.PrivateNamespace.val].isAdded(id))
                {
                    this.context.push(ContextItem.fromString("orphan_namespace_" + id));
                    namespaces[ABCType.PrivateNamespace.val].add(id, context, ContextSet.PRIORITY_Orphan);
                    this.context.pop();
                }
            }

            CONFIG::debug{this.homonymsBuilt = true;}

            for each (var ns:ContextSet in namespaces)
            {
                ns.coagulate(this);
            }

            objects.coagulate(this);
        }

        public override function visitTrait(trait:ASTrait):void
        {
            var m:ASMultiname = trait.name;

            context.push(ContextItem.fromMultiname(m));
            visitMultiname(m, ContextSet.PRIORITY_Declaration);

            switch (trait.type)
            {
                case TraitType.Slot:
                case TraitType.Const:
                    visitMultiname((trait.extraData as ASTraitSlot).typeName, ContextSet.PRIORITY_Usage);

                    super.visitTrait(trait);
                    break;
                case TraitType.Class:
                    var classData:ASTraitClass = trait.extraData as ASTraitClass;
                    addClass(classData.classv, ContextSet.PRIORITY_Declaration);

                    context.push(ContextItem.fromString("class", true));
                    visitTraits(classData.classv.traits);
                    context.pop(); // class

                    context.push(ContextItem.fromString("instance", true));
                    visitTraits(classData.classv.instance.traits);
                    context.pop(); // instance
                    break;
                case TraitType.Function:
                    addMethod((trait.extraData as ASTraitFunction).functionv, ContextSet.PRIORITY_Declaration);
                    
                    super.visitTrait(trait);
                    break;
                case TraitType.Method:
                    addMethod((trait.extraData as ASTraitMethod).method, ContextSet.PRIORITY_Declaration);

                    super.visitTrait(trait);
                    break;
                case TraitType.Getter:
                    context.push(ContextItem.fromString("getter"));
                    addMethod((trait.extraData as ASTraitMethod).method, ContextSet.PRIORITY_Declaration);
                    context.pop(); // getter

                    super.visitTrait(trait);
                    break;
                case TraitType.Setter:
                    context.push(ContextItem.fromString("setter"));
                    addMethod((trait.extraData as ASTraitMethod).method, ContextSet.PRIORITY_Declaration);
                    context.pop(); // setter

                    super.visitTrait(trait);
                    break;
                default:
                    super.visitTrait(trait);
                    break;
            }

            context.pop(); // trait.name
        }

        public function visitNamespace(ns:ASNamespace, priority:int):void
        {
            if (ns == null) return;

            addHomonym(ns);

            if (context.length == 0) throw new Error("Empty context");

            var myPos:uint = context.length;
            for (var i:int in context)
            {
                var item:ContextItem = context[i];
                if (item.type == ContextItem.TYPE_Multiname && item.multiname.type == ABCType.QName && (item.multiname.subdata as ASQName).ns == ns)
                {
                    myPos = i;
                    break;
                }
            }

            if (ns.type == ABCType.PrivateNamespace && myPos == 0)
            {
                possibleOrphanPrivateNamespaces[ns.uniqueId] = true;
                return;
            }

            var myContext:Vector.<ContextItem> = context.slice(0, myPos);
            namespaces[ns.type.val].add(ns.uniqueId, myContext, priority);
        }

        public function visitNamespaceSet(nsSet:Vector.<ASNamespace>, priority:int):void
        {
            for each (var ns:ASNamespace in nsSet)
            {
                visitNamespace(ns, priority);
            }
        }

        public function visitMultiname(m:ASMultiname, priority:int):void
        {
            if (m == null) return;

            switch (m.type)
            {
                case ABCType.QName:
                case ABCType.QNameA:
                    visitNamespace((m.subdata as ASQName).ns, priority);
                    break;
                case ABCType.Multiname:
                case ABCType.MultinameA:
                    visitNamespaceSet((m.subdata as ASMultinameSubdata).ns_set, priority);
                    break;
                case ABCType.MultinameL:
                case ABCType.MultinameLA:
                    visitNamespaceSet((m.subdata as ASMultinameL).ns_set, priority);
                    break;
                case ABCType.TypeName:
                    var typeName:ASTypeName = m.subdata as ASTypeName;
                    visitMultiname(typeName.name, priority);
                    for each (var param:ASMultiname in typeName.params)
                    {
                        visitMultiname(param, priority);
                    }
                    break;
                default:
                    break;
            }
        }

        public function visitMethodBody(b:ASMethodBody):void
        {
            for each (var instruction:ASInstruction in b.instructions)
            {
                for (var i:int in instruction.opcode.arguments)
                {
                    switch (instruction.opcode.arguments[i])
                    {
                        case OpcodeArgumentType.Namespace:
                            visitNamespace(instruction.arguments[i] as ASNamespace, ContextSet.PRIORITY_Usage);
                            break;
                        case OpcodeArgumentType.Multiname:
                            visitMultiname(instruction.arguments[i] as ASMultiname, ContextSet.PRIORITY_Usage);
                            break;
                        case OpcodeArgumentType.Class:
                            context.push(ContextItem.fromString("inline_class"));
                            if (isOrphan(instruction.arguments[i]))
                            {
                                addClass(instruction.arguments[i] as ASClass, ContextSet.PRIORITY_Usage);
                            }
                            context.pop(); // inline_class
                            break;
                        case OpcodeArgumentType.Method:
                            context.push(ContextItem.fromString("inline_method"));
                            if (isOrphan(instruction.arguments[i]))
                            {
                                addMethod(instruction.arguments[i] as ASMethod, ContextSet.PRIORITY_Usage);
                            }
                            context.pop(); // inline_method
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        private static const reservedNames:Vector.<String> = new <String>["CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"];

        public function contextToString(context:Vector.<ContextItem>, filename:Boolean):String
        {
            var log:Logger = Logger.getLogger("RefBuilder");
            log.log("contextToString", "Original: " + context.toString());
            var expanded:Vector.<ContextItem> = ContextItem.expand(this, context);
            log.log("contextToString", "Expanded: " + expanded.toString());
            if (expanded.length == 0) return "";

            // NOT SURE BOUT THAT
            for (var i:int = expanded.length - 2; i >= 0; i--)
            {
                var root:Vector.<ContextItem> = ContextItem.deduplicate(expanded[i], expanded[i + 1]);

                if (root.length > 0)
                {
                    expanded = expanded.slice(0, i).concat(root, expanded.slice(i + 2));
                }
            }
            log.log("contextToString", "Deduplicated: " + expanded.toString());

            var segments:Vector.<Segment> = new <Segment>[];
            for each (var item:ContextItem in expanded)
            {
                segments = segments.concat(item.toSegments(this, filename));
            }

            log.log("contextToString", "Segments: " + segments.toString());

            function escape(s:String):String
            {
                if (!filename) return s;

                var result:String = "";
                for (var i:int = 0; i < s.length; i++)
                {
                    if (s.charAt(i) == '.' || s.charAt(i) == ':')
                        result += '/';
                    else if (s.charAt(i) == '\\' || s.charAt(i) == '*' || s.charAt(i) == '?' || s.charAt(i) == '"' || s.charAt(i) == '<' || s.charAt(i) == '>' || s.charAt(i) == '|' || s.charCodeAt(i) < 0x20 || s.charCodeAt(i) >= 0x7F || s.charAt(i) == ' ' || s.charAt(i) == '%')
                    {
                        var addMe:String = s.charCodeAt(i).toString(16).toUpperCase();
                        if (addMe.length < 2)
                        {
                            addMe = "0" + addMe;
                        }
                        result += "%" + addMe;
                    }
                    else
                    {
                        result += s.charAt(i);
                    }
                }

                var pathSegments:Array = result.split("/");
                if (pathSegments.length == 0) // Don't think this can happen but might as well guard
                {
                    pathSegments = [""];
                }

                for (i = 0; i < pathSegments.length; i++)
                {
                    if (pathSegments[i] == "")
                    {
                        pathSegments[i] = "%";
                    }

                    var pathSegmentU:String = (pathSegments[i] as String).toUpperCase();
                    for each (var reservedName:String in reservedNames)
                    {
                        if (pathSegmentU == reservedName || pathSegmentU.indexOf(reservedName + ".") == 0)
                        {
                            pathSegments[i] = "%" + pathSegments[i];
                        }
                    }

                    pathSegments[i] = (pathSegments[i] as String).slice(0, 240);
                }

                return pathSegments.join("/");
            }

            var strings:Vector.<String> = new Vector.<String>(segments.length, true);
            for (i = 0; i < segments.length; i++)
            {
                strings[i] = (i > 0 ? segments[i].delim : "") + escape(segments[i].str);
            }

            return strings.join("");
        }

        public function addObject(obj:*, priority:int):Boolean
        {
            return objects.add(obj, context, priority);
        }

        public function addClass(clazz:ASClass, priority:int):void
        {
            addObject(clazz, priority);

            context.push(ContextItem.fromString("class", true));
            context.push(ContextItem.fromString("init", true));
            addMethod(clazz.cinit, ContextSet.PRIORITY_Declaration);
            context.pop(); // init
            context.pop(); // class
            
            context.push(ContextItem.fromString("instance", true));
            context.push(ContextItem.fromString("init", true));
            addMethod(clazz.instance.iinit, ContextSet.PRIORITY_Declaration);
            context.pop(); // init

            visitMultiname(clazz.instance.name, ContextSet.PRIORITY_Declaration);
            visitMultiname(clazz.instance.superName, ContextSet.PRIORITY_Usage);
            visitNamespace(clazz.instance.protectedNs, ContextSet.PRIORITY_Declaration);
            for each (var iface:ASMultiname in clazz.instance.interfaces)
            {
                visitMultiname(iface, ContextSet.PRIORITY_Usage);
            }
            context.pop(); // instance
        }

        public function addMethod(method:ASMethod, priority:int):void
        {
            if (addObject(method, priority))
            {
                for each (var paramType:ASMultiname in method.paramTypes)
                {
                    visitMultiname(paramType, ContextSet.PRIORITY_Usage);
                }
                visitMultiname(method.returnType, ContextSet.PRIORITY_Usage);
                if (method.body != null)
                {
                    visitMethodBody(method.body);
                }
            }
        }
    }
}
