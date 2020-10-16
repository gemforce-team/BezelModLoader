package Bezel.Lattice
{
    public class LatticeConstructor
    {
        // locals[name] = index
        private var originalLocals:Object;
        private var locals:Object;
        // params[name] = param type (as string)
        private var params:Object;
        private var returnType:String;
        private var maxStack:uint;
        private var localCount:uint;
        private var initScopeDepth:uint;
        private var maxScopeDepth:uint;

        private var name:String;
        private var refid:String;

        public function LatticeConstructor(contents:String)
        {
            var found:Object = /maxstack (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max stack depth")
            }
            this.maxStack = uint(found[1]);
            found = /localcount (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve local count")
            }
            this.localCount = uint(found[1]);
            found = /initscopedepth (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max scope depth")
            }
            this.initScopeDepth = uint(found[1]);
            found = /maxscopedepth (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max scope depth")
            }
            this.maxScopeDepth = uint(found[1]);
            
            // TODO: body
        }
    }
}
