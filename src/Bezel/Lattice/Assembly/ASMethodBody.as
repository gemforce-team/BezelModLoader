package Bezel.Lattice.Assembly
{
    /**
     * ...
     * @author Chris
     */
    public class ASMethodBody
    {
        public var method:ASMethod;
        public var maxStack:int;
        public var localCount:int;
        public var initScopeDepth:int;
        public var maxScopeDepth:int;
        public var instructions:Vector.<ASInstruction>;
        public var exceptions:Vector.<ASException>;
        public var traits:Vector.<ASTrait>;
    }
}
