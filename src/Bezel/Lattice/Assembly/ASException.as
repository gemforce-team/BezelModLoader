package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ASException
    {
        public var from:InstructionLabel;
        public var to:InstructionLabel;
        public var target:InstructionLabel;
        public var exceptionType:ASMultiname;
        public var varName:ASMultiname;

        public function ASException(from:InstructionLabel = null, to:InstructionLabel = null, target:InstructionLabel = null, exceptionType:ASMultiname = null, varName:ASMultiname = null)
        {
            this.from = from;
            this.to = to;
            this.target = target;
            this.exceptionType = exceptionType;
            this.varName = varName;
        }
    }
}
