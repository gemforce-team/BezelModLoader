package Bezel.Lattice
{
    public class LatticeProperty
    {
        public var type:LatticeQName;
        public var origVal:String;

        public static function fromString(contents:String): LatticeProperty
        {
            var ret:LatticeProperty = new LatticeProperty();

            var found:Object = /type QName\((.*), "(.*)"\)/.exec(contents);
            if (found == null || found[2] == "")
            {
                throw new Error("Lattice: property has no type");
            }
            ret.type = new LatticeQName(LatticeTrait.extractNamespace(found[1]), found[2]);

            found = /value (.*\(.*\))/.exec(contents);
            if (found != null)
            {
                ret.origVal = found[1];
            }

            return ret;
        }
    }
}
