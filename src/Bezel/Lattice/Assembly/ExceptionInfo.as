package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ExceptionInfo
    {
        public var from:ABCLabel;
        public var to:ABCLabel;
        public var target:ABCLabel;
        public var exceptionType:int;
        public var varName:int;

        public function ExceptionInfo(from:ABCLabel = null, to:ABCLabel = null, target:ABCLabel = null, exceptionType:int = 0, varName:int = 0)
        {
            this.from = from;
            this.to = to;
            this.target = target;
            this.exceptionType = exceptionType;
            this.varName = varName;
        }
    }
}
