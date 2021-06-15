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

        public function ASTypeName(name:ASMultiname, params:Vector.<ASMultiname>)
        {
            this.name = name;
            this.params = params;
        }
    }
}
