package Bezel
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.filesystem.*;
	import flash.utils.*;
	import Bezel.Logger;
	import Bezel.BezelEvent;
	import Bezel.Events.*;

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .bind method to bind our class to the game
	public class Bezel extends MovieClip
	{
		public const VERSION:String = "0.2.0";
		public const GAME_VERSION:String = "1.0.21";
		
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
		private var mods:Object;
		private var appStorage:File;
		
		private var modsReloadedTimestamp:int;
		
		// Parameterless constructor for flash.display.Loader
		public function Bezel()
		{
			super();
			prepareFolders();

			Logger.init();
			this.logger = Logger.getLogger("Bezel");
			this.mods = new Object();
			
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
				//logger.log("loadMods", "Looking at " + fileName);
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
			mods[mod.instance.MOD_NAME] = mod;
			this.addChild(mod.instance);
			mod.instance.bind(this, this.gameObjects);
			if (!this.bezelVersionCompatible(mod.instance.BEZEL_VERSION))
			{
				logger.log("Compatibility", "Bezel version is incompatible! Required: " + mod.instance.BEZEL_VERSION);
				delete mods[mod.instance.MOD_NAME];
				mod.unload();
				throw new Error("Bezel version is incompatible! Bezel: " + VERSION + " while " + mod.instance.MOD_NAME+ " requires " + mod.instance.BEZEL_VERSION);
			}
			logger.log("successfulLoad", "Bound mod: " + mod.instance.MOD_NAME);
		}
		
		public function bezelVersionCompatible(requiredVersion:String): Boolean
		{
			var bezelVer:Array = this.VERSION.split(".");
			var thisVer:Array = requiredVersion.split(".");
			if (bezelVer[0] != thisVer[0])
				return false;
			else
			{
				if (bezelVer[1] > thisVer[1])
					return true;
				else if(bezelVer[1] == thisVer[1])
				{
					return bezelVer[2] >= thisVer[2];
				}
			}
			
			return false;
		}
		
		public function failedLoad(e:Event): void
		{
			logger.log("failedLoad", "Failed to load mod: " + e.currentTarget.url);
		}
		
		public function getLogger(id:String): Logger
		{
			return Logger.getLogger(id);
		}
		
		public function getModByName(modName:String): Object
		{
			if (this.mods[modName])
				return this.mods[modName].instance;
			return null;
		}
		
		public function prettyVersion(): String
		{
			return 'v' + VERSION + ' for ' + GAME_VERSION;
		}
		
		public function ingamePrePlayerBuildingsEnterFrame(): void
		{
			//logger.log("ingamePrePlayerBuildingsEnterFrame", "Resorting arrays");
			this.core.sortedMonsterArrays = new Object();
			this.core.sortedMonsterArrays[0] = this.core.monstersOnScene.concat();// .sortOn(["distanceFromOrb"], Array.NUMERIC);
			return;
			this.core.sortedMonsterArrays[1] = this.core.monstersOnScene.concat().sortOn(["isSwarmlingForSorting","distanceFromOrb"], [Array.NUMERIC | Array.DESCENDING,Array.NUMERIC]);
			this.core.sortedMonsterArrays[2] = this.core.monstersOnScene.concat().sortOn(["isGiantForSorting","distanceFromOrb"], [Array.NUMERIC | Array.DESCENDING,Array.NUMERIC]);
			//this.core.sortedMonsterArrays[3] = this.core.monstersOnScene.concat().sortOn(["distanceFromOrb"], Array.NUMERIC); - RANDOM
			this.core.sortedMonsterArrays[4] = this.core.sortedMonsterArrays[0]; //STRUCTURE
			if(this.core.orblets.length == 0)
				this.core.sortedMonsterArrays[5] = this.core.monstersOnScene.concat().sortOn(["calculatedRelativeBanishmentCost"], Array.NUMERIC);
			else
				this.core.sortedMonsterArrays[5] = this.core.monstersOnScene.concat().sortOn(["carriedOrbletsNum","calculatedRelativeBanishmentCost"], Array.NUMERIC);
			this.core.sortedMonsterArrays[6] = this.core.monstersOnScene.concat().sortOn(["shield","armorLevelForSorting"], [Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING]);
			this.core.sortedMonsterArrays[7] = this.core.monstersOnScene.concat().sortOn(["hpForSorting"], Array.NUMERIC);
			this.core.sortedMonsterArrays[14] = this.core.monstersOnScene.concat().sortOn(["numOfEffects"], Array.NUMERIC);
		}
		
		public function ingameAcquireLanternTargets(lantern:Object, rangeSq:Number): void
		{
			//logger.log("lanternTarget", "Acquiring lantern target...");
			lantern.targets = [];
			var targetPriority:int = lantern.insertedGem.targetPriority;
			if (targetPriority == 4)
				lantern.targets = pickMonsters(14, lantern.targetLimit, rangeSq, lantern.x, lantern.y);
			else if (targetPriority == 3)
				lantern.targets = pickRandomMonsters(lantern.targetLimit, rangeSq, lantern.x, lantern.y);
			else
				lantern.targets = pickMonsters(targetPriority, lantern.targetLimit, rangeSq, lantern.x, lantern.y);
				
			if (lantern.targets.length > 0)
				lantern.isTargetMarkableForDeath = true;
		}
		
		public function ingameAcquireTowerTarget(tower:Object, rangeSq:Number): void
		{
			//logger.log("towerTarget", "Acquiring tower target...");
			var targetPriority:int = tower.insertedGem.targetPriority;
			var candidate:Object = null;
			if (targetPriority == 3)
				candidate = pickRandomMonsters(1, rangeSq, tower.x, tower.y)[0];
			else
				candidate = pickMonsters(targetPriority, 1, rangeSq, tower.x, tower.y)[0];
				
			if (!candidate)
				return;
			
			//logger.log("towerTarget", "Got a candidate:" + candidate.toString());
			tower.target = candidate;
			tower.isTargetMarkableForDeath = true;
		}
		
		public function ingameAcquirePylonTarget(pylon:Object, rangeSq:Number): void
		{
			//logger.log("pylonTarget", "Acquiring pylon target...");
			var targetPriority:int = pylon.insertedGem.targetPriority;
			var candidate:Object = null;
			if (targetPriority == 3)
				candidate = pickRandomMonsters(1, rangeSq, pylon.x, pylon.y)[0];
			else
				candidate = pickMonsters(targetPriority, 1, rangeSq, pylon.x, pylon.y)[0];
				
			if (!candidate)
				return;
				
			pylon.target = candidate;
			pylon.isTargetMarkableForDeath = true;
		}
		
		public function ingameAcquireTrapTargets(trap:Object, rangeSq:Number): void
		{
			//logger.log("trapTarget", "Acquiring trap target...");
			trap.targets = [];
			var targetPriority:int = trap.insertedGem.targetPriority;
			if (targetPriority == 4)
				trap.targets = pickMonsters(14, Infinity, rangeSq, trap.x, trap.y);
			else if (targetPriority == 3)
				trap.targets = pickRandomMonsters(Infinity, rangeSq, trap.x, trap.y);
			else
				trap.targets = pickMonsters(targetPriority, Infinity, rangeSq, trap.x, trap.y);
				
			if (trap.targets.length > 0)
				trap.isTargetMarkableForDeath = true;
		}
		
		private function pickMonsters(targetPriority:int, count:int, rangeSq:Number, originX:Number, originY:Number): Array
		{
			//logger.log("pickMonsters", "Picking monsters on priority" + targetPriority.toString());
			var result:Array = new Array();
			var monsterCount:int = this.core.sortedMonsterArrays[0].length;
			for (var m:int = 0; result.length < count && m < monsterCount; m++)
			{
				var monster:Object = this.core.sortedMonsterArrays[targetPriority][m];
				if (this.canBeTargeted(monster, rangeSq, originX, originY))
					result.push(monster);
			}
			return result;
		}
		
		private function pickRandomMonsters(count:int, rangeSq:Number, originX:Number, originY:Number): Array
		{
			//logger.log("pickRandom", "Picking random monsters");
			var result:Array = new Array();
			for each(var monster:Object in this.core.monstersOnScene)
			{
				if (this.canBeTargeted(monster, rangeSq, originX, originY))
					result.push(monster);
			}
			if (result.length < 2)
				return result;
				
			var targets:Array = new Array();
			var randomIndex:int = -1;
			while (result.length > 0 && targets.length < count)
			{
				randomIndex = Math.floor(Math.random() * result.length);
				targets.push(result[randomIndex]);
				result[randomIndex] = result.pop();
			}
			
			return targets;
		}
		
		private function canBeTargeted(monster:Object, rangeSq:Number, originX:Number, originY:Number): Boolean
		{
			//logger.log("canBeTargeted", "Checking if monster can be targeted");
			var dx:Number = monster.x - originX;
			var dy:Number = monster.y - originY;
			if(rangeSq > dx * dx + dy * dy)
			{
				if(!monster.isKillingShotOnTheWay)
				{
					//logger.log("canBeTargeted", "Yes: rangeSq" + rangeSq.toString() + " shooting " + monster.x + ";" + monster.y);
					return true;
				}
				//logger.log("canBeTargeted", "No, killing shot on the way");
				return false;
			}
			//logger.log("canBeTargeted", "No, out of range: rangeSq" + rangeSq.toString() + " shooting " + monster.x + ";" + monster.y);
			return false;
		}
		
		// Called after the gem's info panel has been formed but before it's returned to the game for rendering
		public function ingameGemInfoPanelFormed(infoPanel:Object, gem:Object, numberFormatter:Object): void
		{
			dispatchEvent(new IngameGemInfoPanelFormedEvent(BezelEvent.INGAME_GEM_INFO_PANEL_FORMED, {"infoPanel": infoPanel, "gem": gem, "numberFormatter": numberFormatter}));
		}
		
		// Called before any of the game's logic runs when starting to form an infopanel
		// This method is called before infoPanelFormed (which should be renamed to ingameGemInfoPanelFormed)
		public function ingamePreRenderInfoPanel(): Boolean
		{
			var eventArgs:Object = {"continueDefault": true};
			dispatchEvent(new IngamePreRenderInfoPanelEvent(BezelEvent.INGAME_PRE_RENDER_INFO_PANEL, eventArgs));
			//logger.log("ingamePreRenderInfoPanel", "Dispatched event!");
			return eventArgs.continueDefault;
		}
		
		// Called immediately as a click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		public function ingameClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:Object = {"continueDefault": true, "event":event, "mouseX":mouseX, "mouseY":mouseY, "buildingX": buildingX, "buildingY": buildingY };
			dispatchEvent(new IngameClickOnSceneEvent(BezelEvent.INGAME_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}
		
		// Called immediately as a right click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		public function ingameRightClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:Object = {"continueDefault": true, "event":event, "mouseX":mouseX, "mouseY":mouseY, "buildingX": buildingX, "buildingY": buildingY };
			dispatchEvent(new IngameClickOnSceneEvent(BezelEvent.INGAME_RIGHT_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}
		
		// TODO rename to ingameKeyDown
		// Called after the game checks that a key should be handled, but before any of the actual handling logic
		// Set continueDefault to false to prevent the base game's handler from running
		public function eh_ingameKeyDown(e:KeyboardEvent): Boolean
		{
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