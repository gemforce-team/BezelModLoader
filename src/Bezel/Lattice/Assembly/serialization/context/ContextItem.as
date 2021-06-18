package Bezel.Lattice.Assembly.serialization.context
{
    import Bezel.Lattice.Assembly.ASMultiname;
    import flash.text.engine.ContentElement;
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;

    /**
     * ...
     * @author Chris
     */
    public class ContextItem
    {
        public static const TYPE_Multiname:int = 0;
        public static const TYPE_String:int = 1;
        public static const TYPE_Group:int = 2;

        public var type:int;

        // TYPE_Multiname
        public var multiname:ASMultiname;

        // TYPE_String
        public var str:String;
        public var filenameSuffix:Boolean;

        // TYPE_Group
        public var group:Vector.<ContextItem>;
        public var groupFallback:String;

        private var expanding:Boolean = false;

        public function reduceGroup(refs:RefBuilder):Vector.<ContextItem>
        {
            if (type != TYPE_Group) throw new Error("Tried using group method on ContextItem of a different type");

            var contexts:Vector.<Vector.<ContextItem>> = new <Vector.<ContextItem>>[];
            for each (var c:ContextItem in this.group)
            {
                contexts.push(ContextItem.expand(refs, new <ContextItem>[c]));
            }

            var context:Vector.<ContextItem>;
            if (contexts.length != 0)
            {
                context = contexts[0];
                for (var i:int = 1; i < contexts.length; i++)
                {
                    context = contextRoot(context, contexts[i]);
                }
            }
            else
            {
                context = new <ContextItem>[fromString(groupFallback)];
            }
            return context;
        }

        public static function expand(refs:RefBuilder, context:Vector.<ContextItem>):Vector.<ContextItem>
        {
            var ret:Vector.<ContextItem> = new <ContextItem>[];
            for each (var c:ContextItem in context)
            {
                var expanded:Vector.<ContextItem> = c.expand(refs);
                if (expanded != null && expanded.length != 0)
                {
                    ret = ret.concat(expanded);
                }
            }
            return ret;
        }

        public function expand(refs:RefBuilder):Vector.<ContextItem>
        {
            if (expanding)
            {
                switch(type)
                {
                    case TYPE_String:
                        throw new Error("Cannot expand a string");
                    case TYPE_Multiname:
                        return new <ContextItem>[this];
                    case TYPE_Group:
                        return new <ContextItem>[fromString(groupFallback)];
                }
            }

            expanding = true;

            switch (type)
            {
                case TYPE_Multiname:
                {
                    switch (multiname.type)
                    {
                        case ABCType.QName:
                        {
                            var ns:ASNamespace = (multiname.subdata as ASQName).ns;
                            if (ns.type == ABCType.PrivateNamespace)
                            {
                                var context:Vector.<ContextItem> = refs.namespaces[ns.type.val].getContext(refs, ns.uniqueId);
                                expanding = false;
                                if ((multiname.subdata as ASQName).name.length != 0)
                                {
                                    context.push(fromString((multiname.subdata as ASQName).name));
                                }
                                return context;
                            }
                        }
                        break;
                        case ABCType.Multiname:
                            expanding = false;
                            return (multiname.subdata as ASMultinameSubdata).name.length != 0 ? new <ContextItem>[fromString((multiname.subdata as ASMultinameSubdata).name)] : new <ContextItem>[];
                        default:
                            expanding = false;
                            CONFIG::debug
                            throw new Error("Multiname of type " + multiname.type.val + " trying to be expanded");
                            break;
                    }
                }
                break;
                case TYPE_String:
                    break;
                case TYPE_Group:
                    expanding = false;
                    return reduceGroup(refs);
            }

            return new <ContextItem>[this];
        }

        public function toSegments(refs:RefBuilder, filename:Boolean):Vector.<Segment>
        {
            switch (type)
            {
                case TYPE_Multiname:
                {
                    if (multiname.type != ABCType.QName) throw new Error("Canno convert non-QName to segments");
                    var ns:ASNamespace = (multiname.subdata as ASQName).ns;
                    var nsName:String = ns.name;
                    var name:String = (multiname.subdata as ASQName).name;
                    if (nsName.length != 0)
                    {
                        if (name.length != 0)
                        {
                            return new <Segment>[new Segment('/', nsName), new Segment(filename ? '/' : ':', name)];
                        }
                        else
                        {
                            return new <Segment>[new Segment('/', nsName)];
                        }
                    }
                    else
                    {
                        if (name.length != 0)
                        {
                            return new <Segment>[new Segment('/', name)];
                        }
                        else
                            throw new Error("Empty namespace name and normal name in a multiname ContextInfo");
                    }
                }
                case TYPE_String:
                    return new <Segment>[new Segment((filename && filenameSuffix) ? '.' : '/', str)];
                case TYPE_Group:
                {
                    var segments:Vector.<Segment> = new Vector.<Segment>();
                    for each (var context:ContextItem in reduceGroup(refs))
                    {
                        segments.concat(context.toSegments(refs, filename));
                    }
                    return segments;
                }
                default:
                    throw new Error("ContextItem type is not recognized");
            }
        }

        public static function contextRoot(c1:Vector.<ContextItem>, c2:Vector.<ContextItem>):Vector.<ContextItem>
        {
            function uninteresting(c:Vector.<ContextItem>):Boolean
            {
                CONFIG::debug
                for each (var item:ContextItem in c)
                {
                    if (item.type == TYPE_Group) throw new Error("Groups should be expanded by now");
                }

                return (c.length == 1 && c[0].type == TYPE_String && c[0].str.indexOf("script_") == 0 && c[0].str.lastIndexOf("_sinit") == c[0].str.length - 6) ||
                       (c.length == 1 && c[0].type == TYPE_String && c[0].str.indexOf("orphan_method_") == 0);
            }

            if (uninteresting(c1)) return c2;
            if (uninteresting(c2)) return c1;

            var c:Vector.<ContextItem> = new <ContextItem>[];

            while (c.length < c1.length && c.length < c2.length)
            {
                var root:Vector.<ContextItem> = commonRoot(c1[c.length], c2[c.length]);
                if (root.length > 1) throw new Error("root should not be larger than 1 element");
                if (root.length == 1)
                {
                    c.push(root[0]);
                }
                else
                {
                    break;
                }
            }

            return c;
        }

        public static function combine(truncate:Boolean, c1:ContextItem, c2:ContextItem):Vector.<ContextItem>
        {
            if (similar(c1,c2))
            {
                return new <ContextItem>[c1];
            }
            if (c1.type != TYPE_Multiname || c2.type != TYPE_Multiname || c1.multiname.type != ABCType.QName || c2.multiname.type != ABCType.QName)
            {
                return new <ContextItem>[];
            }

            var name1:String = (c1.multiname.subdata as ASQName).name;
            var name2:String = (c2.multiname.subdata as ASQName).name;
            var ns1:ASNamespace = (c1.multiname.subdata as ASQName).ns;
            var ns2:ASNamespace = (c2.multiname.subdata as ASQName).ns;

            if (nsSimilar(ns1, ns2) && ns1.name.length != 0 && truncate)
            {
                return new <ContextItem>[fromMultiname(new ASMultiname(ABCType.QName, new ASQName(ns1, "")))];
            }

            if (name1.length != 0 && name2.length == 0 && truncate)
            {
                var tmp:* = c1.multiname;
                c1.multiname = c2.multiname;
                c2.multiname = c1.multiname;
                tmp = name1;
                name1 = name2;
                name2 = tmp;
                tmp = ns1;
                ns1 = ns2;
                ns2 = tmp;
            }

            if (name1.length == 0 && name2.length != 0 && nsSimilar(ns1, ns2))
            {
                if (truncate)
                {
                    return new <ContextItem>[fromMultiname(new ASMultiname(ABCType.QName, new ASQName(ns1, "")))];
                }
                else
                {
                    return new <ContextItem>[c2];
                }
            }

            if (ns1.name.length != 0 && ns2.name.length != 0)
            {
                if (nsSimilar(ns1, ns2))
                {
                    if (name1 != name2) throw new Error("This should already have been handled");
                    if (truncate) throw new Error("This should already have been handled");

                    if (name2.length != 0)
                    {
                        return new <ContextItem>[c1, fromString(name2)];
                    }
                    else
                    {
                        return new <ContextItem>[c1];
                    }
                }

                if (ns1.name.length > ns2.name.length && truncate)
                {
                    tmp = c1.multiname;
                    c1.multiname = c2.multiname;
                    c2.multiname = tmp;
                    tmp = name1;
                    name1 = name2;
                    name2 = tmp;
                    tmp = ns1;
                    ns1 = ns2;
                    ns2 = tmp;
                }

                var fullName1:String = ns1.name + (name1.length != 0 ? ":" + name1 : "");
                var fullName2:String = ns2.name + (name2.length != 0 ? ":" + name2 : "");
                if (fullName2.indexOf(fullName1 + ":") == 0)
                {
                    return new <ContextItem>[truncate ? c1 : c2];
                }
            }

            return null;
        }

        public static function commonRoot(c1:ContextItem, c2:ContextItem):Vector.<ContextItem>
        {
            return combine(true, c1, c2);
        }

        public static function deduplicate(c1:ContextItem, c2:ContextItem):Vector.<ContextItem>
        {
            return combine(false, c1, c2);
        }

        public static function fromMultiname(m:ASMultiname):ContextItem
        {
            var ret:ContextItem = new ContextItem();
            ret.type = TYPE_Multiname;
            ret.multiname = m;
            return ret;
        }

        public static function fromString(s:String, filenameSuffix:Boolean = false):ContextItem
        {
            var ret:ContextItem = new ContextItem();
            ret.type = TYPE_Group;
            ret.str = s;
            ret.filenameSuffix = filenameSuffix;
            return ret;
        }

        public static function fromGroup(g:Vector.<ContextItem>, groupFallback:String):ContextItem
        {
            var ret:ContextItem = new ContextItem();
            ret.type = TYPE_Group;
            ret.group = g;
            ret.groupFallback = groupFallback;
            return ret;
        }

        public static function nsSimilar(ns1:ASNamespace, ns2:ASNamespace):Boolean
        {
            if (ns1.type == ABCType.PrivateNamespace || ns2.type == ABCType.PrivateNamespace)
            {
                return ns1.type == ns2.type && ns1.uniqueId == ns2.uniqueId;
            }
            return ns1.name == ns2.name;
        }

        public static function similar(i1:ContextItem, i2:ContextItem):Boolean
        {
            if (i1.type != i2.type) return false;
            switch (i1.type)
            {
                case TYPE_String:
                    return i1.str == i2.str;
                case TYPE_Multiname:
                    if (i1.multiname.type != ABCType.QName || i2.multiname.type != ABCType.QName) throw new Error("ContextItem multinames should be QNames");
                    if ((i1.multiname.subdata as ASQName).name != (i2.multiname.subdata as ASQName).name) return false;
                    return nsSimilar((i1.multiname.subdata as ASQName).ns, (i2.multiname.subdata as ASQName).ns);
                case TYPE_Group:
                    return i1.group == i2.group;
                default:
                    throw new Error("ContextItem Type is not recognized");
            }
        }
    }
}
