package Bezel 
{
	import flash.errors.IllegalOperationError;
	/**
	 * ...
	 * @author Hellrage
	 */
	public class BezelEvent 
	{
		internal static const BEZEL_DONE_MOD_RELOAD:String = "bezelDoneReload";
		internal static const BEZEL_DONE_MOD_LOAD:String = "bezelDoneModLoad";
		
		public function BezelEvent() 
		{
			throw new IllegalOperationError("Illegal instantiation!");
		}
		
	}

}
