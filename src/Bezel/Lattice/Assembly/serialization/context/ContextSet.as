package Bezel.Lattice.Assembly.serialization.context
{
    import flash.utils.Dictionary;

    /**
     * ...
     * @author Chris
     */
    public class ContextSet
    {
        public static const PRIORITY_Declaration:int = 0;
        public static const PRIORITY_Usage:int = 1;
        public static const PRIORITY_Orphan:int = 2;
        // Maps T to Vector.<ContextItem>
        public var contexts:Dictionary;
        // Maps T to Vector.<Vector.<Vector.<ContextItem>>>. Outermost vector always has three elements
        public var contextSets:Dictionary;

        // Maps T to string
        public var names:Dictionary;
        public var filenames:Dictionary;

        // string[string]
        public static var filenameMappings:Object;
        
        CONFIG::debug
        private var contextsSealed:Boolean = false;
        CONFIG::debug
        private var coagulated:Boolean = false;

        private var allowDuplicates:Boolean;

        public function ContextSet(allowDuplicates:Boolean)
        {
            this.allowDuplicates = allowDuplicates;
            this.contexts = new Dictionary();
            this.contextSets = new Dictionary();
            this.names = new Dictionary();
            this.filenames = new Dictionary();

            if (filenameMappings == null)
            {
                filenameMappings = new Object();
            }
        }

        public function add(obj:*, context:Vector.<ContextItem>, priority:int):Boolean
        {
            CONFIG::debug
            if (coagulated) throw new Error("ContextSet must not be coagulated");
            CONFIG::debug
            if (contextsSealed) throw new Error("ContextSet must not be sealed");

            if (!isAdded(obj))
            {
                contextSets[obj] = new <Vector.<Vector.<ContextItem>>>[new <Vector.<ContextItem>>[], new <Vector.<ContextItem>>[], new <Vector.<ContextItem>>[]];
                (contextSets[obj] as Vector.<Vector.<Vector.<ContextItem>>>).fixed = true;
                (contextSets[obj] as Vector.<Vector.<Vector.<ContextItem>>>)[priority].push(context.concat());
                return true;
            }
            else
            {
                contextSets[obj][priority].push(context.concat());
                return false;
            }
        }

        public function isAdded(obj:*):Boolean { return obj in contextSets; }

        public function addIfNew(obj:*, context:Vector.<ContextItem>, priority:int):Boolean
        {
            if (isAdded(obj)) return false;
            else return add(obj, context, priority);
        }

        public function coagulate(refs:RefBuilder):void
        {
            CONFIG::debug
            if (coagulated) throw new Error("ContextSet must not be coagulated");

            // int[string]
            var collisionCounter:Object = new Object();
            // T[string]
            var first:Object = new Object();

            for (var obj:* in contextSets)
            {
                if (!(obj in contexts))
                {
                    getContext(refs, obj);
                }
            }

            for (obj in contexts)
            {
                var context:Vector.<ContextItem> = contexts[obj] as Vector.<ContextItem>;
                var bname:String = refs.contextToString(context, false);
                var bfilename:String = refs.contextToString(context, true);
                var counter:int = collisionCounter[bname];
                if (counter == 1)
                {
                    var firstObj:* = first[bname];
                    names[firstObj] = (names[firstObj] as String) + "#0";
                    filenames[firstObj] = (filenames[firstObj] as String) + "#0";
                }

                var suffix:String = "";
                if (counter == 0)
                {
                    first[bname] = obj;
                }
                else
                {
                    suffix = "#" + counter;
                }
                names[obj] = bname + suffix;
                filenames[obj] = bfilename + suffix;
                collisionCounter[bname] = counter + 1;
            }

            CONFIG::debug
            this.coagulated = true;
        }

        public function getContext(refs:RefBuilder, obj:*):Vector.<ContextItem>
        {
            CONFIG::debug
            this.contextsSealed = true;

            if (obj in contexts) return contexts[obj];

            var set:Vector.<Vector.<ContextItem>> = new <Vector.<ContextItem>>[];
            for each (var prioritySet:Vector.<Vector.<ContextItem>> in (contextSets[obj] as Vector.<Vector.<Vector.<ContextItem>>>))
            {
                if (prioritySet)
                {
                    set = prioritySet;
                }
            }

            if (allowDuplicates)
            {
                var context:Vector.<ContextItem> = ContextItem.expand(refs, set[0]);
                for each (var setContext:Vector.<ContextItem> in set.slice(1))
                {
                    context = ContextItem.contextRoot(context, ContextItem.expand(refs, setContext));
                }
                return contexts[obj] = context;
            }
            else
            {
                if (set.length > 1)
                {
                    return contexts[obj] = [ContextItem.fromString("multireferenced")];
                }
                else
                {
                    return contexts[obj] = ContextItem.expand(refs, set[0]);
                }
            }
        }

        public function getName(obj:*):String
        {
            CONFIG::debug
            if (!coagulated) throw new Error("ContextSet must be coagulated");

            if (!(obj in names)) throw new Error("Object not found in ContextSet");
            return names[obj];
        }

        public function getFilename(obj:*, suffix:String):String
        {
            CONFIG::debug
            if (!coagulated) throw new Error("ContextSet must be coagulated");

            if (!(obj in filenames)) throw new Error("Object not found in filenames");

            var filename:String = filenames[obj];

            var dirSegments:Array = filename.split('/');
            for (var i:int = 0; i < dirSegments.length; i++)
            {
                var again:Boolean;
                var subpath:String;
                var subpathl:String;
                do
                {
                    again = false;
                    subpath = dirSegments.slice(0, i + 1).join('/');
                    subpathl = subpath.toLowerCase();
                    if (subpathl in filenameMappings && filenameMappings[subpathl] != subpath)
                    {
                        dirSegments[i] = dirSegments[i] + "_";
                        again = true;
                    }
                } while (again);
                filenameMappings[subpathl] = subpath;
            }
            filename = dirSegments.join('/');

            return filename + '.' + suffix + '.asasm';
        }
    }
}
