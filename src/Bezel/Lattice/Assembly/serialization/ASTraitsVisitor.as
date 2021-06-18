package Bezel.Lattice.Assembly.serialization
{
    import Bezel.Lattice.Assembly.ASProgram;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;

    /**
     * ...
     * @author Chris
     */
    public class ASTraitsVisitor
    {
        protected var asp:ASProgram;

        public function ASTraitsVisitor(asp:ASProgram)
        {
            this.asp = asp;
        }

        public function run():void
        {
            for each (var script:ASScript in asp.scripts)
            {
                visitTraits(script.traits);
            }
        }

        public final function visitTraits(traits:Vector.<ASTrait>):void
        {
            for each (var trait:ASTrait in traits)
            {
                visitTrait(trait);
            }
        }

        public function visitTrait(trait:ASTrait):void
        {
            switch (trait.type)
            {
                case TraitType.Slot:
                case TraitType.Const:
                    break;
                case TraitType.Class:
                    visitTraits((trait.extraData as ASTraitClass).classv.traits);
                    visitTraits((trait.extraData as ASTraitClass).classv.instance.traits);
                    break;
                case TraitType.Function:
                    if ((trait.extraData as ASTraitFunction).functionv.body != null)
                    {
                        visitTraits((trait.extraData as ASTraitFunction).functionv.body.traits);
                    }
                    break;
                case TraitType.Method:
                case TraitType.Getter:
                case TraitType.Setter:
                    if ((trait.extraData as ASTraitMethod).method.body != null)
                    {
                        visitTraits((trait.extraData as ASTraitMethod).method.body.traits);
                    }
                    break;
                default:
                    throw new Error("Unknown trait type");
            }
        }
    }
}
