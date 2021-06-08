package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class Instance
    {
        public var name:int;
        public var superclassName:int;
        public var flags:int;
        public var protectedNs:int;
        public var interfaces:Vector.<int>;
        public var iinit:int;
        public var traits:Vector.<TraitInfo>;

        public static const FLAG_SEALED:int = 0x1;
        public static const FLAG_FINAL:int = 0x2;
        public static const FLAG_INTERFACE:int = 0x4;
        public static const FLAG_PROTECTEDNS:int = 0x8;

        public function Instance(name:int = 0, superclassName:int = 0, flags:int = 0, protectedNs:int = 0, interfaces:Vector.<int> = null, iinit:int = 0, traits:Vector.<TraitInfo> = null)
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
