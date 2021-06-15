package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.ABCType;

    /**
	 * ...
	 * @author Chris
	 */
	public class ABCMultiname
    {
        public var type:ABCType;
        public var subdata:*;

        public function ABCMultiname(type:ABCType = null, subdata:* = null)
        {
            this.type = type;
            this.subdata = subdata;
        }
    }
}
