package Bezel.GCFW
{
	import Bezel.Bezel;
	import Bezel.Events.EventTypes;
	import Bezel.Events.IngameClickOnSceneEvent;
	import Bezel.Events.IngameGemInfoPanelFormedEvent;
	import Bezel.Events.IngameKeyDownEvent;
	import Bezel.Events.IngameNewSceneEvent;
	import Bezel.Events.IngamePreRenderInfoPanelEvent;
	import Bezel.Events.IngameRightClickOnSceneEvent;
	import Bezel.Events.LoadSaveEvent;
	import Bezel.Events.Persistence.IngameClickOnSceneEventArgs;
	import Bezel.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
	import Bezel.Events.Persistence.IngameKeyDownEventArgs;
	import Bezel.Events.Persistence.IngamePreRenderInfoPanelEventArgs;
	import Bezel.Events.SaveSaveEvent;
	import Bezel.Utils.Keybind;
	import Bezel.bezel_internal;
	
	import com.giab.games.gcfw.GV;
	import com.giab.games.gcfw.SB;
	import com.giab.games.gcfw.entity.Gem;
	import com.giab.games.gcfw.mcDyn.McInfoPanel;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

    use namespace bezel_internal;

    /**
     * ...
     * @author Chris
     */

    public class GCFWEventHandlers
    {
        internal static function register():void
        {
            Bezel.Bezel.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);
        }
    
        internal static function unregister():void
        {
            Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);
        }

		// Called after the gem's info panel has been formed but before it's returned to the game for rendering
		bezel_internal static function ingameGemInfoPanelFormed(infoPanel:McInfoPanel, gem:Gem, numberFormatter:Object): void
		{
			Bezel.Bezel.instance.dispatchEvent(new IngameGemInfoPanelFormedEvent(EventTypes.INGAME_GEM_INFO_PANEL_FORMED, new IngameGemInfoPanelFormedEventArgs(infoPanel, gem, numberFormatter)));
		}

		// Called before any of the game's logic runs when starting to form an infopanel
		// This method is called before infoPanelFormed (which should be renamed to ingameGemInfoPanelFormed)
		bezel_internal static function ingamePreRenderInfoPanel(): Boolean
		{
			var eventArgs:IngamePreRenderInfoPanelEventArgs = new IngamePreRenderInfoPanelEventArgs(true);
			Bezel.Bezel.instance.dispatchEvent(new IngamePreRenderInfoPanelEvent(EventTypes.INGAME_PRE_RENDER_INFO_PANEL, eventArgs));
			//logger.log("ingamePreRenderInfoPanel", "Dispatched event!");
			return eventArgs.continueDefault;
		}

		// Called immediately as a click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		bezel_internal static function ingameClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			Bezel.Bezel.instance.dispatchEvent(new IngameClickOnSceneEvent(EventTypes.INGAME_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called immediately as a right click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		bezel_internal static function ingameRightClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			Bezel.Bezel.instance.dispatchEvent(new IngameRightClickOnSceneEvent(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called after the game checks that a key should be handled, but before any of the actual handling logic
		// Set continueDefault to false to prevent the base game's handler from running
		bezel_internal static function ingameKeyDown(e:KeyboardEvent): Boolean
		{
			var eventArgs:IngameKeyDownEventArgs = new IngameKeyDownEventArgs(e, true);
			var keyDownEvent:IngameKeyDownEvent = new IngameKeyDownEvent(EventTypes.INGAME_KEY_DOWN, eventArgs);
			Bezel.Bezel.instance.dispatchEvent(keyDownEvent);
			doHotkeyTransformation(keyDownEvent);
			return eventArgs.continueDefault;
		}

		bezel_internal static function stageKeyDown(e: KeyboardEvent): void
		{
			if (Bezel.Bezel.instance.keybindManager.getHotkeyValue("GCFW Bezel: Reload all mods").matches(e))
			{
				if (Bezel.Bezel.instance.modsReloadedTimestamp + 10*1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Please wait 10 secods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					return;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Reloading mods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
				Bezel.Bezel.instance.reloadAllMods();
			}
			else if (Bezel.Bezel.instance.keybindManager.getHotkeyValue("GCFW Bezel: Hard reload").matches(e))
			{
				Bezel.Bezel.instance.triggerFullReload();
			}
		}

		// Called after the game is done loading its data
		bezel_internal static function loadSave(): void
		{
			Bezel.Bezel.instance.dispatchEvent(new LoadSaveEvent(GV.ppd, EventTypes.LOAD_SAVE));
		}

		// Called after the game is done saving its data
		bezel_internal static function saveSave(): void
		{
			Bezel.Bezel.instance.dispatchEvent(new SaveSaveEvent(GV.ppd, EventTypes.SAVE_SAVE));
		}

		// Called when a level is loaded or reloaded
		bezel_internal static function ingameNewScene(): void
		{
			Bezel.Bezel.instance.dispatchEvent(new IngameNewSceneEvent(EventTypes.INGAME_NEW_SCENE));
		}
		
		private static function doHotkeyTransformation(e:IngameKeyDownEvent):void
		{
			var origDefault:Boolean = e.eventArgs.continueDefault;
			for(var name:String in GCFWBezel.defaultHotkeys)
			{
                var hotkey:Keybind = GCFWBezel.defaultHotkeys[name];
				if(Bezel.Bezel.instance.keybindManager.getHotkeyValue(name).matches(e))
				{
					e.eventArgs.event.keyCode = hotkey.key;
					e.eventArgs.event.altKey = hotkey.alt;
					e.eventArgs.event.ctrlKey = hotkey.ctrl;
					e.eventArgs.event.shiftKey = hotkey.shift;
					e.eventArgs.continueDefault = origDefault;
					return;
				}
				else if (hotkey.matches(e))
				{
					e.eventArgs.continueDefault = false;
				}
			}
		}
    }
}
