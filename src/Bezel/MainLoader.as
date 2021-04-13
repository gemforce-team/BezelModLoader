package Bezel 
{
	
	/**
	 * ...
	 * @author Chris
	 */
	public interface MainLoader 
	{
		/**
		 * Fills out gameObjects with data from the game. May be called twice
		 * @param	bezel The bezel instance loading the mod
		 * @param	gameObjects The object to fill with game object data
		 */
		function loaderBind(bezel:Bezel, gameObjects:Object):void;
		/**
		 * Sets the main game object from the game
		 */
		function set main(value:Object):void;
		/**
		 * Gets coremods in {name, version, load function} format
		 */
		function get coremodInfo():Object;
		/**
		 * Gets mod's name
		 */
		function get MOD_NAME():String;
	}
	
}