package Bezel
{
	/**
	 * ...
	 * @author Hellrage
	 */

	import Bezel.BezelEvent;
	import Bezel.GCCS.GCCSBezel;
	import Bezel.GCFW.GCFWBezel;
	import Bezel.Lattice.Lattice;
	import Bezel.Lattice.LatticeEvent;
	import Bezel.Logger;

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
	
	use namespace bezel_internal;

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .bind method to bind our class to the game
	public class Bezel extends MovieClip
	{
		public static const VERSION:String = "1.0.0";

		// Game objects, populated by the MainLoader
		private var gameObjects:Object;
		private var lattice:Lattice;
		private var _mainLoader:MainLoader;
		public function get mainLoader():MainLoader { return _mainLoader; }

		private var updateAvailable:Boolean;

		private var logger:Logger;
		private var mods:Object;

		private var waitingMods:uint;

		private var _modsReloadedTimestamp:int;
		
		public function get modsReloadedTimestamp():int
		{
			return _modsReloadedTimestamp;
		}

		private var game:SWFFile;
		private var initialLoad:Boolean;
		private var coremods:Array;
		private var prevCoremods:Array;
		
		private var loadingTextField:TextField;
		private static const loadingText:String = "Loading Mods...";

		public static const bezelFolder:File = File.applicationStorageDirectory.resolvePath("Bezel Mod Loader/");
		public static const toolsFolder:File = bezelFolder.resolvePath("tools/");
		public static const latticeFolder:File = bezelFolder.resolvePath("Lattice/");
		public static const coremodFile:File = bezelFolder.resolvePath("coremods.bzl");

		public static const modsFolder:File = File.applicationDirectory.resolvePath("Mods/");
		private static const gameConfig:File = File.applicationDirectory.resolvePath("game-file.txt");
        private static var _gameSwf:File;
		private static var _moddedSwf:File;
		
		public function get gameSwf(): File
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
		
		public function get moddedSwf(): File
		{
			if (_moddedSwf == null)
			{
				_moddedSwf = File.applicationDirectory.resolvePath(gameSwf.name.split('.').slice(0, -1).join('.') + "-modded.swf");
			}
			return _moddedSwf;
		}

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
			
			loadingTextField = new TextField();
			loadingTextField.selectable = false;
			loadingTextField.text = loadingText;
			loadingTextField.textColor = 0xFFFFFF;
			this.addChild(loadingTextField);

			this.initialLoad = true;

			// Application flow is controlled using events. There's a page on the wiki that outlines it
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_RELOAD, this.doneModReload);
			this.addEventListener(BezelEvent.BEZEL_DONE_MOD_LOAD, this.doneModLoad);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, this.onExit);

			this.logger = Logger.getLogger("Bezel");
			this.mods = new Object();

			this.logger.log("Bezel", "Bezel Mod Loader " + prettyVersion());

			if (!gameSwf.exists)
			{
				this.logger.log("Bezel", "Game file not found. Try removing game-file.txt, reinstalling the game, and reinstalling Bezel");
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
					var toolData:ByteArray = new tool["data"] as ByteArray;
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
			if (lattice.doesFileExist("com/giab/games/gcfw/Main.class.asasm"))
			{
				logger.log("Bezel", "GCFW main found, loading its coremods");
				this._mainLoader = new GCFWBezel();
				
				this.coremods[this.coremods.length] = this._mainLoader.coremodInfo;
			}
			else if (lattice.doesFileExist("com/giab/games/gccs/steam/Main.class.asasm"))
			{
				logger.log("Bezel", "GCCS main found, loading its coremods");
				this._mainLoader = new GCCSBezel();
				
				this.coremods[this.coremods.length] = this._mainLoader.coremodInfo;
			}
			else
			{
				logger.log("Bezel", "Game not recognized! All coremods and mods will have to handle themselves.");
				// Note: a main handling coremod should add a `bezel` field and an `initFromBezel` method that contains all the initialization the constructor would do
				// Coremods should be handled through MainLoader's coremodInfo instead of the normal coremod interface
			}

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
			game.instance.bezel = this;
			this.removeChild(this.loadingTextField);
			this.addChild(DisplayObject(game.instance));
			// Base game's init (main.initFromBezel())
			game.instance.initFromBezel();
			if (this.mainLoader != null)
			{
				this.gameObjects = new Object();
				this.mainLoader.loaderBind(this, game.instance, gameObjects);
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
			for each (var mod:BezelMod in mods)
			{
				mod.bind(this, this.gameObjects);
				this.logger.log("bindMods", "Bound mod: " + mod.MOD_NAME);
			}
		}

		private function prepareFolders(): void
		{
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
			
			this._modsReloadedTimestamp = getTimer();
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
				var mod:BezelMod = modFile.instance as BezelMod;
				name = mod.MOD_NAME;
				logger.log("successfulModLoad", "Loaded mod: " + name + " v" + mod.VERSION);
				if (!bezelVersionCompatible(mod.BEZEL_VERSION))
				{
					logger.log("Compatibility", "Bezel version is incompatible! Required: " + mod.BEZEL_VERSION);
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
						mods[name] = mod;
						this.addChild(DisplayObject(mod));

						if (this.initialLoad)
						{
							if (mod is MainLoader)
							{
								if (this.mainLoader != null)
								{
									logger.log("Bezel", "Multiple main loaders present! This is a fatal error. The two detected are " + this.mainLoader.MOD_NAME + " and " + mod.MOD_NAME);
									NativeApplication.nativeApplication.exit( -1);
								}
								else
								{
									this._mainLoader = mod as MainLoader;
									this.coremods[this.coremods.length] = this.mainLoader.coremodInfo;
								}
							}

							if (mod is BezelCoreMod)
							{
								var coremod:BezelCoreMod = mod as BezelCoreMod;
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
			if (waitingMods == 0)
			{
				dispatchEvent(new Event(this.initialLoad ? BezelEvent.BEZEL_DONE_MOD_LOAD : BezelEvent.BEZEL_DONE_MOD_RELOAD));
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
		bezel_internal static function prettyVersion(): String
		{
			return 'Bezel v' + VERSION;
		}

		/**
		 * Unloads, then reloads every mod. Almost certainly should only be used by MainLoaders
		 */
		bezel_internal function reloadAllMods(): void
		{
			logger.log("eh_keyboardKeyDown", "Reloading all mods!");
			this._modsReloadedTimestamp = getTimer();
			if (!(this.mainLoader is GCFWBezel) && !(this.mainLoader is GCCSBezel))
			{
				this._mainLoader = null;
			}
			for each (var mod:SWFFile in mods)
			{
				var name:String = mod.instance.MOD_NAME;
				mod.unload();
				delete mods[name];
			}
			this.gameObjects = null;
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
	}
}
