package Bezel.Lattice
{
	/**
	 * Storage class for Lattice patches
	 * @author piepie62
	 */

    internal class LatticePatch
    {
        internal var filename:String;
        internal var offset:uint;
        internal var overwritten:uint;
        internal var contents:String;
		internal var causesConflict:Boolean;

        public function LatticePatch(filename:String, offset:int, overwritten:int, contents:String, causesConflict:Boolean = true)
        {
            this.filename = filename;
            this.offset = offset;
            this.overwritten = overwritten;
            this.contents = contents;
			this.causesConflict = causesConflict;
        }
    }
}
