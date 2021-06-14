package Bezel.Lattice.Assembly
{
    public class OpcodeArgumentType
    {
        public static const Unknown:OpcodeArgumentType = new OpcodeArgumentType();
        public static const ByteLiteral:OpcodeArgumentType = new OpcodeArgumentType();
        public static const UByteLiteral:OpcodeArgumentType = new OpcodeArgumentType();
        public static const IntLiteral:OpcodeArgumentType = new OpcodeArgumentType();
        public static const UIntLiteral:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Int:OpcodeArgumentType = new OpcodeArgumentType();
        public static const UInt:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Double:OpcodeArgumentType = new OpcodeArgumentType();
        public static const String:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Namespace:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Multiname:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Class:OpcodeArgumentType = new OpcodeArgumentType();
        public static const Method:OpcodeArgumentType = new OpcodeArgumentType();
        public static const JumpTarget:OpcodeArgumentType = new OpcodeArgumentType();
        public static const SwitchDefaultTarget:OpcodeArgumentType = new OpcodeArgumentType();
        public static const SwitchTargets:OpcodeArgumentType = new OpcodeArgumentType();
    }
}
