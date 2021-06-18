package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.TraitType;

    /**
	 * ...
	 * @author Chris
	 */
    public class ABCTrait
    {
        public var name:int;
        public var type:TraitType;
        public var attributes:int;
        public var extraData:*;
        public var metadata:Vector.<int>;

        public function ABCTrait(name:int = 0, type:TraitType = null, attributes:int = 0, extraData:* = null, metadata:Vector.<int> = null)
        {
            this.name = name;
            this.type = type;
            this.attributes = attributes;
            this.extraData = extraData;
            this.metadata = metadata;
        }
    }
}
