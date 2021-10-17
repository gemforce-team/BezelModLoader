package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASClass {
        public var cinit:ASMethod;
        public var traits:Vector.<ASTrait>;

        public var instance:ASInstance;

        public function equals(other:ASClass):Boolean {
            if (other == null)
                return false;
            if (!instance.equals(other.instance))
                return false;
            if (!cinit.equals(other.cinit))
                return false;
            for (var trait:ASTrait in traits) {
                if (!other.traits.some(function(i:ASTrait, _:*, __:*):Boolean {
                    return (i == null && trait == null) || (i != null && i.equals(trait));
                })) {
                    return false;
                }
            }

            return true;
        }
    }
}
