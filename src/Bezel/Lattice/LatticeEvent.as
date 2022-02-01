package Bezel.Lattice
{
    import flash.errors.IllegalOperationError;

	/**
	 * Lattice lifetime events
	 * @author piepie62
	 */
    public class LatticeEvent
    {
        public static const REBUILD_DONE:String = "rebuildDone";
        public static const DISASSEMBLY_DONE:String = "disassemblyDone";

        public function LatticeEvent()
        {
            throw new IllegalOperationError("Illegal instantiation!");
        }
    }
}
