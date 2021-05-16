package Bezel.Events
{
    /**
	 * ...
	 * @author piepie62
	 */
	
	import flash.events.Event;

	public class SaveSaveEvent extends Event
	{
		
		private var _save:Object;

        public function get save():Object
		{
			return _save;
		}
		
		public override function clone():Event
		{
			return new SaveSaveEvent(save, type, bubbles, cancelable);
		}

		public function SaveSaveEvent(save:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);

            this._save = save;
		}
	}
}
