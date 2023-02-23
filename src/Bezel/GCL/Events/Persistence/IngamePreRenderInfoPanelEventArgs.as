package Bezel.GCL.Events.Persistence
{
	public class IngamePreRenderInfoPanelEventArgs
	{
		/** Whether the default game function should continue to be done after modded actions */
		public var continueDefault:Boolean;

		public function IngamePreRenderInfoPanelEventArgs(continueDefault:Boolean)
		{
			this.continueDefault = continueDefault;
		}
	}
}
