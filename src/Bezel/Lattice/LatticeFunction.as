package Bezel.Lattice
{
    public class LatticeFunction
    {
        // locals[name] = index
        private var originalLocals:Object;
        private var locals:Object;
        // params[index] = type:LatticeQName
        private var params:Array;
        private var returnType:LatticeQName;
        private var flags:Vector.<String>;

        public var body:LatticeFunctionBody;

        private var name:String;
        private var refid:String;
        
        public static function fromString(contents:String): LatticeFunction
        {
            var ret:LatticeFunction = new LatticeFunction();

            ret.originalLocals = new Object();
            ret.locals = new Object();
            ret.params = new Array();
            ret.flags = new Vector.<String>();

            ret.analyzeContents(contents, contents.indexOf("cinit") == -1 && contents.indexOf("iinit") == -1);

            return ret;
        }

        private function analyzeContents(contents:String, constructor:Boolean): void
        {
            var found:Object = /body.*end ; body/ms.exec(contents);
            if (found != null)
            {
                this.body = new LatticeFunctionBody(found[0]);
                contents.replace(found[0], "");
            }

            found = /refid "(.*)"/.exec(contents);
            if (found == null || found[1] == "")
            {
                throw new Error("LatticeFunction: could not retrieve function identifier");
            }
            this.refid = found[1];
            found = /name "(.*)"/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve function identifier");
            }
            this.name = found[1];

            var flagRegex:RegExp = /flag (.*)/g;
            found = flagRegex.exec(contents);
            while (found != null)
            {
                if (found[1] != "PARAM_NAMES")
                {
                    this.flags[this.flags.length] = found[1];
                }
                found = flagRegex.exec(contents);
            }

            var paramRegex:RegExp = /param (.*)/g;
            found = paramRegex.exec(contents);
            while (found != null)
            {
                if (found[1] == "null")
                {
                    params[params.length] = null;
                }
                else
                {
                    found = /QName\(PackageNamespace\("(.*)"\), "(.*)"\)/.exec(found[0]);
                    if (found == null)
                    {
                        throw new Error("Lattice: Parameter type does not match expected format");
                    }
                    params[params.length] = new LatticeQName(found[1], found[2]);
                }
                found = paramRegex.exec(contents);
            }

            if (!constructor)
            {
                found = /returns QName\(PackageNamespace\("(.*)"\), "(.*)"\)/.exec(contents);
                if (found == null)
                {
                    throw new Error("Lattice: Non-constructor has no return type");
                }
                this.returnType = new LatticeQName(found[1], found[2]);
            }
        }

        internal function convertToPatch(): LatticePatch
        {
            
            return null;
        }
    }
}
