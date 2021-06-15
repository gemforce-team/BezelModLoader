package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCInstruction
    {
        public var opcode:Opcode;

        // May only contain integers (for literals or indices), a InstructionLabel (for jump targets), or a Vector.<InstructionLabel> (for switch targets)
        public var arguments:Array;

        // opcode may be Opcode, int, uint, or string
        public function ABCInstruction(opcode:Opcode = null, args:Array = null)
        {
            this.opcode = opcode;
            this.arguments = args;
        }
    }
}
