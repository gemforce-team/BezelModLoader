package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.ABCType;

    /**
	 * ...
	 * @author Chris
	 */
    public class ABCDefaultOption
    {
        public var index:int;
        public var type:ABCType;

        public function ABCDefaultOption(index:int, type:ABCType)
        {
            this.index = index;
            this.type = type;
        }
    }
}
