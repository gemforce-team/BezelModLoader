package Bezel.Lattice.Assembly
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Bezel.Lattice.Assembly.multiname.RTQName;
	import Bezel.Lattice.Assembly.multiname.RTQNameL;
	import Bezel.Lattice.Assembly.multiname.Multiname;
	import Bezel.Lattice.Assembly.multiname.MultinameL;
	import Bezel.Lattice.Assembly.multiname.TypeName;
	import Bezel.Lattice.Assembly.trait.TraitSlot;
	import Bezel.Lattice.Assembly.trait.TraitClass;
	import Bezel.Lattice.Assembly.trait.TraitFunction;
	import Bezel.Lattice.Assembly.trait.TraitMethod;
	/**
	 * ...
	 * @author Chris
	 */
	public class ABCReader
    {
        private var data:ByteArray;

        public function ABCReader(data:ByteArray)
        {
            this.data = data;
        }

        public function readU8():uint { return data.readUnsignedByte(); }
		public function readU16():uint { return data.readUnsignedShort(); }
		public function readS24():int
		{
			return data.readUnsignedByte() | (data.readUnsignedByte() << 8) | (((int)(data.readUnsignedByte() << 24)) >> 8);
		}
		public function readU32():uint
		{
			var ret:uint = data.readUnsignedByte();
			if ((ret & 0x00000080) == 0)
				return ret;
			ret = (ret & 0x0000007f) | data.readUnsignedByte() << 7;
			if ((ret & 0x00004000) == 0)
				return ret;
			ret = (ret & 0x00003fff) | data.readUnsignedByte() << 14;
			if ((ret & 0x00200000) == 0)
				return ret;
			ret = (ret & 0x001fffff) | data.readUnsignedByte() << 21;
			if ((ret & 0x10000000) == 0)
				return ret;
			return (ret & 0x0fffffff) | data.readUnsignedByte() << 28;
		}
		public function readS32():int
		{
			var ret:uint = data.readUnsignedByte();
			if ((ret & 0x00000080) == 0)
				return ((int)(ret << 25)) >> 25;
			ret = (ret & 0x0000007f) | data.readUnsignedByte() << 7;
			if ((ret & 0x00004000) == 0)
				return ((int)(ret << 18)) >> 18;
			ret = (ret & 0x00003fff) | data.readUnsignedByte() << 14;
			if ((ret & 0x00200000) == 0)
				return ((int)(ret << 11)) >> 11;
			ret = (ret & 0x001fffff) | data.readUnsignedByte() << 21;
			if ((ret & 0x10000000) == 0)
				return ((int)(ret << 4)) >> 4;
			return (ret & 0x0fffffff) | data.readUnsignedByte() << 28;
		}
		public function readU30():uint
		{
			var ret:uint = readU32();
			if (ret & ~0x3FFFFFFF)
			{
				throw new Error("Impossible 30-bit value");
			}
			return ret;
		}
		public function readD64():Number
		{
			return data.readDouble();
		}

		public function readDataTo(ret:ByteArray, size:int):void
		{
			data.readBytes(ret, 0, size);
		}
		
		public function readData(size:int):ByteArray
		{
			var ret:ByteArray = new ByteArray();
			data.readBytes(ret, 0, size);
			return ret;
		}

		public function readString():String
		{
			var size:int = readU30();
			return data.readUTFBytes(size);
		}

		public function readNamespaceInfo():NamespaceInfo
		{
			return new NamespaceInfo(readU8(), readU30());
		}

		public function readNamespaceSet():Vector.<uint>
		{
			var ret:Vector.<uint> = new <uint>[];
			var length:int = readU30();
			for (var i:int = 0; i < length; i++)
			{
				ret.push(readU30());
			}

			return ret;
		}

		public function readMultiname():MultinameData
		{
			var ret:MultinameData = new MultinameData(readU8());
			switch (ret.type)
			{
				case ABCType.QName:
				case ABCType.QNameA:
					ret.subdata = new QName(readU30(), readU30());
					break;
				case ABCType.RTQName:
				case ABCType.RTQNameA:
					ret.subdata = new RTQName(readU30());
					break;
				case ABCType.RTQNameL:
				case ABCType.RTQNameLA:
					ret.subdata = new RTQNameL();
					break;
				case ABCType.Multiname:
				case ABCType.MultinameA:
					ret.subdata = new Multiname(readU30(), readU30());
					break;
				case ABCType.MultinameL:
				case ABCType.MultinameLA:
					ret.subdata = new MultinameL(readU30());
					break;
				case ABCType.TypeName:
					ret.subdata = new TypeName(readU30());
					var num:int = readU30();
					while ((ret.subdata as TypeName).params.length < num)
					{
						(ret.subdata as TypeName).params.push(readU30());
					}
					break;
				default:
					throw new Error("Unknown multiname type");
			}
			return ret;
		}

		public function readMethodInfo():MethodInfo
		{
			var ret:MethodInfo = new MethodInfo(new <int>[]);

			var num:int = readU30();
			ret.returnType = readU30();
			while (ret.parameterTypes.length < num)
			{
				ret.parameterTypes.push(readU30());
			}
			ret.name = readU30();
			ret.flags = readU8();

			if (ret.flags & MethodInfo.FLAG_HAS_OPTIONAL)
			{
				num = readU30();
				ret.defaultOptions = new <DefaultOption>[];
				while (ret.defaultOptions.length < num)
				{
					ret.defaultOptions.push(readDefaultOption());
				}
			}

			if (ret.flags & MethodInfo.FLAG_HAS_PARAM_NAMES)
			{
				num = readU30();
				ret.parameterNames = new <int>[];
				while (ret.parameterNames.length < num)
				{
					ret.parameterNames.push(readU30());
				}
			}

			return ret;
		}

		public function readDefaultOption():DefaultOption
		{
			return new DefaultOption(readU30(), readU8());
		}

		public function readMetadata():Metadata
		{
			var name:int = readU30();
			var num:int = readU30();
			var ret:Metadata = new Metadata(name, new <int>[], new <int>[]);

			while (ret.keys.length < num)
			{
				ret.keys.push(readU30());
				ret.values.push(readU30());
			}

			return ret;
		}

		public function readInstance():Instance
		{
			var ret:Instance = new Instance(readU30(), readU30(), readU8(), 0, new <int>[], 0, new <TraitInfo>[]);

			if (ret.flags & Instance.FLAG_PROTECTEDNS)
			{
				ret.protectedNs = readU30();
			}
			
			var num:int = readU30();
			while (ret.interfaces.length < num)
			{
				ret.interfaces.push(readU30());
			}

			ret.iinit = readU30();
			
			num = readU30();
			while (ret.traits.length < num)
			{
				ret.traits.push(readTraitInfo());
			}

			return ret;
		}

		public function readTraitInfo():TraitInfo
		{
			var ret:TraitInfo = new TraitInfo(readU30());

			var num:int = readU8();
			ret.type = num & 0xF;
			ret.attributes = num >> 4;

			switch (ret.type)
			{
				case TraitInfo.TYPE_SLOT:
				case TraitInfo.TYPE_CONST:
					ret.extraData = new TraitSlot(readU30(), readU30(), readU30());
					if ((ret.extraData as TraitSlot).valueIndex != 0)
					{
						(ret.extraData as TraitSlot).valueType = readU8();
					}
					else
					{
						(ret.extraData as TraitSlot).valueType = ABCType.Void;
					}
					break;
				case TraitInfo.TYPE_CLASS:
					ret.extraData = new TraitClass(readU30(), readU30());
					break;
				case TraitInfo.TYPE_FUNCTION:
					ret.extraData = new TraitFunction(readU30(), readU30());
					break;
				case TraitInfo.TYPE_METHOD:
				case TraitInfo.TYPE_GETTER:
				case TraitInfo.TYPE_SETTER:
					ret.extraData = new TraitMethod(readU30(), readU30());
					break;
				default:
					throw new Error("Unknown trait type");
			}

			if (ret.attributes & TraitInfo.ATTR_METADATA)
			{
				num = readU30();
				ret.metadata = new <int>[];
				while (ret.metadata.length < num)
				{
					ret.metadata.push(readU30());
				}
			}

			return ret;
		}

		public function readABCClass():ABCClass
		{
			var ret:ABCClass = new ABCClass(readU30(), new <TraitInfo>[]);

			var num:int = readU30();
			while (ret.traits.length < num)
			{
				ret.traits.push(readTraitInfo());
			}

			return ret;
		}

		public function readABCScript():ABCScript
		{
			var ret:ABCScript = new ABCScript(readU30(), new <TraitInfo>[]);

			var num:int = readU30();
			while (ret.traits.length < num)
			{
				ret.traits.push(readTraitInfo());
			}

			return ret;
		}

		public function readMethodBody():MethodBody
		{
			var ret:MethodBody = new MethodBody(readU30(), readU30(), readU30(), readU30(), readU30(), new <Instruction>[], new <ExceptionInfo>[], new <TraitInfo>[]);

			var num:int = readU30();
			var startCode:uint = data.position;

			data.position = startCode + num;
			num = readU30();
			while (ret.exceptions.length < num)
			{
				ret.exceptions.push(readExceptionInfo());
			}

			num = readU30();
			while (ret.traits.length < num)
			{
				ret.traits.push(readTraitInfo());
			}

			var endBody:uint = data.position;
			data.position = startCode;

			// TODO: handle instructions



			data.position = endBody;

			return ret;
		}

		public function readExceptionInfo():ExceptionInfo
		{
			return new ExceptionInfo(readU30(), readU30(), readU30(), readU30(), readU30());
		}
    }
}
