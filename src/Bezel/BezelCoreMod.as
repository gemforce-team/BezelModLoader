package Bezel
{
	import Bezel.Lattice.Lattice;
	
	/**
	 * Defines the interface of a coremod. Coremods can perform assembly edits to the game using Lattice
	 * @author Chris
	 */
	public interface BezelCoreMod extends BezelMod
	{
		/**
		 * The version of the coremod
		 */
		function get COREMOD_VERSION():String;
		/**
		 * Registers all coremod changes with Lattice
		 */
		function loadCoreMod(lattice:Lattice):void;
	}
	
}