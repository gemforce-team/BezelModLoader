package Bezel.Lattice.Assembly.multiname
{
    /**
	 * ...
	 * @author Chris
	 */
    public class QName
    {
        public var ns:int;
        public var name:int;

        public function QName(ns:int = 0, name:int = 0)
        {
            this.ns = ns;
            this.name = name;
        }
    }
}
