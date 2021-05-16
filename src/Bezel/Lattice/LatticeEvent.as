package Bezel.Lattice
{
	/**
	 * Lattice lifetime events. Shouldn't be used by anything other than Bezel.Bezel
	 * @author piepie62
	 */
	
	import Bezel.bezel_internal;

    import flash.errors.IllegalOperationError;

    public class LatticeEvent
    {
        bezel_internal static const REBUILD_DONE:String = "rebuildDone";
        bezel_internal static const DISASSEMBLY_DONE:String = "disassemblyDone";

        public function LatticeEvent()
        {
            throw new IllegalOperationError("Illegal instantiation!");
        }
    }
}
