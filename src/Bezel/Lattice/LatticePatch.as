package Bezel.Lattice
{
	/**
	 * ...
	 * @author piepie62
	 */

    internal class LatticePatch
    {
        internal var filename:String;
        internal var offset:uint;
        internal var overwritten:uint;
        internal var contents:String;

        public function LatticePatch(filename:String, offset:int, overwritten:int, contents:String)
        {
            this.filename = filename;
            this.offset = offset;
            this.overwritten = overwritten;
            this.contents = contents;
        }
    }
}
