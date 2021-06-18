package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.TraitType;

    /**
     * ...
     * @author Chris
     */
    public class ASTrait
    {
        public var name:ASMultiname;
        public var type:TraitType;
        public var attributes:int;
        public var extraData:*;
        public var metadata:Vector.<ASMetadata>;
    }
}
