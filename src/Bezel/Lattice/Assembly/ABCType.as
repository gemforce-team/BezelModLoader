package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
	public class ABCType
    {
        public static const Void:int = 0x00;  // not actually interned
        public static const Undefined:int = Void;
        public static const Utf8:int = 0x01;
        public static const Decimal:int = 0x02;
        public static const Integer:int = 0x03;
        public static const UInteger:int = 0x04;
        public static const PrivateNamespace:int = 0x05;
        public static const Double:int = 0x06;
        public static const QName:int = 0x07;  // ns::name, const ns, const name
        public static const Namespace:int = 0x08;
        public static const Multiname:int = 0x09;    //[ns...]::name, const [ns...], const name
        public static const False:int = 0x0A;
        public static const True:int = 0x0B;
        public static const Null:int = 0x0C;
        public static const QNameA:int = 0x0D;    // @ns::name, const ns, const name
        public static const MultinameA:int = 0x0E;// @[ns...]::name, const [ns...], const name
        public static const RTQName:int = 0x0F;    // ns::name, var ns, const name
        public static const RTQNameA:int = 0x10;    // @ns::name, var ns, const name
        public static const RTQNameL:int = 0x11;    // ns::[name], var ns, var name
        public static const RTQNameLA:int = 0x12; // @ns::[name], var ns, var name
        public static const Namespace_Set:int = 0x15; // a set of namespaces - used by multiname
        public static const PackageNamespace:int = 0x16; // a namespace that was derived from a package
        public static const PackageInternalNs:int = 0x17; // a namespace that had no uri
        public static const ProtectedNamespace:int = 0x18;
        public static const ExplicitNamespace:int = 0x19;
        public static const StaticProtectedNs:int = 0x1A;
        public static const MultinameL:int = 0x1B;
        public static const MultinameLA:int = 0x1C;
        public static const TypeName:int = 0x1D;
    }
}
