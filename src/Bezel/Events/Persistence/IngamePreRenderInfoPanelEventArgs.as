package Bezel.Events.Persistence 
{
	/**
	 * ...
	 * @author Chris
	 */
	public class IngamePreRenderInfoPanelEventArgs 
	{
		public var continueDefault:Boolean;
		
		public function IngamePreRenderInfoPanelEventArgs(continueDefault:Boolean) 
		{
			this.continueDefault = continueDefault;
		}
		
	}

}