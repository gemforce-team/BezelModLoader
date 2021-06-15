package Bezel.Lattice.Assembly
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Chris
	 */
	public class ABCFile
    {
		internal var minorVersion:uint;
		internal var majorVersion:uint;
		
		// 0 should not be written out from any of these; they are constants for 0, 0, 0, "", <any namespace>, an unusable value, and an unusable value, respectively
		internal var integers:Vector.<int>;
		internal var uintegers:Vector.<uint>;
		internal var doubles:Vector.<Number>;
		internal var strings:Vector.<String>;
        internal var namespaces:Vector.<ABCNamespace>;
        internal var ns_sets:Vector.<Vector.<uint>>;
        internal var multinames:Vector.<ABCMultiname>;

        internal var methods:Vector.<ABCMethodInfo>;
        internal var metadata:Vector.<ABCMetadata>;
        
        internal var instances:Vector.<ABCInstance>;
        internal var classes:Vector.<ABCClass>;
        internal var scripts:Vector.<ABCScript>;
        internal var methodBodies:Vector.<ABCMethodBody>;

        public function ABCFile()
        {
            minorVersion = 16;
            majorVersion = 46;

            integers = new <int>[0];
            uintegers = new <uint>[0];
            doubles = new <Number>[0];
            strings = new <String>[""];
            namespaces = new <ABCNamespace>[null];
            ns_sets = new <Vector.<uint>>[null];
            multinames = new <ABCMultiname>[null];

            methods = new <ABCMethodInfo>[];
            metadata = new <ABCMetadata>[];

            instances = new <ABCInstance>[];
            classes = new <ABCClass>[];
            scripts = new <ABCScript>[];
            methodBodies = new <ABCMethodBody>[];
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
                ret.namespaces[i + 1] = reader.readNamespace();
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
