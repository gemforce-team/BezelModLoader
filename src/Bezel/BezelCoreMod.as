package Bezel
{
	import Bezel.Lattice.Lattice;
	
	/**
	 * ...
	 * @author Chris
	 */
	public interface BezelCoreMod extends BezelMod
	{
		function get COREMOD_VERSION():String;
		function loadCoreMod(lattice:Lattice):void;
	}
	
}