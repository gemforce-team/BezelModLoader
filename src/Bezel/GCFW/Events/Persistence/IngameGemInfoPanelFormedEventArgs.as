package Bezel.GCFW.Events.Persistence 
{
	import com.giab.games.gcfw.mcDyn.McInfoPanel;
	import com.giab.games.gcfw.entity.Gem;

	/**
	 * ...
	 * @author Chris
	 */
	public class IngameGemInfoPanelFormedEventArgs 
	{
		public var infoPanel:McInfoPanel;
		public var gem:Gem;
		public var numberFormatter:Object;
		
		public function IngameGemInfoPanelFormedEventArgs(infoPanel:McInfoPanel, gem:Gem, numberFormatter:Object) 
		{
			this.infoPanel = infoPanel;
			this.gem = gem;
			this.numberFormatter = numberFormatter;
		}
		
	}

}
