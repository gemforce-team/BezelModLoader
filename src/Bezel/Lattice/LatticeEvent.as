package Bezel.Lattice
{
    import flash.errors.IllegalOperationError;

    public class LatticeEvent
    {
        public static const REBUILD_DONE:String = "abcreplaceDone";
        public static const DISASSEMBLY_DONE:String = "disassemblyDone";

        public function LatticeEvent()
        {
            throw new IllegalOperationError("Illegal instantiation!");
        }
    }
}
