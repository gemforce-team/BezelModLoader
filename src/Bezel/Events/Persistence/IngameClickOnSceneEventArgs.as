package Bezel.Events.Persistence 
{
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Chris
	 */
	public class IngameClickOnSceneEventArgs 
	{		
		public var continueDefault:Boolean;
		public var event:MouseEvent;
		public var mouseX:int;
		public var mouseY:int;
		public var buildingX:int;
		public var buildingY:int;
		
		public function IngameClickOnSceneEventArgs(continueDefault:Boolean, event:MouseEvent, mouseX:int, mouseY:int, buildingX:int, buildingY:int) 
		{
			this.continueDefault = continueDefault;
			this.event = event;
			this.mouseX = mouseX;
			this.mouseY = mouseY;
			this.buildingX = buildingX;
			this.buildingY = buildingY;
		}
		
	}

}