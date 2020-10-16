package Bezel.Lattice
{
    public class LatticeTrait
    {
        internal var namespace:String;
        internal var identifier:String;
        internal var accessModifier:String;

        public var traitData:Object;

        public static const PUBLIC:String = "public";
        public static const INTERNAL:String = "internal";
        public static const PROTECTED:String = "protected";
        public static const PRIVATE:String = "private";

        private static const functionRegex:RegExp = /method.*?end ; method/ms;

        public function create(contents:String): void
        {
            var found:Object = /trait (slot|method) QName\((PackageNamespace|PackageInternalNs|PrivateNamespace|ProtectedNamespace)\("(.*)"\), "(.*)"\)/i.exec(contents);
            if (found == null || found[4] == "")
            {
                throw new Error("Lattice: Trait has no name");
            }

            this.accessModifier = transformAccessNamespace(found[2]);
            this.namespace = found[3];
            this.identifier = found[4];

            switch (found[1])
            {
                case "slot":
                    this.traitData = LatticeProperty.fromString(contents);
                    break;
                case "method":
                    found = functionRegex.exec(contents);
                    if (found == null)
                    {
                        throw new Error("Lattice: Method trait has no method field");
                    }
                    this.traitData = LatticeFunction.fromString(found[0]);
                    break;
                default:
                    throw new Error("Lattice: Trait type not recognized");
            }
        }

        internal static function transformAccessNamespace(ns:String): String
        {
            switch (ns)
            {
                case "PackageNamespace":
                    return PUBLIC;
                case "PackageInternalNs":
                    return INTERNAL;
                case "ProtectedNamespace":
                    return PROTECTED;
                case "PrivateNamespace":
                    return PRIVATE;
            }
            return "";
        }

        internal static function extractNamespace(ns:String): String
        {
            var found:Object = /(Namespace|PackageNamespace|PackageInternalNs|PrivateNamespace|ProtectedNamespace)\("(.*)"\)/i.exec(ns);
            if (found == null)
            {
                throw new Error("Lattice: extractNamespace found no namespace to extract");
            }

            return found[2];
        }
    }
}
