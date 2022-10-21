package Bezel
{
	/**
	 * Defines the interface of a main loader mod. Only one of these may be present per game, enforced by the filesystem.
	 * The MainLoader must be at "game executable folder"/Bezel/MainLoader.swf
	 * The MainLoader is only unloaded on full reloads, which also reload the game and may be triggered by the MainLoader calling
	 * Bezel.Bezel.triggerFullReload. All necessary cleanup should happen in cleanupForFullReload.
	 * @author Chris
	 */
	public interface MainLoader
	{
		/**
		 * Fills out gameObjects with data from the game. Will only be called on initial load
		 * @param	bezel The bezel instance loading the mod
		 * @param   mainGame The object loaded and instantiated from the game's SWF
		 * @param	gameObjects The object to fill with game object data
		 */
		function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object):void;

		/**
		 * Gets coremods in {name, version, load function} format.
		 * The load function should have the same signature as Bezel.BezelCoreMod.loadCoreMod
		 * NOTE: MainLoader coremod should add a `bezel` field and an `initFromBezel` method that contains all the initialization the constructor
		 * 		 normally would to the game's main class
		 */
		function get coremodInfo():Object;

		/**
		 * Gets the fully qualified main class name of the game this MainLoader supports. Can be used for sanity checking and multi-game mods.
		 */
		function get gameClassFullyQualifiedName():String;

		/**
		 * Adds boolean options to be displayed on an in-game screen. Should very likely be called through SettingManager, not directly.
		 * @param	mod Origin mod name
		 * @param	name Option name
		 * @param	onSet Function to be called when an option is set. Takes the new value as a parameter.
		 * @param	currentValue Function that gets the current value of the option. Must take no parameters and return a Boolean.
		 * @param	description If more text is able to be displayed than the option name, this will be displayed
		 */
		function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String = null):void;

		/**
		 * Adds floating-point range options to be displayed on an in-game screen. Should very likely be called through SettingManager, not directly.
		 * @param	mod Origin mod name
		 * @param	name Option name
		 * @param	min Option minimum value
		 * @param	max Option maximum value
		 * @param	step Option step value (can be used to limit values to integers with value 1). Must be positive and nonzero.
		 * @param	onSet Function to be called when an option is set. Takes the new value as a parameter.
		 * @param	currentValue Function that gets the current value of the option. Must take no parameters and return a Number.
		 * @param	description If more text is able to be displayed than the option name, this will be displayed
		 */
		function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String = null):void;

		/**
		 * Adds floating-point range options to be displayed on an in-game screen. Should very likely be called through SettingManager, not directly.
		 * @param	mod Origin mod name
		 * @param	name Option name
		 * @param	min Option minimum value
		 * @param	max Option maximum value
		 * @param	onSet Function to be called when an option is set. Takes the new value as a parameter.
		 * @param	currentValue Function that gets the current value of the option. Must take no parameters and return a Number.
		 * @param	description If more text is able to be displayed than the option name, this will be displayed
		 */
		function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void;

		/**
		 * Adds floating-point range options to be displayed on an in-game screen. Should very likely be called through SettingManager, not directly.
		 * @param	mod Origin mod name
		 * @param	name Option name
		 * @param	min Option minimum value
		 * @param	max Option maximum value
		 * @param	step Option step value (can be used to limit values to integers with value 1). Must be positive and nonzero.
		 * @param	onSet Function to be called when an option is set. Takes the new value as a parameter.
		 * @param	currentValue Function that gets the current value of the option. Must take no parameters and return a Number.
		 * @param	description If more text is able to be displayed than the option name, this will be displayed
		 */
		function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void;

		/**
		 * Adds keybind options to be displayed on an in-game screen. Should very likely be called through KeybindManager, not directly.
		 * @param	name Keybind name
		 * @param	onSet Function to be called when an option is set. Takes the new value (as a Bezel.Utils.Keybind) as a parameter.
		 * @param	currentValue Function that gets the current value of the option. Must take no parameters and return a Keybind.
		 * @param	description If more text is able to be displayed than the option name, this will be displayed
		 */
		function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String = null):void;

		/**
		 * Deregisters one or all options from a given mod from in-game display. Should very likely be called through SettingManager, not directly, and only during or after the bind phase.
		 * @param	mod Mod origin name, or "Keybinds" for a keybind
		 * @param	name Option name (or null to deregister all)
		 */
		function deregisterOption(mod:String, name:String):void;

		/**
		 * Cleans up anything necessary for a full reload. This may need to include changing game state, as the game is unloaded too!
		 * Note that this should only ever be called if Bezel.Bezel.reloadAllMods is called; any mod that calls this is asking for things to break.
		 */
		function cleanupForFullReload():void;
	}
}
