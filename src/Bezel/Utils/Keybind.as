package Bezel.Utils
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

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
		private var _stringRep:String;

		/**
		 * The key (as in flash.ui.Keyboard)
		 */
		public function get key():int
		{
			return _key;
		}

		/**
		 * Whether control is down or not
		 */
		public function get ctrl():Boolean
		{
			return _ctrl;
		}

		/**
		 * Whether alt is down or not
		 */
		public function get alt():Boolean
		{
			return _alt;
		}

		/**
		 * Whether shift is down or not
		 */
		public function get shift():Boolean
		{
			return _shift;
		}

		/**
		 * Constructs a Keybind that represents the given sequence
		 * @param sequence A string in the form "[modifiers]+key". Examples: "ctrl+f", "f", "shift+alt+ctrl+f". Exactly one non-modifier key must be specified.
		 * Note that this non-modifier key must be specified as the case-insensitive name of a property of flash.ui.Keyboard, such as "NUMpad_0"
		 * @return Keybind that represents the given sequence
		 * @throws ArgumentError if the given sequence is invalid
		 */
		public function Keybind(sequence:String)
		{
			if (sequence == null)
			{
				throw new ArgumentError("Keybind sequence must not be null");
			}

			var components:Array = sequence.split('+');

			for (var i:int = 0; i < components.length; i++)
			{
				components[i] = components[i].toUpperCase();
			}

			for each (var component:String in components)
			{
				if (component == "CTRL")
				{
					_ctrl = true;
				}
				else if (component == "ALT")
				{
					_alt = true;
				}
				else if (component == "SHIFT")
				{
					_shift = true;
				}
				else
				{
					if (_key != 0)
					{
						throw new ArgumentError("More than one key provided");
					}
					else
					{
						if (component in Keyboard && Keyboard[component] is uint)
						{
							_key = Keyboard[component];
						}
						else
						{
							throw new ArgumentError("Key '" + component + "' was not found");
						}
					}
				}
			}

			if (_key == 0)
			{
				throw new ArgumentError("No key provided");
			}

			_stringRep = sequence;
		}

		/**
		 * Checks that this Keybind represents the same combination as the given argument
		 * @param other KeyboardEvent or Keybind to check against
		 * @return True if other is a KeyboardEvent or a Keybind and the control, alt, shift, and keycode match. False if they don't
		 * @throws ArgumentError if other is not a KeyboardEvent or a Keybind
		 */
		public function matches(other:*):Boolean
		{
			var e:KeyboardEvent;
			if (other is KeyboardEvent)
			{
				e = other as KeyboardEvent;
				return (e.altKey == this.alt) && (e.ctrlKey == this.ctrl) && (e.shiftKey == this.shift) && (e.keyCode == this.key);
			}
			else if (other is Keybind)
			{
				var o:Keybind = other as Keybind;
				return (o.alt == this.alt) && (o.ctrl == this.ctrl) && (o.shift == this.shift) && (o.key == this.key);
			}
			else
			{
				throw new ArgumentError("Bezel.Utils.Keybind tried to match against a " + getQualifiedClassName(other));
			}

			return false;
		}

		public function toJSON(k:*):*
		{
			return this._stringRep;
		}

		public function toString():String
		{
			return this._stringRep;
		}
	}
}
