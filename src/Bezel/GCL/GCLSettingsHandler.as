package Bezel.GCL
{
    import Bezel.Utils.Keybind;
    import Bezel.Utils.SettingManager;

    import com.giab.common.utils.MathToolbox;
    import com.giab.games.gcl.gs.ctrl.CtrlStatistics;
    import com.giab.games.gcl.gs.mcDyn.McInfoPanel;
    import com.giab.games.gcl.gs.mcDyn.McStatStrip;
    import com.giab.games.gcl.gs.mcDyn.McStatsTitlePanel;
    import com.giab.games.gcl.gs.mcStat.McStatistics;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.describeType;

    internal class GCLSettingsHandler
    {
        private static const newSettings:Vector.<GCLSetting> = new <GCLSetting>[];

        private static var currentlyShowing:Boolean = false;

        internal static var IS_CHOOSING_KEYBIND:Boolean = false;

        internal static const KeyboardConstants:XMLList = describeType(Keyboard).constant.(@type == "uint").@name;

        internal static function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String):void
        {
            newSettings[newSettings.length] = GCLSetting.makeBool(mod, name, onSet, currentValue, description);
        }

        internal static function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String):void
        {
            newSettings[newSettings.length] = GCLSetting.makeRange(mod, name, min, max, step, onSet, currentValue, description);
        }

        internal static function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String):void
        {
            newSettings[newSettings.length] = GCLSetting.makeKeybind(name, onSet, currentValue, description);
        }

        internal static function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void
        {
            newSettings[newSettings.length] = GCLSetting.makeNumber(mod, name, min, max, onSet, currentValue, description);
        }

        internal static function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void
        {
            newSettings[newSettings.length] = GCLSetting.makeString(mod, name, validator, onSet, currentValue, description);
        }

        internal static function deregisterOption(mod:String, name:String):void
        {
            for (var i:int = newSettings.length; i > 0; i--)
            {
                if (newSettings[i - 1].mod == mod && (name == null || newSettings[i - 1].name == name))
                {
                    newSettings.splice(i - 1, 1);
                }
            }
        }

        private static function sortSettings(left:GCLSetting, right:GCLSetting):Number
        {
            // Sort keybinds first
            if (left.mod == SettingManager.MOD_KEYBIND) // Keybinds always come second to last
            {
                if (right.mod == SettingManager.MOD_KEYBIND)
                {
                    if (left.name < right.name)
                        return -1;
                    if (left.name > right.name)
                        return 1;
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
            else if (left.mod == SettingManager.MOD_ENABLED)
            {
                if (right.mod == SettingManager.MOD_ENABLED)
                {
                    if (left.name < right.name)
                        return -1;
                    if (left.name > right.name)
                        return 1;
                    return 0;
                }
                else if (right.mod == SettingManager.MOD_KEYBIND)
                {
                    return 1;
                }
                else
                {
                    return -1;
                }
            }
            else if (right.mod == SettingManager.MOD_KEYBIND || right.mod == SettingManager.MOD_ENABLED) // Both come after everything else
            {
                return 1;
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
        }

        private static var onCustom:Boolean = false;

        private static var _hijackedStats:Object;
        private static var _hijackedStatsMc:MovieClip;
        private static var moreSettingsButton:MoreSettingsButtonShim;

        internal static function toggleCustomSettingsFromGame():void
        {
            if (_hijackedStatsMc == null)
            {
                _hijackedStatsMc = new McStatistics();
            }
            var hijackedStatsMc:McStatistics = McStatistics(_hijackedStatsMc);
            if (_hijackedStats == null)
            {
                _hijackedStats = new CtrlStatistics(hijackedStatsMc, GCLGV.main);
                hijackedStatsMc.btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, CtrlStatistics(_hijackedStats).ehBtnDoneDown, true);
                hijackedStatsMc.btnDone.addEventListener(MouseEvent.MOUSE_DOWN, hideCustomSettings, true, 0, true);
            }
            if (moreSettingsButton == null)
            {
                moreSettingsButton = new MoreSettingsButtonShim(GCLGV.main.mcOptions.btnMoreGames);
                moreSettingsButton.tf.text = "Modded Settings";
                moreSettingsButton.x = GCLGV.main.mcOptions.btnReturn.x + (GCLGV.main.mcOptions.btnReturn.x - GCLGV.main.mcOptions.btnRetry.x);
                moreSettingsButton.y = GCLGV.main.mcOptions.btnReturn.y;
                moreSettingsButton.addEventListener(MouseEvent.CLICK, showCustomSettings, true, 0, true);
                moreSettingsButton.addEventListener(MouseEvent.MOUSE_OVER, GCLGV.main.ctrlOptions.ehBtnMouseOver, true, 0, true);
                moreSettingsButton.addEventListener(MouseEvent.MOUSE_OUT, GCLGV.main.ctrlOptions.ehBtnMouseOut, true, 0, true);
            }

            if (!currentlyShowing)
            {
                GCLGV.main.mcOptions.addChild(moreSettingsButton);
            }
            else
            {
                if (onCustom)
                {
                    hideCustomSettings(null);
                }
                GCLGV.main.mcOptions.removeChild(moreSettingsButton);
            }
        }

        private static function enterFrame(e:Event):void
        {
            var hijackedStats:CtrlStatistics = CtrlStatistics(_hijackedStats);
            var hijackedStatsMc:McStatistics = McStatistics(_hijackedStatsMc);

            hijackedStats.doEnterFrame();

            for (var i:int = 0; i < hijackedStats.statStrips.length; i++)
            {
                var statItem:MovieClip = hijackedStats.statStrips[i];
                if (statItem is McStatStrip &&
                    statItem.x < hijackedStatsMc.mouseX && hijackedStatsMc.mouseX < statItem.x + statItem.width &&
                    statItem.y < hijackedStatsMc.mouseY && hijackedStatsMc.mouseY < statItem.y + statItem.height)
                {
                    renderInfoPanel(statItem, GCLGV.main.mcInfoPanel);
                    return;
                }
            }

            if (GCLGV.main.mcInfoPanel.parent == hijackedStatsMc)
            {
                hijackedStatsMc.removeChild(GCLGV.main.mcInfoPanel);
            }
        }

        private static function addMC(mc:MovieClip):void
        {
            CtrlStatistics(_hijackedStats).statStrips.push(mc);
        }

        internal static function showCustomSettings(e:MouseEvent):void
        {
            var hijackedStats:CtrlStatistics = CtrlStatistics(_hijackedStats);
            var hijackedStatsMc:McStatistics = McStatistics(_hijackedStatsMc);

            onCustom = true;
            hijackedStats.initiate();
            hijackedStats.statStrips.length = 0;
            hijackedStats.titlePanel.tfStatsDicovered.visible = false;
            hijackedStats.titlePanel.tfTitle.text = "Custom Settings";
            hijackedStats.btnSubmitScoreEnabled = false;
            GCLGV.main.cntScreens.removeChild(hijackedStatsMc);
            GCLGV.main.mcOptions.addChildAt(hijackedStatsMc, GCLGV.main.mcOptions.numChildren);
            GCLGV.main.mcOptions.addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);

            newSettings.sort(sortSettings);

            var yStart:int = 93;
            var currentName:String = null;
            for each (var setting:GCLSetting in newSettings)
            {
                if (currentName != setting.mod)
                {
                    yStart += 7;
                    var titlePanel:McStatsTitlePanel = new McStatsTitlePanel();
                    titlePanel.scaleX = titlePanel.scaleY = .65;
                    titlePanel.xAbs = 160;
                    titlePanel.yAbs = yStart;
                    titlePanel.tfTitle.text = setting.mod;
                    titlePanel.tfStatsDicovered.visible = false;
                    addMC(titlePanel);

                    yStart += titlePanel.tfTitle.height;

                    currentName = setting.mod;
                }

                if (setting.type == GCLSetting.TYPE_BOOL)
                {
                    var boolStrip:McStatStrip = new McStatStrip();
                    boolStrip.tfStatName.mouseEnabled = false;
                    boolStrip.tfStatName.text = setting.name;
                    boolStrip.tfStatValue.visible = false;

                    boolStrip.xAbs = 34;
                    boolStrip.yAbs = yStart;

                    var boolButton:MovieClip = new (GCLGV.main.mcOptions.btnScreenShaking.constructor as Class)();
                    boolButton.x = boolStrip.tfStatValue.x + boolStrip.tfStatValue.width / 2 - boolButton.width / 2;
                    boolButton.y = boolStrip.tfStatValue.y - 1;
                    boolButton.gotoAndStop(setting.currentVal() ? 2 : 1);
                    boolStrip.addChild(boolButton);
                    boolButton.addEventListener(MouseEvent.CLICK, setting.onClicked, false, 0, true);

                    setting.panel = boolStrip;
                    setting.checkbox = boolButton;

                    addMC(boolStrip);

                    yStart += boolStrip.height + 4;
                }
                else if (setting.type == GCLSetting.TYPE_RANGE)
                {
                    var rangeStrip:McStatStrip = new McStatStrip();
                    rangeStrip.tfStatName.mouseEnabled = false;
                    rangeStrip.tfStatName.text = setting.name;
                    rangeStrip.tfStatValue.visible = false;

                    rangeStrip.xAbs = 34;
                    rangeStrip.yAbs = yStart;

                    var rangeRect:Sprite = new Sprite();
                    rangeRect.graphics.beginFill(0, 0);
                    rangeRect.graphics.drawRect(0, 0, 100, rangeStrip.height);
                    rangeRect.graphics.endFill();
                    rangeRect.graphics.moveTo(0, rangeStrip.height / 2);
                    rangeRect.graphics.lineStyle(4, 0xFFFFFF);
                    rangeRect.graphics.lineTo(100, rangeStrip.height / 2);

                    rangeRect.x = boolStrip.tfStatValue.x + 4;
                    rangeRect.y = rangeStrip.height / 2 - rangeRect.height / 2;
                    rangeRect.width = boolStrip.tfStatValue.width;

                    rangeStrip.addChild(rangeRect);

                    rangeRect.addEventListener(MouseEvent.MOUSE_DOWN, setting.onClicked, false, 0, true);

                    var rangeKnob:Sprite = new Sprite();
                    rangeKnob.graphics.drawGraphicsData(GCLGV.main.mcOptions.btnParticlesNum.graphics.readGraphicsData(true));
                    rangeKnob.x = rangeRect.x;
                    rangeKnob.y = rangeRect.y + rangeRect.height / 2;
                    rangeKnob.addEventListener(MouseEvent.MOUSE_DOWN, setting.onClicked, false, 0, true);

                    rangeStrip.addChild(rangeKnob);

                    setting.panel = rangeStrip;
                    setting.knobLine = rangeRect;
                    setting.knob = rangeKnob;

                    addMC(rangeStrip);

                    rangeKnob.x = calculateX(setting);

                    yStart += rangeStrip.height + 4;
                }
                else if (setting.type == GCLSetting.TYPE_KEYBIND)
                {
                    var keybindStrip:McStatStrip = new McStatStrip();
                    keybindStrip.tfStatName.mouseEnabled = false;
                    keybindStrip.tfStatName.text = setting.name;
                    keybindStrip.tfStatValue.visible = false;

                    keybindStrip.xAbs = 34;
                    keybindStrip.yAbs = yStart;

                    var keybindButton:SettingsButton = new SettingsButton(hijackedStatsMc.btnSubmitScore, keybindStrip.tfStatValue.width, keybindStrip.height);
                    keybindButton.tf.text = (setting.currentVal()).toString().toUpperCase();
                    keybindButton.addEventListener(MouseEvent.MOUSE_DOWN, setting.onClicked, false, 0, true);
                    keybindButton.addEventListener(MouseEvent.MOUSE_OVER, hijackedStats.ehBtnMouseOver, false, 0, true);
                    keybindButton.addEventListener(MouseEvent.MOUSE_OUT, hijackedStats.ehBtnMouseOut, false, 0, true);

                    keybindButton.x = keybindStrip.tfStatValue.x;

                    keybindStrip.addChild(keybindButton);

                    setting.panel = keybindStrip;
                    setting.button = keybindButton;

                    addMC(keybindStrip);

                    yStart += keybindStrip.height + 4;
                }
                else if (setting.type == GCLSetting.TYPE_NUMBER)
                {
                    var numberStrip:McStatStrip = new McStatStrip();
                    numberStrip.tfStatName.mouseEnabled = false;
                    numberStrip.tfStatName.text = setting.name;
                    numberStrip.tfStatValue.visible = false;

                    numberStrip.xAbs = 34;
                    numberStrip.yAbs = yStart;

                    var numberButton:SettingsButton = new SettingsButton(hijackedStatsMc.btnSubmitScore, numberStrip.tfStatValue.width, numberStrip.height);
                    numberButton.tf.text = setting.currentVal().toString();
                    numberButton.addEventListener(MouseEvent.MOUSE_DOWN, setting.onClicked, false, 0, true);
                    numberButton.addEventListener(MouseEvent.MOUSE_OVER, hijackedStats.ehBtnMouseOver, false, 0, true);
                    numberButton.addEventListener(MouseEvent.MOUSE_OUT, hijackedStats.ehBtnMouseOut, false, 0, true);

                    numberButton.x = numberStrip.tfStatValue.x;

                    numberStrip.addChild(numberButton);

                    setting.panel = numberStrip;
                    setting.button = numberButton;

                    addMC(numberStrip);

                    yStart += numberStrip.height + 4;
                }
                else if (setting.type == GCLSetting.TYPE_STRING)
                {
                    var stringStrip:McStatStrip = new McStatStrip();
                    stringStrip.tfStatName.mouseEnabled = false;
                    stringStrip.tfStatName.text = setting.name;
                    stringStrip.tfStatValue.visible = false;

                    stringStrip.xAbs = 34;
                    stringStrip.yAbs = yStart;

                    var stringButton:SettingsButton = new SettingsButton(hijackedStatsMc.btnSubmitScore, stringStrip.tfStatValue.width, stringStrip.height);
                    stringButton.tf.text = setting.currentVal().toString();
                    stringButton.addEventListener(MouseEvent.MOUSE_DOWN, setting.onClicked, false, 0, true);
                    stringButton.addEventListener(MouseEvent.MOUSE_OVER, hijackedStats.ehBtnMouseOver, false, 0, true);
                    stringButton.addEventListener(MouseEvent.MOUSE_OUT, hijackedStats.ehBtnMouseOut, false, 0, true);

                    stringButton.x = stringStrip.tfStatValue.x;

                    stringStrip.addChild(stringButton);

                    setting.panel = stringStrip;
                    setting.button = stringButton;

                    addMC(stringStrip);

                    yStart += stringStrip.height + 4;
                }
            }

            hijackedStatsMc.mcScrollKnob.visible = hijackedStatsMc.mcScrollPlate.visible = yStart >= 550;

            hijackedStats.viewportYMax = yStart - 550;
        }

        internal static function hideCustomSettings(e:MouseEvent):void
        {
            var hijackedStats:CtrlStatistics = CtrlStatistics(_hijackedStats);
            var hijackedStatsMc:McStatistics = McStatistics(_hijackedStatsMc);

            onCustom = false;
            GCLGV.main.removeEventListener(MouseEvent.MOUSE_WHEEL, hijackedStats.ehWheel, true);
            GCLGV.main.mcOptions.removeChild(hijackedStatsMc);
            GCLGV.main.mcOptions.removeEventListener(Event.ENTER_FRAME, enterFrame, false);

            hijackedStatsMc.removeChild(hijackedStats.titlePanel);
            for (var i:int = 0; i < hijackedStats.statStrips.length; i++)
            {
                var strip:MovieClip = hijackedStats.statStrips[i];
                if (strip.isVisible)
                {
                    hijackedStatsMc.removeChild(strip);
                }
            }
            hijackedStats.titlePanel = null;
            hijackedStats.statStrips.length = 0;
        }

        internal static function renderInfoPanel(vP:MovieClip, vIp:Sprite):void
        {
            var optPanel:McStatStrip = vP as McStatStrip;
            var infoPanel:McInfoPanel = vIp as McInfoPanel;
            var hijackedStatsMc:McStatistics = McStatistics(_hijackedStatsMc);

            infoPanel.removeAllTextfields();
            if (IS_CHOOSING_KEYBIND)
            {
                return;
            }
            for each (var setting:GCLSetting in newSettings)
            {
                if (optPanel == setting.panel)
                {
                    var show:Boolean = false;
                    if (setting.description != "" && setting.description != null)
                    {
                        infoPanel.addTextfield(15984813, setting.description, false, 12, null);
                        show = true;
                    }
                    if (setting.knob != null) // if it has a draggable field
                    {
                        infoPanel.addTextfield(15984813, "Current value: " + calculateValue(setting));
                        show = true;
                    }
                    if (show)
                    {
                        hijackedStatsMc.addChild(infoPanel);
                        infoPanel.doEnterFrame();
                    }
                    return;
                }
            }
        }

        internal static function calculateValue(setting:GCLSetting):Number
        {
            var result:Number = MathToolbox.convertCoord(setting.knobLine.x, setting.knobLine.x + setting.knobLine.width - 8, setting.knob.x, setting.min, setting.max);
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

        private static function calculateX(setting:GCLSetting):Number
        {
            return MathToolbox.convertCoord(setting.min, setting.max, setting.currentVal(), setting.knobLine.x, setting.knobLine.x + setting.knobLine.width - 8);
        }

        internal static function updateButtonColors():void
        {
            for (var i:int = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == GCLSetting.TYPE_KEYBIND)
                {
                    newSettings[i].button.tf.setTextFormat(new TextFormat(null, null, 0xFFFFFF));
                }
            }

            for (i = 0; i < newSettings.length; i++)
            {
                if (newSettings[i].type == GCLSetting.TYPE_KEYBIND)
                {
                    var kb:Keybind = newSettings[i].currentVal();
                    for (var j:int = i + 1; j < newSettings.length; j++)
                    {
                        if (newSettings[j].type == GCLSetting.TYPE_KEYBIND && kb.matches(newSettings[j].currentVal()))
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
