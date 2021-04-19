package Bezel.Events
{
    /**
	 * ...
	 * @author piepie62
	 */
	
	import flash.events.Event;

	public class SaveSaveEvent extends Event
	{

        public var save:Object;

		public function SaveSaveEvent(save:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);

            this.save = save;
		}
	}
}
