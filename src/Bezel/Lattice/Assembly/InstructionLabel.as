package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class InstructionLabel {
        public var index:uint;
        public var offset:int;

        public function InstructionLabel(index:uint = uint.MAX_VALUE, offset:int = int.MAX_VALUE) {
            this.index = index;
            this.offset = offset;
        }

        public function equals(other:InstructionLabel):Boolean {
            return other != null && index == other.index && offset == other.offset;
        }
    }
}
