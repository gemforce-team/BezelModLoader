package Bezel.Lattice.Assembly.conversion.context
{
    /**
     * ...
     * @author Chris
     */
    public class Segment
    {
        public var delim:String;
        public var str:String;

        public function toString():String
        {
            return "{ \"" + str + "\", \'" + delim + "\' }";
        }

        public function Segment(chr:String, str:String)
        {
            this.delim = chr;
            this.str = str;
        }
    }
}
