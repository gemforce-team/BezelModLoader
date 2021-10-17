package Bezel.Lattice.Assembly.conversion {
    import flash.utils.Dictionary;
    import avmplus.getQualifiedClassName;
    import Bezel.Lattice.Assembly.ASNamespace;

    /**
     * Will only work for int, uint, Number, String, Vector.<ASNamespace>, or classes that contain a public .equals(same class) method
     * Examples include ASNamespace, ASMultiname, ASMethod, ASMetadata, ASInstance, and ASClass.
     * @author Chris
     */
    public class DataPool {
        private var type:Class;
        private var hasNull:Boolean;

        private var _values:Array;

        public function get values():Array {
            if (_values == null) {
                finalize();
            }
            return _values;
        }

        // Entry[Key] -> Array of keys and Array of Object{hits, value, addIndex, index, parents[]}
        private var keys:Array;
        private var vals:Array;

        private function setToPool(hits:uint, value:*, parents:Array):void {
            keys.push(value);
            vals.push({"hits": hits, "value": value, "addIndex": vals.length, "index": 0, "parents": parents});
        }

        public function DataPool(type:Class, hasNull:Boolean) {
            this.type = type;
            this.hasNull = hasNull;

            this.keys = new Array();
            this.vals = new Array();
        }

        public static function isNull(val:*):Boolean {
            if (val is int) {
                return val == 0;
            } else if (val is uint) {
                return val == 0;
            } else if (val is Number) {
                return isNaN(val as Number);
            } else {
                return val == null;
            }
            return false;
        }

        public static function nullVal(type:Class):* {
            if (type == int || type == uint)
            {
                return 0 as type;
            }
            else if (type == Number)
            {
                return NaN;
            }
            else
            {
                return null;
            }
        }

        private function find(value:*, searchMe:Array = null):int {
            if (searchMe == null) {
                searchMe = keys;
            }
            var i:int;

            if (value is int || value is uint || value is Number || value is String) {
                return searchMe.indexOf(value);
            } else if (value is Vector.<ASNamespace>) {
                var vnsset:Vector.<ASNamespace> = value as Vector.<ASNamespace>;

                for (i = 0; i < searchMe.length; i++) {
                    var knsset:Vector.<ASNamespace> = searchMe[i] as Vector.<ASNamespace>;
                    var found:Boolean = true;
                    for each (var ns:ASNamespace in vnsset) {
                        if (!knsset.some(function(i:ASNamespace, _:*, __:*):Boolean {
                            return (i == null && ns == null) || (i != null && i.equals(ns));
                        })) {
                            found = false;
                            break;
                        }
                    }
                    if (found) {
                        return i;
                    }
                }
            } else {
                for (i = 0; i < searchMe.length; i++) {
                    if (searchMe[i].equals(value)) {
                        return i;
                    }
                }
            }

            return -1;
        }

        public function add(value:*):Boolean {
            if (hasNull && isNull(value)) {
                return false;
            }
            if (!(value is type)) {
                throw new Error("Cannot add a " + getQualifiedClassName(value) + " to DataPool of type " + getQualifiedClassName(type));
            }

            var index:int = find(value);

            if (index != -1) {
                vals[index].hits++;
                return false;
            } else {
                setToPool(1, value, []);
                return true;
            }
        }

        public function notAdded(value:*):Boolean {
            if (hasNull && isNull(value)) {
                return false;
            }

            var idx:int = find(value);

            if (idx != -1)
                vals[idx].hits++;

            return find(value) == -1;
        }

        /// "from" is child of "to", thus "from" must come after "to"
        public function registerDependency(from:*, to:*):void {
            var fromIdx:int = find(from);
            if (fromIdx == -1) {
                throw new Error("Unknown dependency source");
            }
            var toIdx:int = find(to);
            if (toIdx == -1) {
                throw new Error("Unknown dependency target");
            }

            var parentContains:int = find(to, vals[fromIdx].parents);
            if (parentContains != -1) {
                throw new Error("Dependency already set");
            }
            vals[fromIdx].parents.push(to);
        }

        public function getPreliminaryValues():Array {
            return keys;
        }

        public function finalize():void {
            // Array of Object{hits, value, addIndex, index, parents[]}
            var all:Array = vals.concat();

            all.sort(function(a:*, b:*):int {
                if (a.hits > b.hits) {
                    return -1;
                } else if (a.hits < b.hits) {
                    return 1;
                } else {
                    return 0;
                }
            });

            topSort:

            for (var i:int = 0; i < all.length; i++) {
                all[i].index = i;
            }

            for (i = 0; i < vals.length; i++) {
                for each (var parent:* in(vals[i].parents as Array)) {
                    var parentI:int = find(parent);
                    if (parentI == -1)
                    {
                        throw new Error("Can't find referenced parent object");
                    }
                    var parentIdx:int = vals[parentI].index;
                    if (parentIdx > vals[i].index)
                    {
                        // HOPEFULLY equivalent to move(all, pb.index, a.index)
                        all.splice(parentIdx, 0, all[vals[i].index]);
                        all.splice(vals[i].index+1, 1);

                        goto topSort;
                    }
                }
            }

            _values = new Array();
            if (hasNull)
            {
                _values.push(nullVal(type));
            }

            for each (var obj:Object in all)
            {
                _values.push(obj.value);
            }
        }

        public function get(value:*):uint {
            if (hasNull && isNull(value)) {
                return 0;
            }
            return (hasNull ? 1 : 0) + vals[find(value)].index;
        }
    }
}
