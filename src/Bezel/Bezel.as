package Bezel
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.*;
	import Bezel.Logger;
	import Bezel.BezelEvent;
	import Bezel.Events.*;
	import flash.desktop.NativeApplication;
	import Bezel.Lattice.Lattice;
	import Bezel.Lattice.LatticeEvent;
	import flash.events.Event;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.filesystem.File;
	import Bezel.Utils.CCITT16;

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .bind method to bind our class to the game
	public class Bezel extends MovieClip
	{
		public const VERSION:String = "0.2.1";
		public const GAME_VERSION:String = "1.1.2b";
		
		// Game objects
		public var gameObjects:Object;
		public var lattice:Lattice;
		
		// Shortcuts to gameObjects
		private var main:Object;/*Main*/
		private var core:Object;/*IngameCore*/
		private var GV:Class;/*GV*/
		private var SB:Class;/*SB*/
		private var prefs:Object;/*Prefs*/

		private var updateAvailable:Boolean;
		
		private var logger:Logger;
		private var mods:Object;
		private var appStorage:File;

		private var waitingMods:uint;
		
		private var modsReloadedTimestamp:int;

		private var game:SWFFile;
		private var initialLoad:Boolean;
		private var coremods:Array;
		private var prevCoremods:Array;


        [Embed(source = "../../assets/rabcdasm/rabcdasm.exe", mimeType = "application/octet-stream")] private var disassemble:Class;
        [Embed(source = "../../assets/rabcdasm/rabcasm.exe", mimeType = "application/octet-stream")] private var reassemble:Class;
		[Embed(source = "../../assets/rabcdasm/COPYING", mimeType = "application/octet-stream")] private var LICENSE:Class;
		
		// Parameterless constructor for flash.display.Loader
		public function Bezel()
		{
			super();
			prepareFolders();

			this.initialLoad = true;
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_RELOAD, this.doneModReload);
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_LOAD, this.doneModLoad);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING,this.onExit);

			Logger.init();
			this.logger = Logger.getLogger("Bezel");
			this.mods = new Object();
			
			this.logger.log("Bezel", "Bezel Mod Loader " + prettyVersion());
			
            var swfFile:File = File.applicationDirectory.resolvePath("GemCraft Frostborn Wrath Backup.swf");
			if (!swfFile.exists)
			{
				this.logger.log("Bezel", "Game file not found. Try reinstalling the game, then Bezel.");
				NativeApplication.nativeApplication.exit(-1);
			}
			var tools:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/tools/");
			if (!tools.exists)
			{
				tools.createDirectory();
			}
			for each (var tool:String in ["disassemble", "reassemble", "LICENSE"])
			{
				var file:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/tools/" + tool + ".exe");
				if (!file.exists)
				{
					this.logger.log("Bezel", "Exporting tool " + tool);
					var toolData:ByteArray = new this[tool] as ByteArray;
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.WRITE);
					stream.writeBytes(toolData);
					stream.close();
				}
			}

			this.lattice = new Lattice(this);

			this.lattice.addEventListener(LatticeEvent.DISASSEMBLY_DONE, this.onLatticeReady);
			this.lattice.addEventListener(LatticeEvent.REBUILD_DONE, this.onGameBuilt);
			this.addEventListener(LatticeEvent.REBUILD_DONE, this.onGameBuilt);
			
			this.coremods = new Array();
			this.prevCoremods = new Array();
			if (!this.lattice.init())
			{
				var coremodFile:File = File.applicationStorageDirectory.resolvePath("coremods.bzl");
				if (coremodFile.exists)
				{
					var coremodStream:FileStream = new FileStream();
					coremodStream.open(coremodFile, FileMode.READ);
					while (coremodStream.bytesAvailable != 0)
					{
						this.prevCoremods[this.prevCoremods.length] = {"name": coremodStream.readUTF(), "hash": coremodStream.readUnsignedShort()};
					}
					coremodStream.close();
				}
			}
		}
		
		private function onExit(e:Event): void
		{
			Logger.exit();
		}

		private function onLatticeReady(e:Event): void
		{
			BezelCoreMod.installHooks(this);
			var versionBytes:ByteArray = new ByteArray();
			versionBytes.writeUTF(VERSION);
			this.coremods[this.coremods.length] = {"name": "BEZEL_MOD_LOADER", "hash": CCITT16.computeDigest(versionBytes)};

			loadMods();
		}

		private function onGameBuilt(e:Event): void
		{
			this.game = new SWFFile(Lattice.moddedSwf);
			this.game.load(this.gameLoadSuccess, this.gameLoadFail, false);
		}

		private function gameLoadSuccess(game:SWFFile): void
		{
			this.main = game.instance;
			game.instance.bezel = this;
			this.addChild(DisplayObject(game.instance));
			main.initFromBezel();
			bind();
			this.initialLoad = false;
		}

		private function gameLoadFail(e:Event): void
		{
			this.logger.log("gameLoadFail", "Loading game failed");
		}
		
		// This method binds the class to the game's objects
		public function bind() : Bezel
		{
			this.GV = getDefinitionByName("com.giab.games.gcfw.GV") as Class;
			this.SB = getDefinitionByName("com.giab.games.gcfw.SB") as Class;
			this.prefs = getDefinitionByName("com.giab.games.gcfw.Prefs") as Class;
			this.gameObjects = new Object();
			this.gameObjects.main = this.main;
			this.gameObjects.core = this.GV.ingameCore;
			this.gameObjects.GV = this.GV;
			this.gameObjects.SB = this.SB;
			this.gameObjects.prefs = this.prefs;

			this.gameObjects.mods = getDefinitionByName("com.giab.games.gcfw.Mods");
			this.gameObjects.constants = new Object();
			this.gameObjects.constants.achievementIngameStatus = getDefinitionByName("com.giab.games.gcfw.constants.AchievementIngameStatus");
			this.gameObjects.constants.actionStatus = getDefinitionByName("com.giab.games.gcfw.constants.ActionStatus");
			this.gameObjects.constants.battleMode = getDefinitionByName("com.giab.games.gcfw.constants.BattleMode");
			this.gameObjects.constants.battleOutcome = getDefinitionByName("com.giab.games.gcfw.constants.BattleOutcome");
			this.gameObjects.constants.battleTraitId = getDefinitionByName("com.giab.games.gcfw.constants.BattleTraitId");
			this.gameObjects.constants.beaconType = getDefinitionByName("com.giab.games.gcfw.constants.BeaconType");
			this.gameObjects.constants.buildingType = getDefinitionByName("com.giab.games.gcfw.constants.BuildingType");
			this.gameObjects.constants.dropType = getDefinitionByName("com.giab.games.gcfw.constants.DropType");
			this.gameObjects.constants.epicCreatureType = getDefinitionByName("com.giab.games.gcfw.constants.EpicCreatureType");
			this.gameObjects.constants.gameMode = getDefinitionByName("com.giab.games.gcfw.constants.GameMode");
			this.gameObjects.constants.gemComponentType = getDefinitionByName("com.giab.games.gcfw.constants.GemComponentType");
			this.gameObjects.constants.gemEnhancementId = getDefinitionByName("com.giab.games.gcfw.constants.GemEnhancementId");
			this.gameObjects.constants.ingameStatus = getDefinitionByName("com.giab.games.gcfw.constants.IngameStatus");
			this.gameObjects.constants.monsterBodyPartType = getDefinitionByName("com.giab.games.gcfw.constants.MonsterBodyPartType");
			this.gameObjects.constants.monsterBuffId = getDefinitionByName("com.giab.games.gcfw.constants.MonsterBuffId");
			this.gameObjects.constants.monsterType = getDefinitionByName("com.giab.games.gcfw.constants.MonsterType");
			this.gameObjects.constants.pauseType = getDefinitionByName("com.giab.games.gcfw.constants.PauseType");
			this.gameObjects.constants.screenId = getDefinitionByName("com.giab.games.gcfw.constants.ScreenId");
			this.gameObjects.constants.selectorScreenStatus = getDefinitionByName("com.giab.games.gcfw.constants.SelectorScreenStatus");
			this.gameObjects.constants.skillId = getDefinitionByName("com.giab.games.gcfw.constants.SkillId");
			this.gameObjects.constants.skillType = getDefinitionByName("com.giab.games.gcfw.constants.SkillType");
			this.gameObjects.constants.stageType = getDefinitionByName("com.giab.games.gcfw.constants.StageType");
			this.gameObjects.constants.statId = getDefinitionByName("com.giab.games.gcfw.constants.StatId");
			this.gameObjects.constants.strikeSpellId = getDefinitionByName("com.giab.games.gcfw.constants.StrikeSpellId");
			this.gameObjects.constants.talismanFragmentType = getDefinitionByName("com.giab.games.gcfw.constants.TalismanFragmentType");
			this.gameObjects.constants.talismanPropertyId = getDefinitionByName("com.giab.games.gcfw.constants.TalismanPropertyId");
			this.gameObjects.constants.targetPriorityId = getDefinitionByName("com.giab.games.gcfw.constants.TargetPriorityId");
			this.gameObjects.constants.tutorialId = getDefinitionByName("com.giab.games.gcfw.constants.TutorialId");
			this.gameObjects.constants.url = getDefinitionByName("com.giab.games.gcfw.constants.Url");
			this.gameObjects.constants.waveFormation = getDefinitionByName("com.giab.games.gcfw.constants.WaveFormation");
			this.gameObjects.constants.wizLockType = getDefinitionByName("com.giab.games.gcfw.constants.WizLockType");
			this.gameObjects.constants.wizStashStatus = getDefinitionByName("com.giab.games.gcfw.constants.WizStashStatus");
			
			this.updateAvailable = false;
			main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = "Bezel " + prettyVersion();
			//checkForUpdates();
			this.logger.log("Bezel", "Bezel bound to game's objects!");
			this.bindMods();
			return this;
		}

		private function bindMods() : void
		{
			for each (var mod:Object in mods)
			{
				mod.instance.bind(this, this.gameObjects);
				this.logger.log("bindMods", "Bound mod: " + mod.instance.MOD_NAME);
			}
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
			
			var fileList:Array = modsFolder.getDirectoryListing();
			var modFiles:Array = new Array();
			for(var f:int = 0; f < fileList.length; f++)
			{
				var fileName:String = fileList[f].name;
				//logger.log("loadMods", "Looking at " + fileName);
				if (fileName.substring(fileName.length - 4, fileName.length) == ".swf" && fileName != "BezelModLoader.swf")
				{
					modFiles.push(fileName);
				}
			}

			waitingMods = modFiles.length;
			for each (var file:String in modFiles)
			{
				var newMod:SWFFile = new SWFFile(File.applicationDirectory.resolvePath("Mods/" + file));
				newMod.load(successfulModLoad, failedModLoad);
			}
			this.modsReloadedTimestamp = getTimer();
		}
		
		public function successfulModLoad(mod:SWFFile): void
		{
			logger.log("successfulModLoad", "Loaded mod: " + mod.instance.MOD_NAME + " v" + mod.instance.VERSION);
			mods[mod.instance.MOD_NAME] = mod;
			if (!this.bezelVersionCompatible(mod.instance.BEZEL_VERSION))
			{
				logger.log("Compatibility", "Bezel version is incompatible! Required: " + mod.instance.BEZEL_VERSION);
				delete mods[mod.instance.MOD_NAME];
				mod.unload();
				throw new Error("Bezel version is incompatible! Bezel: " + VERSION + " while " + mod.instance.MOD_NAME+ " requires " + mod.instance.BEZEL_VERSION);
			}
			this.addChild(DisplayObject(mod.instance));

			waitingMods--;

			if (this.initialLoad)
			{
				if ("loadCoreMod" in mod.instance)
				{
					this.coremods[this.coremods.length] = {"name": mod.instance.MOD_NAME, "hash": mod.hash};
					logger.log("LoadCoreMod", "Loading coremods for " + mod.instance.MOD_NAME);
					mod.instance.loadCoreMod(this.lattice);
				}

				if (waitingMods == 0)
				{
					this.dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_LOAD));
				}
			}
			else 
			{
				if ("loadCoreMod" in mod.instance)
				{
					logger.log("Mod Reload", "The coremod contained in " + mod.instance.MOD_NAME + " was not reloaded. This may cause issues!");
				}

				if (waitingMods == 0)
				{
					dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_RELOAD));
				}
			}
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
		
		public function failedModLoad(e:Event): void
		{
			logger.log("failedLoad", "Failed to load mod: " + e.currentTarget.url);

			waitingMods--;
			if (waitingMods == 0)
			{
				if (this.initialLoad)
				{
					dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_LOAD));
				}
				else
				{
					dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_RELOAD));
				}
			}
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
			for each (var mod:SWFFile in mods)
			{
				mod.unload();
			}
			this.removeChildren();
			mods = new Array();
			loadMods();
		}

		private function doneModReload(e:Event): void
		{
			bindMods();
		}

		private function doneModLoad(e:Event): void
		{
			var differentCoremods:Boolean = this.coremods.length != this.prevCoremods.length;
			if (!differentCoremods)
			{
				this.coremods.sortOn("name");
				this.prevCoremods.sortOn("name");
				for (var i:int = 0; i < this.coremods.length; i++)
				{
					if (this.coremods[i].name != this.prevCoremods[i].name ||
						this.coremods[i].hash != this.prevCoremods[i].hash)
					{
						differentCoremods = true;
						break;
					}
				}
			}

			if (differentCoremods)
			{
				var file:File = File.applicationStorageDirectory.resolvePath("coremods.bzl");
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				for each (var coremod:Object in this.coremods)
				{
					stream.writeUTF(coremod.name);
					stream.writeShort(coremod.hash);
				}
				stream.close();
				this.lattice.apply();
			}
			else
			{
				dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
			}
		}

		public function loadSave(): void
		{
			dispatchEvent(new LoadSaveEvent(GV.ppd, BezelEvent.LOAD_SAVE));
		}
		public function saveSave(): void
		{
			dispatchEvent(new SaveSaveEvent(GV.ppd, BezelEvent.SAVE_SAVE));
		}
		public function ingameNewScene(): void
		{
			dispatchEvent(new IngameNewSceneEvent(BezelEvent.INGAME_NEW_SCENE));
		}
	}
}
