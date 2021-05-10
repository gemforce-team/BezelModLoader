package Bezel.Utils 
{
	import Bezel.Bezel;
	import Bezel.Logger;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.ui.Keyboard;
	/**
	 * Manages hotkeys for Bezel mods
	 * @author Chris
	 */
	public class KeybindManager 
	{
		protected static const hotkeysFile:File = Bezel.Bezel.bezelFolder.resolvePath("hotkeys.json");
		
		private var _configuredHotkeys:Object;
		
		private function get configuredHotkeys():Object
		{
			if (_configuredHotkeys == null)
			{
				var hotkeysStream:FileStream = new FileStream();
				if (hotkeysFile.exists)
				{
					try
					{
						hotkeysStream.open(hotkeysFile, FileMode.READ);
						_configuredHotkeys = JSON.parse(hotkeysStream.readUTFBytes(hotkeysStream.bytesAvailable), reviver);
						hotkeysStream.close();
					}
					catch (e:Error)
					{
						Logger.getLogger("KeybindManager").log("configuredHotkeys", "Error reading hotkeys from disk, using default (empty)");
						_configuredHotkeys = new Object();
					}
				}
				else
				{
					_configuredHotkeys = new Object();
					this.saveHotkeys();
				}
			}
			return _configuredHotkeys;
		}
		
		public function KeybindManager() 
		{
		}
		
		/**
		 * Registers a hotkey with this KeybindManager.
		 * @param	name Name of the hotkey to register
		 * @param	defaultVal Value to be returned from getHotkeyValue, if name is not already registered
		 */
		public function registerHotkey(name:String, defaultVal:Keybind):void
		{
			if (!(name in this.configuredHotkeys))
			{
				this.configuredHotkeys[name] = defaultVal;
				this.saveHotkeys();
			}
		}
		
		/**
		 * Gets the value of a hotkey registered with registerHotkey.
		 * @param	name Name of the hotkey to retrieve
		 * @return Value currently registered with the MainLoader
		 */
		public function getHotkeyValue(name:String):Keybind
		{
			return this.configuredHotkeys[name];
		}
		
		private function saveHotkeys():void
		{
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(hotkeysFile, FileMode.WRITE);
				stream.writeUTFBytes(JSON.stringify(this.configuredHotkeys, null, 2));
				stream.close();
			}
			catch (e:Error)
			{
				Logger.getLogger("KeybindManager").log("saveHotkeys", "Could not save hotkey information");
			}
		}
		
		private static function reviver(k:*, v:*):*
		{
			if (k != "" && v is Object)
			{
				var keyValue:int;
				if (!(v["key"] is String || v["key"] is Number) ||
					!(v["ctrl"] is Boolean) ||
					!(v["alt"] is Boolean) ||
					!(v["shift"] is Boolean))
				{
					Logger.getLogger("KeybindManager").log("reviver", "Could not parse key '" + k + "'. Discarding it!");
					return undefined;
				}
				if (v["key"] is String)
				{
					if (v["key"] in Keyboard && Keyboard[v["key"]] is uint)
					{
						keyValue = Keyboard[v["key"]];
					}
					else
					{
						Logger.getLogger("KeybindManager").log("reviver", "Could not find key value for string '" + v["key"] + "'");
						keyValue = 0;
					}
				}
				else
				{
					keyValue = v["key"];
				}
				return new Keybind(v["key"], v["ctrl"], v["alt"], v["shift"]);
			}
			
			if (k == "")
			{
				for (var item:String in v)
				{
					if (!(v[item] is Keybind))
					{
						Logger.getLogger("KeybindManager").log("reviver", "Unsupported configuration found for '" + item + "'. Discarding it");
						delete v[item];
					}
				}
			}
			return v;
		}
	}

}