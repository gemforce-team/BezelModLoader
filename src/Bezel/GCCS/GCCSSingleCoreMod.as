package Bezel.GCCS
{
    /**
     * ...
     * @author Chris
     */
    internal class GCCSSingleCoreMod
    {
        private var _matches:Array;
        public function get matches():Array
        {
            return _matches;
        }
        private var _offset:int;
        public function get offset():int
        {
            return _offset;
        }
        private var _replacenum:int;
        public function get replacenum():int
        {
            return _replacenum;
        }
        private var _contents:String;
        public function get contents():String
        {
            return _contents;
        }

        public function GCCSSingleCoreMod(match:*, offset:int, replacenum:int, contents:String)
        {
            if (match is Array)
            {
                _matches = match;
            }
            else
            {
                _matches = [match];
            }

            _offset = offset;
            _replacenum = replacenum;
            _contents = contents;
        }
    }
}
