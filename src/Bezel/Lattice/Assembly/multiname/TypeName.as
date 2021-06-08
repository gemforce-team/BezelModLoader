package Bezel.Lattice.Assembly.multiname
{
    /**
	 * ...
	 * @author Chris
	 */
    public class TypeName
    {
        public var name:int;
        public var params:Vector.<int>;

        public function TypeName(name:int = 0, params:Vector.<int> = null)
        {
            this.name = name;
            this.params = params;
        }
    }
}
