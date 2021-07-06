package Bezel.Lattice.Assembly.multiname
{
    /**
	 * ...
	 * @author Chris
	 */
    public class ASRTQName
    {
        public var name:String;

        public function toString():String
        {
            return ", " + name;
        }

        public function equals(other:ASRTQName):Boolean
        {
            return name == other.name;
        }

        public function ASRTQName(name:String)
        {
            this.name = name;
        }
    }
}
