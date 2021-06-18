package Bezel.Lattice.Assembly
{
	import flash.utils.ByteArray;
	import Bezel.Lattice.Assembly.multiname.ABCQName;
	import Bezel.Lattice.Assembly.multiname.ABCRTQName;
	import Bezel.Lattice.Assembly.multiname.ABCRTQNameL;
	import Bezel.Lattice.Assembly.multiname.ABCMultinameSubdata;
	import Bezel.Lattice.Assembly.multiname.ABCMultinameL;
	import Bezel.Lattice.Assembly.multiname.ABCTypeName;
	import Bezel.Lattice.Assembly.trait.ABCTraitSlot;
	import Bezel.Lattice.Assembly.trait.ABCTraitClass;
	import Bezel.Lattice.Assembly.trait.ABCTraitFunction;
	import Bezel.Lattice.Assembly.trait.ABCTraitMethod;
	import Bezel.Lattice.Assembly.values.ABCType;
	import Bezel.Lattice.Assembly.values.MethodFlags;
	import Bezel.Lattice.Assembly.values.InstanceFlags;
	import Bezel.Lattice.Assembly.values.TraitType;
	import Bezel.Lattice.Assembly.values.TraitAttributes;
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
		public function readS8():int { return data.readByte(); }
		public function readU16():uint { return data.readUnsignedShort(); }
		public function readS16():int { return data.readShort(); }
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
			if (size == 0) return "";
			return data.readUTFBytes(size);
		}

		public function readNamespace():ABCNamespace
		{
			return new ABCNamespace(ABCType.fromByte(readU8()), readU30());
		}

		public function readNamespaceSet():Vector.<uint>
		{
			var ret:Vector.<uint> = new <uint>[];
			var num:int = readU30();
			for (var i:int = 0; i < num; i++)
			{
				ret.push(readU30());
			}

			return ret;
		}

		public function readMultiname():ABCMultiname
		{
			var ret:ABCMultiname = new ABCMultiname(ABCType.fromByte(readU8()));
			switch (ret.type)
			{
				case ABCType.QName:
				case ABCType.QNameA:
					ret.subdata = new ABCQName(readU30(), readU30());
					break;
				case ABCType.RTQName:
				case ABCType.RTQNameA:
					ret.subdata = new ABCRTQName(readU30());
					break;
				case ABCType.RTQNameL:
				case ABCType.RTQNameLA:
					ret.subdata = new ABCRTQNameL();
					break;
				case ABCType.Multiname:
				case ABCType.MultinameA:
					ret.subdata = new ABCMultinameSubdata(readU30(), readU30());
					break;
				case ABCType.MultinameL:
				case ABCType.MultinameLA:
					ret.subdata = new ABCMultinameL(readU30());
					break;
				case ABCType.TypeName:
					ret.subdata = new ABCTypeName(readU30(), new <int>[]);
					var num:int = readU30();
					for (var i:int = 0; i < num; i++)
					{
						(ret.subdata as ABCTypeName).params.push(readU30());
					}
					break;
				default:
					throw new Error("Unknown multiname type");
			}
			return ret;
		}

		public function readMethodInfo():ABCMethodInfo
		{
			var ret:ABCMethodInfo = new ABCMethodInfo(new <int>[], 0, 0, 0, new <ABCDefaultOption>[], new <int>[]);

			var num:int = readU30();
			ret.returnType = readU30();
			for (var i:int = 0; i < num; i++)
			{
				ret.parameterTypes.push(readU30());
			}
			ret.name = readU30();
			ret.flags = readU8();

			if (ret.flags & MethodFlags.HAS_OPTIONAL)
			{
				num = readU30();
				for (i = 0; i < num; i++)
				{
					ret.defaultOptions.push(readDefaultOption());
				}
			}

			if (ret.flags & MethodFlags.HAS_PARAM_NAMES)
			{
				for (i = 0; i < ret.parameterTypes.length; i++)
				{
					ret.parameterNames.push(readU30());
				}
			}

			return ret;
		}

		public function readDefaultOption():ABCDefaultOption
		{
			return new ABCDefaultOption(readU30(), ABCType.fromByte(readU8()));
		}

		public function readMetadata():ABCMetadata
		{
			var name:int = readU30();
			var num:int = readU30();
			var ret:ABCMetadata = new ABCMetadata(name, new <int>[], new <int>[]);

			for (var i:int = 0; i < num; i++)
			{
				ret.keys.push(readU30());
				ret.values.push(readU30());
			}

			return ret;
		}

		public function readInstance():ABCInstance
		{
			var ret:ABCInstance = new ABCInstance(readU30(), readU30(), readU8(), 0, new <int>[], 0, new <ABCTrait>[]);

			if (ret.flags & InstanceFlags.PROTECTEDNS)
			{
				ret.protectedNs = readU30();
			}
			
			var num:int = readU30();
			for (var i:int = 0; i < num; i++)
			{
				ret.interfaces.push(readU30());
			}

			ret.iinit = readU30();
			
			num = readU30();
			for (i = 0; i < num; i++)
			{
				ret.traits.push(readTrait());
			}

			return ret;
		}

		public function readTrait():ABCTrait
		{
			var ret:ABCTrait = new ABCTrait(readU30(), null,0, null, new <int>[]);

			var num:int = readU8();
			ret.type = TraitType.fromByte(num & 0xF);
			ret.attributes = num >> 4;

			switch (ret.type)
			{
				case TraitType.Slot:
				case TraitType.Const:
					ret.extraData = new ABCTraitSlot(readU30(), readU30(), readU30());
					if ((ret.extraData as ABCTraitSlot).valueIndex != 0)
					{
						(ret.extraData as ABCTraitSlot).valueType = ABCType.fromByte(readU8());
					}
					else
					{
						(ret.extraData as ABCTraitSlot).valueType = ABCType.Void;
					}
					break;
				case TraitType.Class:
					ret.extraData = new ABCTraitClass(readU30(), readU30());
					break;
				case TraitType.Function:
					ret.extraData = new ABCTraitFunction(readU30(), readU30());
					break;
				case TraitType.Method:
				case TraitType.Getter:
				case TraitType.Setter:
					ret.extraData = new ABCTraitMethod(readU30(), readU30());
					break;
				default:
					throw new Error("Unknown trait type");
			}

			if (ret.attributes & TraitAttributes.METADATA)
			{
				num = readU30();
				for (var i:int = 0; i < num; i++)
				{
					ret.metadata.push(readU30());
				}
			}

			return ret;
		}

		public function readABCClass():ABCClass
		{
			var ret:ABCClass = new ABCClass(readU30(), new <ABCTrait>[]);

			var num:int = readU30();
			for (var i:int = 0; i < num; i++)
			{
				ret.traits.push(readTrait());
			}

			return ret;
		}

		public function readABCScript():ABCScript
		{
			var ret:ABCScript = new ABCScript(readU30(), new <ABCTrait>[]);

			var num:int = readU30();
			for (var i:int = 0; i < num; i++)
			{
				ret.traits.push(readTrait());
			}

			return ret;
		}

		public function readMethodBody(file:ABCFile = null):ABCMethodBody
		{
			var ret:ABCMethodBody = new ABCMethodBody(readU30(), readU30(), readU30(), readU30(), readU30(), new <ABCInstruction>[], new <ABCException>[], new <ABCTrait>[]);

			var numCodeBytes:int = readU30();
			var startCode:uint = data.position;

			data.position += numCodeBytes;
			var numObjects:int = readU30();
			for (var i:int = 0; i < numObjects; i++)
			{
				ret.exceptions.push(readException());
			}

			numObjects = readU30();
			for (i = 0; i < numObjects; i++)
			{
				ret.traits.push(readTrait());
			}

			var endBody:uint = data.position;

			// Trace state: unexplored = 0, pending = 1, instruction = 2, instructionbody = 3

			var traceStates:Vector.<int> = new Vector.<int>(numCodeBytes, true);
			var localInstructions:Vector.<ABCInstruction> = new Vector.<ABCInstruction>(numCodeBytes, true);

			var pendingExploration:Boolean = true;

			function queue(newOffset:int):void
			{
				if (newOffset < numCodeBytes && traceStates[newOffset] == 0)
				{
					traceStates[newOffset] = 1;
					pendingExploration = true;
				}
			}

			function offset():int { return data.position - startCode; }

			queue(0);

			for each (var exception:ABCException in ret.exceptions)
			{
				queue(exception.target.offset);
			}

			while (pendingExploration)
			{
				pendingExploration = false;
				data.position = startCode;

				while (data.position < startCode + numCodeBytes)
				{
					if (traceStates[offset()] == 1)
					{
						while (data.position < startCode + numCodeBytes)
						{
							var instructionBegin:int = offset();

							if (traceStates[instructionBegin] == 3)
								throw new Error("Overlapping instruction");
							if (traceStates[instructionBegin] == 2) // Already decoded instruction
								break;
							
							var instruction:ABCInstruction = new ABCInstruction(Opcode.fromInfo(readU8()));
							if (!instruction.opcode.usable)
							{
								throw new Error("Opcode \'" + instruction.opcode.name + "\' cannot be parsed by this library");
							}

							instruction.arguments = new Array();

							for (i = 0; i < instruction.opcode.arguments.length; i++)
							{
								switch (instruction.opcode.arguments[i])
								{
									case OpcodeArgumentType.ByteLiteral:
										instruction.arguments[i] = readS8();
										break;
									case OpcodeArgumentType.UByteLiteral:
										instruction.arguments[i] = readU8();
										break;
									case OpcodeArgumentType.IntLiteral:
										instruction.arguments[i] = readS32();
										break;
									case OpcodeArgumentType.UIntLiteral:
										instruction.arguments[i] = readU32();
										break;
									
									case OpcodeArgumentType.Int:
									case OpcodeArgumentType.UInt:
									case OpcodeArgumentType.Double:
									case OpcodeArgumentType.String:
									case OpcodeArgumentType.Namespace:
									case OpcodeArgumentType.Multiname:
									case OpcodeArgumentType.Class:
									case OpcodeArgumentType.Method:
									{
										instruction.arguments[i] = readU30();
										if (file != null && instruction.arguments[i] >= file.lengthOf(instruction.opcode.arguments[i]))
										{
											throw new Error("Out of bounds constant index");
										}
									}
									break;

									case OpcodeArgumentType.JumpTarget:
									{
										var delta:int = readS24();
										var jumpTarget:uint = offset() + delta;
										instruction.arguments[i] = new InstructionLabel(uint.MAX_VALUE, jumpTarget);
										queue(jumpTarget);
									}
									break;

									case OpcodeArgumentType.SwitchDefaultTarget:
									{
										var defaultTarget:uint = instructionBegin + readS24();
										instruction.arguments[i] = new InstructionLabel(uint.MAX_VALUE, defaultTarget);
										queue(defaultTarget);
									}
									break;

									case OpcodeArgumentType.SwitchTargets:
									{
										var switchTargets:Vector.<InstructionLabel> = new Vector.<InstructionLabel>(readU30() + 1, true);
										for (var j:int = 0; j < switchTargets.length; j++)
										{
											switchTargets[j] = new InstructionLabel(uint.MAX_VALUE, instructionBegin + readS24());
											queue(switchTargets[j].offset);
										}
										instruction.arguments[i] = switchTargets;
									}
									break;
								}
							}

							if (data.position > startCode + numCodeBytes)
							{
								throw new Error("Out-of-bounds code read error");
							}

							localInstructions[instructionBegin] = instruction;
							traceStates[instructionBegin] = 2;
							for (j = instructionBegin + 1; j < offset(); j++)
							{
								traceStates[j] = 3;
							}

							// if (instruction.opcode.stopsExecution) break;
						}
					}
					else
					{
						data.position++;
					}
				}
			}

			var instructionOffsets:Vector.<uint> = new <uint>[];
			var instructionAtOffset:Vector.<uint> = new Vector.<uint>(numCodeBytes, true);
			for (i = 0; i < instructionAtOffset.length; i++)
			{
				instructionAtOffset[i] = uint.MAX_VALUE;
			}

			function addInstruction(i:ABCInstruction, offset:uint):void
			{
				instructionAtOffset[offset] = ret.instructions.length;
				ret.instructions[ret.instructions.length] = i;
				instructionOffsets[instructionOffsets.length] = offset;
			}

			for (i = 0; i < traceStates.length; i++)
			{
				if (traceStates[i] == 2)
				{
					addInstruction(localInstructions[i], i);
				}
				else if (traceStates[i] != 3)
				{
					throw new Error("Did not process the instruction at " + (i + startCode) + " within the ABC file");
				}
			}

			function translateLabel(label:InstructionLabel):void
			{
				var absoluteOffset:int = label.offset;
				var instructionOffset:int = absoluteOffset;
				while (true)
				{
					if (instructionOffset >= numCodeBytes)
					{
						label.index = ret.instructions.length;
						instructionOffset = numCodeBytes;
						break;
					}
					if (instructionOffset <= 0)
					{
						label.index = 0;
						instructionOffset = 0;
						break;
					}
					if (instructionAtOffset[instructionOffset] != uint.MAX_VALUE)
					{
						label.index = instructionAtOffset[instructionOffset];
						break;
					}
					instructionOffset--;
				}
				label.offset = absoluteOffset - instructionOffset;
			}

			for (i = 0; i < ret.instructions.length; i++)
			{
				for (j = 0; j < ret.instructions[i].opcode.arguments.length; j++)
				{
					switch (ret.instructions[i].opcode.arguments[j])
					{
						case OpcodeArgumentType.JumpTarget:
						case OpcodeArgumentType.SwitchDefaultTarget:
							translateLabel(ret.instructions[i].arguments[j] as InstructionLabel);
							break;
						case OpcodeArgumentType.SwitchTargets:
							for each (var label:InstructionLabel in (ret.instructions[i].arguments[j] as Vector.<InstructionLabel>))
							{
								translateLabel(label);
							}
							break;
						default:
							break;
					}
				}
			}

			for each (exception in ret.exceptions)
			{
				translateLabel(exception.from);
				translateLabel(exception.to);
				translateLabel(exception.target);
			}

			data.position = endBody;

			return ret;
		}

		public function readException():ABCException
		{
			return new ABCException(new InstructionLabel(uint.MAX_VALUE, readU30()), new InstructionLabel(uint.MAX_VALUE, readU30()), new InstructionLabel(uint.MAX_VALUE, readU30()), readU30(), readU30());
		}
    }
}
