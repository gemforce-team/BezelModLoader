package Bezel.Utils
{

    import flash.errors.IllegalOperationError;
    import Bezel.Bezel;
    import flash.utils.Dictionary;

    import Bezel.bezel_internal;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.events.Event;
    import flash.desktop.NativeApplication;

    use namespace bezel_internal;

    /**
     * Manages settings for Bezel mods. Currently only works for numerical and boolean settings
     * @author Chris
     */
    public class SettingManager
    {
        public static const SETTINGS_FOLDER:File = Bezel.Bezel.bezelFolder.resolvePath("Mod Settings");
     
        private static var _managers:Dictionary;

        private static function get managers():Dictionary
        {
            if (_managers == null)
            {
                _managers = new Dictionary();
                NativeApplication.nativeApplication.addEventListener(Event.EXITING, unregisterAllManagers);
            }
            return _managers;
        }

        private var id:String;

        private var _settings:Object;

        private function get file():File
        {
            return SETTINGS_FOLDER.resolvePath(id + ".json");
        }

        private function get settings():Object
        {
            if (_settings == null)
            {
                if (file.exists)
                {
                    var stream:FileStream = new FileStream();
                    stream.open(this.file, FileMode.READ);
                    var data:String = stream.readUTFBytes(stream.bytesAvailable);
                    stream.close();
                    _settings = JSON.parse(data);
                }
                else
                {
                    _settings = new Object();
                }
            }
            return _settings;
        }

        // Cannot be called
		public function SettingManager(identifier:String, _blocker:SettingManagerInstantiationBlocker)
		{
            if (!SETTINGS_FOLDER.exists)
            {
                SETTINGS_FOLDER.createDirectory();
            }
			if (identifier == null || identifier == "")
				throw new ArgumentError("SettingManager identifier can't be null or empty");
			if (identifier in managers || _blocker == null)
				throw new IllegalOperationError("Constructor should only be called by getLogger! Get your logger instance that way");
			this.id = identifier;
		}

        // Used internally to save all configs
        bezel_internal static function unregisterAllManagers(... args):void
        {
            for each (var manager:SettingManager in _managers)
            {
                if (manager._settings != null)
                {
                    manager.file.deleteFile();
                    var stream:FileStream = new FileStream();
                    stream.open(manager.file, FileMode.WRITE);
                    stream.writeUTFBytes(JSON.stringify(manager._settings))
                    stream.close();
                }
            }

            _managers = null;

            NativeApplication.nativeApplication.removeEventListener(Event.EXITING, unregisterAllManagers);
        }
		
		/**
		 * Get an instance of a setting manager that writes to the standardized Bezel settings
		 * @param	identifier Name to use in the log file
		 * @return SettingManager for the given identifier
		 */
		public static function getManager(identifier:String): SettingManager
		{
			if (identifier == null || identifier == "")
				throw new ArgumentError("SettingManager identifier can't be null or empty");
		
			if (identifier in managers)
				return managers[identifier];
			else
			{
				managers[identifier] = new SettingManager(identifier, new SettingManagerInstantiationBlocker());
				//writeLog("Logger", "getLogger", "Created a new logger: " + identifier);
				return managers[identifier];
			}
		}

        /**
         * Registers a boolean setting to be managed by Bezel's standard settings
         * @param name Name of the setting
         * @param onSet Function to be called when an option is set. Takes the new value as a parameter.
         * @param defaultVal Default value of the setting
         */
        public function registerBoolean(name:String, onSet:Function, defaultVal:Boolean, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set:Function = function(newVal:Boolean):void
            {
                settings[name] = newVal;
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get:Function = function():Boolean
            {
                return settings[name];
            };
            Bezel.Bezel.instance.mainLoader.registerBooleanForDisplay(id, name, set, get, description);
        }

        /**
         * Retrieves the value of a boolean setting managed by Bezel's standard settings
         * @param name Name of the setting
         * @return Value of the boolean
         */
        public function retrieveBoolean(name:String):Boolean
        {
            if (!(name in settings))
            {
                throw new ArgumentError("\"" + name + "\" is not a registered setting for mod " + id);
            }
            else
            {
                return settings[name] as Boolean;
            }
        }

        /**
		 * Adds a floating-point range setting to be managed by Bezel's standard settings
		 * @param	name Setting name
		 * @param	min Setting minimum value
		 * @param	max Setting maximum value
		 * @param	step Setting step value (can be used to limit values to integers with value 1). Must be positive and nonzero.
		 * @param	onSet Function to be called when an setting is set. Takes the new value as a parameter.
		 * @param	defaultVal Default value of the setting 
		 */
		public function registerFloatRange(name:String, min:Number, max:Number, step:Number, onSet:Function, defaultVal:Number, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set:Function = function(newVal:Number):void
            {
                settings[name] = newVal;
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get:Function = function():Number
            {
                return settings[name];
            };
            Bezel.Bezel.instance.mainLoader.registerFloatRangeForDisplay(id, name, min, max, step, set, get, description);
        }

        public function retrieveFloatRange(name:String):Number
        {
            if (!(name in settings))
            {
                throw new ArgumentError("\"" + name + "\" is not a registered setting for mod " + id);
            }
            else
            {
                return settings[name] as Number;
            }
        }
    }
}

class SettingManagerInstantiationBlocker {}
