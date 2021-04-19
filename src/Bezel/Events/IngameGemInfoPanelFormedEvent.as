package Bezel.Events
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.events.Event;

	public class IngameGemInfoPanelFormedEvent extends Event
	{
		private var _eventArgs:Object;
		
		public function get eventArgs():Object 
		{
			return _eventArgs;
		}
	
		public function IngameGemInfoPanelFormedEvent(type:String, eventArgs:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
