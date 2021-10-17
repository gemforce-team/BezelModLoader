package Bezel.Lattice.Assembly {

    /**
     * ...
     * @author Chris
     */
    public class ASMetadata {
        public var name:String;
        public var keys:Vector.<String>;
        public var values:Vector.<String>;

        public function equals(other:ASMetadata):Boolean {
            if (other == null)
                return false;
            if (name != other.name)
                return false;
            if (keys.length != other.keys.length)
                return false;
            for (var i:int = 0; i < keys.length; i++) {
                if (keys[i] != other.keys[i] || values[i] != other.values[i])
                    return false;
            }

            return true;
        }
    }
}
