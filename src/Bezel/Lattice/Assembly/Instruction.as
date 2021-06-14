package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class Instruction
    {
        public var opcode:Opcode;

        // May only contain integers (for literals or indices), a ABCLabel (for jump targets), or a Vector.<ABCLabel> (for switch targets)
        public var arguments:Array;

        // opcode may be Opcode, int, uint, or string
        public function Instruction(opcode:* = 0, args:Array = null)
        {
            if (opcode is Opcode)
            {
                this.opcode = opcode as Opcode;
            }
            else if (opcode is String)
            {
                this.opcode = Opcode.codesByName[opcode as String]
            }
            else if (opcode is int)
            {
                this.opcode = Opcode.codesByByte[opcode as int];
            }
            else if (opcode is uint)
            {
                this.opcode = Opcode.codesByByte[opcode as uint];
            }
            else
            {
                throw new Error("opcode type may not be \'" + typeof(opcode) + "\'. It must be one of String, int, or Opcode");
            }
            this.arguments = args;
        }
    }
}
