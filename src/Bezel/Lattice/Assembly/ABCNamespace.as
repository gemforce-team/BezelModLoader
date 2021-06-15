package Bezel.Lattice.Assembly
{
	import Bezel.Lattice.Assembly.values.ABCType;

	/**
	 * ...
	 * @author Chris
	 */
	public class ABCNamespace
    {
        public var type:ABCType;
        public var name:uint;

        public function ABCNamespace(type:ABCType = null, name:uint = 0)
        {
            this.type = type;
            this.name = name;
        }
    }
}
