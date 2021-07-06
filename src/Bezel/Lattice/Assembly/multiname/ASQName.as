package Bezel.Lattice.Assembly.multiname
{
    import Bezel.Lattice.Assembly.ASNamespace;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASQName
    {
        public var ns:ASNamespace;
        public var name:String;

        public function toString():String
        {
            return ", { " + ns.toString() + ", " + name + " }";
        }

        public function equals(other:ASQName):Boolean
        {
            return ns.equals(other.ns) && name == other.name;
        }

        public function ASQName(ns:ASNamespace, name:String)
        {
            this.ns = ns;
            this.name = name;
        }
    }
}
