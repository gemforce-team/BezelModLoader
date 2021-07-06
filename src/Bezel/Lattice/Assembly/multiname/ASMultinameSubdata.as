package Bezel.Lattice.Assembly.multiname
{
    import Bezel.Lattice.Assembly.ASNamespace;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASMultinameSubdata
    {
        public var name:String;
        public var ns_set:Vector.<ASNamespace>;

        public function toString():String
        {
            var ret:String = ", [";
            for each (var ns:ASNamespace in ns_set)
            {
                ret += ns.toString();
            }
            ret += " ], " + name;
            return ret;
        }

        public function equals(other:ASMultinameSubdata):Boolean
        {
            if (ns_set.length != other.ns_set.length) return false;
            for (var i:int = 0; i < ns_set.length; i++)
            {
                if (!ns_set[i].equals(other.ns_set[i])) return false;
            }
            return name == other.name;
        }

        public function ASMultinameSubdata(name:String, ns_set:Vector.<ASNamespace>)
        {
            this.name = name;
            this.ns_set = ns_set;
        }
    }
}
