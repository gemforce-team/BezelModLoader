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
        }

        public static function parse(data:ByteArray):ABCFile
        {
            var ret:ABCFile = new ABCFile();

            return ret;
        }

		
    }
}
