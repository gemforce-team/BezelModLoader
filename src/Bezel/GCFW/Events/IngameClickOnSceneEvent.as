package Bezel.GCFW.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.GCFW.Events.Persistence.IngameClickOnSceneEventArgs;
	import flash.events.Event;

	public class IngameClickOnSceneEvent extends Event
	{
		private var _eventArgs:IngameClickOnSceneEventArgs;
		
		public function get eventArgs():IngameClickOnSceneEventArgs 
		{
			return _eventArgs;
		}
		
		public override function clone():Event
		{
			return new IngameClickOnSceneEvent(type, eventArgs, bubbles, cancelable);
		}
	
		public function IngameClickOnSceneEvent(type:String, eventArgs:IngameClickOnSceneEventArgs, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
