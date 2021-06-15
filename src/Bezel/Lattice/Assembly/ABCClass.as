package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCClass
    {
        public var cinit:int;
        public var traits:Vector.<ABCTrait>;

        public function ABCClass(cinit:int = 0, traits:Vector.<ABCTrait> = null)
        {
            this.cinit = cinit;
            this.traits = traits;
        }
    }
}
