package Bezel.GCCS 
{
	import Bezel.MainLoader;
	import Bezel.Bezel;
	/**
	 * ...
	 * @author piepie62
	 */
	public class GCCSBezel implements MainLoader
	{
		private var _main:Object;
		
		public function GCCSBezel() 
		{
		}
		
		public static const _MOD_NAME:String = "GCCS Bezel";
		
		public function get MOD_NAME():String
		{
			return _MOD_NAME;
		}
		
		public function loaderBind(bezel:Bezel, gameObjects:Object): void
		{
			// TODO: add objects to gameObjects
		}
		
		public function set main(value:Object):void 
		{
			_main = value;
		}
		
		public function get coremodInfo():Object 
		{
			return {"name": "GCCS_BEZEL_MOD_LOADER", "version": GCCSCoreMod.VERSION, "load": GCCSCoreMod.installHooks};
		}
		
	}

}
