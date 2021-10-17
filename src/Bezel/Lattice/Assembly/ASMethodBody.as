package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASMethodBody {
        public var method:ASMethod;
        public var maxStack:int;
        public var localCount:int;
        public var initScopeDepth:int;
        public var maxScopeDepth:int;
        public var instructions:Vector.<ASInstruction>;
        public var exceptions:Vector.<ASException>;
        public var traits:Vector.<ASTrait>;

        public function equals(other:ASMethodBody):Boolean {
            if (other == null)
                return false;

            // Intentionally shallow check; if a non-shallow check would return something different, something is VERY wrong
            // if (method != other.method)
            //     return false;

            if (instructions.length != other.instructions.length || exceptions.length != other.exceptions.length || traits.length != other.traits.length)
                return false;
            if (maxStack != other.maxStack || localCount != other.localCount || initScopeDepth != other.initScopeDepth || maxScopeDepth != other.maxScopeDepth)
                return false;

            for (var i:int = 0; i < instructions.length; i++) {
                if (!instructions[i].equals(other.instructions[i])) {
                    return false;
                }
            }

            for (i = 0; i < exceptions.length; i++) {
                if (!other.exceptions.some(function(j:ASException, _:*, __:*):Boolean {
                    return exceptions[i].equals(j);
                })) {
                    return false;
                }
            }

            for (i = 0; i < traits.length; i++) {
                if (!other.traits.some(function(j:ASTrait, _:*, __:*):Boolean {
                    return traits[i].equals(j);
                })) {
                    return false;
                }
            }

            return true;
        }
    }
}
