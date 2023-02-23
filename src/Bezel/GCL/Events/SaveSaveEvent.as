package Bezel.GCL.Events
{
	import com.giab.games.gcl.gs.entity.Player;

	import flash.events.Event;

	public class SaveSaveEvent extends Event
	{
		private var _save:Player;

		/** The save that is being saved */
		public function get save():Player
		{
			return _save;
		}

		public override function clone():Event
		{
			return new SaveSaveEvent(save, type, bubbles, cancelable);
		}

		public function SaveSaveEvent(save:Player, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			this._save = save;
		}
	}
}
