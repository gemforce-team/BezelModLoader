package Bezel.Events 
{
	/**
	 * ...
	 * @author piepie62
	 */
	
	import flash.events.Event;

	public class IngameNewSceneEvent extends Event
	{
		public function IngameNewSceneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
	}
}
