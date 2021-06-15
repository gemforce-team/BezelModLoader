package Bezel.Lattice.Assembly.trait
{
    import Bezel.Lattice.Assembly.ASMethod;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASTraitMethod
    {
        public var slotId:int;
        public var method:ASMethod;

        public function ASTraitMethod(slotId:int = 0, method:ASMethod = null)
        {
            this.slotId = slotId;
            this.method = method;
        }
    }
}
