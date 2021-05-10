package Bezel.Utils 
{
	import flash.events.KeyboardEvent;
	/**
	 * Represents a keybind for an action
	 * @author Chris
	 */
	public class Keybind 
	{
		private var _key:int;
		private var _ctrl:Boolean;
		private var _alt:Boolean;
		private var _shift:Boolean;
		
		public function get key():int { return _key; }
		public function get ctrl():Boolean { return _ctrl; }
		public function get alt():Boolean { return _alt; }
		public function get shift():Boolean { return _shift; }
		
		public function Keybind(key:int, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false) 
		{
			_key = key;
			_ctrl = ctrl;
			_alt = alt;
			_shift = shift;
		}
		
		/**
		 * Checks that this Keybind represents the same combination as the given argument
		 * @param	other Either a KeyboardEvent or a Keybind to check against
		 * @return True if other is a KeyboardEvent or a Keybind and the control, alt, shift, and keycode match. False otherwise
		 */
		public function matches(other:*):Boolean
		{
			if (other is KeyboardEvent)
			{
				var e:KeyboardEvent = other as KeyboardEvent;
				return (e.altKey == this.alt) && (e.ctrlKey == this.ctrl) && (e.shiftKey == this.shift) && (e.keyCode == this.key);
			}
			else if (other is Keybind)
			{
				var o:Keybind = other as Keybind;
				return (o.alt == this.alt) && (o.ctrl == this.ctrl) && (o.shift == this.shift) && (o.key == this.key);
			}
			
			return false;
		}
		
		public function toJSON(k):*
		{
			return {"key":this.key, "ctrl":this.ctrl, "alt":this.alt, "shift":this.shift};
		}
	}

}