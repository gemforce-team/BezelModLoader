package Bezel.Lattice
{
    public class LatticeFunctionBody
    {
        public var maxStack:uint;
        public var localCount:uint;
        public var initScopeDepth:uint;
        public var maxScopeDepth:uint;

        public var traits:Vector.<LatticeTrait>;
		public var instructions:Vector.<String>;
        
        public function LatticeFunctionBody(contents:String)
        {
            this.traits = new Vector.<LatticeTrait>();
			this.instructions = new Vector.<String>();

            var found:Object = /maxstack (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max stack depth")
            }
            this.maxStack = uint(found[1]);
            found = /localcount (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve local count")
            }
            this.localCount = uint(found[1]);
            found = /initscopedepth (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max scope depth")
            }
            this.initScopeDepth = uint(found[1]);
            found = /maxscopedepth (\d+)/.exec(contents);
            if (found == null)
            {
                throw new Error("LatticeFunction: could not retrieve max scope depth")
            }
            this.maxScopeDepth = uint(found[1]);
			
			found = /code\n(.*?)\nend ; code/ms.exec(contents);
			if (found != null)
			{
				for each (var instruction:String in found[1].split('\n'))
				{
					Lattice.logger.log("LatticeFunctionBody", "Instruction: " + instruction);
					if (instruction != "")
					{
						instructions[instructions.length] = instruction;
					}
				}
			}
			
			var methodRegex:RegExp = /trait.*?end ; trait/ms;
			
			found = methodRegex.exec(contents);
			while (found != null)
			{
				var nestedFunc:LatticeTrait = new LatticeTrait();
				nestedFunc.create(found[0]);
				traits[traits.length] = nestedFunc;
				
				contents = contents.replace(found[0], "");
				
				found = methodRegex.exec(contents);
			}
			
			var propRegex:RegExp = /trait slot.*end/;
			
			found = propRegex.exec(contents);
			while (found != null)
			{
				var nestedProp:LatticeTrait = new LatticeTrait();
				nestedProp.create(found[0]);
				traits[traits.length] = nestedProp;
				
				contents = contents.replace(found[0], "");
				
				found = propRegex.exec(contents);
			}
			{
				
			}
        }
    }
}
