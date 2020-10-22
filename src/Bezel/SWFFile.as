package Bezel 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import Bezel.Utils.CCITT16;
	 
	internal class SWFFile 
	{
		private var loader:Loader;
		private var file:File;
		public var instance:Object;

		private var _hash:uint;

		public function get hash():uint
		{
			return _hash;
		}
		
		private var successfulLoadCallback:Function;
		private var failedLoadCallback:Function;
		
		public function SWFFile(file:File) 
		{
			if (file == null || !file.exists)
				throw new ArgumentError("Tried to create a mod with no mod file!");
			this.file = file;
			this.loader = new Loader();
		}
		
		public function load(successCallback:Function, failureCallback:Function): void
		{
			this.successfulLoadCallback = successCallback;
			this.failedLoadCallback = failureCallback;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSuccessfully);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			var bytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
			this._hash = CCITT16.computeDigest(bytes);
			var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			context.checkPolicyFile = false;
			context.allowCodeImport = true;
			loader.loadBytes(bytes, context);
		}
		
		public function unload(): void
		{
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedSuccessfully);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failedLoadCallback);
			this.loader.unloadAndStop(false);
			this.instance.unload();
			this.instance = null;
		}
		
		private function loadedSuccessfully(e:Event): void
		{
			this.instance = this.loader.content;
			successfulLoadCallback(this);
		}
	}

}
