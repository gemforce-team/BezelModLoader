package Bezel.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.events.Event;
	import Bezel.BezelEvent;
	public class IngameNewSceneEvent extends Event
	{
		public function IngameNewSceneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
	}
}
