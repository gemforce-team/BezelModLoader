package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
    public class MethodBody
    {
        public var method:int;
        public var maxStack:int;
        public var localCount:int;
        public var initScopeDepth:int;
        public var maxScopeDepth:int;
        public var instructions:Vector.<Instruction>;
        public var exceptions:Vector.<ExceptionInfo>;
        public var traits:Vector.<TraitInfo>;

        public function MethodBody(method:int = 0, maxStack:int = 0, localCount:int = 0, initScopeDepth:int = 0, maxScopeDepth:int = 0, instructions:Vector.<Instruction> = null, exceptions:Vector.<ExceptionInfo> = null, traits:Vector.<TraitInfo> = null)
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
