package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCScript
    {
        public var sinit:int;
        public var traits:Vector.<TraitInfo>;

        public function ABCScript(sinit:int = 0, traits:Vector.<TraitInfo> = null)
        {
            this.sinit = sinit;
            this.traits = traits;
        }
    }
}
