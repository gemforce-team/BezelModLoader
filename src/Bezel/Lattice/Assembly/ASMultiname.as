package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.values.ABCType;

    /**
	 * ...
	 * @author Chris
	 */
	public class ASMultiname
    {
        public var type:ABCType;
        public var subdata:*;

        public function toString():String
        {
            return "{ type = " + type.name + subdata.toString() + " }";
        }

        public function equals(other:ASMultiname):Boolean
        {
            return type == other.type && typeof(subdata) == typeof(other.subdata) && subdata.equals(other.subdata);
        }

        public function ASMultiname(type:ABCType, subdata:*)
        {
            this.type = type;
            this.subdata = subdata;
        }

        public function toQNames():Vector.<ASMultiname>
        {
            switch (type)
            {
                case ABCType.QName:
                case ABCType.QNameA:
                    return new <ASMultiname>[this];
                case ABCType.Multiname:
                case ABCType.MultinameA:
                {
                    var result:Vector.<ASMultiname> = new <ASMultiname>[];
                    var data:ASMultinameSubdata = subdata as ASMultinameSubdata;

                    for each (var ns:ASNamespace in data.ns_set)
                    {
                        result.push(new ASMultiname(type == ABCType.Multiname ? ABCType.QName : ABCType.QNameA, new ASQName(ns, data.name)));
                    }

                    return result;
                }
                default:
                    throw new Error("Cannot expand multiname of this type");
            }
        }
    }
}
