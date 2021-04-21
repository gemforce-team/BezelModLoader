package Bezel.Events
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
	import flash.events.Event;

	public class IngameGemInfoPanelFormedEvent extends Event
	{
		private var _eventArgs:IngameGemInfoPanelFormedEventArgs;
		
		public function get eventArgs():IngameGemInfoPanelFormedEventArgs 
		{
			return _eventArgs;
		}
	
		public function IngameGemInfoPanelFormedEvent(type:String, eventArgs:IngameGemInfoPanelFormedEventArgs, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
