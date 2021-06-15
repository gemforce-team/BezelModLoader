package Bezel.Lattice.Assembly
{
    /**
	 * ...
	 * @author Chris
	 */
	public class ASMethod
    {
		public var paramTypes:Vector.<ASMultiname>;
		public var returnType:ASMultiname;
		public var name:String;
		public var flags:uint;
		public var options:Vector.<ASValue>;
		public var paramNames:String;

		public var id:uint;

		public var body:ASMethodBody;
    }
}
