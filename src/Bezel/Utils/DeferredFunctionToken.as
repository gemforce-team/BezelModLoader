package Bezel.Utils
{
    internal class DeferredFunctionToken
    {
        public var func:Function;
        public var that:*;
        public var args:Array;
        public var forceFrame:Boolean;

        public function DeferredFunctionToken(func:Function, that:*, args:Array, forceFrame:Boolean)
        {
            this.func = func;
            this.args = args;
            this.forceFrame = forceFrame;
        }
    }
}
