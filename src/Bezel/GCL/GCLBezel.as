package Bezel.GCL
{
    import Bezel.Bezel;
    import Bezel.Lattice.Lattice;
    import Bezel.Logger;
    import Bezel.MainLoader;
    import Bezel.Utils.Keybind;
    import Bezel.Utils.SettingManager;

    import com.giab.games.gcl.gs.Main;

    import flash.display.MovieClip;

    /**
     * The MainLoader for GemCraft: Frostborn Wrath.
     * @author piepie62
     */
    public class GCLBezel extends MovieClip implements MainLoader
    {
        private var logger:Logger;

        internal static const defaultHotkeys:Object = createDefaultKeyConfiguration();

        internal static const RELOAD_HOTKEY:String = "GCL Bezel: Reload all mods";
        internal static const ENUMBER_SETTING:String = "Optimize game numbers";
        internal static const HARD_RELOAD_HOTKEY:String = "GCL Bezel: Hard reload";

        public function get gameClassFullyQualifiedName():String
        {
            return "com.giab.games.gcl.gs.Main";
        }
        public function get MOD_NAME():String
        {
            return "GCL Bezel";
        }
        public function get VERSION():String
        {
            return Bezel.Bezel.VERSION;
        }
        public function get BEZEL_VERSION():String
        {
            return Bezel.Bezel.VERSION;
        }

        private var manager:SettingManager;

        public function GCLBezel()
        {
            manager = Bezel.Bezel.instance.getSettingManager("GCL Bezel");
        }

        public function get coremodInfo():Object
        {
            // This may not be registered, so default to true if not
            var doEnumberFix:Boolean = true;
            try
            {
                doEnumberFix = manager.retrieveBoolean(ENUMBER_SETTING);
            }
            catch (e:*) {}

            return {"name": "GCL_BEZEL_MOD_LOADER", "version": GCLCoreMod.VERSION + (doEnumberFix ? "" : "NOENUMBER"), "load": function (lattice:Lattice):void
                {
                    GCLCoreMod.installHooks(lattice, doEnumberFix);
                }
            };
        }

        // mainGame cannot be the proper type, for consistency with MainLoader interface
        public function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object):void
        {
            this.logger = bezel.getLogger("GCL Bezel");

            gameObjects.main = mainGame;

            GCLGV.main = mainGame as Main;

            // checkForUpdates();

            this.logger.log("GCL Bezel", "GCL Bezel bound to game's objects!");

            GCLEventHandlers.register();

            registerHotkeys();
            registerSettings();

            // var version:String = mainGame.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text;
            // version = version.slice(0, version.search(' ') + 1) + Bezel.Bezel.prettyVersion();
            // GV.main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = version;
        }

        internal static function registerHotkeys():void
        {
            for (var hotkey:String in defaultHotkeys)
            {
                Bezel.Bezel.instance.keybindManager.registerHotkey(hotkey, defaultHotkeys[hotkey]);
            }

            Bezel.Bezel.instance.keybindManager.registerHotkey(RELOAD_HOTKEY, new Keybind("ctrl+alt+shift+home"));
            // Bezel.Bezel.instance.keybindManager.registerHotkey(HARD_RELOAD_HOTKEY, new Keybind("ctrl+alt+shift+f12"));
        }

        internal function registerSettings():void
        {
            manager.registerBoolean(ENUMBER_SETTING, function (...args):void {}, true, "Makes the game faster by optimizing away some useless memory obfuscation code. Probably don't disable unless you're a developer making a coremod that's frustrated by long loading times.");
        }

        private static function createDefaultKeyConfiguration():Object
        {
            var config:Object = new Object();
            config["Build amplifier"] = new Keybind("a");
            config["Build charged bolt shrine"] = new Keybind("c");
            config["Build lightning shrine"] = new Keybind("l");
            config["Build tower"] = new Keybind("t");
            config["Build trap"] = new Keybind("r");
            config["Build wall"] = new Keybind("w");
            config["Combine gems"] = new Keybind("g");
            config["Create Armor Tearing gem 2"] = new Keybind("numpad_3");
            config["Create Armor Tearing gem"] = new Keybind("number_3");
            config["Create Bloodbound gem 2"] = new Keybind("numpad_6");
            config["Create Bloodbound gem"] = new Keybind("number_6");
            config["Create Chain Hit gem 2"] = new Keybind("numpad_7");
            config["Create Chain Hit gem"] = new Keybind("number_7");
            config["Create Mana Gain gem 2"] = new Keybind("numpad_9");
            config["Create Mana Gain gem"] = new Keybind("number_9");
            config["Create Multiple Damage gem 2"] = new Keybind("numpad_8");
            config["Create Multiple Damage gem"] = new Keybind("number_8");
            config["Create Poison gem 2"] = new Keybind("numpad_4");
            config["Create Poison gem"] = new Keybind("number_4");
            config["Create Shock gem 2"] = new Keybind("numpad_1");
            config["Create Shock gem"] = new Keybind("number_1");
            config["Create Slow gem 2"] = new Keybind("numpad_2");
            config["Create Slow gem"] = new Keybind("number_2");
            config["Destroy gem for mana"] = new Keybind("x");
            config["Duplicate gem"] = new Keybind("d");
            config["Expand mana pool"] = new Keybind("m");
            config["Open options 2"] = new Keybind("p");
            config["Open options"] = new Keybind("escape");
            config["Pause time"] = new Keybind("space");
            config["Start next wave"] = new Keybind("n");
            config["Switch time speed"] = new Keybind("q");
            config["Throw gem bombs"] = new Keybind("b");
            config["Toggle 'Show info panels'"] = new Keybind("i");
            config["Upgrade gem"] = new Keybind("u");

            return config;
        }

        public function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String = null):void
        {
            GCLSettingsHandler.registerBooleanForDisplay(mod, name, onSet, currentValue, description);
        }

        public function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String = null):void
        {
            GCLSettingsHandler.registerFloatRangeForDisplay(mod, name, min, max, step, onSet, currentValue, description);
        }

        public function deregisterOption(mod:String, name:String):void
        {
            GCLSettingsHandler.deregisterOption(mod, name);
        }

        public function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String = null):void
        {
            GCLSettingsHandler.registerKeybindForDisplay(name, onSet, currentValue, description);
        }

        public function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void
        {
            GCLSettingsHandler.registerStringForDisplay(mod, name, validator, onSet, currentValue, description);
        }

        public function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void
        {
            GCLSettingsHandler.registerNumberForDisplay(mod, name, min, max, onSet, currentValue, description);
        }

        public function registerButtonForDisplay(mod:String, name:String, onClick:Function, description:String = null):void
        {
            GCLSettingsHandler.registerButtonForDisplay(mod, name, onClick, description);
        }

        public function cleanupForFullReload():void
        {
            GCLEventHandlers.unregister();
        }
    }
}
