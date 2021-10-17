package Bezel.Lattice.Assembly
{
    import Bezel.Lattice.Assembly.values.ABCType;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.multiname.ABCQName;
    import Bezel.Lattice.Assembly.multiname.ASRTQName;
    import Bezel.Lattice.Assembly.multiname.ASRTQNameL;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ABCRTQName;
    import Bezel.Lattice.Assembly.multiname.ABCMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameL;
    import Bezel.Lattice.Assembly.multiname.ABCMultinameL;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.multiname.ABCTypeName;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.trait.ABCTraitSlot;
    import Bezel.Lattice.Assembly.trait.ABCTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ABCTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ABCTraitMethod;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Logger;

    /**
	 * ...
	 * @author Chris
	 */
	public class ASProgram
    {
        public var minorVersion:int;
        public var majorVersion:int;
        public var scripts:Vector.<ASScript>;
        public var orphanClasses:Vector.<ASClass>;
        public var orphanMethods:Vector.<ASMethod>;

        public function ASProgram()
        {
            this.minorVersion = 16;
            this.majorVersion = 46;

            this.scripts = new <ASScript>[];
            this.orphanClasses = new <ASClass>[];
            this.orphanMethods = new <ASMethod>[];
        }
    }
}
