package Bezel.Lattice.Assembly.multiname
{
    import Bezel.Lattice.Assembly.ASNamespace;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASMultinameL
    {
        public var ns_set:Vector.<ASNamespace>;

        public function toString():String
        {
            var ret:String = ", [";
            for each (var ns:ASNamespace in ns_set)
            {
                ret += ns.toString();
            }
            ret += " ]";
            return ret;
        }

        public function equals(other:ASMultinameL):Boolean
        {
            if (ns_set.length != other.ns_set.length) return false;
            for (var i:int = 0; i < ns_set.length; i++)
            {
                if (!ns_set[i].equals(other.ns_set[i])) return false;
            }
            return true;
        }

        public function ASMultinameL(ns_set:Vector.<ASNamespace>)
        {
            this.ns_set = ns_set;
        }
    }
}
