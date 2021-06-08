package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class Metadata
    {
        public var name:int;
        public var keys:Vector.<int>;
        public var values:Vector.<int>;

        public function Metadata(name:int = 0, keys:Vector.<int> = null, values:Vector.<int> = null)
        {
            this.name = name;
            this.keys = keys;
            this.values = values;
        }
    }
}
