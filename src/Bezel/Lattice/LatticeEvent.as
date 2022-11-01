package Bezel.Lattice
{
    import flash.errors.IllegalOperationError;

    /**
     * Lattice lifetime events
     * @author piepie62
     */
    public class LatticeEvent
    {
        /** Indicates that the lattice patch and rebuild (essentially, the entire process handled by lattice.apply()) has finished */
        public static const REBUILD_DONE:String = "rebuildDone";

        /** Indicates that the lattice disassembly, if it was required, is done. */
        public static const DISASSEMBLY_DONE:String = "disassemblyDone";

        /** Indicates that a single coremod has been applied. Mostly meant for display to users */
        public static const SINGLE_PATCH_APPLIED:String = "singleCoremodApplied";

        /** Indicates that the reassembly has been started. Mostly meant for display to users */
        public static const REASSEMBLY_STARTED:String = "reassemblyStarted";

        public function LatticeEvent()
        {
            throw new IllegalOperationError("Illegal instantiation!");
        }
    }
}
