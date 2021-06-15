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

        public function ASMultinameSubdata(name:String, ns_set:Vector.<ASNamespace>)
        {
            this.name = name;
            this.ns_set = ns_set;
        }
    }
}
