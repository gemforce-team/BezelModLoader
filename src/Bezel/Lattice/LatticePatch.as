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

        public static function compare(patch1:LatticePatch, patch2:LatticePatch):int
        {
            if (patch1.filename < patch2.filename)
            {
                return -1;
            }
            else if (patch2.filename < patch1.filename)
            {
                return 1;
            }
            else
            {
                if (patch1.offset < patch2.offset)
                {
                    return 1;
                }
                else if (patch2.offset < patch1.offset)
                {
                    return -1;
                }
                else
                {
                    if (!patch1.causesConflict && patch2.causesConflict)
                    {
                        return -1;
                    }
                    else if (patch1.causesConflict && !patch2.causesConflict)
                    {
                        return 1;
                    }
                    else
                    {
                        if (patch1.overwritten < patch2.overwritten)
                        {
                            return 1;
                        }
                        else if (patch2.overwritten < patch1.overwritten)
                        {
                            return -1;
                        }
                        else
                        {
                            if (patch1.contents < patch2.contents)
                            {
                                return -1;
                            }
                            else if (patch2.contents < patch1.contents)
                            {
                                return 1;
                            }
                            else
                            {
                                return 0;
                            }
                        }
                    }
                }
            }
        }
    }
}
