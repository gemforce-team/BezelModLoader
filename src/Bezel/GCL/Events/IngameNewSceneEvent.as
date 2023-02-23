package Bezel.GCL.Events
{
	import flash.events.Event;

	public class IngameNewSceneEvent extends Event
	{

		public override function clone():Event
		{
			return new IngameNewSceneEvent(type, bubbles, cancelable);
		}

		public function IngameNewSceneEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
