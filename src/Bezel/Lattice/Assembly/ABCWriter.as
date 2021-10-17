package Bezel.Lattice.Assembly
{
	import flash.utils.ByteArray;
	import Bezel.Lattice.Assembly.multiname.ABCQName;
	import Bezel.Lattice.Assembly.multiname.ABCRTQName;
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
	import flash.utils.Endian;
	/**
	 * ...
	 * @author Chris
	 */
	public class ABCWriter
    {
        private var _data:ByteArray;
        private var abc:ABCFile;

        public function get data():ByteArray { return this._data; }

        public function ABCWriter(abc:ABCFile)
        {
            this.abc = abc;
            this._data = new ByteArray();
            this._data.endian = Endian.LITTLE_ENDIAN;

            writeU16(abc.minorVersion);
            writeU16(abc.majorVersion);

            writeU30(abc.integers.length <= 1 ? 0 : abc.integers.length);
            for (var i:int = 1; i < abc.integers.length; i++)
            {
                writeS32(abc.integers[i]);
            }

            writeU30(abc.uintegers.length <= 1 ? 0 : abc.uintegers.length)
            for (i = 1; i < abc.uintegers.length; i++)
            {
                writeU32(abc.uintegers[i]);
            }

            writeU30(abc.doubles.length <= 1 ? 0 : abc.doubles.length)
            for (i = 1; i < abc.doubles.length; i++)
            {
                writeD64(abc.doubles[i]);
            }

            writeU30(abc.strings.length <= 1 ? 0 : abc.strings.length)
            for (i = 1; i < abc.strings.length; i++)
            {
                writeString(abc.strings[i]);
            }

            writeU30(abc.namespaces.length <= 1 ? 0 : abc.namespaces.length)
            for (i = 1; i < abc.namespaces.length; i++)
            {
                writeNamespace(abc.namespaces[i]);
            }

            writeU30(abc.ns_sets.length <= 1 ? 0 : abc.ns_sets.length)
            for (i = 1; i < abc.ns_sets.length; i++)
            {
                writeNamespaceSet(abc.ns_sets[i]);
            }

            writeU30(abc.multinames.length <= 1 ? 0 : abc.multinames.length)
            for (i = 1; i < abc.multinames.length; i++)
            {
                writeMultiname(abc.multinames[i]);
            }

            writeU30(abc.methods.length);
            for each (var method:ABCMethodInfo in abc.methods)
            {
                writeMethodInfo(method);
            }

            writeU30(abc.metadata.length);
            for each (var metadata:ABCMetadata in abc.metadata)
            {
                writeMetadata(metadata);
            }

            writeU30(abc.instances.length);
            for each (var instance:ABCInstance in abc.instances)
            {
                writeInstance(instance);
            }

            if (abc.classes.length != abc.instances.length) throw new Error("Cannot have different number of classes and instances");
            for each (var clazz:ABCClass in abc.classes)
            {
                writeABCClass(clazz);
            }

            writeU30(abc.scripts.length);
            for each (var script:ABCScript in abc.scripts)
            {
                writeABCScript(script);
            }

            writeU30(abc.methodBodies.length);
            for each (var body:ABCMethodBody in abc.methodBodies)
            {
                writeMethodBody(body);
            }
        }

        public function writeU8(v:uint):void { _data.writeByte(v); }
		public function writeS8(v:int):void { _data.writeByte(v); }
		public function writeU16(v:uint):void { _data.writeShort(v); }
		public function writeS16(v:int):void { _data.writeShort(v); }
		public function writeS24(v:int):void
		{
            var writeme:uint = v;
            writeU8(writeme);
            writeU8(writeme >> 8);
            writeU8(writeme >> 16);
		}
		public function writeU32(v:uint):void
		{
			if (v < 0x00000080)
            {
                writeU8(v & 0x7F);
            }
            else if (v < 0x00004000)
            {
                writeU8((v & 0x7F) | 0x80);
                writeU8((v >> 7) & 0x7F);
            }
            else if (v < 0x00200000)
            {
                writeU8((v & 0x7F) | 0x80);
                writeU8((v >> 7) | 0x80);
                writeU8((v >> 14) & 0x7F);
            }
            else if (v < 0x10000000)
            {
                writeU8((v & 0x7F) | 0x80);
                writeU8((v >> 7) | 0x80);
                writeU8((v >> 14) | 0x80);
                writeU8((v >> 21) & 0x7F);
            }
            else
            {
                writeU8((v & 0x7F) | 0x80);
                writeU8((v >> 7) | 0x80);
                writeU8((v >> 14) | 0x80);
                writeU8((v >> 21) | 0x80);
                writeU8((v >> 28) & 0x0F);
            }
		}
		public function writeS32(v:int):void
		{
            writeU32(v);
		}
		public function writeU30(v:uint):void
		{
			if (v & ~0x3FFFFFFF)
			{
				throw new Error("Impossible 30-bit value");
			}
			writeU32(v);
		}
		public function writeD64(v:Number):void
		{
			_data.writeDouble(v);
		}

		public function writeData(v:ByteArray):void
		{
			_data.writeBytes(v);
		}

		public function writeString(v:String):void
		{
            writeU30(v.length);
            if (v.length != 0)
            {
                _data.writeUTFBytes(v);
            }
		}

		public function writeNamespace(v:ABCNamespace):void
		{
            writeU8(v.type.val);
            writeU30(v.name);
		}

		public function writeNamespaceSet(v:Vector.<uint>):void
		{
            writeU30(v.length);
            for each (var val:uint in v)
            {
                writeU30(val);
            }
		}

		public function writeMultiname(v:ABCMultiname):void
		{
            writeU8(v.type.val);
			switch (v.type)
			{
				case ABCType.QName:
				case ABCType.QNameA:
                    writeU30((v.subdata as ABCQName).ns);
                    writeU30((v.subdata as ABCQName).name);
					break;
				case ABCType.RTQName:
				case ABCType.RTQNameA:
                    writeU30((v.subdata as ABCRTQName).name);
					break;
				case ABCType.RTQNameL:
				case ABCType.RTQNameLA:
					break;
				case ABCType.Multiname:
				case ABCType.MultinameA:
                    writeU30((v.subdata as ABCMultinameSubdata).name);
                    writeU30((v.subdata as ABCMultinameSubdata).ns_set);
					break;
				case ABCType.MultinameL:
				case ABCType.MultinameLA:
                    writeU30((v.subdata as ABCMultinameL).ns_set);
					break;
				case ABCType.TypeName:
                    writeU30((v.subdata as ABCTypeName).name);
                    writeU30((v.subdata as ABCTypeName).params.length);
                    for each (var val:int in (v.subdata as ABCTypeName).params)
                    {
                        writeU30(val);
                    }
					break;
				default:
					throw new Error("Unknown multiname type");
			}
		}

		public function writeMethodInfo(v:ABCMethodInfo):void
		{
            writeU30(v.parameterTypes.length);
            writeU30(v.returnType);
            for each (var val:int in v.parameterTypes)
            {
                writeU30(val);
            }
            writeU30(v.name);
            writeU8(v.flags);

            if (v.flags & MethodFlags.HAS_OPTIONAL)
            {
                writeU30(v.defaultOptions.length);
                for each (var opt:ABCDefaultOption in v.defaultOptions)
                {
                    writeDefaultOption(opt);
                }
            }

            if (v.flags & MethodFlags.HAS_PARAM_NAMES)
            {
                for each (val in v.parameterNames)
                {
                    writeU30(val);
                }
            }
		}

		public function writeDefaultOption(v:ABCDefaultOption):void
		{
            writeU30(v.index);
            writeU8(v.type.val);
		}

		public function writeMetadata(v:ABCMetadata):void
		{
            writeU30(v.name);
            writeU30(v.keys.length);
            for (var i:int = 0; i < v.keys.length; i++)
            {
                writeU30(v.keys[i]);
                writeU30(v.values[i]);
            }
		}

		public function writeInstance(v:ABCInstance):void
		{
            writeU30(v.name);
            writeU30(v.superclassName);
            writeU8(v.flags);

            if (v.flags & InstanceFlags.PROTECTEDNS)
            {
                writeU30(v.protectedNs);
            }

            writeU30(v.interfaces.length);
            for each (var val:int in v.interfaces)
            {
                writeU30(val);
            }

            writeU30(v.iinit);

            writeU30(v.traits.length);
            for each (var trait:ABCTrait in v.traits)
            {
                writeTrait(trait);
            }
		}

		public function writeTrait(v:ABCTrait):void
		{
            writeU30(v.name);
            writeU8(v.type.val | (v.attributes << 4));

			switch (v.type)
			{
				case TraitType.Slot:
				case TraitType.Const:
                    writeU30((v.extraData as ABCTraitSlot).slotId);
                    writeU30((v.extraData as ABCTraitSlot).typeName);
                    writeU30((v.extraData as ABCTraitSlot).valueIndex);
                    if ((v.extraData as ABCTraitSlot).valueIndex != 0)
                    {
                        writeU8((v.extraData as ABCTraitSlot).valueType.val);
                    }
					break;
				case TraitType.Class:
                    writeU30((v.extraData as ABCTraitClass).slotId);
                    writeU30((v.extraData as ABCTraitClass).classi);
					break;
				case TraitType.Function:
                    writeU30((v as ABCTraitFunction).slotId);
                    writeU30((v as ABCTraitFunction).functioni);
					break;
				case TraitType.Method:
				case TraitType.Getter:
				case TraitType.Setter:
                    writeU30((v as ABCTraitMethod).slotId);
                    writeU30((v as ABCTraitMethod).methodi);
					break;
				default:
					throw new Error("Unknown trait type");
			}

			if (v.attributes & TraitAttributes.METADATA)
			{
                writeU30(v.metadata.length);
                for each (var val:int in v.metadata)
                {
                    writeU30(val);
                }
            }
		}

		public function writeABCClass(v:ABCClass):void
		{
            writeU30(v.cinit);

            writeU30(v.traits.length);
            for each (var trait:ABCTrait in v.traits)
            {
                writeTrait(trait);
            }
		}

		public function writeABCScript(v:ABCScript):void
		{
            writeU30(v.sinit);

			writeU30(v.traits.length);
            for each (var trait:ABCTrait in v.traits)
            {
                writeTrait(trait);
            }
		}

		public function writeMethodBody(v:ABCMethodBody):void
		{
            writeU30(v.method);
            writeU30(v.maxStack);
            writeU30(v.localCount);
            writeU30(v.initScopeDepth);
            writeU30(v.maxScopeDepth);

            var instructionOffsets:Vector.<uint> = new Vector.<uint>(v.instructions.length+1, true);

            function resolveLabel(label:InstructionLabel):uint { return instructionOffsets[label.index]+label.offset; }

            var globalByteArray:ByteArray = this._data;
            this._data = new ByteArray();
            var fixups:Vector.<InstructionFixup> = new <InstructionFixup>[];

            for (var i:int = 0; i < v.instructions.length; i++)
            {
                var instruction:ABCInstruction = v.instructions[i]
                var instructionOffset:uint = this._data.position;
                instructionOffsets[i] = instructionOffset;

                writeU8(instruction.opcode.val);

                if (instruction.arguments.length != instruction.opcode.arguments.length)
                {
                    throw new Error("Mismatching number of instruction args");
                }

                for (var j:int = 0; j < instruction.arguments.length; j++)
                {
                    switch (instruction.opcode.arguments[j])
                    {
                        case OpcodeArgumentType.Unknown:
                            throw new Error("Don't know how to encode OP_" + instruction.opcode.name);

                        case OpcodeArgumentType.ByteLiteral:
							writeU8(instruction.arguments[i]);
							break;
						case OpcodeArgumentType.UByteLiteral:
							writeU8(instruction.arguments[i]);
							break;
						case OpcodeArgumentType.IntLiteral:
							writeS32(instruction.arguments[i]);
							break;
						case OpcodeArgumentType.UIntLiteral:
							writeU32(instruction.arguments[i]);
							break;

                        case OpcodeArgumentType.Int:
						case OpcodeArgumentType.UInt:
						case OpcodeArgumentType.Double:
						case OpcodeArgumentType.String:
						case OpcodeArgumentType.Namespace:
						case OpcodeArgumentType.Multiname:
						case OpcodeArgumentType.Class:
						case OpcodeArgumentType.Method:
							writeU30(instruction.arguments[i]);
							break;
                        
                        case OpcodeArgumentType.JumpTarget:
                            fixups.push(new InstructionFixup(instruction.arguments[i] as InstructionLabel), _data.position, _data.position + 3);
                            writeS24(0);
                            break;
                        
                        case OpcodeArgumentType.JumpTarget:
                            fixups.push(new InstructionFixup(instruction.arguments[i] as InstructionLabel), _data.position, instructionOffset);
                            writeS24(0);
                            break;

                        case OpcodeArgumentType.SwitchTargets:
                            var currentTargets:Vector.<InstructionLabel> = instruction.arguments[i] as Vector.<InstructionLabel>;
                            if (currentTargets.length < 1)
                            {
                                throw new Error("Too few switch cases");
                            }
                            writeU30(currentTargets.length-1);
                            for each (var target:InstructionLabel in currentTargets)
                            {
                                fixups.push(new InstructionFixup(target, _data.position, instructionOffset));
                                writeS24(0);
                            }
                            break;
                    }
                }
            }

            instructionOffsets[v.instructions.length] = _data.position;

            for each (var fixup:InstructionFixup in fixups)
            {
                _data.position = fixup.pos;
                writeS24(resolveLabel(fixup.target)-fixup.base);
            }

            var codeData:ByteArray = this._data;
            // restore global buffer
            this._data = globalByteArray;

            writeData(codeData);

            writeU30(v.exceptions.length);
            for each (var exception:ABCException in v.exceptions)
            {
                exception.from.offset = resolveLabel(exception.from);
                exception.to.offset = resolveLabel(exception.to);
                exception.target.offset = resolveLabel(exception.target);
                writeException(exception);
            }
            writeU30(v.traits.length);
            for each (var trait:ABCTrait in v.traits)
            {
                writeTrait(trait);
            }
		}

		public function writeException(v:ABCException):void
		{
            writeU30(v.from.offset);
            writeU30(v.to.offset);
            writeU30(v.target.offset);
            writeU30(v.exceptionType);
            writeU30(v.varName);
		}
    }
}
