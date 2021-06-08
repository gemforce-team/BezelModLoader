package Bezel.Lattice.Assembly
{
	import Bezel.bezel_internal;
	import Bezel.Lattice.LatticeUtils;
	import flash.utils.ByteArray;
	use namespace bezel_internal;
	/**
	 * ...
	 * @author Chris
	 */
	public class ABCTagData 
	{
		private var data:ByteArray;

		private var flags:uint;
		private var name:String;

		private var file:ABCFile;

		
		public function ABCTagData(data:ByteArray) 
		{
			this.data = data;
			this.flags = data.readUnsignedInt();
			this.name = LatticeUtils.readNTString(data);
			
			this.file = ABCFile.parse(data);
		}
	}

}
