package Bezel.GCFW
{
    import Bezel.bezel_internal;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;
    import Bezel.Utils.Keybind;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import flash.utils.describeType;
    import flash.text.TextFormat;
    import flash.display.Sprite;

    /**
     * ...
     * @author Chris
     */
    public class GCFWSettingsHandler
    {
        private static var _newSettings:Vector.<Object>;
        private static function get newSettings():Vector.<Object>
        {
            if (_newSettings == null)
            {
                _newSettings = new Vector.<Object>();
            }
            return _newSettings;
        }

        private static var newMCs:Array = new Array();
        private static var currentlyShowing:Boolean = false;

        bezel_internal static var IS_CHOOSING_KEYBIND:Boolean = false;

        private static var KeyboardConstants:XMLList = describeType(Keyboard).constant.(@type == "uint").@name;

        bezel_internal static function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String):void
		{
            newSettings.push({"type":Boolean, "mod":mod, "name":name, "onSet":onSet, "currentVal":currentValue, "description":description, "panel":null});
		}

		bezel_internal static function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String):void
		{
			newSettings.push({"type":Number, "mod":mod, "name":name, "min":min, "max":max, "step":step, "onSet":onSet, "currentVal":currentValue, "description":description, "panel":null});
		}

        bezel_internal static function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String):void
        {
            newSettings.push({"type":Keybind, "mod":"Keybinds", "name":name, "onSet":onSet, "currentVal":currentValue, "description":description, "panel":null, "button":null});
        }

		bezel_internal static function deregisterOption(mod:String, name:String):void
		{
            for (var i:int = newSettings.length; i > 0; i--)
            {
                if (newSettings[i-1].mod as String == mod && (name == null || newSettings[i-1].name as String == name))
                {
                    newSettings.splice(i-1, 1);
                }
            }
		}

        bezel_internal static function toggleCustomSettingsFromGame(scrOptions:Object):void
        {
            if (!currentlyShowing)
            {
                var vY:int = 2720;
                newSettings.sort(function(left:Object, right:Object):Number{
                    // Sort keybinds first
                    if (left.mod == "Keybinds")
                    {
                        if (right.mod == "Keybinds")
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
                    else if (right.mod == "Keybinds")
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
                var McOptPanel:Class = getDefinitionByName("com.giab.games.gcfw.mcDyn.McOptPanel") as Class;
                var McOptTitle:Class = getDefinitionByName("com.giab.games.gcfw.mcDyn.McOptTitle") as Class;
                for each (var setting:Object in newSettings)
                {
                    var newMC:Object = null;
                    if (currentName != setting.mod)
                    {
                        vY += 120;
                        newMC = new McOptTitle(setting.mod, 536, vY);
                        newMCs.push(newMC);
                        scrOptions.mc.arrCntContents.push(newMC);
                        scrOptions.mc.cnt.addChild(newMC);
                        currentName = setting.mod;
                    }

                    if (setting.type == Boolean)
                    {
                        vY += 60;
                        newMC = new McOptPanel(setting.name, 658, vY, false);
                        var onBooleanClicked:Function = function(s:Object):Function
                        {
                            return function(e:MouseEvent):void
                            {
                                var current:Boolean = s.currentVal();
                                s.onSet(!current);
                                e.target.parent.btn.gotoAndStop(!current ? 2 : 1);
                            };
                        }(setting);
                        newMC.btn.gotoAndStop(setting.currentVal() ? 2 : 1);
                        newMC.plate.addEventListener(MouseEvent.CLICK, onBooleanClicked);
                        setting.panel = newMC;

                        newMCs.push(newMC);
                        scrOptions.mc.arrCntContents.push(newMC);
                        scrOptions.mc.cnt.addChild(newMC);
                    }
                    else if (setting.type == Number)
                    {
                        vY += 60;
                        newMC = new McOptPanel(setting.name, 658, vY, true);
                        var onNumberClicked:Function = function(s:Object):Function
                        {
                            var onNumberReleased:Function = function(e:MouseEvent):void
                            {
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, arguments.callee, true);
                                scrOptions.isDragging = false;
                                if (scrOptions.draggedKnob != null)
                                {
                                    scrOptions.draggedKnob.gotoAndStop(1);
                                    scrOptions.draggedKnob = null;
                                }
                                scrOptions.isVpDragging = false;

                                s.onSet(calculateValue(s, s.panel.knob));
                            };
                            return function(e:MouseEvent):void
                            {
                                scrOptions.draggedKnob = e.target.parent;
                                scrOptions.draggedKnob.gotoAndStop(2);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, onNumberReleased, true, 0, false);
                                scrOptions.isDragging = true;
                            };
                        }(setting);
                        newMC.knob.addEventListener(MouseEvent.MOUSE_DOWN, onNumberClicked);
                        setting.panel = newMC;
                        
                        newMCs.push(newMC);
                        scrOptions.mc.arrCntContents.push(newMC);
                        scrOptions.mc.cnt.addChild(newMC);

                        newMC.knob.x = calculateX(setting);
                    }
                    else if (setting.type == Keybind)
                    {
                        vY += 60;
                        var newButton:SettingsButtonShim = new SettingsButtonShim(scrOptions.mc.btnClose);
                        newButton.tf.text = (setting.currentVal()).toString().toUpperCase();
                        var onKeybindMouseover:Function = function(e:MouseEvent):void
                        {
                            e.target.parent.plate.gotoAndStop(2);
                        };
                        var onKeybindMouseout:Function = function(e:MouseEvent):void
                        {
                            e.target.parent.plate.gotoAndStop(1);
                        }
                        var discardAllMouseInput:Function = function(e:MouseEvent):void
                        {
                            e.stopImmediatePropagation();
                        }
                        var onKeybindClick:Function = function(s:Object):Function
                        {
                            var onKeybindTyped:Function = function(e:KeyboardEvent):void
                            {
                                if (e.keyCode == 0 || e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.SHIFT || e.keyCode == Keyboard.ALTERNATE)
                                    return;
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.CLICK, discardAllMouseInput, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true);
                                e.stopImmediatePropagation();
                                e.preventDefault();
                                s.button.plate.gotoAndStop(1);

                                bezel_internal::IS_CHOOSING_KEYBIND = false;

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
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeybindTyped, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.CLICK, discardAllMouseInput, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_DOWN, discardAllMouseInput, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, discardAllMouseInput, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_OVER, discardAllMouseInput, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_OUT, discardAllMouseInput, true, 10, false);
                                Bezel.Bezel.instance.gameObjects.GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, discardAllMouseInput, true, 10, false);
                                s.button.tf.text = "???";
                                s.button.plate.gotoAndStop(4);

                                bezel_internal::IS_CHOOSING_KEYBIND = true;
                            };
                        }(setting);
                        newButton.addEventListener(MouseEvent.CLICK, onKeybindClick, true);
                        newButton.addEventListener(MouseEvent.MOUSE_OVER, onKeybindMouseover);
                        newButton.addEventListener(MouseEvent.MOUSE_OUT, onKeybindMouseout);

                        newButton.yReal = vY - 6;
                        newButton.x = 1150;

                        newMC = new McOptPanel(setting.name, 500, vY, false);
                        newMC.removeChild(newMC.btn);

                        var extraSizeSprite:Sprite = new Sprite();
                        extraSizeSprite.graphics.beginFill(0,0);
                        extraSizeSprite.graphics.drawRect(0,0,1,1);
                        extraSizeSprite.graphics.endFill();
                        extraSizeSprite.width = (newButton.x + newButton.width) - 500;
                        extraSizeSprite.height = newButton.height;

                        newMC.addChild(extraSizeSprite);
                        extraSizeSprite.y = -6;

                        setting.panel = newMC;
                        setting.button = newButton;

                        newMCs.push(newMC);
                        scrOptions.mc.arrCntContents.push(newMC);
                        scrOptions.mc.cnt.addChild(newMC);
                        
                        newMCs.push(newButton);
                        scrOptions.mc.arrCntContents.push(newButton);
                        scrOptions.mc.cnt.addChild(newButton);
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
                    scrOptions.mc.arrCntContents.pop();
                    scrOptions.mc.cnt.removeChild(newMCs[i]);
                }
                newMCs.length = 0;
            }

            scrOptions.vpYMax = 0;
            for (i = 0; i < scrOptions.mc.arrCntContents.length; i++)
            {
                scrOptions.vpYMax = Math.max(scrOptions.vpYMax, scrOptions.mc.arrCntContents[i].yReal - 735);
            }

            scrOptions.renderViewport();

            currentlyShowing = !currentlyShowing;
        }

        bezel_internal static function renderInfoPanel(vP:Object, vIp:Object):Boolean
        {
            var i:int = newMCs.indexOf(vP);
            if (i == -1)
            {
                return false;
            }
            else
            {
                for each (var setting:Object in newSettings)
                {
                    if (vP == setting.panel)
                    {
                        var display:Boolean = false;
                        if (setting.description != "" && setting.description != null)
                        {
                            vIp.addTextfield(15984813, setting.description, false, 12, null, 16777215);
                            display = true;
                        }
                        if (vP.knob.parent == vP) // if it has a draggable field
                        {
                            vIp.addTextfield(15984813, "Current value: " + calculateValue(setting, vP.knob));
                            display = true;
                        }
                        return display;
                    }
                }
            }
            // not reachable
            return false;
        }

        private static var convertCoord:Function = getDefinitionByName("com.giab.common.utils.MathToolbox").convertCoord;

        private static function calculateValue(setting:Object, knob:Object):Number
        {
            var result:Number = convertCoord(507, 582, knob.x, setting.min, setting.max);
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

        private static function calculateX(setting:Object):Number
        {
            return convertCoord(setting.min, setting.max, setting.currentVal(), 507, 582);
        }

        private static function updateButtonColors():void
        {
            for (var i:int = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == Keybind)
                {
                    newSettings[i].button.tf.setTextFormat(new TextFormat(null, null, 0xFFFFFF));
                }
            }

            for (i = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == Keybind)
                {
                    var kb:Keybind = newSettings[i].currentVal();
                    for (var j:int = i+1; j < newSettings.length; j++)
                    {
                        if (newSettings[j].type == Keybind && kb.matches(newSettings[j].currentVal()))
                        {
                            newSettings[j].button.tf.setTextFormat(new TextFormat(null, null, 0xFF0000));
                            newSettings[i].button.tf.setTextFormat(new TextFormat(null, null, 0xFF0000));
                        }
                    }
                }
            }
        }
    }
}
