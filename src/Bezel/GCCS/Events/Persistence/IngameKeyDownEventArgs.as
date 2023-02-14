package Bezel.GCCS.Events.Persistence
{
	import flash.events.KeyboardEvent;

	public class IngameKeyDownEventArgs
	{
		/** The original KeyboardEvent */
		public var event:KeyboardEvent;

		/** Whether the default game function should continue to be done after modded actions */
		public var continueDefault:Boolean;

		public function IngameKeyDownEventArgs(event:KeyboardEvent, continueDefault:Boolean)
		{
			this.event = event;
			this.continueDefault = continueDefault;
		}
	}
}
