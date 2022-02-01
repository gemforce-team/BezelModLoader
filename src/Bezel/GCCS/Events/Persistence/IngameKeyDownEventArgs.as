package Bezel.GCCS.Events.Persistence 
{
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Chris
	 */
	public class IngameKeyDownEventArgs 
	{
		public var event:KeyboardEvent;
		public var continueDefault:Boolean;
		
		public function IngameKeyDownEventArgs(event:KeyboardEvent, continueDefault:Boolean) 
		{
			this.event = event;
			this.continueDefault = continueDefault;
		}
		
	}

}