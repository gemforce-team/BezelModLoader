package Bezel.GCFW.Events
{
	import com.giab.games.gcfw.struct.PlayerProgressData;

	import flash.events.Event;

	public class LoadSaveEvent extends Event
	{
		private var _save:PlayerProgressData;

		/** The save that is being loaded */
		public function get save():PlayerProgressData
		{
			return _save;
		}

		public override function clone():Event
		{
			return new LoadSaveEvent(save, type, bubbles, cancelable);
		}

		public function LoadSaveEvent(save:PlayerProgressData, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			this._save = save;
		}
	}
}
