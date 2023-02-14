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

	/**
	 * Represents an SWF file on disk
	 * @author piepie62
	 */
	public class SWFFile
	{
		private static var mainLoaderDomain:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		private var loader:Loader;
		private var file:File;
		public var instance:Object;

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
		public function loadBytes(bytes:ByteArray, successCallback:Function, failureCallback:Function, intoMainLoaderDomain:Boolean = false):void
		{
			this.loader = new Loader();

			this.successfulLoadCallback = successCallback;
			this.failedLoadCallback = failureCallback;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSuccessfully);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);

			var context:LoaderContext;

			// The domain matters: if you load mods into the same domain as the game, they will stay loaded until you restart the entire flash application
			// There are three cases:
			// 1. This is the MainLoader. Load it into a known domain to enable the below two.
			// 2. This is the game. Game classes should be loaded into the MainLoader's ApplicationDomain (for type checking and anything else).
			// 3. This is a normal mod. Load it into a child domain of the MainLoader, allowing it to access the types from the game and the MainLoader

			if (intoMainLoaderDomain)
			{
				context = new LoaderContext(true, mainLoaderDomain);
			}
			else
			{
				context = new LoaderContext(true, new ApplicationDomain(mainLoaderDomain));
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
		public function load(successCallback:Function, failureCallback:Function, intoMainLoaderDomain:Boolean = false):void
		{
			if (!file.exists)
				throw new Error("SWF " + file.nativePath + " does not exist");

			var bytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();

			loadBytes(bytes, successCallback, failureCallback, intoMainLoaderDomain);
		}

		/**
		 * Unloads this SWF from memory.
		 * @param resetMainLoaderIfApplicable If true, and the instance is a MainLoader, the MainLoader ApplicationDomain will be reassigned when it's loaded again.
		 */
		public function unload(resetMainLoaderIfApplicable:Boolean = false):void
		{
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedSuccessfully);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			// Make sure the mod cleans up its event subscribers and resources
			if (this.instance is BezelMod)
			{
				this.instance.unload();
			}
			if (resetMainLoaderIfApplicable && this.instance is MainLoader)
			{
				mainLoaderDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
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
	}
}
