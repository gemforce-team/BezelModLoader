package Bezel.GCL
{
    import Bezel.Utils.Keybind;
    import Bezel.Utils.SettingManager;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;

    internal class GCLSetting
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

        public var knob:Sprite;
        public var knobLine:Sprite;
        public var panel:MovieClip;
        public var button:SettingsButton;
        public var checkbox:MovieClip;

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
        public static const TYPE_BUTTON:String = "button";

        public function GCLSetting(type:String = null, mod:String = null, name:String = null, onSet:Function = null, currentVal:Function = null, description:String = null, min:Number = NaN, max:Number = NaN, step:Number = NaN, validator:Function = null)
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

        public static function makeBool(mod:String, name:String, onSet:Function, currentVal:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_BOOL, mod, name, onSet, currentVal, description);
        }

        public static function makeRange(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentVal:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_RANGE, mod, name, onSet, currentVal, description, min, max, step);
        }

        public static function makeKeybind(name:String, onSet:Function, currentVal:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_KEYBIND, SettingManager.MOD_KEYBIND, name, onSet, currentVal, description);
        }

        public static function makeNumber(mod:String, name:String, min:Number, max:Number, onSet:Function, currentVal:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_NUMBER, mod, name, onSet, currentVal, description, min, max);
        }

        public static function makeString(mod:String, name:String, validator:Function, onSet:Function, currentVal:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_STRING, mod, name, onSet, currentVal, description, NaN, NaN, NaN, validator);
        }

        public static function makeButton(mod:String, name:String, onClick:Function, description:String):GCLSetting
        {
            return new GCLSetting(TYPE_BUTTON, mod, name, onClick, null, description);
        }

        private function discardAllMouseInput(e:MouseEvent):void
        {
            e.stopImmediatePropagation();
        }

        private function onBooleanClicked(e:MouseEvent):void
        {
            var current:Boolean = this.currentVal();
            this.onSet(!current);
            checkbox.gotoAndStop(!current ? 2 : 1);
        }

        private function onRangeClicked(e:MouseEvent):void
        {
            knob.startDrag(true, new Rectangle(knobLine.x, knob.y, knobLine.width - 8, 0));
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_UP, this.onRangeReleased, true, 0, true);
        }

        private function onRangeReleased(e:MouseEvent):void
        {
            knob.stopDrag();
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onRangeReleased, true);

            this.onSet(GCLSettingsHandler.calculateValue(this));
        }

        private function onKeybindTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == 0 || e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.SHIFT || e.keyCode == Keyboard.ALTERNATE)
                return;
            GCLGV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
            GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            e.stopImmediatePropagation();
            e.preventDefault();
            this.button.plate.gotoAndStop(1);
            this.button.plate.filters = [];

            GCLSettingsHandler.IS_CHOOSING_KEYBIND = false;

            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString().toUpperCase();
                GCLSettingsHandler.updateButtonColors();
                return;
            }

            var sequence:String = (e.controlKey ? "ctrl+" : "") +
                (e.shiftKey ? "shift+" : "") +
                (e.altKey ? "alt+" : "");

            for each (var key:String in GCLSettingsHandler.KeyboardConstants)
            {
                if (e.keyCode == Keyboard[key])
                {
                    sequence = sequence + key.toLowerCase();
                    break;
                }
            }

            this.onSet(new Keybind(sequence));

            this.button.tf.text = sequence.toUpperCase();

            GCLSettingsHandler.updateButtonColors();
        }

        private function onKeybindClicked(e:MouseEvent):void
        {
            GCLGV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "???";
            this.button.plate.filters = [new ColorMatrixFilter([
                        1, 0, 0, 0, 0,
                        0, .5, 0, 0, 0,
                        0, 0, .5, 0, 0,
                        0, 0, 0, 1, 0])];

            GCLSettingsHandler.IS_CHOOSING_KEYBIND = true;
        }

        private function onNumberTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                this.button.plate.filters = [];
                GCLGV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            }
            else if (e.keyCode == Keyboard.ENTER)
            {
                if (this.button.tf.text.lastIndexOf("-") <= 0 && this.button.tf.text.indexOf(".") == this.button.tf.text.lastIndexOf("."))
                {
                    var newValue:Number = parseFloat(this.button.tf.text);
                    if (!isNaN(newValue) && newValue > this.min && newValue < this.max)
                    {
                        this.onSet(newValue);
                    }
                }
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                this.button.plate.filters = [];
                GCLGV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            }
            else if (e.keyCode == Keyboard.BACKSPACE)
            {
                this.button.tf.text = this.button.tf.text.slice(0, -1);
            }
            else
            {
                var newCharacter:String = String.fromCharCode(e.charCode);
                if (newCharacter != null && newCharacter != "" && "1234567890-.e".indexOf(newCharacter.toLowerCase()) != -1 &&
                    (newCharacter != "-" || this.button.tf.text.length == 0 || this.button.tf.text.charAt(-1).toLowerCase() == "e") // Only the front or directly after an e may be a negative sign
                    && (newCharacter != "." || this.button.tf.text.indexOf(".") == -1) // Only one decimal allowed
                    && (newCharacter.toLowerCase() != "e" || this.button.tf.text.toLowerCase().indexOf("e") == -1) // Only one e allowed
                    )
                {
                    this.button.tf.text = this.button.tf.text + newCharacter.toLowerCase();
                }
            }
            e.stopImmediatePropagation();
            e.preventDefault();
        }

        private function onNumberClicked(e:MouseEvent):void
        {
            GCLGV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "";
            this.button.plate.filters = [new ColorMatrixFilter([
                        1, 0, 0, 0, 0,
                        0, .5, 0, 0, 0,
                        0, 0, .5, 0, 0,
                        0, 0, 0, 1, 0])];
        }

        private function onStringTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                this.button.plate.filters = [];
                GCLGV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            }
            else if (e.keyCode == Keyboard.ENTER)
            {
                if (this.validator(this.button.tf.text))
                {
                    this.onSet(this.button.tf.text);
                }
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                this.button.plate.filters = [];
                GCLGV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GCLGV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            }
            else if (e.keyCode == Keyboard.BACKSPACE)
            {
                this.button.tf.text = this.button.tf.text.slice(0, -1);
            }
            else
            {
                var newCharacter:String = String.fromCharCode(e.charCode);
                if (newCharacter != null && newCharacter != "")
                {
                    this.button.tf.text = this.button.tf.text + newCharacter;
                }
            }
            e.stopImmediatePropagation();
            e.preventDefault();
        }

        private function onStringClicked(e:MouseEvent):void
        {
            GCLGV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GCLGV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "";
            this.button.plate.filters = [new ColorMatrixFilter([
                        1, 0, 0, 0, 0,
                        0, .5, 0, 0, 0,
                        0, 0, .5, 0, 0,
                        0, 0, 0, 1, 0])];
        }

        private function onButtonClicked(e:MouseEvent):void
        {
            this.button.plate.filters = [new ColorMatrixFilter([
                        1, 0, 0, 0, 0,
                        0, .5, 0, 0, 0,
                        0, 0, .5, 0, 0,
                        0, 0, 0, 1, 0])];

            this.button.addEventListener(MouseEvent.MOUSE_OUT, resetPlateColor, false, 0, true);
            this.button.addEventListener(MouseEvent.MOUSE_UP, resetPlateColor, false, 0, true);
            onSet();
        }

        private function resetPlateColor(e:MouseEvent):void
        {
            this.button.removeEventListener(MouseEvent.MOUSE_OUT, resetPlateColor, false);
            this.button.removeEventListener(MouseEvent.MOUSE_UP, resetPlateColor, false);
            this.button.plate.filters = [];
        }

        public function onClicked(e:MouseEvent):void
        {
            switch (type)
            {
                case TYPE_BOOL:
                    return onBooleanClicked(e);
                case TYPE_KEYBIND:
                    return onKeybindClicked(e);
                case TYPE_NUMBER:
                    return onNumberClicked(e);
                case TYPE_RANGE:
                    return onRangeClicked(e);
                case TYPE_STRING:
                    return onStringClicked(e);
                case TYPE_BUTTON:
                    return onButtonClicked(e);
            }
        }
    }
}
