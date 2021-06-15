package Bezel.Lattice.Assembly.values
{
    /**
     * ...
     * @author Chris
     */
    public class MethodFlags
    {
        public static const NEED_ARGUMENTS:int = 0x1;
        public static const NEED_ACTIVATION:int = 0x2;
        public static const NEED_REST:int = 0x4;
        public static const HAS_OPTIONAL:int = 0x8;
        public static const SET_DXNS:int = 0x40;
        public static const HAS_PARAM_NAMES:int = 0x80;
    }
}
