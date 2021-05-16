package Bezel 
{
	import flash.errors.IllegalOperationError;
	/**
	 * Bezel lifetime events. Shouldn't be used by anything except Bezel.Bezel
	 * @author Hellrage
	 */
	internal class BezelEvent 
	{
		internal static const BEZEL_DONE_MOD_RELOAD:String = "bezelDoneReload";
		internal static const BEZEL_DONE_MOD_LOAD:String = "bezelDoneModLoad";
		
		public function BezelEvent() 
		{
			throw new IllegalOperationError("Illegal instantiation!");
		}
		
	}

}
