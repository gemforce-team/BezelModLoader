package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
	public class MultinameData
    {
        public var type:int;
        public var subdata:*;

        public function MultinameData(type:int = 0, subdata:* = null)
        {
            this.type = type;
            this.subdata = subdata;
        }
    }
}
