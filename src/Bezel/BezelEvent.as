package Bezel 
{
	import flash.errors.IllegalOperationError;
	/**
	 * ...
	 * @author Hellrage
	 */
	public class BezelEvent 
	{
		public static const GEM_INFO_PANEL_FORMED:String = "gemInfoPanelFormed";
		public static const INGAME_KEY_DOWN:String = "ingameKeyDown";
		
		public function BezelEvent() 
		{
			throw new IllegalOperationError("Illegal instantiation!");
		}
		
	}

}