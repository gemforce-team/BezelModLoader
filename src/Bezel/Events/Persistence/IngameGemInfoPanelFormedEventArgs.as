package Bezel.Events.Persistence 
{
	/**
	 * ...
	 * @author Chris
	 */
	public class IngameGemInfoPanelFormedEventArgs 
	{
		public var infoPanel:Object;
		public var gem:Object;
		public var numberFormatter:Object;
		
		public function IngameGemInfoPanelFormedEventArgs(infoPanel:Object, gem:Object, numberFormatter:Object) 
		{
			this.infoPanel = infoPanel;
			this.gem = gem;
			this.numberFormatter = numberFormatter;
		}
		
	}

}