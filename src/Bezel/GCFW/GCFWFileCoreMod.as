package Bezel.GCFW
{
    /**
     * ...
     * @author Chris
     */
    internal class GCFWFileCoreMod
    {
        private var _filename:String;
        public function get filename():String { return _filename; }
        private var _matches:Array;
        public function get matches():Array { return _matches; }
        private var _offsets:Array;
        public function get offsets():Array { return _offsets; }
        private var _replacenums:Array;
        public function get replaceNums():Array { return _replacenums; }
        private var _contents:Array;
        public function get contents():Array { return _contents; }

        public function GCFWFileCoreMod(filename:String, matches:Array, offsets:Array, replacenums:Array, contents:Array)
        {
            this._filename = filename;
            this._matches = matches;
            this._offsets = offsets;
            this._replacenums = replacenums;
            this._contents = contents;
        }
    }
}
