package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASMethod {
        public var paramTypes:Vector.<ASMultiname>;
        public var returnType:ASMultiname;
        public var name:String;
        public var flags:uint;
        public var options:Vector.<ASValue>;
        public var paramNames:Vector.<String>;

        public var id:uint;

        public var body:ASMethodBody;

        public function equals(other:ASMethod):Boolean {
            if (other == null)
                return false;
            if (paramTypes.length != other.paramTypes.length || paramNames.length != other.paramNames.length || options.length != other.options.length)
                return false;
            if (((returnType == null) != (other.returnType == null)) || (returnType != null && !returnType.equals(other.returnType)) || name != other.name || flags != other.flags || id != other.id)
                return false;

            // Intentionally shallow check: if a non-shallow check would return something different, something is VERY wrong
            // if (body != other.body)
            //     return false;
            for (var i:int = 0; i < paramTypes.length; i++) {
                if (!paramTypes[i].equals(other.paramTypes[i])) {
                    return false;
                }
            }

            for (i = 0; i < paramNames.length; i++) {
                if (paramNames[i] != other.paramNames[i]) {
                    return false;
                }
            }

            for (i = 0; i < options.length; i++) {
                if (!options[i].equals(other.options[i])) {
                    return false;
                }
            }

            return true;
        }
    }
}
