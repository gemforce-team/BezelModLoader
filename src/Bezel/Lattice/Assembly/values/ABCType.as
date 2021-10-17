class ABCTypeConstructorBlocker {}
package Bezel.Lattice.Assembly.values
{
    /**
	 * ...
	 * @author Chris
	 */
	public class ABCType
    {
        public static const Void:ABCType = new ABCType(0x00, "Void", new ABCTypeConstructorBlocker());  // not actually interned
        public static const Undefined:ABCType = Void;
        public static const Utf8:ABCType = new ABCType(0x01, "Utf8", new ABCTypeConstructorBlocker());
        public static const Decimal:ABCType = new ABCType(0x02, "Decimal", new ABCTypeConstructorBlocker());
        public static const Integer:ABCType = new ABCType(0x03, "Integer", new ABCTypeConstructorBlocker());
        public static const UInteger:ABCType = new ABCType(0x04, "UInteger", new ABCTypeConstructorBlocker());
        public static const PrivateNamespace:ABCType = new ABCType(0x05, "PrivateNamespace", new ABCTypeConstructorBlocker());
        public static const Double:ABCType = new ABCType(0x06, "Double", new ABCTypeConstructorBlocker());
        public static const QName:ABCType = new ABCType(0x07, "QName", new ABCTypeConstructorBlocker());  // ns::name, const ns, const name
        public static const Namespace:ABCType = new ABCType(0x08, "Namespace", new ABCTypeConstructorBlocker());
        public static const Multiname:ABCType = new ABCType(0x09, "Multiname", new ABCTypeConstructorBlocker());    //[ns...]::name, const [ns...], const name
        public static const False:ABCType = new ABCType(0x0A, "False", new ABCTypeConstructorBlocker());
        public static const True:ABCType = new ABCType(0x0B, "True", new ABCTypeConstructorBlocker());
        public static const Null:ABCType = new ABCType(0x0C, "Null", new ABCTypeConstructorBlocker());
        public static const QNameA:ABCType = new ABCType(0x0D, "QNameA", new ABCTypeConstructorBlocker());    // @ns::name, const ns, const name
        public static const MultinameA:ABCType = new ABCType(0x0E, "MultinameA", new ABCTypeConstructorBlocker());// @[ns...]::name, const [ns...], const name
        public static const RTQName:ABCType = new ABCType(0x0F, "RTQName", new ABCTypeConstructorBlocker());    // ns::name, var ns, const name
        public static const RTQNameA:ABCType = new ABCType(0x10, "RTQNameA", new ABCTypeConstructorBlocker());    // @ns::name, var ns, const name
        public static const RTQNameL:ABCType = new ABCType(0x11, "RTQNameL", new ABCTypeConstructorBlocker());    // ns::[name], var ns, var name
        public static const RTQNameLA:ABCType = new ABCType(0x12, "RTQNameLA", new ABCTypeConstructorBlocker()); // @ns::[name], var ns, var name
        public static const Namespace_Set:ABCType = new ABCType(0x15, "Namespace_Set", new ABCTypeConstructorBlocker()); // a set of namespaces - used by multiname
        public static const PackageNamespace:ABCType = new ABCType(0x16, "PackageNamespace", new ABCTypeConstructorBlocker()); // a namespace that was derived from a package
        public static const PackageInternalNs:ABCType = new ABCType(0x17, "PackageInternalNs", new ABCTypeConstructorBlocker()); // a namespace that had no uri
        public static const ProtectedNamespace:ABCType = new ABCType(0x18, "ProtectedNamespace", new ABCTypeConstructorBlocker());
        public static const ExplicitNamespace:ABCType = new ABCType(0x19, "ExplicitNamespace", new ABCTypeConstructorBlocker());
        public static const StaticProtectedNs:ABCType = new ABCType(0x1A, "StaticProtectedNs", new ABCTypeConstructorBlocker());
        public static const MultinameL:ABCType = new ABCType(0x1B, "MultinameL", new ABCTypeConstructorBlocker());
        public static const MultinameLA:ABCType = new ABCType(0x1C, "MultinameLA", new ABCTypeConstructorBlocker());
        public static const TypeName:ABCType = new ABCType(0x1D, "TypeName", new ABCTypeConstructorBlocker());

        private var _val:int;
        private var _name:String;

        public function get val():int { return _val; }
        public function get name():String { return _name; }

        public function ABCType(val:int, name:String, blocker:ABCTypeConstructorBlocker)
        {
            if (blocker == null)
            {
                throw new Error("Do not use the ABCType constructor");
            }
            this._val = val;
            this._name = name;
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

        public static function fromString(val:String):ABCType
        {
            switch (val)
            {
                case "Void":
                    return Void;
                case "Undefined":
                    return Undefined;
                case "Utf8":
                    return Utf8;
                case "Decimal":
                    return Decimal;
                case "Integer":
                    return Integer;
                case "UInteger":
                    return UInteger;
                case "PrivateNamespace":
                    return PrivateNamespace;
                case "Double":
                    return Double;
                case "QName":
                    return QName;
                case "Namespace":
                    return Namespace;
                case "Multiname":
                    return Multiname;
                case "False":
                    return False;
                case "True":
                    return True;
                case "Null":
                    return Null;
                case "QNameA":
                    return QNameA;
                case "MultinameA":
                    return MultinameA;
                case "RTQName":
                    return RTQName;
                case "RTQNameA":
                    return RTQNameA;
                case "RTQNameL":
                    return RTQNameL;
                case "RTQNameLA":
                    return RTQNameLA;
                case "Namespace_Set":
                    return Namespace_Set;
                case "PackageNamespace":
                    return PackageNamespace;
                case "PackageInternalNs":
                    return PackageInternalNs;
                case "ProtectedNamespace":
                    return ProtectedNamespace;
                case "ExplicitNamespace":
                    return ExplicitNamespace;
                case "StaticProtectedNs":
                    return StaticProtectedNs;
                case "MultinameL":
                    return MultinameL;
                case "MultinameLA":
                    return MultinameLA;
                case "TypeName":
                    return TypeName;
            }

            return null;
        }
    }
}
