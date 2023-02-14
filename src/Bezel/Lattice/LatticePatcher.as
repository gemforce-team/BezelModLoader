package Bezel.Lattice
{
	import com.cff.anebe.ir.ASClass;

	/**
	 * A higher level view of Lattice patching. Allows manipulating bytecode directly instead of through text.
	 * @author Chris
	 */
	public interface LatticePatcher
	{
		/**
		 * Called by Lattice after registering this Patcher with it.
		 * @param clazz The class requested to patch with this class.
		 */
		function patchClass(clazz:ASClass):void;
	}
}
