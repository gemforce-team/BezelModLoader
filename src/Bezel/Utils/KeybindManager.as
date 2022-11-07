package Bezel.Utils
{
	import Bezel.Bezel;
	import Bezel.Logger;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * Manages hotkeys for Bezel mods
	 * @author Chris
	 */
	public class KeybindManager
	{
		private static const HOTKEYS_FILE:File = Bezel.Bezel.BEZEL_FOLDER.resolvePath("hotkeys.json");

		private var _configuredHotkeys:Object;

		private function get configuredHotkeys():Object
		{
			if (_configuredHotkeys == null)
			{
				var hotkeysStream:FileStream = new FileStream();
				if (HOTKEYS_FILE.exists)
				{
					try
					{
						hotkeysStream.open(HOTKEYS_FILE, FileMode.READ);
						_configuredHotkeys = JSON.parse(hotkeysStream.readUTFBytes(hotkeysStream.bytesAvailable), reviver);
					}
					catch (e:Error)
					{
						Logger.getLogger("KeybindManager").log("configuredHotkeys", "Error reading hotkeys from disk, using default (empty)");
						_configuredHotkeys = new Object();
					}
					finally
							{
							hotkeysStream.close();
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

	public function KeybindManager() {}

	/**
	 * Registers a hotkey with this KeybindManager.
	 * @param	name Name of the hotkey to register
	 * @param	defaultVal Value to be returned from getHotkeyValue, if name is not already registered
	 * @param	description Longer-form description of what the keybind does, if necessary
	 */
	public function registerHotkey(name:String, defaultVal:Keybind, description:String = null):void
	{
		if (!(name in this.configuredHotkeys))
		{
			this.configuredHotkeys[name] = defaultVal;
			this.saveHotkeys();
		}
		var set :Function = function (val:Keybind):void
		{
			configuredHotkeys[name] = val;
			saveHotkeys();
		};
		var get :Function = function ():Keybind
		{
			return getHotkeyValue(name);
		};
		if (Bezel.Bezel.instance.mainLoader != null)
		{
			Bezel.Bezel.instance.mainLoader.registerKeybindForDisplay(name, set , get , description);
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
			stream.open(HOTKEYS_FILE, FileMode.WRITE);
			var data:String = JSON.stringify(this.configuredHotkeys, null, 2);
			var lines:Array = data.split('\n').slice(1, -1);
			for (var i:int = 0; i < lines.length - 1; i++)
			{
				lines[i] = (lines[i] as String).slice(0, -1);
			}
			lines.sort();

			stream.writeUTFBytes("{\n" + lines.join(",\n") + "\n}");
		}
		catch (e:Error)
		{
			Logger.getLogger("KeybindManager").log("saveHotkeys", "Could not save hotkey information " + e.message);
		}
		finally
				{
				stream.close();
	}
}

private static function reviver(k:*, v:*):*
{
	if (k != "")
	{
		if (v is String)
		{
			try
			{
				return new Keybind(v);
			}
			catch (e:ArgumentError)
			{
				Logger.getLogger("KeybindManager").log("reviver", e.message);
				return undefined;
			}
		}
	}
	else // root object
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
