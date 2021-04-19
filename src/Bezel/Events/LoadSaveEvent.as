package Bezel.Events
{
    /**
	 * ...
	 * @author piepie62
	 */
	
	import flash.events.Event;

	public class LoadSaveEvent extends Event
	{

        public var save:Object;

		public function LoadSaveEvent(save:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);

            this.save = save;
		}
	}
}
