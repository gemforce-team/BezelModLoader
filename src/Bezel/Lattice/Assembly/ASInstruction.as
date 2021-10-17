package Bezel.Lattice.Assembly {

    import flash.utils.getQualifiedClassName;

    /**
     * ...
     * @author Chris
     */
    public class ASInstruction {
        public var opcode:Opcode;

        // May contain int, uint, Number, String, ASNamespace, ASMultiname, ASClass, ASMethod, InstructionLabel, or Vector.<InstructionLabel>
        public var arguments:Array;

        public function equals(other:ASInstruction):Boolean {
            if (other == null)
                return false;
            if (opcode != other.opcode)
                return false;
            if (arguments.length != other.arguments.length)
                return false;

            for (var i:int = 0; i < arguments.length; i++) {
                if (getQualifiedClassName(arguments[i]) != getQualifiedClassName(other.arguments[i]))
                    return false;
                if ((arguments[i] is int || arguments[i] is uint || arguments[i] is String) && arguments[i] != other.arguments[i])
                    return false;
                if (arguments[i] is Number && ((isNaN(arguments[i]) != isNaN(other.arguments[i])) || arguments[i] != other.arguments[i]))
                    return false;
                if ((arguments[i] is ASNamespace || arguments[i] is ASMultiname || arguments[i] is ASClass || arguments[i] is ASMethod || arguments[i] is InstructionLabel) && !arguments[i].equals(other.arguments[i]))
                    return false;
                if (arguments[i] is Vector.<InstructionLabel>) {
                    for (var j:int = 0; j < (arguments[i] as Vector.<InstructionLabel>).length; j++) {
                        if (!(arguments[i] as Vector.<InstructionLabel>)[j].equals((other.arguments[i] as Vector.<InstructionLabel>)[j])) {
                            return false;
                        }
                    }
                }
            }

            return true;
        }
    }
}
