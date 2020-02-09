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
		public static const KEYBOARD_KEY_DOWN:String = "keyboardKeyDown";
		
		public function BezelEvent() 
		{
			throw new IllegalOperationError("Illegal instantiation!");
		}
		
	}

}