package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class TraitInfo
    {
        public var name:int;
        public var type:int;
        public var attributes:int;
        public var extraData:*;
        public var metadata:Vector.<int>;

        public static const TYPE_SLOT:int = 0;
        public static const TYPE_METHOD:int = 1;
        public static const TYPE_GETTER:int = 2;
        public static const TYPE_SETTER:int = 3;
        public static const TYPE_CLASS:int = 4;
        public static const TYPE_FUNCTION:int = 5;
        public static const TYPE_CONST:int = 6;

        public static const ATTR_FINAL:int = 0x1;
        public static const ATTR_OVERRIDE:int = 0x2;
        public static const ATTR_METADATA:int = 0x4;

        public function TraitInfo(name:int = 0, type:int = 0, attributes:int = 0, extraData:* = null, metadata:Vector.<int> = null)
        {
            this.name = name;
            this.type = type;
            this.attributes = attributes;
            this.extraData = extraData;
            this.metadata = metadata;
        }
    }
}
