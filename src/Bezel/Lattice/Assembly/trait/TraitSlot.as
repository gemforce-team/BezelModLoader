package Bezel.Lattice.Assembly.trait
{
    /**
	 * ...
	 * @author Chris
	 */
    public class TraitSlot
    {
        public var slotId:int;
        public var typeName:int;
        public var valueIndex:int;
        public var valueType:int;

        public function TraitSlot(slotId:int = 0, typeName:int = 0, valueIndex:int = 0, valueType:int = 0)
        {
            this.slotId = slotId;
            this.typeName = typeName;
            this.valueIndex = valueIndex;
            this.valueType = valueType;
        }
    }
}
