package Bezel.Lattice.Assembly {
    import Bezel.Lattice.Assembly.values.ABCType;
    import flash.utils.getQualifiedClassName;

    /**
     * ...
     * @author Chris
     */
    public class ASValue {
        public var type:ABCType;
        // One of int, uint, Number, String, or ASNamespace
        public var data:*;

        public function equals(other:ASValue):Boolean {
            if (other == null)
                return false;
            if (type != other.type)
                return false;
            if (getQualifiedClassName(data) != getQualifiedClassName(other.data))
                return false;
            if ((data is int || data is uint || data is Number || data is String) && data != other.data)
                return false;
            if (!(data is ASNamespace))
                return false; // Should never happen
            return (data as ASNamespace).equals(other.data as ASNamespace);
        }
    }
}
