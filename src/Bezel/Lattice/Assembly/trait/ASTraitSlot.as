package Bezel.Lattice.Assembly.trait {
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.ASValue;

    /**
     * ...
     * @author Chris
     */
    public class ASTraitSlot {
        public var slotId:int;
        public var typeName:ASMultiname;
        public var value:ASValue;

        public function ASTraitSlot(slotId:int = 0, typeName:ASMultiname = null, value:ASValue = null) {
            this.slotId = slotId;
            this.typeName = typeName;
            this.value = value;
        }

        public function equals(other:ASTraitSlot):Boolean {
            return other != null && slotId == other.slotId && typeName.equals(other.typeName) && ((value == null) == (other.value == null)) && (value == null || value.equals(other.value));
        }
    }
}
