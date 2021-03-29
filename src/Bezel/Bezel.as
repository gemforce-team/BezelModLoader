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

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .bind method to bind our class to the game
	public class Bezel extends MovieClip
	{
		public const VERSION:String = "0.3.1";

		// Game objects
		public var gameObjects:Object;
		public var lattice:Lattice;

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

		private var waitingMods:uint;

		private var modsReloadedTimestamp:int;

		private var game:SWFFile;
		private var initialLoad:Boolean;
		private var coremods:Array;
		private var prevCoremods:Array;

		public static const bezelFolder:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/");
		public static const toolsFolder:File = bezelFolder.resolvePath("tools/");
		public static const latticeFolder:File = bezelFolder.resolvePath("Lattice/");
		public static const coremodFile:File = bezelFolder.resolvePath("coremods.bzl");

		public static const modsFolder:File = File.applicationDirectory.resolvePath("Mods/");
        public static const gameSwf:File = File.applicationDirectory.resolvePath("GemCraft Frostborn Wrath.swf");
		public static const moddedSwf:File = File.applicationDirectory.resolvePath("gcfw-modded.swf");

        [Embed(source = "../../assets/rabcdasm/rabcdasm.exe", mimeType = "application/octet-stream")] private static const disassemble_data:Class;
        [Embed(source = "../../assets/rabcdasm/rabcasm.exe", mimeType = "application/octet-stream")] private static const reassemble_data:Class;
		[Embed(source = "../../assets/rabcdasm/COPYING", mimeType = "application/octet-stream")] private static const LICENSE_data:Class;
		
		private static const disassemble:Object = {"name": "disassemble.exe", "data":disassemble_data};
		private static const reassemble:Object = {"name": "reassemble.exe", "data":reassemble_data};
		private static const LICENSE:Object = {"name": "LICENSE", "data":LICENSE_data};

		// Parameterless constructor for flash.display.Loader
		public function Bezel()
		{
			super();
			prepareFolders();

			this.initialLoad = true;

			// Application flow is controlled using events. There's a page on the wiki that outlines it
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_RELOAD, this.doneModReload);
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_LOAD, this.doneModLoad);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, this.onExit);

			Logger.init();
			this.logger = Logger.getLogger("Bezel");
			this.mods = new Object();

			this.logger.log("Bezel", "Bezel Mod Loader " + prettyVersion());

			if (!gameSwf.exists)
			{
				this.logger.log("Bezel", "Game file not found. Try reinstalling the game.");
				NativeApplication.nativeApplication.exit(-1);
			}

			if (!toolsFolder.exists)
			{
				toolsFolder.createDirectory();
			}
			
			for each (var tool:Object in [disassemble, reassemble, LICENSE])
			{
				var file:File = toolsFolder.resolvePath(tool.name);
				if (!file.exists)
				{
					this.logger.log("Bezel", "Exporting tool " + tool);
					var toolData:ByteArray = new tool.data as ByteArray;
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

			// Initializes Lattice. This method raises DISASSEMBLY_DONE
			var reloadCoremods:Boolean = this.lattice.init();

			if (!reloadCoremods)
			{
				if (coremodFile.exists)
				{
					var coremodStream:FileStream = new FileStream();
					coremodStream.open(coremodFile, FileMode.READ);
					while (coremodStream.bytesAvailable != 0)
					{
						this.prevCoremods[this.prevCoremods.length] = {"name": coremodStream.readUTF(), "version": coremodStream.readUTF()};
					}
					coremodStream.close();
				}
			}
		}

		private function onExit(e:Event): void
		{
			Logger.exit();
		}

		// After we have the dissassembled game, add BezelCoreMod and load mods
		private function onLatticeReady(e:Event): void
		{
			this.coremods[this.coremods.length] = {"name": "BEZEL_MOD_LOADER", "version": BezelCoreMod.VERSION, "load": BezelCoreMod.installHooks};

			loadMods();
		}

		// After we've loaded all mods and applied coremods & rebuilt the modded swf, we're ready to start the game
		private function onGameBuilt(e:Event): void
		{
			this.game = new SWFFile(moddedSwf);
			// Last argument tells the flash Loader to load the game into the same ApplicationDomain as Bezel is running in.
			// This gives Bezel direct access to the game's classes (using getDefinitionByName).
			this.game.load(this.gameLoadSuccess, this.gameLoadFail, true);
		}

		// Bind the game and Bezel to each other
		private function gameLoadSuccess(game:SWFFile): void
		{
			this.main = game.instance;
			game.instance.bezel = this;
			this.addChild(DisplayObject(game.instance));
			// Base game's init (main.initFromBezel())
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

			var version:String = main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text;
			version = version.slice(0, version.search(' ') + 1) + prettyVersion();
			main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = version;
			//checkForUpdates();

			GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

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
			if(!bezelFolder.isDirectory)
				bezelFolder.createDirectory();
			if (!latticeFolder.isDirectory)
				latticeFolder.createDirectory();
		}

		// Tries to load every .swf except itself in /Mods/ directory as a mod
		private function loadMods(): void
		{
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
				var newMod:SWFFile = new SWFFile(modsFolder.resolvePath(file));
				newMod.load(successfulModLoad, failedModLoad);
			}
			
			if (modFiles.length == 0)
			{
				if (this.initialLoad)
				{
					this.dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_LOAD));
				}
				else
				{
					this.dispatchEvent(new Event(BezelEvent.BEZEL_DONE_MOD_RELOAD));
				}
			}
			
			this.modsReloadedTimestamp = getTimer();
		}

		// Assuming the file loaded, add the mod to tracked mods. Check compatibility. Check if the mod has a coremod and add the patches if so.
		public function successfulModLoad(mod:SWFFile): void
		{
			var name: String = mod.instance.MOD_NAME;
			logger.log("successfulModLoad", "Loaded mod: " + name + " v" + mod.instance.VERSION);
			mods[name] = mod;
			if (!this.bezelVersionCompatible(mod.instance.BEZEL_VERSION))
			{
				logger.log("Compatibility", "Bezel version is incompatible! Required: " + mod.instance.BEZEL_VERSION);
				delete mods[name];
				var requiredVersion:String = mod.instance.BEZEL_VERSION;
				mod.unload();
				throw new Error("Bezel version is incompatible! Bezel: " + VERSION + " while " + name + " requires " + requiredVersion);
			}
			this.addChild(DisplayObject(mod.instance));

			waitingMods--;

			if (this.initialLoad)
			{
				if ("loadCoreMod" in mod.instance)
				{
					if ("COREMOD_VERSION" in mod.instance)
					{
						this.coremods[this.coremods.length] = {"name": name, "version": mod.instance.COREMOD_VERSION, "load": mod.instance.loadCoreMod};
					}
					else
					{
						this.coremods[this.coremods.length] = {"name": name, "version": mod.instance.VERSION, "load": mod.instance.loadCoreMod};
					}
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
					logger.log("Mod Reload", "The coremod contained in " + name + " was not reloaded. This may cause issues!");
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

		// Returns a mod's instance, if such a mod is loaded. Used for cross-mod interactions
		public function getModByName(modName:String): Object
		{
			if (this.mods[modName])
				return this.mods[modName].instance;
			return null;
		}

		public function prettyVersion(): String
		{
			return 'Bezel v' + VERSION;
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

		// Called after the game checks that a key should be handled, but before any of the actual handling logic
		// Set continueDefault to false to prevent the base game's handler from running
		public function ingameKeyDown(e:KeyboardEvent): Boolean
		{
			var kbKDEventArgs:Object = {"event": e, "continueDefault": true};
			dispatchEvent(new IngameKeyDownEvent(BezelEvent.INGAME_KEY_DOWN, kbKDEventArgs));
			return kbKDEventArgs.continueDefault;
		}

		//
		public function stageKeyDown(e: KeyboardEvent): void
		{
			if (e.controlKey && e.altKey && e.shiftKey && e.keyCode == 36)
			{
				if (this.modsReloadedTimestamp + 10*1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Please wait 10 secods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					return;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Reloading mods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
				reloadAllMods();
			}
		}
		private function reloadAllMods(): void
		{
			logger.log("eh_keyboardKeyDown", "Reloading all mods!");
			this.modsReloadedTimestamp = getTimer();
			for each (var mod:SWFFile in mods)
			{
				var name: String = mod.instance.MOD_NAME;
				mod.unload();
				delete mods[name];
			}
			this.removeChildren();
			this.addChild(DisplayObject(game.instance));
			mods = new Array();
			loadMods();
		}

		private function doneModReload(e:Event): void
		{
			bindMods();
		}

		// After bezel loads mods from /Mods/ and aggregates all coremods, check if we need to reapply the coremods.
		// If we do, load them into Lattice, apply them, rebuild the modded swf.
		// Either Bezel sees that the coremods are all the same and skips calling Lattice (raises REBUILD_DONE)
		// Or They are different and we call Lattice, which then raises REBUILD_DONE
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
						this.coremods[i].version != this.prevCoremods[i].version)
					{
						differentCoremods = true;
						break;
					}
				}
			}

			if (differentCoremods)
			{
				var stream:FileStream = new FileStream();
				stream.open(coremodFile, FileMode.WRITE);
				for each (var coremod:Object in this.coremods)
				{
					stream.writeUTF(coremod.name);
					stream.writeUTF(coremod.version);

					logger.log("doneModLoad", "Loading coremods for " + coremod.name);
					coremod.load(this.lattice);
				}
				stream.close();

				try {
					this.lattice.apply();
				}
				catch (e:Error)
				{
					if (moddedSwf.exists)
					{
						moddedSwf.deleteFile();
					}
					throw e;
				}
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
