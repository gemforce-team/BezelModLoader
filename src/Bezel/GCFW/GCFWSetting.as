package Bezel.GCFW
{
    import Bezel.Utils.SettingManager;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import Bezel.Utils.Keybind;

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
            return new GCFWSetting(TYPE_KEYBIND, SettingManager.MOD_KEYBIND, name, onSet, currentVal, description);
        }

        public static function makeNumber(mod:String, name:String, min:Number, max:Number, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_NUMBER, mod, name, onSet, currentVal, description, min, max);
        }

        public static function makeString(mod:String, name:String, validator:Function, onSet:Function, currentVal:Function, description:String):GCFWSetting
        {
            return new GCFWSetting(TYPE_STRING, mod, name, onSet, currentVal, description, NaN, NaN, NaN, validator);
        }

        private function discardAllMouseInput(e:MouseEvent):void
        {
            e.stopImmediatePropagation();
        }

        private function onBooleanClicked(e:MouseEvent):void
        {
            var current:Boolean = this.currentVal();
            this.onSet(!current);
            e.target.parent.btn.gotoAndStop(!current ? 2 : 1);
        }

        private function onRangeClicked(e:MouseEvent):void
        {
            GV.main.scrOptions.draggedKnob = e.target.parent;
            GV.main.scrOptions.draggedKnob.gotoAndStop(2);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, this.onRangeReleased, true, 0, true);
            GV.main.scrOptions.isDragging = true;
        }

        private function onRangeReleased(e:MouseEvent):void
        {
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onRangeReleased, true);
            GV.main.scrOptions.isDragging = false;
            if (GV.main.scrOptions.draggedKnob != null)
            {
                GV.main.scrOptions.draggedKnob.gotoAndStop(1);
                GV.main.scrOptions.draggedKnob = null;
            }
            GV.main.scrOptions.isVpDragging = false;

            this.onSet(GCFWSettingsHandler.calculateValue(this, (this.panel as McOptPanel).knob));
        }

        private function onKeybindTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == 0 || e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.SHIFT || e.keyCode == Keyboard.ALTERNATE)
                return;
            GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true);
            GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            e.stopImmediatePropagation();
            e.preventDefault();
            this.button.plate.gotoAndStop(1);

            GCFWSettingsHandler.IS_CHOOSING_KEYBIND = false;

            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString().toUpperCase();
                return;
            }

            var sequence:String = (e.controlKey ? "ctrl+" : "") +
                (e.shiftKey ? "shift+" : "") +
                (e.altKey ? "alt+" : "");

            for each (var key:String in GCFWSettingsHandler.KeyboardConstants)
            {
                if (e.keyCode == Keyboard[key])
                {
                    sequence = sequence + key.toLowerCase();
                    break;
                }
            }

            this.onSet(new Keybind(sequence));

            this.button.tf.text = sequence.toUpperCase();

            GCFWSettingsHandler.updateButtonColors();
        }

        private function onKeybindClicked(e:MouseEvent):void
        {
            GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "???";
            this.button.plate.gotoAndStop(4);

            GCFWSettingsHandler.IS_CHOOSING_KEYBIND = true;
        }

        private function onNumberTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true);
                GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
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
                GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true);
                GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
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
            GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "";
            this.button.plate.gotoAndStop(4);
        }

        private function onStringTyped(e:KeyboardEvent):void
        {
            if (e.keyCode == Keyboard.ESCAPE)
            {
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true);
                GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
            }
            else if (e.keyCode == Keyboard.ENTER)
            {
                if (this.validator(this.button.tf.text))
                {
                    this.onSet(this.button.tf.text);
                }
                this.button.tf.text = this.currentVal().toString();
                this.button.plate.gotoAndStop(1);
                GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true);
                GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
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
            GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, true);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, true);
            this.button.tf.text = "";
            this.button.plate.gotoAndStop(4);
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
            }
        }
    }
}
