package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASScript {
        public var sinit:ASMethod;
        public var traits:Vector.<ASTrait>;

        public function equals(other:ASScript):Boolean {
            if (other == null)
                return false;
            if (traits.length != other.traits.length)
                return false;
            if (!sinit.equals(other.sinit))
                return false;
            for (var i:int = 0; i < traits.length; i++) {
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
