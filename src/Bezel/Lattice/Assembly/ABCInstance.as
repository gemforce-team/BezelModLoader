package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCInstance
    {
        public var name:int;
        public var superclassName:int;
        public var flags:int;
        public var protectedNs:int;
        public var interfaces:Vector.<int>;
        public var iinit:int;
        public var traits:Vector.<ABCTrait>;

        public function ABCInstance(name:int = 0, superclassName:int = 0, flags:int = 0, protectedNs:int = 0, interfaces:Vector.<int> = null, iinit:int = 0, traits:Vector.<ABCTrait> = null)
        {
            this.name = name;
            this.superclassName = superclassName;
            this.flags = flags;
            this.protectedNs = protectedNs;
            this.interfaces = interfaces;
            this.iinit = iinit;
            this.traits = traits;
        }
    }
}
