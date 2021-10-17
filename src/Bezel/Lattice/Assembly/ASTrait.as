package Bezel.Lattice.Assembly {
    import Bezel.Lattice.Assembly.values.TraitType;

    /**
     * ...
     * @author Chris
     */
    public class ASTrait {
        public var name:ASMultiname;
        public var type:TraitType;
        public var attributes:int;
        public var extraData:*;
        public var metadata:Vector.<ASMetadata>;

        public function equals(other:ASTrait):Boolean {
            return other != null && name.equals(other.name) && type == other.type && attributes == other.attributes && extraData.equals(other.extraData);
        }
    }
}
