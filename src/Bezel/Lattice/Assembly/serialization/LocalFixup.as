package Bezel.Lattice.Assembly.serialization
{
    internal class LocalFixup
    {
        public var where:FilePosition;
        public var ii:uint;
        public var ai:uint;
        public var name:String;
        public var si:uint;

        public function LocalFixup(where:FilePosition, ii:uint, ai:uint, name:String, si:uint = 0)
        {
            this.where = where;
            this.ii = ii;
            this.ai = ai;
            this.name = name;
            this.si = si;
        }
    }
}
