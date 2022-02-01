package Bezel.GCCS
{
	import Bezel.Utils.Keybind;
	
	import com.giab.common.utils.MathToolbox;
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.mcDyn.McInfoPanel;
	import com.giab.games.gccs.steam.mcDyn.McOptPanel;
	import com.giab.games.gccs.steam.mcDyn.McOptTitle;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.describeType;

    /**
     * ...
     * @author Chris
     */
    internal class GCCSSettingsHandler
    {
        private static const newSettings:Vector.<GCCSSetting> = new Vector.<GCCSSetting>();

        private static var newMCs:Vector.<MovieClip> = new Vector.<MovieClip>();
        private static var currentlyShowing:Boolean = false;

        internal static var IS_CHOOSING_KEYBIND:Boolean = false;

        private static var KeyboardConstants:XMLList = describeType(Keyboard).constant.(@type == "uint").@name;

        internal static function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String):void
		{
            newSettings[newSettings.length] = GCCSSetting.makeBool(mod, name, onSet, currentValue, description);
		}

		internal static function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String):void
		{
			newSettings[newSettings.length] = GCCSSetting.makeRange(mod, name, min, max, step, onSet, currentValue, description);
		}

        internal static function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String):void
        {
            newSettings[newSettings.length] = GCCSSetting.makeKeybind(name, onSet, currentValue, description);
        }

        internal static function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void
        {
            newSettings[newSettings.length] = GCCSSetting.makeNumber(mod, name, min, max, onSet, currentValue, description);
        }

        internal static function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void
        {
            newSettings[newSettings.length] = GCCSSetting.makeString(mod, name, validator, onSet, currentValue, description);
        }

		internal static function deregisterOption(mod:String, name:String):void
		{
            for (var i:int = newSettings.length; i > 0; i--)
            {
                if (newSettings[i-1].mod as String == mod && (name == null || newSettings[i-1].name as String == name))
                {
                    newSettings.splice(i-1, 1);
                }
            }
		}

        internal static function toggleCustomSettingsFromGame():void
        {
            if (!currentlyShowing)
            {
                var vY:int = 1630;
                var currentPanelX:int = getNewPanelX(0);
                newSettings.sort(function(left:GCCSSetting, right:GCCSSetting):Number{
                    // Sort keybinds first
                    if (left.mod == GCCSSetting.MOD_KEYBIND)
                    {
                        if (right.mod == GCCSSetting.MOD_KEYBIND)
                        {
                            if (left.name < right.name)
                                return -1;
                            if (left.name > right.name)
                                return 1;
                            return 0;
                        }
                        else
                        {
                            return 1;
                        }
                    }
                    else if (right.mod == GCCSSetting.MOD_KEYBIND)
                    {
                        return -1;
                    }
                    if (left.mod < right.mod)
                        return -1;
                    if (left.mod > right.mod)
                        return 1;
                    if (left.name < right.name)
                        return -1;
                    if (left.name > right.name)
                        return 1;
                    return 0;
                });
                var currentName:String = null;
                for each (var setting:GCCSSetting in newSettings)
                {
                    if (currentName != setting.mod)
                    {
                        vY += 80;
                        currentPanelX = getNewPanelX(0);
                        addMC(new McOptTitle(setting.mod, 127, vY));
                        currentName = setting.mod;
                    }

                    if (setting.type == GCCSSetting.TYPE_BOOL)
                    {
                        vY += getNewPanelYModifier(currentPanelX);
                        var boolPanel:McOptPanel = new McOptPanel(setting.name, currentPanelX, vY, false);
                        currentPanelX = getNewPanelX(currentPanelX);
                        var onBooleanClicked:Function = function(s:GCCSSetting):Function
                        {
                            return function(e:MouseEvent):void
                            {
                                var current:Boolean = s.currentVal();
                                s.onSet(!current);
                                e.target.parent.btn.gotoAndStop(!current ? 2 : 1);
                            };
                        }(setting);
                        boolPanel.btn.gotoAndStop(setting.currentVal() ? 2 : 1);
                        boolPanel.plate.addEventListener(MouseEvent.CLICK, onBooleanClicked);
                        setting.panel = boolPanel;

                        addMC(boolPanel);
                    }
                    else if (setting.type == GCCSSetting.TYPE_RANGE)
                    {
                        vY += getNewPanelYModifier(currentPanelX);
                        var rangePanel:McOptPanel = new McOptPanel(setting.name, currentPanelX, vY, true);
                        currentPanelX = getNewPanelX(currentPanelX);
                        var onRangeClicked:Function = function(s:GCCSSetting):Function
                        {
                            var onRangeReleased:Function = function(e:MouseEvent):void
                            {
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, arguments.callee, true);
                                GV.main.scrOptions.isDragging = false;
                                if (GV.main.scrOptions.draggedKnob != null)
                                {
                                    GV.main.scrOptions.draggedKnob.gotoAndStop(1);
                                    GV.main.scrOptions.draggedKnob = null;
                                }
                                GV.main.scrOptions.isVpDragging = false;

                                s.onSet(calculateValue(s, s.panel.knob));
                            };
                            return function(e:MouseEvent):void
                            {
                                GV.main.scrOptions.draggedKnob = e.target.parent;
                                GV.main.scrOptions.draggedKnob.gotoAndStop(2);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, onRangeReleased, true, 0, false);
                                GV.main.scrOptions.isDragging = true;
                            };
                        }(setting);
                        rangePanel.knob.addEventListener(MouseEvent.MOUSE_DOWN, onRangeClicked);
                        setting.panel = rangePanel;

                        addMC(rangePanel);
                        
                        rangePanel.knob.x = calculateX(setting);
                    }
                    else if (setting.type == GCCSSetting.TYPE_KEYBIND)
                    {
                        vY += 40;
                        currentPanelX = getNewPanelX(0);
                        var keybindButton:SettingsButtonShim = new SettingsButtonShim(GV.main.scrOptions.mc.btnClose);
                        keybindButton.tf.text = (setting.currentVal()).toString().toUpperCase();
                        var onKeybindClick:Function = function(s:GCCSSetting):Function
                        {
                            var onKeybindTyped:Function = function(e:KeyboardEvent):void
                            {
                                if (e.keyCode == 0 || e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.SHIFT || e.keyCode == Keyboard.ALTERNATE)
                                    return;
                                GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                e.stopImmediatePropagation();
                                e.preventDefault();
                                s.button.plate.gotoAndStop(1);

                                IS_CHOOSING_KEYBIND = false;

                                if (e.keyCode == Keyboard.ESCAPE)
                                {
                                    s.button.tf.text = s.currentVal().toString().toUpperCase();
                                    return;
                                }

                                var sequence:String = (e.controlKey ? "ctrl+" : "") +
                                                        (e.shiftKey ? "shift+" : "") +
                                                        (e.altKey ? "alt+" : "");
                                
                                for each (var key:String in KeyboardConstants)
                                {
                                    if (e.keyCode == Keyboard[key])
                                    {
                                        sequence = sequence + key.toLowerCase();
                                        break;
                                    }
                                }

                                s.onSet(new Keybind(sequence));

                                s.button.tf.text = sequence.toUpperCase();

                                updateButtonColors();
                            };
                            return function(e:MouseEvent):void
                            {
                                GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, false);
                                s.button.tf.text = "???";
                                s.button.plate.gotoAndStop(4);

                                IS_CHOOSING_KEYBIND = true;
                            };
                        }(setting);
                        keybindButton.addEventListener(MouseEvent.CLICK, onKeybindClick, true);
                        keybindButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseover);
                        keybindButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseout);

                        keybindButton.yReal = vY - 3;
                        keybindButton.x = 625;

                        var keybindPanel:McOptPanel = new McOptPanel(setting.name, 200, vY, false);
                        keybindPanel.removeChild(keybindPanel.btn);

                        var keybindExtraSize:Sprite = new Sprite();
                        keybindExtraSize.graphics.beginFill(0,0);
                        keybindExtraSize.graphics.drawRect(0,0,1,1);
                        keybindExtraSize.graphics.endFill();
                        keybindExtraSize.width = (keybindButton.x + keybindButton.width) - 200;
                        keybindExtraSize.height = keybindButton.height;

                        keybindPanel.addChild(keybindExtraSize);
                        keybindExtraSize.y = -3;

                        setting.panel = keybindPanel;
                        setting.button = keybindButton;
                        
                        addMC(keybindPanel);
                        addMC(keybindButton);
                    }
                    else if (setting.type == GCCSSetting.TYPE_NUMBER)
                    {
                        vY += 40;
                        currentPanelX = getNewPanelX(0);
                        var numberButton:SettingsButtonShim = new SettingsButtonShim(GV.main.scrOptions.mc.btnClose);
                        numberButton.tf.text = setting.currentVal().toString();
                        var onNumberClicked:Function = function(s:GCCSSetting):Function
                        {
                            var onNumberTyped:Function = function(e:KeyboardEvent):void
                            {
                                if (e.keyCode == Keyboard.ESCAPE)
                                {
                                    s.button.tf.text = setting.currentVal().toString();
                                    s.button.plate.gotoAndStop(1);
                                    GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                    GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                }
                                else if (e.keyCode == Keyboard.ENTER)
                                {
                                    if (s.button.tf.text.lastIndexOf("-") <= 0 && s.button.tf.text.indexOf(".") == s.button.tf.text.lastIndexOf("."))
                                    {
                                        var newValue:Number = parseFloat(s.button.tf.text);
                                        if (!isNaN(newValue) && newValue > s.min && newValue < s.max)
                                        {
                                            s.onSet(newValue);
                                        }
                                    }
                                    s.button.tf.text = s.currentVal().toString();
                                    s.button.plate.gotoAndStop(1);
                                    GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                    GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                }
                                else if (e.keyCode == Keyboard.BACKSPACE)
                                {
                                    s.button.tf.text = s.button.tf.text.slice(0, -1);
                                }
                                else
                                {
                                    var newCharacter:String = String.fromCharCode(e.charCode);
                                    if (newCharacter != null && newCharacter != "" && "1234567890-.e".indexOf(newCharacter.toLowerCase()) != -1 &&
                                        (newCharacter != "-" || s.button.tf.text.length == 0 || s.button.tf.text.charAt(-1).toLowerCase() == "e") // Only the front or directly after an e may be a negative sign
                                        && (newCharacter != "." || s.button.tf.text.indexOf(".") == -1) // Only one decimal allowed
                                        && (newCharacter.toLowerCase() != "e" || s.button.tf.text.toLowerCase().indexOf("e") == -1) // Only one e allowed
                                        )
                                    {
                                        s.button.tf.text = s.button.tf.text + newCharacter.toLowerCase();
                                    }
                                }
                                e.stopImmediatePropagation();
                                e.preventDefault();
                            };
                            return function(e:MouseEvent):void
                            {
                                GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onNumberTyped, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, false);
                                s.button.tf.text = "";
                                s.button.plate.gotoAndStop(4);
                            };
                        }(setting);
                        numberButton.addEventListener(MouseEvent.CLICK, onNumberClicked, true);
                        numberButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseover);
                        numberButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseout);

                        numberButton.yReal = vY - 6;
                        numberButton.x = 625;

                        var numberPanel:McOptPanel = new McOptPanel(setting.name, 200, vY, false);
                        numberPanel.removeChild(numberPanel.btn);

                        var integerExtraSize:Sprite = new Sprite();
                        integerExtraSize.graphics.beginFill(0,0);
                        integerExtraSize.graphics.drawRect(0,0,1,1);
                        integerExtraSize.graphics.endFill();
                        integerExtraSize.width = (numberButton.x + numberButton.width) - 200;
                        integerExtraSize.height = numberButton.height;

                        numberPanel.addChild(integerExtraSize);
                        integerExtraSize.y = -3;

                        setting.panel = numberPanel;
                        setting.button = numberButton;
                        
                        addMC(numberPanel);
                        addMC(numberButton);
                    }
                    else if (setting.type == GCCSSetting.TYPE_STRING)
                    {
                        vY += 40;
                        currentPanelX = getNewPanelX(0);
                        var stringButton:SettingsButtonShim = new SettingsButtonShim(GV.main.scrOptions.mc.btnClose);
                        stringButton.plate.scaleX = 3;
                        stringButton.tf.width = stringButton.plate.width;
                        stringButton.tf.text = setting.currentVal();
                        var onStringClick:Function = function(s:GCCSSetting):Function
                        {
                            var onStringTyped:Function = function(e:KeyboardEvent):void
                            {
                                if (e.keyCode == Keyboard.ESCAPE)
                                {
                                    s.button.tf.text = setting.currentVal().toString();
                                    s.button.plate.gotoAndStop(1);
                                    GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                    GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                }
                                else if (e.keyCode == Keyboard.ENTER)
                                {
                                    if (s.validator(s.button.tf.text))
                                    {
                                        s.onSet(s.button.tf.text);
                                    }
                                    s.button.tf.text = s.currentVal().toString();
                                    s.button.plate.gotoAndStop(1);
                                    GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                    GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                    GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                }
                                else if (e.keyCode == Keyboard.BACKSPACE)
                                {
                                    s.button.tf.text = s.button.tf.text.slice(0, -1);
                                }
                                else
                                {
                                    var newCharacter:String = String.fromCharCode(e.charCode);
                                    if (newCharacter != null && newCharacter != "")
                                    {
                                        s.button.tf.text = s.button.tf.text + newCharacter;
                                    }
                                }
                                e.stopImmediatePropagation();
                                e.preventDefault();
                            };
                            return function(e:MouseEvent):void
                            {
                                GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onStringTyped, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, false);
                                GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, false);
                                s.button.tf.text = "";
                                s.button.plate.gotoAndStop(4);
                            };
                        }(setting);
                        stringButton.addEventListener(MouseEvent.CLICK, onStringClick, true);
                        stringButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseover);
                        stringButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseout);

                        stringButton.yReal = vY - 6;
                        stringButton.x = 525;

                        var stringPanel:McOptPanel = new McOptPanel(setting.name, 100, vY, false);
                        stringPanel.removeChild(stringPanel.btn);

                        var stringExtraSize:Sprite = new Sprite();
                        stringExtraSize.graphics.beginFill(0,0);
                        stringExtraSize.graphics.drawRect(0,0,1,1);
                        stringExtraSize.graphics.endFill();
                        stringExtraSize.width = (stringButton.x + stringButton.width) - 100;
                        stringExtraSize.height = stringButton.height;

                        stringPanel.addChild(stringExtraSize);
                        stringExtraSize.y = -6;

                        setting.panel = stringPanel;
                        setting.button = stringButton;
                        
                        addMC(stringPanel);
                        addMC(stringButton);
                    }
                    else
                    {
                        throw new Error("Unrecognized option type when enabling settings");
                    }
                }

                updateButtonColors();
            }
            else
            {
                for (var i:int = 0; i < newMCs.length; i++)
                {
                    GV.main.scrOptions.mc.arrCntContents.pop();
                    GV.main.scrOptions.mc.cnt.removeChild(newMCs[i]);
                }
                newMCs.length = 0;
            }

            GV.main.scrOptions.vpYMax = 0;
            for (i = 0; i < GV.main.scrOptions.mc.arrCntContents.length; i++)
            {
                GV.main.scrOptions.vpYMax = Math.max(GV.main.scrOptions.vpYMax, GV.main.scrOptions.mc.arrCntContents[i].yReal - 435);
            }

            GV.main.scrOptions.renderViewport();

            currentlyShowing = !currentlyShowing;
        }

        internal static function renderInfoPanel(vP:Object, vIp:Object):Boolean
        {
            var optPanel:McOptPanel = vP as McOptPanel;
            var infoPanel:McInfoPanel = vIp as McInfoPanel;
            var i:int = newMCs.indexOf(optPanel);
            if (i == -1)
            {
                return false;
            }
            else
            {
                for each (var setting:GCCSSetting in newSettings)
                {
                    if (optPanel == setting.panel)
                    {
                        var display:Boolean = false;
                        if (setting.description != "" && setting.description != null)
                        {
                            infoPanel.addTextfield(15984813, setting.description, false, 12, null, 16777215);
                            display = true;
                        }
                        if (optPanel.knob.parent == optPanel) // if it has a draggable field
                        {
                            infoPanel.addTextfield(15984813, "Current value: " + calculateValue(setting, optPanel.knob));
                            display = true;
                        }
                        return display;
                    }
                }
            }
            // not reachable
            return false;
        }

        private static function calculateValue(setting:GCCSSetting, knob:MovieClip):Number
        {
            var result:Number = MathToolbox.convertCoord(338, 388, knob.x, setting.min, setting.max);
            if (result == setting.max || result == setting.min)
            {
                return result;
            }
            if (result % setting.step != 0)
            {
                return result - (result % setting.step);
            }
            return result;
        }

        private static function calculateX(setting:GCCSSetting):Number
        {
            return MathToolbox.convertCoord(setting.min, setting.max, setting.currentVal(), 338, 388);
        }

        private static function addMC(mc:MovieClip):void
        {
            newMCs.push(mc);
            GV.main.scrOptions.mc.arrCntContents.push(mc);
            GV.main.scrOptions.mc.cnt.addChild(mc);
        }

        private static function getNewPanelX(currentPanelX:int):int
        {
            if (currentPanelX == 89)
            {
                return 559;
            }
            else
            {
                return 89;
            }
        }

        private static function getNewPanelYModifier(currentPanelX:int):int
        {
            if (currentPanelX == 89)
            {
                return 40;
            }
            else
            {
                return 0;
            }
        }

        private static function updateButtonColors():void
        {
            for (var i:int = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == GCCSSetting.TYPE_KEYBIND)
                {
                    newSettings[i].button.tf.setTextFormat(new TextFormat(null, null, 0xFFFFFF));
                }
            }

            for (i = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == GCCSSetting.TYPE_KEYBIND)
                {
                    var kb:Keybind = newSettings[i].currentVal();
                    for (var j:int = i+1; j < newSettings.length; j++)
                    {
                        if (newSettings[j].type == GCCSSetting.TYPE_KEYBIND && kb.matches(newSettings[j].currentVal()))
                        {
                            newSettings[j].button.tf.setTextFormat(new TextFormat(null, null, 0xFF0000));
                            newSettings[i].button.tf.setTextFormat(new TextFormat(null, null, 0xFF0000));
                        }
                    }
                }
            }
        }

        private static function onButtonMouseover(e:MouseEvent):void
        {
            e.target.parent.plate.gotoAndStop(2);
        }

        private static function onButtonMouseout(e:MouseEvent):void
        {
            e.target.parent.plate.gotoAndStop(1);
        }

        private static function discardAllMouseInput(e:MouseEvent):void
        {
            e.stopImmediatePropagation();
        }
    }
}
