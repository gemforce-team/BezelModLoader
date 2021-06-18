package Bezel.Lattice.Assembly.serialization.context
{
    /**
     * ...
     * @author Chris
     */
    public class Segment
    {
        public var delim:int;
        public var str:String;

        public function Segment(chr:String, str:String)
        {
            this.delim = chr.charCodeAt(0);
            this.str = str;
        }
    }
}
