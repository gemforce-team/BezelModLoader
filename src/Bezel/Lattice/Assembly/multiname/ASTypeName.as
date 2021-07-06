package Bezel.Lattice.Assembly.multiname
{
    import Bezel.Lattice.Assembly.ASMultiname;

    /**
	 * ...
	 * @author Chris
	 */
    public class ASTypeName
    {
        public var name:ASMultiname;
        public var params:Vector.<ASMultiname>;

        public function toString():String
        {
            var ret:String = ", name = " + name.toString() + ", [";
            for each (var ns:ASMultiname in params)
            {
                ret += ns.toString();
            }
            ret += " ], ";
            return ret;
        }

        public function equals(other:ASTypeName):Boolean
        {
            if (!name.equals(other.name) || params.length != other.params.length) return false;
            for (var i:int = 0; i < params.length; i++)
            {
                if (!params[i].equals(other.params[i])) return false;
            }
            return true;
        }

        public function ASTypeName(name:ASMultiname, params:Vector.<ASMultiname>)
        {
            this.name = name;
            this.params = params;
        }
    }
}
