package Bezel.GCFW
{
    import flash.display.MovieClip;

    /**
     * ...
     * @author Chris
     */

    internal class GCFWSetting
    {
        private var _type:String;
        private var _mod:String;
        private var _name:String;
        private var _onSet:Function;
        private var _currentVal:Function;
        private var _description:String;
        private var _min:Number;
        private var _max:Number;
        private var _step:Number;
        private var _validator:Function;

        // Cannot be McOptPanel for load time reasons
        public var panel:MovieClip;
        public var button:SettingsButtonShim;

        public function get type():String
        {
        	return _type;
        }

        public function get mod():String
        {
        	return _mod;
        }

        public function get name():String
        {
        	return _name;
        }

        public function get onSet():Function
        {
        	return _onSet;
        }

        public function get currentVal():Function
        {
        	return _currentVal;
        }

        public function get description():String
        {
        	return _description;
        }

        public function get min():Number
        {
        	return _min;
        }

        public function get max():Number
        {
        	return _max;
        }

        public function get step():Number
        {
        	return _step;
        }

        public function get validator():Function
        {
        	return _validator;
        }

        public static const TYPE_BOOL:String = "bool";
        public static const TYPE_RANGE:String = "range";
        public static const TYPE_KEYBIND:String = "keybind";
        public static const TYPE_NUMBER:String = "number";
        public static const TYPE_STRING:String = "string";

        public static const MOD_KEYBIND:String = "Keybinds";
        
        public function GCFWSetting(type:String = null, mod:String = null, name:String = null, onSet:Function = null, currentVal:Function = null, description:String = null, min:Number = NaN, max:Number = NaN, step:Number = NaN, validator:Function = null)
        {
            this._type = type;
            this._mod = mod;
            this._name = name;
            this._onSet = onSet;
            this._currentVal = currentVal;
            this._description = description;
            this._min = min;
            this._max = max;
            this._step = step;
            this._validator = validator;

            this.panel = null;
            this.button = null;
        }

        public static function makeBool(mod:String, name:String, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_BOOL, mod, name, onSet, currentVal, description);
        }

        public static function makeRange(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_RANGE, mod, name, onSet, currentVal, description, min, max, step);
        }

        public static function makeKeybind(name:String, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_KEYBIND, MOD_KEYBIND, name, onSet, currentVal, description);
        }

        public static function makeNumber(mod:String, name:String, min:Number, max:Number, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_NUMBER, mod, name, onSet, currentVal, description, min, max);
        }

        public static function makeString(mod:String, name:String, validator:Function, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_STRING, mod, name, onSet, currentVal, description, null, null, null, validator);
        }
    }
}
