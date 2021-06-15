package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ABCMethodBody
    {
        public var method:int;
        public var maxStack:int;
        public var localCount:int;
        public var initScopeDepth:int;
        public var maxScopeDepth:int;
        public var instructions:Vector.<ABCInstruction>;
        public var exceptions:Vector.<ABCException>;
        public var traits:Vector.<ABCTrait>;

        public function ABCMethodBody(method:int = 0, maxStack:int = 0, localCount:int = 0, initScopeDepth:int = 0, maxScopeDepth:int = 0, instructions:Vector.<ABCInstruction> = null, exceptions:Vector.<ABCException> = null, traits:Vector.<ABCTrait> = null)
        {
            this.method = method;
            this.maxStack = maxStack;
            this.localCount = localCount;
            this.initScopeDepth = initScopeDepth;
            this.maxScopeDepth = maxScopeDepth;
            this.instructions = instructions;
            this.exceptions = exceptions;
            this.traits = traits;
        }
    }
}
