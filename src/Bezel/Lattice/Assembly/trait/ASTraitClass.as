package Bezel.Lattice.Assembly.trait
{
    import Bezel.Lattice.Assembly.ASClass;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASTraitClass
    {
        public var slotId:int;
        public var classv:ASClass;

        public function ASTraitClass(slotId:int = 0, classv:ASClass = null)
        {
            this.slotId = slotId;
            this.classv = classv;
        }
    }
}
