package Bezel.GCCS.Events.Persistence
{
	import com.giab.games.gccs.steam.entity.Gem;
	import com.giab.games.gccs.steam.mcDyn.McInfoPanel;

	public class IngameGemInfoPanelFormedEventArgs
	{
		/** Info panel that is being created */
		public var infoPanel:McInfoPanel;

		/** Gem for which this info panel is being created */
		public var gem:Gem;

		/** Number formatter class */
		public var numberFormatter:Object;

		public function IngameGemInfoPanelFormedEventArgs(infoPanel:McInfoPanel, gem:Gem, numberFormatter:Object)
		{
			this.infoPanel = infoPanel;
			this.gem = gem;
			this.numberFormatter = numberFormatter;
		}
	}
}
