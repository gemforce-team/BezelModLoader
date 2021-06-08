package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ExceptionInfo
    {
        public var fromRaw:int;
        public var toRaw:int;
        public var targetRaw:int;
        public var exceptionType:int;
        public var varName:int;

        public function ExceptionInfo(fromRaw:int = 0, toRaw:int = 0, targetRaw:int = 0, exceptionType:int = 0, varName:int = 0)
        {
            this.fromRaw = fromRaw;
            this.toRaw = toRaw;
            this.targetRaw = targetRaw;
            this.exceptionType = exceptionType;
            this.varName = varName;
        }
    }
}
