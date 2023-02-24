package Bezel.Utils
{
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.bezel_internal;

    import flash.errors.IllegalOperationError;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    /**
     * Manages settings for Bezel mods. Currently only works for numerical, boolean, and string settings.
     * Automatically registers them for display with a MainLoader, if present
     * @author Chris
     */
    public class SettingManager
    {
        public static const SETTINGS_FOLDER:File = Bezel.Bezel.BEZEL_FOLDER.resolvePath("Mod Settings");

        // Reserved mod names that should not be used for mod settings handlers
        public static const MOD_KEYBIND:String = "Keybinds";
        public static const MOD_ENABLED:String = "Enabled Mods";

        private static var managers:Dictionary = new Dictionary();

        private var id:String;

        private var _settings:Object;

        private static var logger:Logger = Bezel.Bezel.instance.getLogger("SettingManager");

        private function get SETTINGS_FILE():File
        {
            return SETTINGS_FOLDER.resolvePath(id + ".json");
        }

        private function get settings():Object
        {
            if (_settings == null)
            {
                if (SETTINGS_FILE.exists)
                {
                    var stream:FileStream = new FileStream();
                    stream.open(this.SETTINGS_FILE, FileMode.READ);
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

        /**
         * Cannot be called
         */
        public function SettingManager(identifier:String, _blocker:SettingManagerInstantiationBlocker)
        {
            if (!SETTINGS_FOLDER.exists)
            {
                SETTINGS_FOLDER.createDirectory();
            }
            if (identifier == null || identifier == "")
                throw new ArgumentError("SettingManager identifier can't be null or empty");
            if (identifier in managers || _blocker == null)
                throw new IllegalOperationError("Constructor should only be called by getManager! Get your settingmanager instance that way");
            this.id = identifier;
        }

        /**
         * Used internally on reload
         */
        bezel_internal static function unregisterAllManagers():void
        {
            logger.log("unregisterAllManagers", "Unregistering managers...");
            for each (var manager:SettingManager in managers)
            {
                manager.deregisterFromMainLoader();
            }

            managers = new Dictionary();
        }

        /**
         * Removes all of this SettingManager's settings from the MainLoader's display.
         */
        public function deregisterFromMainLoader():void
        {
            if (this._settings != null)
            {
                logger.log("saveSettings", "Deregistering " + this.id);

                if (Bezel.Bezel.instance.mainLoader != null)
                {
                    Bezel.Bezel.instance.mainLoader.deregisterOption(this.id, null);
                }
            }
        }

        private function saveSettings():void
        {
            if (this._settings != null)
            {
                logger.log("saveSettings", "Saving settings for " + this.id);
                var stream:FileStream = new FileStream();
                stream.open(this.SETTINGS_FILE, FileMode.WRITE);
                var data:String = JSON.stringify(this._settings, null, 2);
                var lines:Array = data.split('\n').slice(1, -1);
                for (var i:int = 0; i < lines.length - 1; i++)
                {
                    lines[i] = (lines[i] as String).slice(0, -1);
                }
                lines.sort();

                stream.writeUTFBytes("{\n" + lines.join(",\n") + "\n}");
                stream.close();
            }
        }

        /**
         * Get an instance of a setting manager that writes to the standardized Bezel settings
         * @param	identifier Name to use in the log SETTINGS_FILE
         * @return SettingManager for the given identifier
         */
        public static function getManager(identifier:String):SettingManager
        {
            if (identifier == null || identifier == "")
                throw new ArgumentError("SettingManager identifier can't be null or empty");

            return managers[identifier] || (managers[identifier] = new SettingManager(identifier, new SettingManagerInstantiationBlocker()));
        }

        /**
         * Registers a boolean setting to be managed by Bezel's standard settings
         * @param name Name of the setting
         * @param onSet Function to be called when an option is set. Takes the new value as a parameter.
         * @param defaultVal Default value of the setting
         * @param description Extra description of setting to be displayed
         */
        public function registerBoolean(name:String, onSet:Function, defaultVal:Boolean, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set :Function = function (newVal:Boolean):void
            {
                settings[name] = newVal;
                saveSettings();
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get :Function = function ():Boolean
            {
                return settings[name];
            };
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.registerBooleanForDisplay(id, name, set , get , description);
            }
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
         * @param   description Extra description of setting to be displayed
         */
        public function registerFloatRange(name:String, min:Number, max:Number, step:Number, onSet:Function, defaultVal:Number, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set :Function = function (newVal:Number):void
            {
                settings[name] = newVal;
                saveSettings();
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get :Function = function ():Number
            {
                return settings[name];
            };
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.registerFloatRangeForDisplay(id, name, min, max, step, set , get , description);
            }
        }

        /**
         * Retrieves the value of a float range setting managed by Bezel's standard settings
         * @param name Name of the setting
         * @return Value of the float range
         */
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

        /**
         * Adds a number setting to be managed by Bezel's standard settings
         * @param	name Setting name
         * @param	min Setting minimum value
         * @param	max Setting maximum value
         * @param	onSet Function to be called when an setting is set. Takes the new value as a parameter.
         * @param	defaultVal Default value of the setting
         * @param   description Extra description of setting to be displayed
         */
        public function registerNumber(name:String, min:Number, max:Number, onSet:Function, defaultVal:Number, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set :Function = function (newVal:Number):void
            {
                settings[name] = newVal;
                saveSettings();
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get :Function = function ():Number
            {
                return settings[name];
            };
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.registerNumberForDisplay(id, name, min, max, set , get , description);
            }
        }

        /**
         * Retrieves the value of an number setting managed by Bezel's standard settings
         * @param name Name of the setting
         * @return Value of the integer
         */
        public function retrieveNumber(name:String):Number
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

        /**
         * Adds a string setting to be managed by Bezel's standard settings
         * @param	name Setting name
         * @param   validator Function to be called to validate input. Takes the new value as a parameter and returns a Boolean.
         * @param	onSet Function to be called when an setting is set. Takes the new value as a parameter.
         * @param	defaultVal Default value of the setting
         * @param   description Extra description of setting to be displayed
         */
        public function registerString(name:String, validator:Function, onSet:Function, defaultVal:String, description:String = null):void
        {
            if (!(name in settings))
            {
                settings[name] = defaultVal;
            }
            var set :Function = function (newVal:String):void
            {
                settings[name] = newVal;
                saveSettings();
                if (onSet != null)
                {
                    onSet(newVal);
                }
            };
            var get :Function = function ():String
            {
                return settings[name];
            };
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.registerStringForDisplay(id, name, validator, set , get , description);
            }
        }

        /**
         * Adds a setting with a button that does nothing except call the onClick function.
         * Meant for interactions or more complex settings than can be handled with the basic ones.
         * @param name Setting name
         * @param onClick Function to call on setting click. Will be called with 0 arguments.
         * @param description Extra description of setting to be displayed
         */
        public function registerButton(name:String, onClick:Function, description:String = null):void
        {
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.registerButtonForDisplay(id, name, onClick, description);
            }
        }

        /**
         * Deregisters a setting.
         * @param name Setting to deregister. Null for all
         * @param del Whether to remove the setting from the save SETTINGS_FILE or not
         */
        public function deregisterSetting(name:String, del:Boolean):void
        {
            if (name == null)
            {
                deregisterFromMainLoader();
                if (del)
                {
                    _settings = new Object();
                    saveSettings();
                }
                return;
            }
            if (Bezel.Bezel.instance.mainLoader != null)
            {
                Bezel.Bezel.instance.mainLoader.deregisterOption(id, name);
            }
            if (del)
            {
                delete settings[name];
                saveSettings();
            }
        }
    }
}

class SettingManagerInstantiationBlocker {}
