package Bezel.Lattice.Assembly.serialization
{
    internal class UnifiedFixup
    {
        public var where:FilePosition;
        private var arr:Array;
        private var idx:int;
        public var name:String;

        public function UnifiedFixup(where:FilePosition, arr:Array, idx:int, name:String)
        {
            this.where = where;
            this.arr = arr;
            this.idx = idx;
            this.name = name;
        }

        public function get value():*
        {
            return arr[idx];
        }

        public function set value(v:*):void
        {
            arr[idx] = v;
        }
    }
}
