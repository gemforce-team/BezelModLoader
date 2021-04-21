package Bezel.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.Events.Persistence.IngameClickOnSceneEventArgs;
	import flash.events.Event;

	public class IngameClickOnSceneEvent extends Event
	{
		private var _eventArgs:IngameClickOnSceneEventArgs;
		
		public function get eventArgs():IngameClickOnSceneEventArgs 
		{
			return _eventArgs;
		}
	
		public function IngameClickOnSceneEvent(type:String, eventArgs:IngameClickOnSceneEventArgs, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
