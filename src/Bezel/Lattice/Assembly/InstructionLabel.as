package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class InstructionLabel
    {
        public var index:uint;
        public var offset:int;

        public function InstructionLabel(index:uint = uint.MAX_VALUE, offset:int = int.MAX_VALUE)
        {
            this.index = index;
            this.offset = offset;
        }
    }
}
