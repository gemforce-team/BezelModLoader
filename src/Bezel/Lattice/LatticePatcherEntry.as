package Bezel.Lattice
{
    import com.cff.anebe.ir.ASMultiname;

    internal class LatticePatcherEntry
    {
        public var patcher:LatticePatcher;
        public var name:ASMultiname;
        public var idx:uint;

        public function LatticePatcherEntry(patcher:LatticePatcher, name:ASMultiname, idx:uint)
        {
            this.patcher = patcher;
            this.name = name;
            this.idx = idx;
        }
    }
}
