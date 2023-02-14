package Bezel.GCCS.Events
{
	import com.giab.games.gccs.steam.struct.PlayerProgressData;

	import flash.events.Event;

	public class SaveSaveEvent extends Event
	{
		private var _save:PlayerProgressData;

		/** The save that is being saved */
		public function get save():PlayerProgressData
		{
			return _save;
		}

		public override function clone():Event
		{
			return new SaveSaveEvent(save, type, bubbles, cancelable);
		}

		public function SaveSaveEvent(save:PlayerProgressData, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			this._save = save;
		}
	}
}
