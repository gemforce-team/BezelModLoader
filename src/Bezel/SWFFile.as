package Bezel
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.display.LoaderInfo;

	/**
	 * Represents an SWF file on disk
	 * @author piepie62
	 */
	public class SWFFile
	{
		private static var mainLoaderDomain:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		private static var libDomain:ApplicationDomain = new ApplicationDomain(mainLoaderDomain);
		private var loader:Loader;
		private var file:File;
		public var instance:Object;

		public static const MAINLOADER_DOMAIN:String = "mainloader";
		public static const MOD_DOMAIN:String = "mod";
		public static const LIB_DOMAIN:String = "lib";

		/**
		 * The path of the file as a string
		 */
		public function get filePath():String
		{
			return file.nativePath;
		}

		private var successfulLoadCallback:Function;
		private var failedLoadCallback:Function;

		public function SWFFile(file:File)
		{
			if (file == null)
				throw new ArgumentError("Tried to create a mod with no mod file!");
			this.file = file;
		}

		/**
		 * Loads a bytearray as this SWF.
		 * @param bytes ByteArray containing the SWF to load
		 * @param successCallback Function to call on load success. Should take an SWFFile argument.
		 * @param failureCallback Function to call on load fail. Should take an Event argument.
		 * @param intoMainLoaderDomain Where to load the file: into the main loader domain or its own. This should only be set to true for the main game loaded by Bezel.
		 */
		public function loadBytes(bytes:ByteArray, successCallback:Function, failureCallback:Function, domain:String = MOD_DOMAIN):void
		{
			this.loader = new Loader();

			this.successfulLoadCallback = successCallback;
			this.failedLoadCallback = failureCallback;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSuccessfully);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			loader.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, failedLoadCallback);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, failedLoadCallback);

			var context:LoaderContext;

			// The domain matters: if you load mods into the same domain as the game, they will stay loaded until you restart the entire flash application
			// There are three cases:
			// 1. This is the MainLoader. Load it into a known domain to enable the below two.
			// 2. This is the game. Game classes should be loaded into the MainLoader's ApplicationDomain (for type checking and anything else).
			// 3. This is a mod library. Load it into a child of the MainLoader and game, allowing it to access their types.
			// 4. This is a normal mod. Load it into a child domain of the library domain, allowing it to access the types from them, the game, and the MainLoader.

			if (domain == MAINLOADER_DOMAIN)
			{
				context = new LoaderContext(true, mainLoaderDomain);
			}
			else if (domain == LIB_DOMAIN)
			{
				context = new LoaderContext(true, libDomain);

				loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtLib, false, 0, true);
			}
			else if (domain == MOD_DOMAIN)
			{
				context = new LoaderContext(true, new ApplicationDomain(libDomain));

				loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtMod, false, 0, true);
			}
			else
			{
				throw new ArgumentError("Unknown domain '" + domain + "'");
			}
			context.checkPolicyFile = false;
			context.allowCodeImport = true;
			loader.loadBytes(bytes, context);
		}

		/**
		 * Loads the SWF from the disk.
		 * @param successCallback Function to call on load success. Should take an SWFFile argument.
		 * @param failureCallback Function to call on load fail. Should take an Event argument.
		 * @param intoMainLoaderDomain Where to load the file: into the main loader domain or its own. This should only be set to true for the main game loaded by Bezel.
		 */
		public function load(successCallback:Function, failureCallback:Function, domain:String = MOD_DOMAIN):void
		{
			if (!file.exists)
				throw new Error("SWF " + file.nativePath + " does not exist");

			var bytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();

			loadBytes(bytes, successCallback, failureCallback, domain);
		}

		/**
		 * Unloads this SWF from memory.
		 * @param resetMainLoaderIfApplicable If true, and the instance is a MainLoader, the MainLoader ApplicationDomain will be reassigned when it's loaded again.
		 */
		public function unload(resetMainLoaderIfApplicable:Boolean = false):void
		{
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedSuccessfully);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			this.loader.contentLoaderInfo.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, failedLoadCallback);
			this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, failedLoadCallback);
			// Make sure the mod cleans up its event subscribers and resources
			if (this.instance is BezelMod)
			{
				this.instance.unload();
			}
			if (resetMainLoaderIfApplicable && this.instance is MainLoader)
			{
				mainLoaderDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
				libDomain = new ApplicationDomain(libDomain);
			}
			// Stop all execution and unsubscribe events, let garbage collection occur
			this.instance = null;
			this.loader.unloadAndStop(true);
			this.loader = null;
			this.successfulLoadCallback = null;
			this.failedLoadCallback = null;
		}

		private function unloadWithoutUnload():void
		{
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedSuccessfully);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			this.loader.contentLoaderInfo.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, failedLoadCallback);
			this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, failedLoadCallback);
			// Make sure the mod cleans up its event subscribers and resources
			// if (this.instance is BezelMod)
			// {
			// this.instance.unload();
			// }
			// Stop all execution and unsubscribe events, let garbage collection occur
			this.instance = null;
			this.loader.unloadAndStop(true);
			this.loader = null;
			this.successfulLoadCallback = null;
			this.failedLoadCallback = null;
		}

		private function loadedSuccessfully(e:Event):void
		{
			this.instance = this.loader.content;
			successfulLoadCallback(this);
		}

		private function onUncaughtLib(e:UncaughtErrorEvent):void
		{
			if (e.error is Error)
			{
				onUncaught("Library", e);
			}
		}

		private function onUncaughtMod(e:UncaughtErrorEvent):void
		{
			if (e.error is Error)
			{
				onUncaught("Mod", e);
			}
		}

		private function onUncaught(type:String, e:UncaughtErrorEvent):void
		{
			var error:Error = e.error as Error;
			var logger:Logger = Bezel.Bezel.instance.getLogger("SWF Loader");

			var logMe:String = type + " ";
			try
			{
				logMe += "'" + ((e.target as LoaderInfo).content as BezelMod).MOD_NAME + "' ";
			}
			catch (e:*) {}

			logMe += "from " + filePath + " threw a " + error.name;
			if (error.errorID != 0)
			{
				logMe += " #" + error.errorID;
			}
			logMe += ": " + error.message + "\n" + error.getStackTrace();

			logger.log("onUncaughtMod", logMe);
			logger.log("onUncaughtMod", "Attempting to unload it...");

			try
			{
				(this.instance as BezelMod).unload();
			}
			catch (e:*) {}

			unloadWithoutUnload();

			e.preventDefault();
			e.stopImmediatePropagation();

			throw new Error(logMe);
		}
	}
}
