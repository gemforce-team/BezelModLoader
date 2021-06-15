package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCScript
    {
        public var sinit:int;
        public var traits:Vector.<ABCTrait>;

        public function ABCScript(sinit:int = 0, traits:Vector.<ABCTrait> = null)
        {
            this.sinit = sinit;
            this.traits = traits;
        }
    }
}
