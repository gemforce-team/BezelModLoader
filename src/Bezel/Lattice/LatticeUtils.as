package Bezel.Lattice 
{
    import Bezel.bezel_internal;
    import flash.utils.ByteArray;
    import flash.utils.IDataOutput;
    use namespace bezel_internal;
	/**
	 * ...
	 * @author Chris
	 */
	public class LatticeUtils 
	{
		
		bezel_internal static function readNTString(data:ByteArray): String
        {
            var num:uint = 0;
            while (num + data.position < data.length && data[num + data.position] != 0)
            {
                ++num;
            }

            var ret:String = data.readUTFBytes(num);
            data.position++; // Consume the null terminator
            return ret;
        }

        bezel_internal static function writeNTString(stream:IDataOutput, data:String): void
        {
            stream.writeUTFBytes(data);
            stream.writeByte(0);
        }
		
	}

}
