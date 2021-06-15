package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
	public class ASInstance
    {
        public var name:ASMultiname;
        public var superName:ASMultiname;
        public var flags:uint;
        public var protectedNs:ASNamespace;
        public var interfaces:Vector.<ASMultiname>;
        public var iinit:ASMethod;
        public var traits:Vector.<ASTrait>;
    }
}
