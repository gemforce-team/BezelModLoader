package Bezel.GCCS
{
	import Bezel.Bezel;
	import Bezel.GCCS.Events.EventTypes;
	import Bezel.GCCS.Events.IngameClickOnSceneEvent;
	import Bezel.GCCS.Events.IngameGemInfoPanelFormedEvent;
	import Bezel.GCCS.Events.IngameKeyDownEvent;
	import Bezel.GCCS.Events.IngameNewSceneEvent;
	import Bezel.GCCS.Events.IngamePreRenderInfoPanelEvent;
	import Bezel.GCCS.Events.IngameRightClickOnSceneEvent;
	import Bezel.GCCS.Events.LoadSaveEvent;
	import Bezel.GCCS.Events.Persistence.IngameClickOnSceneEventArgs;
	import Bezel.GCCS.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
	import Bezel.GCCS.Events.Persistence.IngameKeyDownEventArgs;
	import Bezel.GCCS.Events.Persistence.IngamePreRenderInfoPanelEventArgs;
	import Bezel.GCCS.Events.SaveSaveEvent;
	import Bezel.Utils.Keybind;
	import Bezel.mainloader_only;

	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.SB;
	import com.giab.games.gccs.steam.entity.Gem;
	import com.giab.games.gccs.steam.mcDyn.McInfoPanel;
	import com.giab.games.gccs.steam.mcStat.McMainMenu;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	use namespace mainloader_only;

	internal class GCCSEventHandlers
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

		// Called immediately as a right click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		internal static function ingameRightClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number):Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			Bezel.Bezel.instance.dispatchEvent(new IngameRightClickOnSceneEvent(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eventArgs));
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

		internal static function stageKeyDown(e:KeyboardEvent):void
		{
			if (Bezel.Bezel.instance.keybindManager.getHotkeyValue(GCCSBezel.RELOAD_HOTKEY).matches(e))
			{
				if (Bezel.Bezel.instance.modsReloadedTimestamp + 10 * 1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60 ? Number(GV.main.mouseY + 30) : Number(GV.main.mouseY - 20), "Please wait 10 secods!", 16768392, 14, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					return;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60 ? Number(GV.main.mouseY + 30) : Number(GV.main.mouseY - 20), "Reloading mods!", 16768392, 14, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
				Bezel.Bezel.instance.reloadAllMods();
				GCCSBezel.registerHotkeys();
				(Bezel.Bezel.instance.mainLoader as GCCSBezel).registerSettings();
			}
			// else if (Bezel.Bezel.instance.keybindManager.getHotkeyValue("GCCS Bezel: Hard reload").matches(e))
			// {
			// Bezel.Bezel.instance.triggerFullReload();
			// }
		}

		// Called after the game is done loading its data
		internal static function loadSave():void
		{
			Bezel.Bezel.instance.dispatchEvent(new LoadSaveEvent(GV.ppd, EventTypes.LOAD_SAVE));
		}

		// Called after the game is done saving its data
		internal static function saveSave():void
		{
			Bezel.Bezel.instance.dispatchEvent(new SaveSaveEvent(GV.ppd, EventTypes.SAVE_SAVE));
		}

		// Called when a level is loaded or reloaded
		internal static function ingameNewScene():void
		{
			Bezel.Bezel.instance.dispatchEvent(new IngameNewSceneEvent(EventTypes.INGAME_NEW_SCENE));
		}

		internal static function setVersion(mcmainmenu:McMainMenu):void
		{
			var versionText:TextField = Bezel.Bezel.createTextBox(new TextFormat("Celtic Garamond for GemCraft", 10, 0xFFFFFF, null, null, null, null, null, "center"));
			versionText.selectable = false;
			versionText.text = Bezel.Bezel.prettyVersion();
			mcmainmenu.mcBottomTexts.addChild(versionText);
			versionText.width = versionText.parent.width;
			// var version:String = GV.main.scrMainMenu.mc.mcBottomTexts.getChildAt(0).text;
			// version = version.slice(0, version.search(' ') + 1) + Bezel.Bezel.prettyVersion();
			// GV.main.scrMainMenu.mc.mcBottomTexts.getChildAt(0).text = version;
		}

		private static function doHotkeyTransformation(e:IngameKeyDownEvent):void
		{
			var origDefault:Boolean = e.eventArgs.continueDefault;
			for (var name:String in GCCSBezel.defaultHotkeys)
			{
				var hotkey:Keybind = GCCSBezel.defaultHotkeys[name];
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
