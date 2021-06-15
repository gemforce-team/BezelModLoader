package Bezel.Lattice.Assembly.trait
{
    import Bezel.Lattice.Assembly.ASMethod;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASTraitFunction
    {
        public var slotId:int;
        public var functionv:ASMethod;

        public function ASTraitFunction(slotId:int = 0, functionv:ASMethod = null)
        {
            this.slotId = slotId;
            this.functionv = functionv;
        }
    }
}
