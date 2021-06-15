package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.ABCType;

    /**
	 * ...
	 * @author Chris
	 */
	public class ASNamespace
    {
        public var type:ABCType;
        public var name:String;

        public var uniqueId:uint;

        public function ASNamespace(type:ABCType, name:String, id:uint)
        {
            this.type = type;
            this.name = name;
            this.uniqueId = id;
        }
    }
}
