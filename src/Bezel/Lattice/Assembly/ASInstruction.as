package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ASInstruction
    {
        public var opcode:Opcode;

        // May contain int, uint, Number, String, ASNamespace, ASMultiname, ASClass, ASMethod, InstructionLabel, or Vector.<InstructionLabel>
        public var arguments:Array;
    }
}
