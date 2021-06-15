package Bezel.Lattice.Assembly.trait
{
    import Bezel.Lattice.Assembly.values.ABCType;

    /**
	 * ...
	 * @author Chris
	 */
    public class ABCTraitSlot
    {
        public var slotId:int;
        public var typeName:int;
        public var valueIndex:int;
        public var valueType:ABCType;

        public function ABCTraitSlot(slotId:int = 0, typeName:int = 0, valueIndex:int = 0, valueType:ABCType = null)
        {
            this.slotId = slotId;
            this.typeName = typeName;
            this.valueIndex = valueIndex;
            this.valueType = valueType;
        }
    }
}
