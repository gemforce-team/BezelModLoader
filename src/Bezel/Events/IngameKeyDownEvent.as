package Bezel.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.Events.Persistence.IngameKeyDownEventArgs;
	import flash.events.Event;

	public class IngameKeyDownEvent extends Event
	{
		private var _eventArgs:IngameKeyDownEventArgs;
		
		public function get eventArgs():IngameKeyDownEventArgs 
		{
			return _eventArgs;
		}
	
		public function IngameKeyDownEvent(type:String, eventArgs:IngameKeyDownEventArgs, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
