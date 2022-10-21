package Bezel.GCCS.Events.Persistence
{
	import com.giab.games.gccs.steam.mcDyn.McInfoPanel;
	import com.giab.games.gccs.steam.entity.Gem;

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
