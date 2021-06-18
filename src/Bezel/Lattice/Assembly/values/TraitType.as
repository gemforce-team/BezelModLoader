class TraitTypeConstructorBlocker {}
package Bezel.Lattice.Assembly.values
{
    /**
     * ...
     * @author Chris
     */
    public class TraitType
    {
        public static const Slot:TraitType = new TraitType(0, "slot", new TraitTypeConstructorBlocker());
        public static const Method:TraitType = new TraitType(1, "method", new TraitTypeConstructorBlocker());
        public static const Getter:TraitType = new TraitType(2, "getter", new TraitTypeConstructorBlocker());
        public static const Setter:TraitType = new TraitType(3, "setter", new TraitTypeConstructorBlocker());
        public static const Class:TraitType = new TraitType(4, "class", new TraitTypeConstructorBlocker());
        public static const Function:TraitType = new TraitType(5, "function", new TraitTypeConstructorBlocker());
        public static const Const:TraitType = new TraitType(6, "const", new TraitTypeConstructorBlocker());

        private var _val:int;
        private var _name:String;

        public function get val():int { return _val; }
        public function get name():String { return _name; }

        public function TraitType(val:int, name:String, blocker:TraitTypeConstructorBlocker)
        {
            if (blocker == null)
            {
                throw new Error("Do not use the TraitType constructor");
            }
            this._val = val;
            this._name = name;
        }

        public static function fromByte(val:uint):TraitType
        {
            switch (val)
            {
                case 0:
                    return Slot;
                case 1:
                    return Method;
                case 2:
                    return Getter;
                case 3:
                    return Setter;
                case 4:
                    return Class;
                case 5:
                    return Function;
                case 6:
                    return Const;
            }

            return null;
        }
    }
}
