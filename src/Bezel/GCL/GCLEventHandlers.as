package Bezel.GCL
{
    import Bezel.Bezel;
    import Bezel.GCL.Events.EventTypes;
    import Bezel.GCL.Events.IngameClickOnSceneEvent;
    import Bezel.GCL.Events.IngameGemInfoPanelFormedEvent;
    import Bezel.GCL.Events.IngameKeyDownEvent;
    import Bezel.GCL.Events.IngameNewSceneEvent;
    import Bezel.GCL.Events.IngamePreRenderInfoPanelEvent;
    import Bezel.GCL.Events.LoadSaveEvent;
    import Bezel.GCL.Events.Persistence.IngameClickOnSceneEventArgs;
    import Bezel.GCL.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
    import Bezel.GCL.Events.Persistence.IngameKeyDownEventArgs;
    import Bezel.GCL.Events.Persistence.IngamePreRenderInfoPanelEventArgs;
    import Bezel.GCL.Events.PostInitiateEvent;
    import Bezel.GCL.Events.SaveSaveEvent;
    import Bezel.Utils.Keybind;
    import Bezel.mainloader_only;

    import com.giab.games.gcl.gs.Main;
    import com.giab.games.gcl.gs.entity.Gem;
    import com.giab.games.gcl.gs.mcDyn.McInfoPanel;
    import com.giab.games.gcl.gs.mcStat.McMainMenu;

    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getTimer;

    use namespace mainloader_only;

    internal class GCLEventHandlers
    {
        internal static function register():void
        {
            Bezel.Bezel.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown, false, 0, true);
        }

        internal static function unregister():void
        {
            Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown, false);
        }

        // Called after the gem's info panel has been formed but before it's returned to the game for rendering
        internal static function ingameGemInfoPanelFormed(infoPanel:McInfoPanel, gem:Gem, numberFormatter:Object):void
        {
            Bezel.Bezel.instance.dispatchEvent(new IngameGemInfoPanelFormedEvent(EventTypes.INGAME_GEM_INFO_PANEL_FORMED, new IngameGemInfoPanelFormedEventArgs(infoPanel, gem, numberFormatter)));
        }

        internal static function setVersion(mcmainmenu:McMainMenu):void
        {
            var versionText:TextField = Bezel.Bezel.createTextBox(new TextFormat("Celtic Garamond for GemCraft", 10, 0xFFFFFF, null, null, null, null, null, "center"));
            versionText.selectable = false;
            versionText.text = Bezel.Bezel.prettyVersion();
            versionText.x = -730;
            mcmainmenu.mcBottomTexts.addChild(versionText);
            versionText.width = versionText.parent.width;
        }

        // Called before any of the game's logic runs when starting to form an infopanel
        // This method is called before infoPanelFormed (which should be renamed to ingameGemInfoPanelFormed)
        internal static function ingamePreRenderInfoPanel():Boolean
        {
            var eventArgs:IngamePreRenderInfoPanelEventArgs = new IngamePreRenderInfoPanelEventArgs(true);
            Bezel.Bezel.instance.dispatchEvent(new IngamePreRenderInfoPanelEvent(EventTypes.INGAME_PRE_RENDER_INFO_PANEL, eventArgs));
            // logger.log("ingamePreRenderInfoPanel", "Dispatched event!");
            return eventArgs.continueDefault;
        }

        // Called immediately as a click event is fired by the base game
        // set continueDefault to false to prevent the base game's handler from running
        internal static function ingameClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number):Boolean
        {
            var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
            Bezel.Bezel.instance.dispatchEvent(new IngameClickOnSceneEvent(EventTypes.INGAME_CLICK_ON_SCENE, eventArgs));
            return eventArgs.continueDefault;
        }

        // Called after the game checks that a key should be handled, but before any of the actual handling logic
        // Set continueDefault to false to prevent the base game's handler from running
        internal static function ingameKeyDown(e:KeyboardEvent):Boolean
        {
            var eventArgs:IngameKeyDownEventArgs = new IngameKeyDownEventArgs(e, true);
            var keyDownEvent:IngameKeyDownEvent = new IngameKeyDownEvent(EventTypes.INGAME_KEY_DOWN, eventArgs);
            Bezel.Bezel.instance.dispatchEvent(keyDownEvent);
            doHotkeyTransformation(keyDownEvent);
            return eventArgs.continueDefault;
        }

        internal static function doNothingEventHandler(e:Event):void
        {
            e.preventDefault();
        }

        internal static function stageKeyDown(e:KeyboardEvent):void
        {
            if (Bezel.Bezel.instance.keybindManager.getHotkeyValue(GCLBezel.RELOAD_HOTKEY).matches(e))
            {
                if (Bezel.Bezel.instance.modsReloadedTimestamp + 10 * 1000 > getTimer())
                {
                    GCLGV.main.vfxEngine.createFloatingText(GCLGV.main.mouseX, GCLGV.main.mouseY < 60 ? Number(GCLGV.main.mouseY + 30) : Number(GCLGV.main.mouseY - 20), "Please wait 10 secods!", 16768392, 14);
                    return;
                }
                GCLGV.main.sndTickPress.play();
                GCLGV.main.vfxEngine.createFloatingText(GCLGV.main.mouseX, GCLGV.main.mouseY < 60 ? Number(GCLGV.main.mouseY + 30) : Number(GCLGV.main.mouseY - 20), "Reloading mods!", 16768392, 14);
                // Temporarily deparent
                // Bezel.Bezel.instance.removeChild(main);
                // Disable input
                Bezel.Bezel.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(KeyboardEvent.KEY_UP, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.CLICK, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_UP, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_OUT, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_OVER, doNothingEventHandler, true, int.MAX_VALUE, true);
                Bezel.Bezel.instance.stage.addEventListener(MouseEvent.MOUSE_WHEEL, doNothingEventHandler, true, int.MAX_VALUE, true);

                Bezel.Bezel.instance.reloadAllMods();
                GCLBezel.registerHotkeys();
                (Bezel.Bezel.instance.mainLoader as GCLBezel).registerSettings();

                // Reenable input
                Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_UP, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.CLICK, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_UP, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_OUT, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_OVER, doNothingEventHandler, true);
                Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, doNothingEventHandler, true);

                // And reparent
                // Bezel.Bezel.instance.addChild(main);
            }
            // else if (Bezel.Bezel.instance.keybindManager.getHotkeyValue(GCLBezel.HARD_RELOAD_HOTKEY).matches(e))
            // {
            // Bezel.Bezel.instance.triggerFullReload();
            // }
        }

        // Called after the game is done loading its data
        internal static function loadSave():void
        {
            Bezel.Bezel.instance.dispatchEvent(new LoadSaveEvent(GCLGV.main.player, EventTypes.LOAD_SAVE));
        }

        // Called after the game is done saving its data
        internal static function saveSave():void
        {
            Bezel.Bezel.instance.dispatchEvent(new SaveSaveEvent(GCLGV.main.player, EventTypes.SAVE_SAVE));
        }

        // Called when a level is loaded or reloaded
        internal static function ingameNewScene():void
        {
            Bezel.Bezel.instance.dispatchEvent(new IngameNewSceneEvent(EventTypes.INGAME_NEW_SCENE));
        }

        internal static function postInitiate(main:Main):void
        {
            Bezel.Bezel.instance.dispatchEvent(new PostInitiateEvent(main, EventTypes.POST_INITIATE));
        }

        private static function doHotkeyTransformation(e:IngameKeyDownEvent):void
        {
            var origDefault:Boolean = e.eventArgs.continueDefault;
            for (var name:String in GCLBezel.defaultHotkeys)
            {
                var hotkey:Keybind = GCLBezel.defaultHotkeys[name];
                if (Bezel.Bezel.instance.keybindManager.getHotkeyValue(name).matches(e.eventArgs.event))
                {
                    e.eventArgs.event.keyCode = hotkey.key;
                    e.eventArgs.event.altKey = hotkey.alt;
                    e.eventArgs.event.ctrlKey = hotkey.ctrl;
                    e.eventArgs.event.shiftKey = hotkey.shift;
                    e.eventArgs.continueDefault = origDefault;
                    return;
                }
                else if (hotkey.matches(e.eventArgs.event))
                {
                    e.eventArgs.continueDefault = false;
                }
            }
        }
    }
}
