package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCClass
    {
        public var cinit:int;
        public var traits:Vector.<TraitInfo>;

        public function ABCClass(cinit:int = 0, traits:Vector.<TraitInfo> = null)
        {
            this.cinit = cinit;
            this.traits = traits;
        }
    }
}
