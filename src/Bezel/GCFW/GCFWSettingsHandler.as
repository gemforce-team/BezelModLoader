package Bezel.GCFW
{
    import Bezel.bezel_internal;
    import flash.utils.getDefinitionByName;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    /**
     * ...
     * @author Chris
     */
    public class GCFWSettingsHandler
    {
        private static var _newSettings:Array;
        private static function get newSettings():Array
        {
            if (_newSettings == null)
            {
                _newSettings = new Array();
            }
            return _newSettings;
        }

        private static var newMCs:Array = new Array();
        private static var currentlyShowing:Boolean = false;
        private static var currentKnobEditing:Object;

        bezel_internal static function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String):void
		{
            newSettings.push({"type":Boolean, "mod":mod, "name":name, "onSet":onSet, "currentVal":currentValue, "description":description});
		}

		bezel_internal static function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String):void
		{
			newSettings.push({"type":Number, "mod":mod, "name":name, "min":min, "max":max, "step":step, "onSet":onSet, "currentVal":currentValue, "description":description});
		}

		bezel_internal static function deregisterOption(mod:String, name:String):void
		{
            for (var i:int = newSettings.length; i > 0; i--)
            {
                if (newSettings[i-1].mod as String == mod && newSettings[i-1].name as String == name)
                {
                    delete newSettings[i-1];
                }
            }
		}

        bezel_internal static function toggleCustomSettingsFromGame(scrOptions:Object):void
        {
            if (!currentlyShowing)
            {
                var vY:int = 2720;
                newSettings.sortOn(["mod", "name"]);
                var currentName:String = null;
                var McOptPanel:Class = getDefinitionByName("com.giab.games.gcfw.mcDyn.McOptPanel") as Class;
                var McOptTitle:Class = getDefinitionByName("com.giab.games.gcfw.mcDyn.McOptTitle") as Class;
                for each (var setting:Object in newSettings)
                {
                    var newMC:MovieClip = null;
                    if (currentName != setting.mod)
                    {
                        vY += 120;
                        newMC = new McOptTitle(setting.mod, 536, vY);
                        newMCs.push(newMC);
                        scrOptions.mc.arrCntContents.push(newMC);
                        scrOptions.mc.cnt.addChild(newMC);
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
                    }
                    else if (setting.type == Number)
                    {
                        vY += 60;
                        newMC = new McOptPanel(setting.name, 658, vY, true);
                        var onNumberReleased:Function = function(s:Object):Function
                        {
                            return function(e:MouseEvent):void
                            {
                                getDefinitionByName("com.giab.games.gcfw.GV").main.stage.removeEventListener(MouseEvent.MOUSE_UP, arguments.callee, true);
                                scrOptions.isDragging = false;
                                if (scrOptions.draggedKnob != null)
                                {
                                    scrOptions.draggedKnob.gotoAndStop(1);
                                    scrOptions.draggedKnob = null;
                                }
                                scrOptions.isVpDragging = false;

                                s.onSet(calculateValue(s, newMC.knob));
                            };
                        }(setting);
                        var onNumberClicked:Function = function(s:Object):Function
                        {
                            return function(e:MouseEvent):void
                            {
                                scrOptions.draggedKnob = e.target.parent;
                                scrOptions.draggedKnob.gotoAndStop(2);
                                getDefinitionByName("com.giab.games.gcfw.GV").main.stage.addEventListener(MouseEvent.MOUSE_UP, onNumberReleased, true, 0, false);
                                scrOptions.isDragging = true;
                                currentKnobEditing = s;
                            };
                        }(setting);
                        newMC.knob.addEventListener(MouseEvent.MOUSE_DOWN, scrOptions.ehKnobDown);
                    }
                    else
                    {
                        throw new Error("Unrecognized option type when enabling settings");
                    }
                    newMCs.push(newMC);
                    scrOptions.mc.arrCntContents.push(newMC);
                    scrOptions.mc.cnt.addChild(newMC);
                }
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
                for (var j:int = 0; j < newSettings.length; j++)
                {
                    if (vP.tf.text == newSettings[j].name && newSettings[j].description != "" && newSettings[j].description != null)
                    {
                        vIp.addTextfield(15984813, newSettings[j].description, false, 12, null, 16777215)
                    }
                    if (vP.knob.parent == vP) // if it has a draggable field
                    {
                        vIp.addTextfield(15984813, "Current value: " + calculateValue(newSettings[j], vP.knob));
                    }
                }
            }
            // not reachable
            return false;
        }

        private static function calculateValue(setting:Object, knob:Object):Number
        {
            var MathToolbox:Object = getDefinitionByName("com.giab.common.utils.MathToolbox");
            var result:Number = MathToolbox.convertCoord(507, 582, knob.x, setting.min, setting.max);
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
    }
}
