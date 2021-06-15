package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCException
    {
        public var from:InstructionLabel;
        public var to:InstructionLabel;
        public var target:InstructionLabel;
        public var exceptionType:int;
        public var varName:int;

        public function ABCException(from:InstructionLabel = null, to:InstructionLabel = null, target:InstructionLabel = null, exceptionType:int = 0, varName:int = 0)
        {
            this.from = from;
            this.to = to;
            this.target = target;
            this.exceptionType = exceptionType;
            this.varName = varName;
        }
    }
}
