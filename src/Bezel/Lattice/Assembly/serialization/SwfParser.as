package Bezel.Lattice.Assembly.serialization
{
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import Bezel.Lattice.Assembly.serialization.ABCTagData;
	import Bezel.Lattice.Assembly.ABCFile;
	import Bezel.Lattice.Assembly.ABCWriter;
	/**
	 * ...
	 * @author Chris
	 */
	public class SwfParser 
	{
		private var abcTag:ABCTagData;
		private var _editedSwf:ByteArray;

		private static const ABCTAG_WRITE_TYPE:uint = 0x14BF; // 82 << 6 | 0x3F

		public function get abcFile():ABCFile { return abcTag.abc; }
		
		public function SwfParser(swf:IDataInput)
		{
			_editedSwf = new ByteArray();
			_editedSwf.endian = Endian.LITTLE_ENDIAN;
			
			var signature:String = swf.readUTFBytes(3);
			var version:uint = swf.readUnsignedByte();
			var fileSizeDecompressed:uint = swf.readUnsignedInt();
			var restOfData:ByteArray = new ByteArray();
			restOfData.endian = Endian.LITTLE_ENDIAN;
			swf.readBytes(restOfData);
			
			if (signature == "CWS")
			{
				restOfData.uncompress(CompressionAlgorithm.ZLIB);
			}
			else if (signature == "ZWS")
			{
				restOfData.uncompress(CompressionAlgorithm.LZMA);
			}
			else if (signature != "FWS")
			{
				throw new Error("The given data was not a valid SWF");
			}
			
			_editedSwf.writeUTFBytes("FWS");
			_editedSwf.writeByte(version);
			// Placeholder for number of bytes
			_editedSwf.writeUnsignedInt(0);
			
			// Get data about the frame
			var frameSize:uint = restOfData.readUnsignedByte() >> 3;
			restOfData.position -= 1;
			frameSize = frameSize * 4 + 5;
			if (frameSize % 8 != 0)
			{
				frameSize += 8 - (frameSize % 8);
			}
			frameSize /= 8;
			// Write frame RECT
			restOfData.readBytes(_editedSwf, _editedSwf.length, frameSize);
			// Frame rate
			_editedSwf.writeShort(restOfData.readUnsignedShort());
			// Frame count
			_editedSwf.writeShort(restOfData.readUnsignedShort());
			
			// ABC tag data for use with ABC
			var abcData:ByteArray = new ByteArray();
			abcData.endian = Endian.LITTLE_ENDIAN;
			
			var tags:Vector.<uint> = new Vector.<uint>();
			
			while (restOfData.bytesAvailable != 0)
			{
				var tagType:uint = restOfData.readUnsignedShort();
				var tagSize:uint = tagType & 0x3F;
				tagType = tagType >> 6;
				if (tagSize == 0x3F)
				{
					tagSize = restOfData.readUnsignedInt();
				}
				
				tags.push(tagType, tagSize);
				
				// DoABC2
				if (tagType == 82)
				{
					if (abcData.length != 0)
					{
						throw new Error("More than one DoABC2 tag found in the given SWF");
					}
					restOfData.readBytes(abcData, 0, tagSize);
				}
				else if (tagType == 72)
				{
					throw new Error("DoABC tags are currently unsupported. DoABC2 tags are");
				}
				else
				{
					var newTagHeader:uint = (tagType << 6) | (tagSize > 0x3F ? 0x3F : tagSize);
					_editedSwf.writeShort(newTagHeader);
					if (tagSize >= 0x3F)
					{
						_editedSwf.writeUnsignedInt(tagSize);
					}
					if (tagSize > 0)
					{
						restOfData.readBytes(_editedSwf, _editedSwf.length, tagSize);
					}
				}
			}
			
			if (abcData.length == 0)
			{
				throw new Error("Empty or no ABC found");
			}
			
			this.abcTag = new ABCTagData(abcData);
		}

		public function replaceABC(abc:ABCFile):ByteArray
		{
			var writer:ABCWriter = new ABCWriter(abc);
			var newBytes:ByteArray = writer.data;
			_editedSwf.position = _editedSwf.length;
			_editedSwf.writeShort(ABCTAG_WRITE_TYPE);
			_editedSwf.writeUnsignedInt(newBytes.length);
			_editedSwf.writeBytes(newBytes);
			_editedSwf.position = 4;
			_editedSwf.writeUnsignedInt(_editedSwf.length);
			_editedSwf.position = 0;
			return _editedSwf;
		}
	}
}
