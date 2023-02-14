package Bezel.Lattice
{
    import com.cff.anebe.ir.ASMultiname;

    internal class LatticePatcherEntry
    {
        public var patcher:LatticePatcher;
        public var name:ASMultiname;

        public function LatticePatcherEntry(patcher:LatticePatcher, name:ASMultiname)
        {
            this.patcher = patcher;
            this.name = name;
        }
    }
}
