package Bezel.GCL.Events
{
	import com.giab.games.gcl.gs.entity.Player;

	import flash.events.Event;

	public class LoadSaveEvent extends Event
	{
		private var _save:Player;

		/** The save that is being loaded */
		public function get save():Player
		{
			return _save;
		}

		public override function clone():Event
		{
			return new LoadSaveEvent(save, type, bubbles, cancelable);
		}

		public function LoadSaveEvent(save:Player, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			this._save = save;
		}
	}
}
