package Bezel.Lattice.Assembly
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Chris
	 */
	public class ABCFile
    {
		private var minorVersion:uint;
		private var majorVersion:uint;
		
		// 0 should not be written out from any of these; they are constants for 0, 0, 0, "", <any namespace>, an unusable value, and an unusable value, respectively
		private var integers:Vector.<int>;
		private var uintegers:Vector.<uint>;
		private var doubles:Vector.<Number>;
		private var strings:Vector.<String>;
        private var namespaces:Vector.<NamespaceInfo>;
        private var ns_sets:Vector.<Vector.<uint>>;
        private var multinames:Vector.<MultinameData>;

        private var methods:Vector.<MethodInfo>;
        private var metadata:Vector.<Metadata>;
        
        private var instances:Vector.<Instance>;
        private var classes:Vector.<ABCClass>;
        private var scripts:Vector.<ABCScript>;
        private var methodBodies:Vector.<MethodBody>;

        public function ABCFile()
        {
            minorVersion = 16;
            majorVersion = 46;

            integers = new <int>[0];
            uintegers = new <uint>[0];
            doubles = new <Number>[0];
            strings = new <String>[""];
            namespaces = new <NamespaceInfo>[null];
            ns_sets = new <Vector.<uint>>[null];
            multinames = new <MultinameData>[null];

            methods = new <MethodInfo>[];
            metadata = new <Metadata>[];

            instances = new <Instance>[];
            classes = new <ABCClass>[];
            scripts = new <ABCScript>[];
            methodBodies = new <MethodBody>[];
        }

        public static function parse(data:ByteArray):ABCFile
        {
            var ret:ABCFile = new ABCFile();

            var reader:ABCReader = new ABCReader(data);

            ret.minorVersion = reader.readU16();
            ret.majorVersion = reader.readU16();

            var numConstants:int = reader.readU30();
            for (var i:int = 0; i < numConstants; i++)
            {
                ret.integers[i + 1] = reader.readS32();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.uintegers[i + 1] = reader.readU32();
            }
            
            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.doubles[i + 1] = reader.readD64();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.strings[i + 1] = reader.readString();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.namespaces[i + 1] = reader.readNamespaceInfo();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.ns_sets[i + 1] = reader.readNamespaceSet();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.multinames[i + 1] = reader.readMultiname();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.methods[i + 1] = reader.readMethodInfo();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.metadata[i] = reader.readMetadata();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.instances[i] = reader.readInstance();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.classes[i] = reader.readABCClass();
            }
            
            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.scripts[i] = reader.readABCScript();
            }

            numConstants = reader.readU30();
            for (i = 0; i < numConstants; i++)
            {
                ret.methodBodies[i] = reader.readMethodBody();
            }

            return ret;
        }

		internal function lengthOf(type:OpcodeArgumentType):uint
        {
            switch (type)
            {
                case OpcodeArgumentType.Int:
                    return integers.length;
                case OpcodeArgumentType.UInt:
                    return uintegers.length;
                case OpcodeArgumentType.Double:
                    return doubles.length;
                case OpcodeArgumentType.String:
                    return strings.length;
                case OpcodeArgumentType.Namespace:
                    return namespaces.length;
                case OpcodeArgumentType.Multiname:
                    return multinames.length;
                case OpcodeArgumentType.Class:
                    return classes.length;
                case OpcodeArgumentType.Method:
                    return methods.length;
                default:
                    throw new Error("Argument type does not have an associated vector");
            }
        }
    }
}
