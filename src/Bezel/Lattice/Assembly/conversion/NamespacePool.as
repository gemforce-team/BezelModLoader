package Bezel.Lattice.Assembly.conversion
{
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.values.ABCType;
    import flash.utils.Dictionary;

    /**
     * Equivalent of Pool!(ASProgram.Namespace, ASType, string, uint)
     * @author Chris
     */
    public class NamespacePool
    {
        // Namespace[struct { type, string, uint }] -> Dictionary<type, Object<string, Dictionary<uint, ASNamespace>>>
        private var data:Dictionary;

        public function NamespacePool()
        {
            this.data = new Dictionary();
        }

        public function get(kind:ABCType, name:String, id:uint):ASNamespace
        {
            if (!(kind in this.data))
            {
                this.data[kind] = new Object();
            }
            if (!(name in this.data[kind]))
            {
                this.data[kind][name] = new Dictionary();
            }
            if (!(id in this.data[kind][name]))
            {
                this.data[kind][name][id] = new ASNamespace(kind, name, id);
            }
            return this.data[kind][name][id];
        }
    }
}
