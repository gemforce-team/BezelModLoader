package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class InstructionFixup
    {
        public var target:InstructionLabel;
        public var pos:uint;
        public var base:uint;

        public function InstructionFixup(target:InstructionLabel = null, pos:uint = 0, base:uint = 0)
        {
            this.target = target;
            this.pos = pos;
            this.base = base;
        }
    }
}
