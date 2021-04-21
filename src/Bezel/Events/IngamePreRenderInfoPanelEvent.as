package Bezel.Events 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.Events.Persistence.IngamePreRenderInfoPanelEventArgs;
	import flash.events.Event;

	public class IngamePreRenderInfoPanelEvent extends Event
	{
		private var _eventArgs:IngamePreRenderInfoPanelEventArgs;
		
		public function get eventArgs():IngamePreRenderInfoPanelEventArgs 
		{
			return _eventArgs;
		}
	
		public function IngamePreRenderInfoPanelEvent(type:String, eventArgs:IngamePreRenderInfoPanelEventArgs, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this._eventArgs = eventArgs;
		}
	}
}
