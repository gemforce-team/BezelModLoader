package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class Instruction
    {
        public var opcode:int;

        // May only contain integers (for literals or indices) or JumpLabels
        public var arguments:Array;

        public function Instruction(opcode:int = 0, args:Array = null)
        {
            this.opcode = opcode;
            this.arguments = args;
        }
    }
}
