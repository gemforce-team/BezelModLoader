package Bezel.Lattice
{
    public class LatticeClass
    {
        private var instanceTraits:Object;
        private var staticTraits:Object;
        private var constructor:LatticeConstructor;
        private var staticConstructor:LatticeConstructor;

        private var superclass:LatticeQName;
        private var interfaces:Array;
        private var flags:Vector.<String>;
        private var protectedNamespace:String;

        public function LatticeClass(contents:String)
        {
			this.instanceTraits = new Object();
			this.staticTraits = new Object();
			this.interfaces = new Array();
			this.flags = new Vector.<String>();
			
            contents = contents.replace(/^( )+/m, "").replace(/^(\w+)( )+(.*)$/m, "$1 $2").replace(/([gs]etlocal)(\d+)/, "$1 $2");

            var instanceData:Object = /instance.*end ; instance/ms.exec(contents);
            if (instanceData == null)
            {
                throw new Error("Lattice: Class has no instance data")
            }

            contents = contents.replace(instanceData[0], "");

            var found:Object = /iinit.*?end ; method/ms.exec(instanceData[0]);
            if (found == null)
            {
                throw new Error("Lattice: Class has no instance constructor");
            }

            this.constructor = new LatticeConstructor(found[0]);
            
            var flagRegex:RegExp = /flag (.*)/g;
            found = flagRegex.exec(instanceData[0]);
            while (found != null)
            {
                this.flags[this.flags.length] = found[1];
                found = flagRegex.exec(instanceData[0]);
            }
            
            if (flags.indexOf("PROTECTEDNS") != -1)
            {
                found = /protectedns ProtectedNamespace\("(.*)"\)/.exec(instanceData[0]);
                if (found == null)
                {
                    throw new Error("Lattice: Class's protected namespace missing");
                }
				this.protectedNamespace = found[1];
            }

            var instanceString:String = instanceData[0];
            // TODO: traits, both instance and static
            var methodRegex:RegExp = /trait method.*?end ; trait/ms;
            found = methodRegex.exec(instanceString);
            while (found != null)
            {
                var method:LatticeTrait = new LatticeTrait();
                method.create(found[0]);
                this.instanceTraits[method.identifier] = method;

                instanceString = instanceString.replace(found[0], "");

                found = methodRegex.exec(instanceString);
            }

            var propRegex:RegExp = /trait slot.*end/;
            found = propRegex.exec(instanceString);
            while (found != null)
            {
                var property:LatticeTrait = new LatticeTrait();
                property.create(found[0]);
                this.instanceTraits[property.identifier] = property;

                instanceString = instanceString.replace(found[0], "");
				
				found = propRegex.exec(instanceString);
            }

            // Static data
			Lattice.logger.log("LatticeClass", "String without instance data: " + contents);
            found = /cinit.*?end ; method/ms.exec(contents);
            if (found == null)
            {
                throw new Error("Lattice: Class has no class constructor");
            }
            this.staticConstructor = new LatticeConstructor(found[0]);

            found = methodRegex.exec(contents);
            while (found != null)
            {
				Lattice.logger.log("LatticeClass", "Static method found: " + found[0]);
                var staticMethod:LatticeTrait = new LatticeTrait();
                staticMethod.create(found[0]);
                this.staticTraits[staticMethod.identifier] = staticMethod;
				
				contents = contents.replace(found[0], "");

                found = methodRegex.exec(contents);
            }

            found = propRegex.exec(contents);
            while (found != null)
            {
				Lattice.logger.log("LatticeClass", "Static property found: " + found[0]);
                var staticProp:LatticeTrait = new LatticeTrait();
                staticProp.create(found[0]);
                this.staticTraits[staticProp.identifier] = staticProp;
				
				contents = contents.replace(found[0], "");

                found = propRegex.exec(contents);
            }
        }
    }
}
