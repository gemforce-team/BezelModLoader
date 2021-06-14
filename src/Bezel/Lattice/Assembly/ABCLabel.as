package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCLabel
    {
        public var index:uint;
        public var offset:int;

        public function ABCLabel(index:uint = uint.MAX_VALUE, offset:int = int.MAX_VALUE)
        {
            this.index = index;
            this.offset = offset;
        }
    }
}
