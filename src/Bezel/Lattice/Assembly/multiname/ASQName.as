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

        public function ASQName(ns:ASNamespace, name:String)
        {
            this.ns = ns;
            this.name = name;
        }
    }
}
