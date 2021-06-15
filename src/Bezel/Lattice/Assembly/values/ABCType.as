package Bezel.Lattice.Assembly.values
{
    /**
	 * ...
	 * @author Chris
	 */
	public class ABCType
    {
        public static const Void:ABCType = new ABCType(0x00, new ABCTypeConstructorBlocker());  // not actually interned
        public static const Undefined:ABCType = Void;
        public static const Utf8:ABCType = new ABCType(0x01, new ABCTypeConstructorBlocker());
        public static const Decimal:ABCType = new ABCType(0x02, new ABCTypeConstructorBlocker());
        public static const Integer:ABCType = new ABCType(0x03, new ABCTypeConstructorBlocker());
        public static const UInteger:ABCType = new ABCType(0x04, new ABCTypeConstructorBlocker());
        public static const PrivateNamespace:ABCType = new ABCType(0x05, new ABCTypeConstructorBlocker());
        public static const Double:ABCType = new ABCType(0x06, new ABCTypeConstructorBlocker());
        public static const QName:ABCType = new ABCType(0x07, new ABCTypeConstructorBlocker());  // ns::name, const ns, const name
        public static const Namespace:ABCType = new ABCType(0x08, new ABCTypeConstructorBlocker());
        public static const Multiname:ABCType = new ABCType(0x09, new ABCTypeConstructorBlocker());    //[ns...]::name, const [ns...], const name
        public static const False:ABCType = new ABCType(0x0A, new ABCTypeConstructorBlocker());
        public static const True:ABCType = new ABCType(0x0B, new ABCTypeConstructorBlocker());
        public static const Null:ABCType = new ABCType(0x0C, new ABCTypeConstructorBlocker());
        public static const QNameA:ABCType = new ABCType(0x0D, new ABCTypeConstructorBlocker());    // @ns::name, const ns, const name
        public static const MultinameA:ABCType = new ABCType(0x0E, new ABCTypeConstructorBlocker());// @[ns...]::name, const [ns...], const name
        public static const RTQName:ABCType = new ABCType(0x0F, new ABCTypeConstructorBlocker());    // ns::name, var ns, const name
        public static const RTQNameA:ABCType = new ABCType(0x10, new ABCTypeConstructorBlocker());    // @ns::name, var ns, const name
        public static const RTQNameL:ABCType = new ABCType(0x11, new ABCTypeConstructorBlocker());    // ns::[name], var ns, var name
        public static const RTQNameLA:ABCType = new ABCType(0x12, new ABCTypeConstructorBlocker()); // @ns::[name], var ns, var name
        public static const Namespace_Set:ABCType = new ABCType(0x15, new ABCTypeConstructorBlocker()); // a set of namespaces - used by multiname
        public static const PackageNamespace:ABCType = new ABCType(0x16, new ABCTypeConstructorBlocker()); // a namespace that was derived from a package
        public static const PackageInternalNs:ABCType = new ABCType(0x17, new ABCTypeConstructorBlocker()); // a namespace that had no uri
        public static const ProtectedNamespace:ABCType = new ABCType(0x18, new ABCTypeConstructorBlocker());
        public static const ExplicitNamespace:ABCType = new ABCType(0x19, new ABCTypeConstructorBlocker());
        public static const StaticProtectedNs:ABCType = new ABCType(0x1A, new ABCTypeConstructorBlocker());
        public static const MultinameL:ABCType = new ABCType(0x1B, new ABCTypeConstructorBlocker());
        public static const MultinameLA:ABCType = new ABCType(0x1C, new ABCTypeConstructorBlocker());
        public static const TypeName:ABCType = new ABCType(0x1D, new ABCTypeConstructorBlocker());

        private var _val:int;

        public function get val():int { return _val; }

        public function ABCType(val:int, blocker:ABCTypeConstructorBlocker)
        {
            if (blocker == null)
            {
                throw new Error("Do not use the ABCType constructor");
            }
            this._val = val;
        }

        public static function fromByte(val:int):ABCType
        {
            switch (val)
            {
                case 0x00:
                    return Void;
                case 0x01:
                    return Utf8;
                case 0x02:
                    return Decimal;
                case 0x03:
                    return Integer;
                case 0x04:
                    return UInteger;
                case 0x05:
                    return PrivateNamespace;
                case 0x06:
                    return Double;
                case 0x07:
                    return QName;
                case 0x08:
                    return Namespace;
                case 0x09:
                    return Multiname;
                case 0x0A:
                    return False;
                case 0x0B:
                    return True;
                case 0x0C:
                    return Null;
                case 0x0D:
                    return QNameA;
                case 0x0E:
                    return MultinameA;
                case 0x0F:
                    return RTQName;
                case 0x10:
                    return RTQNameA;
                case 0x11:
                    return RTQNameL;
                case 0x12:
                    return RTQNameLA;
                case 0x15:
                    return Namespace_Set;
                case 0x16:
                    return PackageNamespace;
                case 0x17:
                    return PackageInternalNs;
                case 0x18:
                    return ProtectedNamespace;
                case 0x19:
                    return ExplicitNamespace;
                case 0x1A:
                    return StaticProtectedNs;
                case 0x1B:
                    return MultinameL;
                case 0x1C:
                    return MultinameLA;
                case 0x1D:
                    return TypeName;
            }

            return null;
        }
    }
}
class ABCTypeConstructorBlocker {}
