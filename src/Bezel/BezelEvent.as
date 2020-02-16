package Bezel 
{
	import flash.errors.IllegalOperationError;
	/**
	 * ...
	 * @author Hellrage
	 */
	public class BezelEvent 
	{
		public static const INGAME_GEM_INFO_PANEL_FORMED:String = "ingameGemInfoPanelFormed";
		public static const INGAME_KEY_DOWN:String = "ingameKeyDown";
		public static const INGAME_PRE_RENDER_INFO_PANEL:String = "ingamePreRenderInfoPanel";
		public static const INGAME_CLICK_ON_SCENE:String = "ingameClickOnScene";
		public static const INGAME_RIGHT_CLICK_ON_SCENE:String = "ingameRightClickOnScene";
		
		public function BezelEvent() 
		{
			throw new IllegalOperationError("Illegal instantiation!");
		}
		
	}

}