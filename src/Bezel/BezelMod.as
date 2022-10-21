package Bezel
{

	/**
	 * Defines the interface of a normal mod
	 * @author Chris
	 */
	public interface BezelMod
	{
		/**
		 * Gets mod's version
		 */
		function get VERSION():String;

		/**
		 * Gets mod's name
		 */
		function get MOD_NAME():String;

		/**
		 * Gets supported Bezel version
		 */
		function get BEZEL_VERSION():String;

		/**
		 * Binds the any required game data to the mod.
		 * Called after all other mods and the game are loaded.
		 * Other mods may not yet be bound when this is called.
		 * @param	bezel The instance of Bezel.Bezel loading the mod
		 * @param	gameObjects A container of objects set up by the game's Bezel.MainLoader that may be useful to the mod
		 * @return  this
		 */
		function bind(bezel:Bezel, gameObjects:Object):void;
		function unload():void;
	}

}
