package Bezel
{
	import Bezel.Lattice.Lattice;
	import Bezel.Lattice.LatticeEvent;
	import Bezel.Logger;
	import Bezel.Utils.FunctionDeferrer;
	import Bezel.Utils.KeybindManager;
	import Bezel.Utils.SettingManager;

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.events.ErrorEvent;

	use namespace bezel_internal;
	use namespace mainloader_only;

	/**
	 * Loader class for Bezel Mod Loader
	 * @author Hellrage
	 */
	public class Bezel extends MovieClip
	{
		/** The installed version of Bezel */
		public static const VERSION:String = "2.1.0";

		private var _gameObjects:Object;
		private var _mainLoader:MainLoader;
		private var _keybindManager:KeybindManager;
		private var _modsReloadedTimestamp:int;
		private static var _instance:Bezel;
		private static var _gameSwf:File;
		private static var _moddedSwf:File;

		private var lattice:Lattice;
		private var logger:Logger;
		private const mods:Object = new Object();
		private const libs:Vector.<String> = new <String>[];

		private var waitingMods:uint;
		private var progressTotal:uint;
		private var patchesApplied:uint;

		private var initialLoad:Boolean;
		private const coremods:Array = [];
		private const prevCoremods:Array = [];

		private const loadingStageTextField:TextField = new TextField();
		private const loadingProgressTextField:TextField = new TextField();
		private const loadingProgressBar:Sprite = new Sprite();

		private var manager:SettingManager;

		private static const DISASSEMBLING_GAME:String = "Disassembling Game...";
		private static const LOADING_LIBS:String = "Loading Mod Libraries...";
		private static const LOADING_MODS:String = "Loading Mods...";
		private static const LOADING_COREMODS:String = "Loading Coremods...";
		private static const APPLYING_COREMODS:String = "Applying Coremods...";
		private static const ASSEMBLING_GAME:String = "Assembling Game...";
		private static const LOADING_GAME:String = "Loading Game...";
		private static const BINDING_MODS:String = "Binding Mods...";

		/** The folder Bezel uses. */
		public static const BEZEL_FOLDER:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/");

		/** The tools folder where extra binary utilities are put */
		public static const TOOLS_FOLDER:File = BEZEL_FOLDER.resolvePath("tools/");

		/** The folder Lattice uses */
		public static const LATTICE_FOLDER:File = BEZEL_FOLDER.resolvePath("Lattice/");

		/** The file for Lattice to use for the edited game bytecode */
		public static const LATTICE_DEFAULT_ASM:File = LATTICE_FOLDER.resolvePath("game.basasm");

		/** The file for Lattice to use for the clean game bytecode */
		public static const LATTICE_DEFAULT_CLEAN_ASM:File = LATTICE_FOLDER.resolvePath("game-clean.basasm");

		/** The file for Lattice to use to cache submitted coremods */
		public static const LATTICE_DEFAULT_COREMODS:File = LATTICE_FOLDER.resolvePath("coremods.lttc");

		/** The mods folder */
		public static const MODS_FOLDER:File = File.applicationDirectory.resolvePath("Mods/");
		public static const LIBS_FOLDER:File = File.applicationDirectory.resolvePath("Libs/");

		private static const gameConfig:File = File.applicationDirectory.resolvePath("game-file.txt");
		private static const BEZEL_COREMODS:File = BEZEL_FOLDER.resolvePath("coremods.bzl");
		private static const mainLoaderFile:File = File.applicationDirectory.resolvePath("Bezel/MainLoader.swf");

		[Embed(source = "../../assets/splitter/splitter.exe", mimeType = "application/octet-stream")] private static const splitter_data:Class;
		private static const splitter:Object = {"name": "splitter.exe", "data": splitter_data};

		private static const DEBUG_INSTR_SETTING:String = "Include Debug Instructions";
		private static const ALWAYS_COREMOD_SETTING:String = "Always submit coremod patches";

		private const gameLoader:SWFFile = new SWFFile(moddedSwf);
		private const mainLoaderLoader:SWFFile = new SWFFile(mainLoaderFile);

		/**
		 * The instance of this class.
		 */
		public static function get instance():Bezel
		{
			return _instance;
		}

		/**
		 * MainLoaders may store references to game objects here. See your MainLoader for documentation on its gameObjects format.
		 * Will never be null during or after the bind phase.
		 */
		public function get gameObjects():Object
		{
			return _gameObjects;
		}

		/**
		 * The MainLoader for the game. May be null for a game loaded without a MainLoader!
		 */
		public function get mainLoader():MainLoader
		{
			return _mainLoader;
		}

		/**
		 * The KeybindManager used for the game
		 */
		public function get keybindManager():KeybindManager
		{
			return _keybindManager;
		}

		/**
		 * Last time mods were reloaded. Can be used to implement a reload timeout.
		 */
		public function get modsReloadedTimestamp():int
		{
			return _modsReloadedTimestamp;
		}

		/**
		 * The unmodified game SWF
		 */
		bezel_internal static function get gameSwf():File
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

		/**
		 * The modified game SWF for Bezel to cache its results to.
		 */
		bezel_internal static function get moddedSwf():File
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
			prepareFolders();

			FunctionDeferrer.deferFunction(this.startLoadFromScratch, [], this, true);
		}

		private function startLoadFromScratch():void
		{
			manager = getSettingManager("Bezel Mod Loader");

			this._keybindManager = new KeybindManager();

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

			loadingProgressBar.graphics.beginFill(0x800000);
			loadingProgressBar.graphics.drawRect(0, 0, emptyLoadingBar.width - emptyLoadingBarWidth * 2, emptyLoadingBar.height - emptyLoadingBarWidth * 2);

			loadingProgressBar.scaleX = 0;
			loadingProgressBar.y = emptyLoadingBar.y + emptyLoadingBarWidth / 2;
			loadingProgressBar.x = emptyLoadingBar.x + emptyLoadingBarWidth / 2;

			this.addChild(loadingProgressBar);

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
				includeDebugInstrs = manager.retrieveBoolean(DEBUG_INSTR_SETTING);
			}
			catch (e:*) {}

			this.lattice = new Lattice(gameSwf, moddedSwf, LATTICE_DEFAULT_ASM, LATTICE_DEFAULT_CLEAN_ASM, LATTICE_DEFAULT_COREMODS, includeDebugInstrs);

			this.lattice.addEventListener(LatticeEvent.DISASSEMBLY_DONE, this.onDisassembleDone, false, 0, true);
			this.lattice.addEventListener(LatticeEvent.REBUILD_DONE, this.onGameBuilt, false, 0, true);
			this.lattice.addEventListener(LatticeEvent.SINGLE_PATCH_APPLIED, this.onSinglePatch, false, 0, true);
			this.lattice.addEventListener(LatticeEvent.REASSEMBLY_STARTED, this.onReassembleStart, false, 0, true);

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
				FunctionDeferrer.hardDeferFunction(doNothingFunction, [], null, true);
			}
		}

		private function onDisassembleDone(e:Event):void
		{
			FunctionDeferrer.deferFunction(this.loadMainLoader, [], this, true);
		}

		private function onSinglePatch(e:Event):void
		{
			updateProgress(++ patchesApplied, lattice.numberOfPatches);
		}

		private function onReassembleStart(e:Event):void
		{
			this.loadingStageTextField.text = ASSEMBLING_GAME;
			updateProgress(0, 1);
			// Don't really have anything to do, but we need to do *something*
			FunctionDeferrer.hardDeferFunction(doNothingFunction, [], null, true);
		}

		private function onMainloaderLoadSuccess(file:SWFFile):void
		{
			_mainLoader = MainLoader(mainLoaderLoader.instance);
			addChild(DisplayObject(mainLoaderLoader.instance));
			logger.log("Bezel", "MainLoader loaded from " + File.applicationDirectory.getRelativePath(mainLoaderFile));
			coremods[coremods.length] = mainLoader.coremodInfo;
			FunctionDeferrer.deferFunction(this.loadLibs, [], this, true);
		}

		private function onMainloaderLoadFail(e:Event):void
		{
			logger.log("Bezel", "MainLoader could not be loaded");
			throw new Error("MainLoader could not be loaded!");
		}

		// After we have the dissassembled game, add the MainLoader (if it exists) and load mods
		private function loadMainLoader():void
		{
			if (mainLoaderFile.exists)
			{
				this.mainLoaderLoader.load(this.onMainloaderLoadSuccess, this.onMainloaderLoadFail, SWFFile.MAINLOADER_DOMAIN);
			}
			else
			{
				logger.log("Bezel", "No MainLoader present! All mods and coremods will have to handle themselves, and full reloads are not possible!");
				FunctionDeferrer.deferFunction(this.loadLibs, [], this, true);
			}
		}

		// After we've loaded all mods and applied coremods & rebuilt the modded swf, we're ready to start the game
		private function onGameBuilt(e:Event):void
		{
			// Last argument tells the flash Loader to load the game into the same ApplicationDomain as Bezel is running in.
			// This gives Bezel direct access to the game's classes (using getDefinitionByName).
			this.loadingStageTextField.text = LOADING_GAME;
			this.updateProgress(0, 1);
			if (lattice.swfBytes != null)
			{
				this.gameLoader.loadBytes(lattice.swfBytes, this.gameLoadSuccess, this.gameLoadFail, SWFFile.MAINLOADER_DOMAIN);
			}
			else
			{
				this.gameLoader.load(this.gameLoadSuccess, this.gameLoadFail, SWFFile.MAINLOADER_DOMAIN);
			}

			lattice.cleanup();
		}

		// Bind the game and Bezel to each other
		private function gameLoadSuccess(game:SWFFile):void
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
			bindModsAndLateRegisterSettingsAndKeybinds();
			this.initialLoad = false;
		}

		private function gameLoadFail(e:ErrorEvent):void
		{
			this.logger.log("gameLoadFail", "Loading game failed");
			throw new Error("Game load failed due to an error of type: " + e.type);
		}

		private function bindSingleMod(vecMods:Vector.<SWFFile>, i:int):void
		{
			vecMods[i].instance.bind(this, gameObjects);
			logger.log("bindMods", "Bound mod: " + vecMods[i].instance.MOD_NAME);
			updateProgress(i + 1, vecMods.length);
			if (i + 1 < vecMods.length)
			{
				FunctionDeferrer.deferFunction(bindSingleMod, [vecMods, i + 1], null, true);
			}
		}

		private function resetLattice(...args):void
		{
			if (LATTICE_DEFAULT_CLEAN_ASM.exists)
			{
				LATTICE_DEFAULT_CLEAN_ASM.deleteFile();
			}
		}

		private function bindModsAndLateRegisterSettingsAndKeybinds():void
		{
			manager.registerBoolean(DEBUG_INSTR_SETTING, resetLattice, false, "Requires restart and may cause slowdown");
			manager.registerBoolean(ALWAYS_COREMOD_SETTING, doNothingFunction, false, "Requires restart and may cause longer load times. Mostly useful for coremod devs.");

			var vecMods:Vector.<SWFFile> = new Vector.<SWFFile>();
			for each (var mod:SWFFile in mods)
			{
				vecMods[vecMods.length] = mod;
			}

			this.loadingStageTextField.text = BINDING_MODS;
			this.updateProgress(0, vecMods.length);

			if (vecMods.length != 0)
			{
				FunctionDeferrer.hardDeferFunction(bindSingleMod, [vecMods, 0], null, true);
			}
		}

		private function prepareFolders():void
		{
			if (!BEZEL_FOLDER.isDirectory)
				BEZEL_FOLDER.createDirectory();
			if (!LATTICE_FOLDER.isDirectory)
				LATTICE_FOLDER.createDirectory();
		}

		private function loadSingleLib(libFiles:Vector.<String>, i:int):void
		{
			var newMod:SWFFile = new SWFFile(LIBS_FOLDER.resolvePath(libFiles[i]));
			newMod.load(successfulLibLoad, failedLibLoad, SWFFile.LIB_DOMAIN);
			if (i + 1 < libFiles.length)
			{
				FunctionDeferrer.deferFunction(loadSingleLib, [libFiles, i + 1], null, true);
			}
			else
			{
				_modsReloadedTimestamp = getTimer();
			}
		}

		private function loadLibs():void
		{
			var libFiles:Vector.<String> = new <String>[];
			if (!LIBS_FOLDER.exists)
			{
				logger.log("", "No libs folder found, not loading any libraries");
			}
			else
			{
				var fileList:Array = LIBS_FOLDER.getDirectoryListing();
				for (var f:int = 0; f < fileList.length; f++)
				{
					var fileName:String = fileList[f].name;
					// logger.log("loadMods", "Looking at " + fileName);
					if (fileName.substring(fileName.length - 4, fileName.length) == ".swf")
					{
						libFiles[libFiles.length] = fileName;
					}
				}

				waitingMods = progressTotal = libFiles.length;

				updateProgress(0, progressTotal);
				this.loadingStageTextField.text = LOADING_LIBS;
			}

			if (libFiles.length == 0)
			{
				FunctionDeferrer.deferFunction(this.loadMods, [], this, true);
			}
			else
			{
				FunctionDeferrer.hardDeferFunction(loadSingleLib, [libFiles, 0], null, true);
			}
		}

		// Assuming the file loaded, add the library to tracked mods and libs. Check compatibility. Check if the library has a coremod and add the patches if so.
		private function successfulLibLoad(libFile:SWFFile):void
		{
			var name:String;
			if (!(libFile.instance is BezelMod))
			{
				if ("MOD_NAME" in libFile.instance)
				{
					name = " '" + libFile.instance.MOD_NAME + "' ";
					logger.log("Compatibility", "Unknown type of SWF found. Is the mod" + name + "at '" + libFile.filePath + "' using the correct interface?");
				}
				else
				{
					name = libFile.filePath;
					logger.log("Compatibility", "Unknown type of SWF found at '" + name + "'");
				}
				libFile.unload();
			}
			else
			{
				var mod:BezelMod = BezelMod(libFile.instance);
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
						logger.log("Loader", "Mod '" + name + "' is already registered.");
						logger.log("Loader", "The first loaded '" + name + "' will be used over the one at " + libFile.filePath);
					}
					else
					{
						mods[name] = libFile;
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

			if (!(name in mods))
			{
				throw new Error("An error occurred while loading " + libFile.filePath + ".\nSee log file for details.");
			}

			reduceWaitingLibs();
			libs[libs.length] = name;
		}

		private function failedLibLoad(e:Event):void
		{
			logger.log("failedLoad", "Failed to load library: " + e.currentTarget.url);

			reduceWaitingMods();
		}

		private function reduceWaitingLibs():void
		{
			waitingMods--;
			updateProgress(progressTotal - waitingMods, progressTotal);
			if (waitingMods == 0)
			{
				FunctionDeferrer.deferFunction(this.loadMods, [], this, true);
			}
		}

		private function loadSingleMod(modFiles:Vector.<String>, i:int):void
		{
			var newMod:SWFFile = new SWFFile(MODS_FOLDER.resolvePath(modFiles[i]));
			newMod.load(successfulModLoad, failedModLoad);
			if (i + 1 < modFiles.length)
			{
				FunctionDeferrer.deferFunction(loadSingleMod, [modFiles, i + 1], null, true);
			}
			else
			{
				_modsReloadedTimestamp = getTimer();
			}
		}

		// Tries to load every .swf in /Mods/ directory as a mod
		private function loadMods():void
		{
			var modFiles:Vector.<String> = new <String>[];
			if (!MODS_FOLDER.exists)
			{
				logger.log("", "No mods folder found, not loading any mods");
			}
			else
			{
				var enabledMods:SettingManager = this.getSettingManager("Enabled Mods");

				var fileList:Array = MODS_FOLDER.getDirectoryListing();
				for (var f:int = 0; f < fileList.length; f++)
				{
					var fileName:String = fileList[f].name;
					// logger.log("loadMods", "Looking at " + fileName);
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
			}

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
				FunctionDeferrer.hardDeferFunction(loadSingleMod, [modFiles, 0], null, true);
			}
		}

		// Assuming the file loaded, add the mod to tracked mods. Check compatibility. Check if the mod has a coremod and add the patches if so.
		private function successfulModLoad(modFile:SWFFile):void
		{
			var name:String;
			if (!(modFile.instance is BezelMod))
			{
				if ("MOD_NAME" in modFile.instance)
				{
					name = " '" + modFile.instance.MOD_NAME + "' ";
					logger.log("Compatibility", "Unknown type of SWF found. Is the mod" + name + "at '" + modFile.filePath + "' using the correct interface?");
				}
				else
				{
					name = modFile.filePath;
					logger.log("Compatibility", "Unknown type of SWF found at '" + name + "'");
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
						logger.log("Loader", "Mod '" + name + "' is already registered.");
						logger.log("Loader", "The first loaded '" + name + "' will be used over the one at " + modFile.filePath);
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

		/**
		 * Checks whether a version of Bezel given is compatible with the current one
		 * @param requiredVersion The version to check
		 * @return Whether current Bezel version is compatible with the given version
		 */
		public static function bezelVersionCompatible(requiredVersion:String):Boolean
		{
			var bezelVer:Array = VERSION.split(".");
			var thisVer:Array = requiredVersion.split(".");
			if (bezelVer[0] != thisVer[0])
				return false;
			else
			{
				if (bezelVer[1] > thisVer[1])
					return true;
				else if (bezelVer[1] == thisVer[1])
				{
					return bezelVer[2] >= thisVer[2];
				}
			}

			return false;
		}

		private function failedModLoad(e:Event):void
		{
			logger.log("failedLoad", "Failed to load mod: " + e.currentTarget.url);

			reduceWaitingMods();
		}

		/**
		 * Gets a logger for the given mod ID
		 * @param id Mod ID
		 * @return Logger for the ID
		 */
		public function getLogger(id:String):Logger
		{
			return Logger.getLogger(id);
		}

		/**
		 * Gets a setting manager for the given mod ID
		 * @param id Mod ID
		 * @return Manager for the ID
		 */
		public function getSettingManager(id:String):SettingManager
		{
			return SettingManager.getManager(id);
		}

		/**
		 * Returns a mod's instance, if such a mod is loaded. Used for cross-mod interactions
		 * @param	modName Name of the mod to retrive
		 * @return  The mod loaded by the name "modName", or null if none exists
		 */
		public function getModByName(modName:String):Object
		{
			if (this.mods[modName])
				return this.mods[modName].instance;
			return null;
		}

		/**
		 * Returns the version formatted for display in a game version string. Probably unnecessary for anything except MainLoaders
		 * @return Formatted version string
		 */
		public static function prettyVersion():String
		{
			return 'Bezel v' + VERSION;
		}

		/**
		 * Unloads, then reloads every mod. Almost certainly should only be used by MainLoaders
		 */
		mainloader_only function reloadAllMods():void
		{
			FunctionDeferrer.clear();
			logger.log("eh_keyboardKeyDown", "Reloading all mods!");
			this._modsReloadedTimestamp = getTimer();
			SettingManager.unregisterAllManagers();
			if (mainLoader != null)
			{
				mainLoader.deregisterOption(SettingManager.MOD_KEYBIND, null);
			}
			for (var modName:String in mods)
			{
				var mod:SWFFile = mods[modName];
				if (libs.indexOf(modName) == -1)
				{
					mod.unload();
					for (var coremod:int = 0; coremod < coremods.length; coremod++)
					{
						if (coremods[coremod].name == modName)
						{
							delete coremods[coremod];
							break;
						}
					}
					this.removeChild(DisplayObject(mod.instance));
					delete mods[modName];
				}
			}
			loadMods();
		}

		private function doneModReload():void
		{
			bindModsAndLateRegisterSettingsAndKeybinds();
		}

		private function loadSingleCoremod(stream:FileStream, idx:int):void
		{
			if (idx < coremods.length)
			{
				var coremod:Object = coremods[idx];
				stream.writeUTF(coremod.name);
				stream.writeUTF(coremod.version);

				logger.log("doneModLoad", "Loading coremods for " + coremod.name);
				coremod.load(lattice);
				updateProgress(idx + 1, coremods.length);

				FunctionDeferrer.deferFunction(loadSingleCoremod, [stream, idx + 1], null, true);
			}
			else
			{
				loadingStageTextField.text = APPLYING_COREMODS;
				patchesApplied = 0;
				updateProgress(0, lattice.numberOfPatches);

				FunctionDeferrer.hardDeferFunction(lattice.apply, [], lattice, true);
			}
		}

		// After bezel loads mods from /Mods/ and aggregates all coremods, check if we need to reapply the coremods.
		// If we do, load them into Lattice, apply them, rebuild the modded swf.
		// Either Bezel sees that the coremods are all the same and skips calling Lattice (deferring onGameBuilt)
		// Or they are different and we call Lattice, which then raises REBUILD_DONE
		private function doneModLoad():void
		{
			var differentCoremods:Boolean = false;
			try
			{
				// We intentionally register this boolean later so that the MainLoader can see that we registered it, so make sure to catch the error if it occurs
				differentCoremods = manager.retrieveBoolean(ALWAYS_COREMOD_SETTING);
			}
			catch (e:*) {}

			differentCoremods = differentCoremods || this.coremods.length != this.prevCoremods.length;
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

				FunctionDeferrer.hardDeferFunction(loadSingleCoremod, [stream, 0], null, true);
			}
			else
			{
				FunctionDeferrer.hardDeferFunction(this.onGameBuilt, [null], this, false);
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
			if (mainLoader != null)
			{
				mainLoader.deregisterOption(SettingManager.MOD_KEYBIND, null);
			}
			for (var modName:String in mods)
			{
				var mod:SWFFile = mods[modName];
				mod.unload();
				delete mods[modName];
			}
			this.removeChildren();

			this.stage.addChild(this); // Reparent this to the stage
			this.stage.removeChild(DisplayObject(this.gameLoader.instance));

			clearEventListeners();
			this._gameObjects = null;
			this.mainLoader.cleanupForFullReload();
			this._mainLoader = null;
			this._keybindManager = null;
			this.lattice = null;
			Logger.clearLoggers();
			this.logger = null;
			this.coremods.length = 0;
			this.prevCoremods.length = 0;
			this.libs.length = 0;
			this.mainLoaderLoader.unload(true);
			this.gameLoader.unload();
			SettingManager.unregisterAllManagers();
			this.manager = null;
		}

		private function updateProgress(current:int, total:int):void
		{
			this.loadingProgressTextField.text = current + " / " + total;
			this.loadingProgressBar.scaleX = Number(current) / Number(total);
		}

		private const _listeners:Object = new Object();
		private const _weakListeners:Object = new Object();

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			var dict:Dictionary;
			var vect:Vector.<Boolean>;
			if (useWeakReference)
			{
				dict = _weakListeners[type] || (_weakListeners[type] = new Dictionary(true));
			}
			else
			{
				dict = _listeners[type] || (_listeners[type] = new Dictionary(true));
			}

			vect = dict[listener] || (dict[listener] = new <Boolean>[useCapture]);

			if (vect.length == 1 && vect[0] != useCapture)
			{
				vect[1] = useCapture;
			}

			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			var dict:Dictionary;
			var vect:Vector.<Boolean>;
			if (type in _listeners)
			{
				dict = _listeners[type] as Dictionary;
				if (listener in dict)
				{
					vect = dict[listener] as Vector.<Boolean>;
					if (vect[0] == useCapture)
					{
						vect.shift();
					}
					else if (vect.length == 2 && vect[1] == useCapture)
					{
						vect.pop();
					}

					if (vect.length == 0)
					{
						delete dict[listener];
					}
				}
			}
			if (type in _weakListeners)
			{
				dict = _weakListeners[type] as Dictionary;
				if (listener in dict)
				{
					vect = dict[listener] as Vector.<Boolean>;
					if (vect[0] == useCapture)
					{
						vect.shift();
					}
					else if (vect.length == 2 && vect[1] == useCapture)
					{
						vect.pop();
					}

					if (vect.length == 0)
					{
						delete dict[listener];
					}
				}
			}

			super.removeEventListener(type, listener, useCapture);
		}

		private function clearEventListeners():void
		{
			for (var type:String in _listeners)
			{
				for (var listener:Object in (_listeners[type] as Dictionary))
				{
					super.removeEventListener(type, listener as Function, true);
					super.removeEventListener(type, listener as Function, false);
				}
				delete _listeners[type];
			}
			for (type in _weakListeners)
			{
				for (listener in (_weakListeners[type] as Dictionary))
				{
					super.removeEventListener(type, listener as Function, true);
					super.removeEventListener(type, listener as Function, false);
				}
				delete _weakListeners[type];
			}
		}

		private static function doNothingFunction(...args):void {}
	}
}
