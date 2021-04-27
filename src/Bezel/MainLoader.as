package Bezel 
{
	
	/**
	 * Defines the interface of a main loader mod. Only one of these may be present per game. Having more is a hard error
	 * @author Chris
	 */
	public interface MainLoader extends BezelMod
	{
		/**
		 * Fills out gameObjects with data from the game
		 * @param	bezel The bezel instance loading the mod
		 * @param   mainGame The object loaded and instantiated from the game's SWF
		 * @param	gameObjects The object to fill with game object data
		 */
		function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object):void;
		/**
		 * Gets coremods in {name, version, load function} format.
		 * The load function should have the same signature as Bezel.BezelCoreMod.loadCoreMod
		 */
		function get coremodInfo():Object;
		/**
		 * Gets the value of a hotkey registered with registerHotkey.
		 * NOTE: main handler coremod should add a `bezel` field and an `initFromBezel` method that contains all the initialization the constructor normally would
		 * @param	name Name of the hotkey to retrieve
		 * @return Value currently registered with the MainLoader
		 */
		function getHotkeyValue(name:String):int;
		/**
		 * Registers a hotkey with the MainLoader.
		 * @param	name Name of the hotkey to register
		 * @param	defaultVal Value to be returned from getHotkeyValue, if name is not already registered
		 */
		function registerHotkey(name:String, defaultVal:int):void;
	}
}
