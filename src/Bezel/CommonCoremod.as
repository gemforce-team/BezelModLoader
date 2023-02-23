package Bezel
{
    import Bezel.Lattice.Lattice;

    internal class CommonCoremod
    {
        public static const VERSION:String = "1";

        public static function apply(lattice:Lattice):void
        {
            lattice.submitInserter(new CommonCreateTextboxInserter());
        }
    }
}

import Bezel.Lattice.LatticeInserter;

import com.cff.anebe.ir.ASInstruction;
import com.cff.anebe.ir.ASMethod;
import com.cff.anebe.ir.ASMethodBody;
import com.cff.anebe.ir.ASMultiname;
import com.cff.anebe.ir.ASScript;
import com.cff.anebe.ir.multinames.ASQName;
import com.cff.anebe.ir.namespaces.PackageNamespace;
import com.cff.anebe.ir.traits.TraitMethod;

class CommonCreateTextboxInserter implements LatticeInserter
{
    public function doInsert(script:ASScript):void
    {
        script.setTrait(TraitMethod(ASQName(PackageNamespace("Bezel.Helpers"), "CreateTextBox"), new ASMethod(
            new <ASMultiname>[ASQName(PackageNamespace("flash.text"), "TextFormat")],
            ASQName(PackageNamespace("flash.text"), "TextField"), "CreateTextBox", null, null, null, new ASMethodBody(
            4, 3, 0, 1, new <ASInstruction>[
                ASInstruction.GetLocal0(),
                ASInstruction.PushScope(),
                ASInstruction.FindPropStrict(ASQName(PackageNamespace("flash.text"), "TextField")),
                ASInstruction.ConstructProp(ASQName(PackageNamespace("flash.text"), "TextField"), 0),
                ASInstruction.SetLocal2(),
                ASInstruction.GetLocal2(),
                ASInstruction.PushTrue(),
                ASInstruction.SetProperty(ASQName(PackageNamespace(""), "embedFonts")),
                ASInstruction.GetLocal2(),
                ASInstruction.GetLocal1(),
                ASInstruction.SetProperty(ASQName(PackageNamespace(""), "defaultTextFormat")),
                ASInstruction.GetLocal2(),
                ASInstruction.ReturnValue()
            ]
            ))));
    }
}
