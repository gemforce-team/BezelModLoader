package Bezel.GCL.Events.Persistence
{
	import flash.events.MouseEvent;

	public class IngameClickOnSceneEventArgs
	{
		/** Whether the default game function should continue to be done after modded actions */
		public var continueDefault:Boolean;

		/** Original event that the game would receive */
		public var event:MouseEvent;

		/** X value of the mouse on the screen */
		public var mouseX:int;

		/** Y value of the mouse on the screen */
		public var mouseY:int;

		/** X index of the building the mouse would be over */
		public var buildingX:int;

		/** Y index of the building the mouse would be over */
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
