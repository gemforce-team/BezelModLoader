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

        public static const SINGLE_PATCH_APPLIED:String = "singleCoremodApplied";

        public function LatticeEvent()
        {
            throw new IllegalOperationError("Illegal instantiation!");
        }
    }
}
