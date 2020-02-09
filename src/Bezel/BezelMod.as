package Bezel 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.*;
	import flash.filesystem.*;
	import Bezel.Logger;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.*;
	 
	internal class BezelMod 
	{
		private var loader:Loader;
		private var fileName:String;
		public var instance: Object;
		
		private var successfulLoadCallback:Function;
		
		public function BezelMod(fileName:String) 
		{
			if (fileName == null || fileName == "")
				throw new ArgumentError("Tried to create a mod with no mod file!");
			this.fileName = fileName;
			this.loader = new Loader();
		}
		
		public function load(successCallback:Function, failureCallback:Function): void
		{
			this.successfulLoadCallback = successCallback;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSuccessfully);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failureCallback);
			loader.load(new URLRequest(this.fileName), new LoaderContext(false, ApplicationDomain.currentDomain));
		}
		
		private function loadedSuccessfully(e:Event): void
		{
			this.instance = this.loader.content;
			successfulLoadCallback(this);
		}
	}

}