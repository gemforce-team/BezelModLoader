package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASInstance {
        public var name:ASMultiname;
        public var superName:ASMultiname;
        public var flags:uint;
        public var protectedNs:ASNamespace;
        public var interfaces:Vector.<ASMultiname>;
        public var iinit:ASMethod;
        public var traits:Vector.<ASTrait>;

        public function equals(other:ASInstance):Boolean {
            if (other == null)
                return false;
            if (interfaces.length != other.interfaces.length || traits.length != other.traits.length)
                return false;
            if (!name.equals(other.name) || !superName.equals(other.superName) || flags != other.flags || !protectedNs.equals(other.protectedNs) || !iinit.equals(other.iinit))
                return false;

            for (var i:int = 0; i < interfaces.length; i++) {
                if (!other.interfaces.some(function(j:ASMultiname, _:*, __:*):Boolean {
                    return interfaces[i].equals(j);
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

            return false;
        }
    }
}
