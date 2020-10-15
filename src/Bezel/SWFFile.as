package Bezel 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	 
	internal class SWFFile 
	{
		private var loader:Loader;
		private var file:File;
		public var instance: Object;
		
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
			this.loader = null;
		}
		
		private function loadedSuccessfully(e:Event): void
		{
			this.instance = this.loader.content;
			successfulLoadCallback(this);
		}
	}

}
