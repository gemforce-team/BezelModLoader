package Bezel 
{
	/**
	 * ...
	 * @author piepie62
	 */
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	 
	public class SWFFile
	{
		private static var mainLoaderDomain:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		private var loader:Loader;
		private var file:File;
		public var instance:Object;
		
		public function get filePath(): String
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
		
		public function load(successCallback:Function, failureCallback:Function, intoMainLoaderDomain:Boolean = false): void
		{
			if (!file.exists)
				throw new Error("SWF " + file.nativePath + " does not exist");

			this.loader = new Loader();

			this.successfulLoadCallback = successCallback;
			this.failedLoadCallback = failureCallback;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSuccessfully);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			var bytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
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
		
		public function unload(resetMainLoaderIfApplicable:Boolean = false): void
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
			this.loader.unloadAndStop(true);
			this.instance = null;
			this.loader = null;
		}
		
		private function loadedSuccessfully(e:Event): void
		{
			this.instance = this.loader.content;
			successfulLoadCallback(this);
		}
	}

}
