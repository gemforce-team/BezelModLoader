package Bezel.GCFW.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.events.Event;
	import Bezel.BezelEvent;
	public class IngameRightClickOnSceneEvent extends Event
	{
		private var _eventArgs:Object;
		
		public function get eventArgs():Object 
		{
			return _eventArgs;
		}
	
		public function IngameRightClickOnSceneEvent(type:String, eventArgs:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}