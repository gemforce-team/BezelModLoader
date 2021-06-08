package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class MethodInfo
    {
        public var parameterTypes:Vector.<int>;
        public var returnType:int;
        public var name:int;
        public var flags:int;
        public var defaultOptions:Vector.<DefaultOption>;
        public var parameterNames:Vector.<int>;

        public static const FLAG_NEED_ARGUMENTS:int = 0x1;
        public static const FLAG_NEED_ACTIVATION:int = 0x2;
        public static const FLAG_NEED_REST:int = 0x4;
        public static const FLAG_HAS_OPTIONAL:int = 0x8;
        public static const FLAG_SET_DXNS:int = 0x40;
        public static const FLAG_HAS_PARAM_NAMES:int = 0x80;

        public function MethodInfo(parameterTypes:Vector.<int> = null, returnType:int = 0, name:int = 0, flags:int = 0, defaultOptions:Vector.<DefaultOption> = null, parameterNames:Vector.<int> = null)
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
