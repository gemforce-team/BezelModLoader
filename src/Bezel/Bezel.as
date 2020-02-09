package Bezel
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.Events.InfoPanelFormedEvent;
	import Bezel.Events.IngameKeyDownEvent;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.filesystem.*;
	import flash.utils.getTimer;
	import Bezel.Logger;
	import Bezel.BezelEvent;

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .Bind method to bind our class to the game
	public class Bezel extends MovieClip
	{
		public const VERSION:String = "0.1.0";
		public const GAME_VERSION:String = "1.0.19a";
		
		// Game objects
		public var gameObjects:Object;
		
		// Shortcuts to gameObjects
		private var main:Object;/*Main*/
		private var core:Object;/*IngameCore*/
		private var GV:Object;/*GV*/
		private var SB:Object;/*SB*/
		private var prefs:Object;/*Prefs*/

		private var updateAvailable:Boolean;
		
		private var logger:Logger;
		public var mods:Array;
		private var appStorage:File;
		
		private var modsReloadedTimestamp:int;
		
		// Parameterless constructor for flash.display.Loader
		public function Bezel()
		{
			super();
			prepareFolders();

			Logger.init();
			this.logger = Logger.getLogger("Bezel");
			this.mods = new Array();
			
			this.logger.log("Bezel", "Bezel Mod Loader " + prettyVersion());
		}
		
		// This method binds the class to the game's objects
		public function bind(gameObjects:Object) : Bezel
		{
			this.gameObjects = gameObjects;
			this.main = gameObjects.main;
			this.core = gameObjects.GV.ingameCore;
			this.SB = gameObjects.SB;
			this.GV = gameObjects.GV;
			this.prefs = gameObjects.prefs;
			this.updateAvailable = false;
			main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = "Bezel " + prettyVersion();
			//checkForUpdates();
			this.logger.log("Bezel", "Bezel bound to game's objects!");
			this.loadMods();
			return this;
		}

		private function prepareFolders(): void
		{
			this.appStorage = File.applicationStorageDirectory;
			var storageFolder:File = this.appStorage.resolvePath("Bezel Mod Loader");
			if(!storageFolder.isDirectory)
				storageFolder.createDirectory();
		}
		
		private function loadMods(): void
		{
			var modsFolder:File = File.applicationDirectory.resolvePath("Mods/");
			
			var fileList: Array = modsFolder.getDirectoryListing();
			for(var f:int = 0; f < fileList.length; f++)
			{
				var fileName:String = fileList[f].name;
				logger.log("loadMods", "Looking at " + fileName);
				if (fileName.substring(fileName.length - 4, fileName.length) == ".swf" && fileName != "BezelModLoader.swf")
				{
					var newMod:BezelMod = new BezelMod(fileName);
					newMod.load(successfulLoad, failedLoad);
				}
			}
			this.modsReloadedTimestamp = getTimer();
		}
		
		public function successfulLoad(mod: Object): void
		{
			logger.log("successfulLoad", "Loaded mod: " + mod.instance.MOD_NAME + " v" + mod.instance.VERSION);
			mods.push(mod);
			this.addChild(mod.instance);
			mod.instance.bind(this, this.gameObjects);
			logger.log("successfulLoad", "Bound mod: " + mod.instance.MOD_NAME);
		}
		
		public function failedLoad(e:Event): void
		{
			logger.log("failedLoad", "Failed to load mod: " + e.currentTarget.url);
		}
		
		public function getLogger(id:String): Logger
		{
			return Logger.getLogger(id);
		}
		
		public function prettyVersion(): String
		{
			return 'v' + VERSION + ' for ' + GAME_VERSION;
		}
		
		public function infoPanelFormed(infoPanel:Object, gem:Object, numberFormatter:Object): void
		{
			dispatchEvent(new InfoPanelFormedEvent(BezelEvent.GEM_INFO_PANEL_FORMED, {"infoPanel": infoPanel, "gem": gem, "numberFormatter": numberFormatter}));
		}
		
		public function eh_ingameKeyDown(e:KeyboardEvent): Boolean
		{
			//this.logger.log("infoPanelFormed", "Dispatching event...");
			if (e.controlKey && e.altKey && e.shiftKey && e.keyCode == 36)
			{
				if (this.modsReloadedTimestamp + 10*1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Please wait 10 secods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					return false;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Reloading mods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
				reloadAllMods();
				return false;
			}
			var kbKDEventArgs:Object = {"event": e, "continueDefault": true};
			dispatchEvent(new IngameKeyDownEvent(BezelEvent.INGAME_KEY_DOWN, kbKDEventArgs));
			return kbKDEventArgs.continueDefault;
			
			//this.logger.log("infoPanelFormed", "Dispatched event...");
		}
		
		private function reloadAllMods(): void
		{
			logger.log("eh_keyboardKeyDown", "Reloading all mods!");
			this.modsReloadedTimestamp = getTimer();
			for each(var mod:BezelMod in mods)
			{
				mod.unload();
			}
			this.removeChildren();
			mods = new Array();
			loadMods();
		}
	}
}