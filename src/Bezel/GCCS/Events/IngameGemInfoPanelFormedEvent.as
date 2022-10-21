package Bezel.GCCS.Events
{
	/**
	 * ...
	 * @author Hellrage
	 */

	import Bezel.GCCS.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
	import flash.events.Event;

	public class IngameGemInfoPanelFormedEvent extends Event
	{
		private var _eventArgs:IngameGemInfoPanelFormedEventArgs;

		public function get eventArgs():IngameGemInfoPanelFormedEventArgs
		{
			return _eventArgs;
		}

		public override function clone():Event
		{
			return new IngameGemInfoPanelFormedEvent(type, eventArgs, bubbles, cancelable);
		}

		public function IngameGemInfoPanelFormedEvent(type:String, eventArgs:IngameGemInfoPanelFormedEventArgs, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
