package Bezel.Utils 
{
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Christopher Feger
	 */
	public class CCITT16 
	{
		
		public static function computeDigest(data:ByteArray): uint
		{
			var chk:uint = 0xFFFF;
			for (var i:uint = 0; i < data.length; i++)
			{
				chk ^= data[i] << 8;
				for (var j:uint = 0; j < 8; j++)
				{
					if ((chk & 0x8000) != 0)
					{
						chk = ((chk << 1) ^ 0x1021) & 0xFFFF;
					}
					else
					{
						chk = (chk << 1) & 0xFFFF;
					}
				}
			}

			return chk;
		}
		
		public function CCITT16() 
		{
			throw new IllegalOperationError("Illegal instantiation of CCITT16");
		}
		
	}

}
