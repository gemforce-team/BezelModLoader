package Bezel
{
	import Bezel.Lattice.Lattice;
	import Bezel.Lattice.LatticeEvent;
	import Bezel.Logger;
	import Bezel.Utils.FunctionDeferrer;
	import Bezel.Utils.KeybindManager;
	import Bezel.Utils.SettingManager;

	import flash.desktop.NativeApplication;
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	import flash.filesystem.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.getQualifiedClassName;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	use namespace bezel_internal;
	use namespace mainloader_only;
	
	/**
	 * Loader class for Bezel Mod Loader
	 * @author Hellrage
	 */
	public class Bezel extends MovieClip
	{
		public static const VERSION:String = "2.0.5";

		private var _gameObjects:Object;
		private var _mainLoader:MainLoader;
		private var _keybindManager:KeybindManager;
		private var _modsReloadedTimestamp:int;
		private static var _instance:Bezel;
        private static var _gameSwf:File;
		private static var _moddedSwf:File;

		private var lattice:Lattice;
		private var logger:Logger;
		private var mods:Object;

		private var waitingMods:uint;
		private var progressTotal:uint;

		private var initialLoad:Boolean;
		private var coremods:Array;
		private var prevCoremods:Array;
		
		private var loadingStageTextField:TextField;
		private var loadingProgressTextField:TextField;
		private var loadingProgressBar:Sprite;

		private var manager:SettingManager;

		private static const DISASSEMBLING_GAME:String = "Disassembling Game...";
		private static const LOADING_MODS:String = "Loading Mods...";
		private static const LOADING_COREMODS:String = "Loading Coremods...";
		private static const APPLYING_COREMODS:String = "Applying Coremods...";
		private static const LOADING_GAME:String = "Loading Game...";
		private static const BINDING_MODS:String = "Binding Mods...";

		public static const BEZEL_FOLDER:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/");
		public static const TOOLS_FOLDER:File = BEZEL_FOLDER.resolvePath("tools/");
		public static const LATTICE_FOLDER:File = BEZEL_FOLDER.resolvePath("Lattice/");

        public static const LATTICE_DEFAULT_ASM:File = LATTICE_FOLDER.resolvePath("game.basasm");
        public static const LATTICE_DEFAULT_CLEAN_ASM:File = LATTICE_FOLDER.resolvePath("game-clean.basasm");
        public static const LATTICE_DEFAULT_COREMODS:File = LATTICE_FOLDER.resolvePath("coremods.lttc");

		public static const MODS_FOLDER:File = File.applicationDirectory.resolvePath("Mods/");

		private static const gameConfig:File = File.applicationDirectory.resolvePath("game-file.txt");
		private static const BEZEL_COREMODS:File = BEZEL_FOLDER.resolvePath("coremods.bzl");
		private static const mainLoaderFile:File = File.applicationDirectory.resolvePath("Bezel/MainLoader.swf");

		[Embed(source = "../../assets/splitter/splitter.exe", mimeType = "application/octet-stream")] private static const splitter_data:Class;
		private static const splitter:Object = {"name": "splitter.exe", "data":splitter_data};
		
		private const gameLoader:SWFFile = new SWFFile(moddedSwf);
		private const mainLoaderLoader:SWFFile = new SWFFile(mainLoaderFile);

		/**
		 * The instance of this class.
		 */
		public static function get instance():Bezel { return _instance; }
		/**
		 * MainLoaders may store references to game objects here. See your MainLoader for documentation on its gameObjects format.
		 * Will never be null during or after the bind phase.
		 */
		public function get gameObjects():Object { return _gameObjects; }
		/**
		 * The MainLoader for the game. May be null for a game loaded without a MainLoader!
		 */
		public function get mainLoader():MainLoader { return _mainLoader; }
		/**
		 * The KeybindManager used for the game
		 */
		public function get keybindManager():KeybindManager { return _keybindManager; }
		/**
		 * Last time mods were reloaded. Can be used to implement a reload timeout.
		 */
		public function get modsReloadedTimestamp():int { return _modsReloadedTimestamp; }
		
		bezel_internal static function get gameSwf(): File
		{
			if (_gameSwf == null)
			{
				var config:FileStream = new FileStream();
				config.open(gameConfig, FileMode.READ);
				_gameSwf = File.applicationDirectory.resolvePath(config.readUTFBytes(config.bytesAvailable));
				config.close();
			}
			return _gameSwf;
		}
		
		bezel_internal static function get moddedSwf(): File
		{
			if (_moddedSwf == null)
			{
				_moddedSwf = LATTICE_FOLDER.resolvePath(gameSwf.name.split('.').slice(0, -1).join('.') + "-modded.swf");
			}
			return _moddedSwf;
		}

		public function Bezel()
		{
			_instance = this;
			manager = getSettingManager("Bezel Mod Loader");
			prepareFolders();
			this.addEventListener(LatticeEvent.REBUILD_DONE, this.onGameBuilt);

			FunctionDeferrer.deferFunction(this.startLoadFromScratch, [], this, true);
		}

		private function startLoadFromScratch():void
		{
			this._keybindManager = new KeybindManager();
			
			loadingStageTextField = new TextField();
			loadingStageTextField.selectable = false;
			var textFormat:TextFormat = loadingStageTextField.defaultTextFormat;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.size = 24;
			loadingStageTextField.defaultTextFormat = textFormat;
			loadingStageTextField.textColor = 0xFFFFFF;
			loadingStageTextField.text = LOADING_MODS;
			loadingStageTextField.width = this.stage.stageWidth;
			loadingStageTextField.y = this.stage.stageHeight * .40;
			this.addChild(loadingStageTextField);

			const emptyLoadingBarWidth:int = 4;

			var emptyLoadingBar:Sprite = new Sprite();
			emptyLoadingBar.graphics.lineStyle(emptyLoadingBarWidth, 0xFF0000, 1.0, true, "normal", "square", "miter");
			emptyLoadingBar.graphics.lineTo(0, this.stage.stageHeight * .10);
			emptyLoadingBar.graphics.lineTo(this.stage.stageWidth * .90, this.stage.stageHeight * .10);
			emptyLoadingBar.graphics.lineTo(this.stage.stageWidth * .90, 0);
			emptyLoadingBar.graphics.lineTo(0, 0);

			emptyLoadingBar.y = this.stage.stageHeight * .50;
			emptyLoadingBar.x = (this.stage.stageWidth - emptyLoadingBar.width) / 2;

			this.addChild(emptyLoadingBar);

			loadingProgressBar = new Sprite();
			loadingProgressBar.graphics.beginFill(0x800000);
			loadingProgressBar.graphics.drawRect(0, 0, emptyLoadingBar.width - emptyLoadingBarWidth * 2, emptyLoadingBar.height - emptyLoadingBarWidth * 2);

			loadingProgressBar.scaleX = 0;
			loadingProgressBar.y = emptyLoadingBar.y + emptyLoadingBarWidth / 2;
			loadingProgressBar.x = emptyLoadingBar.x + emptyLoadingBarWidth / 2;

			this.addChild(loadingProgressBar);

			loadingProgressTextField = new TextField();
			loadingProgressTextField.selectable = false;
			loadingProgressTextField.defaultTextFormat = textFormat;
			loadingProgressTextField.textColor = 0xFFFFFF;
			loadingProgressTextField.text = LOADING_MODS;
			loadingProgressTextField.width = this.stage.stageWidth;
			// I give up, close enough.
			loadingProgressTextField.y = (this.stage.stageHeight + emptyLoadingBar.height - loadingStageTextField.textHeight) / 2;

			loadingProgressTextField.text = "";
			loadingStageTextField.text = "";

			this.addChild(loadingProgressTextField);

			FunctionDeferrer.deferFunction(loadFromScratch2, [], this, true);
		}

		private function loadFromScratch2():void
		{
			this.initialLoad = true;

			this.logger = Logger.getLogger("Bezel");
			this.mods = new Object();

			this.logger.log("Bezel", "Bezel Mod Loader " + prettyVersion());

			if (!gameSwf.exists)
			{
				this.logger.log("Bezel", "Game file not found. Try removing game-file.txt, reinstalling the game, and reinstalling Bezel");
				NativeApplication.nativeApplication.exit(-1);
			}

			if (!TOOLS_FOLDER.exists)
			{
				TOOLS_FOLDER.createDirectory();
			}
			
			for each (var tool:Object in [splitter])
			{
				var file:File = TOOLS_FOLDER.resolvePath(tool.name);
				if (!file.exists)
				{
					this.logger.log("Bezel", "Exporting tool " + tool.name);
					var toolData:ByteArray = new tool["data"] as ByteArray;
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.WRITE);
					stream.writeBytes(toolData);
					stream.close();
				}
			}

			FunctionDeferrer.deferFunction(this.initLattice, [], this, true);
		}

		private function initLattice():void
		{
			var includeDebugInstrs:Boolean = false;
			try
			{
				// We intentionally register this boolean later so that the MainLoader can see that we registered it, so make sure to catch the error if it occurs
				includeDebugInstrs = manager.retrieveBoolean("Include Debug Instructions");
			}
			catch (e:*){}

			this.lattice = new Lattice(gameSwf, moddedSwf, LATTICE_DEFAULT_ASM, LATTICE_DEFAULT_CLEAN_ASM, LATTICE_DEFAULT_COREMODS, includeDebugInstrs);

			this.lattice.addEventListener(LatticeEvent.DISASSEMBLY_DONE, this.onDisassembleDone);
			this.lattice.addEventListener(LatticeEvent.REBUILD_DONE, this.onGameBuilt);
			var patchesApplied:int = 0;
			this.lattice.addEventListener(LatticeEvent.SINGLE_PATCH_APPLIED, function(...args):void{ updateProgress(++patchesApplied, lattice.numberOfPatches); });

			this.coremods = new Array();
			this.prevCoremods = new Array();

			// Initializes Lattice. This method raises DISASSEMBLY_DONE
			var reloadCoremods:Boolean = this.lattice.init();

			if (!reloadCoremods)
			{
				if (BEZEL_COREMODS.exists)
				{
					var coremodStream:FileStream = new FileStream();
					coremodStream.open(BEZEL_COREMODS, FileMode.READ);
					while (coremodStream.bytesAvailable != 0)
					{
						this.prevCoremods[this.prevCoremods.length] = {"name": coremodStream.readUTF(), "version": coremodStream.readUTF()};
					}
					coremodStream.close();
				}
			}
			else
			{
				this.loadingStageTextField.text = DISASSEMBLING_GAME;
				updateProgress(0, 1);
				// Don't really have anything to do, but we need to do *something*
				FunctionDeferrer.hardDeferFunction(function(...args):void{}, [], null, true);
			}
		}

		private function onDisassembleDone(e:Event):void
		{
			FunctionDeferrer.deferFunction(this.loadMainLoader, [], this, true);
		}

		// After we have the dissassembled game, add the MainLoader (if it exists) and load mods
		private function loadMainLoader(): void
		{
			if (mainLoaderFile.exists)
			{
				var that:Bezel = this;

				this.mainLoaderLoader.load(
					function(...args):void{
						_mainLoader = MainLoader(mainLoaderLoader.instance);
						addChild(DisplayObject(mainLoaderLoader.instance));
						logger.log("Bezel", "MainLoader loaded from " + File.applicationDirectory.getRelativePath(mainLoaderFile));
						coremods[coremods.length] = mainLoader.coremodInfo;
						manager.registerBoolean("Include Debug Instructions", function(...args):void{ if (LATTICE_DEFAULT_CLEAN_ASM.exists) LATTICE_DEFAULT_CLEAN_ASM.deleteFile(); }, false, "Requires restart and may cause slowdown");
						FunctionDeferrer.deferFunction(that.loadMods, [], that, true);
					},
					function(...args):void{
						logger.log("Bezel", "MainLoader could not be loaded");
						throw new Error("MainLoader could not be loaded!");
					},
					true);
			}
			else
			{
				logger.log("Bezel", "No MainLoader present! All mods and coremods will have to handle themselves, and full reloads are not possible!");
				FunctionDeferrer.deferFunction(this.loadMods, [], this, true);
			}
		}

		// After we've loaded all mods and applied coremods & rebuilt the modded swf, we're ready to start the game
		private function onGameBuilt(e:Event): void
		{
			// Last argument tells the flash Loader to load the game into the same ApplicationDomain as Bezel is running in.
			// This gives Bezel direct access to the game's classes (using getDefinitionByName).
			this.loadingStageTextField.text = LOADING_GAME;
			this.updateProgress(0, 1);
			if (lattice.swfBytes != null)
			{
				this.gameLoader.loadBytes(lattice.swfBytes, this.gameLoadSuccess, this.gameLoadFail, true);
			}
			else
			{
				this.gameLoader.load(this.gameLoadSuccess, this.gameLoadFail, true);
			}
		}

		// Bind the game and Bezel to each other
		private function gameLoadSuccess(game:SWFFile): void
		{
			this.stage.addChild(DisplayObject(game.instance));
			var className:String = getQualifiedClassName(game.instance);
			var wantedName:String = this.mainLoader.gameClassFullyQualifiedName;
			if (wantedName.indexOf("::") == -1)
			{
				var components:Array = wantedName.split(".");
				var finalName:String = components.pop();
				wantedName = components.join(".") + "::" + finalName;
			}
			if (className != wantedName)
			{
				throw new TypeError("This game class (" + className + ") does not match the main loader's supported class name (" + wantedName + ")");
			}
			game.instance.bezel = this;
			removeChildren();
			game.instance.addChild(this);
			// Base game's init (main.initFromBezel())
			game.instance.initFromBezel();

			if (this.initialLoad)
			{
				this._gameObjects = new Object();
				if (this.mainLoader != null)
				{
					this.mainLoader.loaderBind(this, gameLoader.instance, gameObjects);
				}
			}
			bindMods();
			this.initialLoad = false;
		}

		private function gameLoadFail(e:Event): void
		{
			this.logger.log("gameLoadFail", "Loading game failed");
		}

		private function bindMods() : void
		{
			var vecMods:Vector.<SWFFile> = new Vector.<SWFFile>();
			for each (var mod:SWFFile in mods)
			{
				vecMods[vecMods.length] = mod;
			}

			this.loadingStageTextField.text = BINDING_MODS;
			this.updateProgress(0, vecMods.length);

			var that:Bezel = this;
			var bindSingleMod:Function = function(i:int):void
			{
				vecMods[i].instance.bind(that, gameObjects);
				logger.log("bindMods", "Bound mod: " + vecMods[i].instance.MOD_NAME);
				updateProgress(i+1, vecMods.length);
				if (i+1 < vecMods.length)
				{
					FunctionDeferrer.deferFunction(bindSingleMod, [i+1], null, true);
				}
			};

			if (vecMods.length != 0)
			{
				FunctionDeferrer.hardDeferFunction(bindSingleMod, [0], null, true);
			}
		}

		private function prepareFolders(): void
		{
			if(!BEZEL_FOLDER.isDirectory)
				BEZEL_FOLDER.createDirectory();
			if (!LATTICE_FOLDER.isDirectory)
				LATTICE_FOLDER.createDirectory();
		}

		// Tries to load every .swf in /Mods/ directory as a mod
		private function loadMods(): void
		{
			var enabledMods:SettingManager = this.getSettingManager("Enabled Mods");

			var fileList:Array = MODS_FOLDER.getDirectoryListing();
			var modFiles:Vector.<String> = new Vector.<String>();
			for(var f:int = 0; f < fileList.length; f++)
			{
				var fileName:String = fileList[f].name;
				//logger.log("loadMods", "Looking at " + fileName);
				if (fileName.substring(fileName.length - 4, fileName.length) == ".swf")
				{
					enabledMods.registerBoolean(fileName, null, true, "Requires restart");
					if (enabledMods.retrieveBoolean(fileName))
					{
						modFiles[modFiles.length] = fileName;
					}
				}
			}

			waitingMods = progressTotal = modFiles.length;
			
			updateProgress(0, progressTotal);
			this.loadingStageTextField.text = LOADING_MODS;

			var that:Bezel = this;
			var loadSingleMod:Function = function(i:int):void
			{
				var newMod:SWFFile = new SWFFile(MODS_FOLDER.resolvePath(modFiles[i]));
				newMod.load(successfulModLoad, failedModLoad);
				if (i+1 < modFiles.length)
				{
					FunctionDeferrer.deferFunction(loadSingleMod, [i+1], null, true);
				}
				else
				{
					_modsReloadedTimestamp = getTimer();
				}
			};
			
			if (modFiles.length == 0)
			{
				this._modsReloadedTimestamp = getTimer();
				if (this.initialLoad)
				{
					FunctionDeferrer.deferFunction(this.doneModLoad, [], this, true);
				}
				else
				{
					FunctionDeferrer.deferFunction(this.doneModReload, [], this, true);
				}
			}
			else
			{
				FunctionDeferrer.hardDeferFunction(loadSingleMod, [0], null, true);
			}
		}

		// Assuming the file loaded, add the mod to tracked mods. Check compatibility. Check if the mod has a coremod and add the patches if so.
		private function successfulModLoad(modFile:SWFFile): void
		{
			var name:String;
			if (!(modFile.instance is BezelMod))
			{
				if ("MOD_NAME" in modFile.instance)
				{
					name = " \'" + modFile.instance.MOD_NAME + "\' ";
					logger.log("Compatibility", "Unknown type of SWF found. Is the mod" + name + "at \'" + modFile.filePath + "\' using the correct interface?");
				}
				else
				{
					name = modFile.filePath;
					logger.log("Compatibility", "Unknown type of SWF found at \'" + name + "\'");
				}
				modFile.unload();
			}
			else
			{
				var mod:BezelMod = BezelMod(modFile.instance);
				name = mod.MOD_NAME;
				logger.log("successfulModLoad", "Loaded mod: " + name + " v" + mod.VERSION);
				if (!bezelVersionCompatible(mod.BEZEL_VERSION))
				{
					logger.log("Compatibility", "Bezel version is incompatible! Mod compiled for : " + mod.BEZEL_VERSION);
					var requiredVersion:String = mod.BEZEL_VERSION;
					mod.unload();
				}
				else
				{
					if (name in mods)
					{
						logger.log("Loader", "Mod \'" + name + "\' is already registered.");
						logger.log("Loader", "The first loaded \'" + name + "\' will be used over the one at " + modFile.filePath);
					}
					else
					{
						mods[name] = modFile;
						this.addChild(DisplayObject(mod));

						if (this.initialLoad)
						{
							if (mod is BezelCoreMod)
							{
								var coremod:BezelCoreMod = BezelCoreMod(mod);
								this.coremods[this.coremods.length] = {"name": name, "version": coremod.COREMOD_VERSION, "load": coremod.loadCoreMod};
							}
						}
						else
						{
							if (mod is BezelCoreMod)
							{
								logger.log("Mod Reload", "Coremod for " + name + " was not reloaded!");
							}
						}
					}
				}
			}
			
			reduceWaitingMods();
			
			if (!(name in mods))
			{
				throw new Error("An error occurred while loading " + modFile.filePath + ".\nSee log file for details.");
			}
		}
		
		private function reduceWaitingMods():void
		{
			waitingMods--;
			updateProgress(progressTotal - waitingMods, progressTotal);
			if (waitingMods == 0)
			{
				if (this.initialLoad)
				{
					FunctionDeferrer.deferFunction(this.doneModLoad, [], this, true);
				}
				else
				{
					FunctionDeferrer.deferFunction(this.doneModReload, [], this, true);
				}
			}
		}

		public static function bezelVersionCompatible(requiredVersion:String): Boolean
		{
			var bezelVer:Array = VERSION.split(".");
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

		private function failedModLoad(e:Event): void
		{
			logger.log("failedLoad", "Failed to load mod: " + e.currentTarget.url);

			reduceWaitingMods();
		}

		/**
		 * Gets a logger for the given mod ID
		 * @param id Mod ID
		 * @return Logger for the ID
		 */
		public function getLogger(id:String): Logger
		{
			return Logger.getLogger(id);
		}

		/**
		 * Gets a setting manager for the given mod ID
		 * @param id Mod ID
		 * @return Manager for the ID
		 */
		public function getSettingManager(id:String): SettingManager
		{
			return SettingManager.getManager(id);
		}

		/**
		 * Returns a mod's instance, if such a mod is loaded. Used for cross-mod interactions
		 * @param	modName Name of the mod to retrive
		 * @return  The mod loaded by the name "modName", or null if none exists
		 */
		public function getModByName(modName:String): Object
		{
			if (this.mods[modName])
				return this.mods[modName].instance;
			return null;
		}

		/**
		 * Returns the version formatted for display in a game version string. Probably unnecessary for anything except MainLoaders
		 * @return Formatted version string
		 */
		public static function prettyVersion(): String
		{
			return 'Bezel v' + VERSION;
		}

		/**
		 * Unloads, then reloads every mod. Almost certainly should only be used by MainLoaders
		 */
		mainloader_only function reloadAllMods(): void
		{
			FunctionDeferrer.clear();
			logger.log("eh_keyboardKeyDown", "Reloading all mods!");
			this._modsReloadedTimestamp = getTimer();
			SettingManager.unregisterAllManagers();
			if (mainLoader != null)
			{
				mainLoader.deregisterOption("Keybinds", null);
			}
			for each (var mod:SWFFile in mods)
			{
				var name:String = mod.instance.MOD_NAME;
				mod.unload();
				delete mods[name];
			}
			this.removeChildren();
			this.addChild(DisplayObject(mainLoader));
			mods = new Array();
			loadMods();
		}

		private function doneModReload(): void
		{
			bindMods();
		}

		// After bezel loads mods from /Mods/ and aggregates all coremods, check if we need to reapply the coremods.
		// If we do, load them into Lattice, apply them, rebuild the modded swf.
		// Either Bezel sees that the coremods are all the same and skips calling Lattice (raises REBUILD_DONE)
		// Or They are different and we call Lattice, which then raises REBUILD_DONE
		private function doneModLoad(): void
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
				this.loadingStageTextField.text = LOADING_COREMODS;
				updateProgress(0, coremods.length);
				var stream:FileStream = new FileStream();
				stream.open(BEZEL_COREMODS, FileMode.WRITE);

				var loadSingleCoremod:Function = function(idx:int):void
				{
					var coremod:Object = coremods[idx];
					stream.writeUTF(coremod.name);
					stream.writeUTF(coremod.version);

					logger.log("doneModLoad", "Loading coremods for " + coremod.name);
					coremod.load(lattice);
					updateProgress(idx+1, coremods.length);

					if (idx+1 < coremods.length)
					{
						FunctionDeferrer.deferFunction(loadSingleCoremod, [idx+1], null, true);
					}
					else
					{
						loadingStageTextField.text = APPLYING_COREMODS;
						updateProgress(0, lattice.numberOfPatches);

						FunctionDeferrer.hardDeferFunction(lattice.apply, [], lattice, true);
					}
				};

				FunctionDeferrer.hardDeferFunction(loadSingleCoremod, [0], null, true);
			}
			else
			{
				dispatchEvent(new Event(LatticeEvent.REBUILD_DONE));
			}
		}

		/**
		 * Triggers a full reload of Bezel, the game, and the MainLoader. Will not be called by Bezel itself, and must instead be called by
		 * a MainLoader (and nearly certainly not a regular mod).
		 */
		mainloader_only function triggerFullReload():void
		{
			logger.log("Bezel", "Performing FULL RELOAD");
			fullUnload();
			FunctionDeferrer.deferFunction(this.startLoadFromScratch, [], this, true);
		}

		private function fullUnload():void
		{
			FunctionDeferrer.clear();
			this._modsReloadedTimestamp = getTimer();
			SettingManager.unregisterAllManagers();
			if (mainLoader != null)
			{
				mainLoader.deregisterOption("Keybinds", null);
			}
			for each (var mod:SWFFile in mods)
			{
				var name:String = mod.instance.MOD_NAME;
				mod.unload();
				delete mods[name];
			}
			this.removeChildren();
			mods = new Array();
		
			this.stage.addChild(this); // Reparent this to the stage
			this.stage.removeChild(DisplayObject(this.gameLoader.instance));
	
			this.mainLoader.cleanupForFullReload();
			this.mainLoaderLoader.unload(true);
			this.gameLoader.unload();
		}

		private function updateProgress(current:int, total:int):void
		{
			this.loadingProgressTextField.text = current + " / " + total;
			this.loadingProgressBar.scaleX = Number(current)/Number(total);
		}
	}
}
