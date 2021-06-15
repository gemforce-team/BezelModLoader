package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCMethodInfo
    {
        public var parameterTypes:Vector.<int>;
        public var returnType:int;
        public var name:int;
        public var flags:int;
        public var defaultOptions:Vector.<ABCDefaultOption>;
        public var parameterNames:Vector.<int>;

        public function ABCMethodInfo(parameterTypes:Vector.<int> = null, returnType:int = 0, name:int = 0, flags:int = 0, defaultOptions:Vector.<ABCDefaultOption> = null, parameterNames:Vector.<int> = null)
        {
            this.parameterTypes = parameterTypes;
            this.returnType = returnType;
            this.name = name;
            this.flags = flags;
            this.defaultOptions = defaultOptions;
            this.parameterNames = parameterNames;
        }
    }
}
