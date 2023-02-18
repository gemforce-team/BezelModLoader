package Bezel.GCFW
{
	import Bezel.Bezel;
	import Bezel.Lattice.Lattice;
	import Bezel.Logger;
	import Bezel.MainLoader;
	import Bezel.Utils.Keybind;
	import Bezel.Utils.SettingManager;

	import com.giab.common.utils.Key;
	import com.giab.games.gcfw.GV;
	import com.giab.games.gcfw.Main;
	import com.giab.games.gcfw.Mods;
	import com.giab.games.gcfw.Prefs;
	import com.giab.games.gcfw.SB;
	import com.giab.games.gcfw.constants.AchievementIngameStatus;
	import com.giab.games.gcfw.constants.ActionStatus;
	import com.giab.games.gcfw.constants.BattleMode;
	import com.giab.games.gcfw.constants.BattleOutcome;
	import com.giab.games.gcfw.constants.BattleTraitId;
	import com.giab.games.gcfw.constants.BeaconType;
	import com.giab.games.gcfw.constants.BuildingType;
	import com.giab.games.gcfw.constants.DropType;
	import com.giab.games.gcfw.constants.EpicCreatureType;
	import com.giab.games.gcfw.constants.GameMode;
	import com.giab.games.gcfw.constants.GemComponentType;
	import com.giab.games.gcfw.constants.GemEnhancementId;
	import com.giab.games.gcfw.constants.IngameStatus;
	import com.giab.games.gcfw.constants.MonsterBodyPartType;
	import com.giab.games.gcfw.constants.MonsterBuffId;
	import com.giab.games.gcfw.constants.MonsterType;
	import com.giab.games.gcfw.constants.PauseType;
	import com.giab.games.gcfw.constants.ScreenId;
	import com.giab.games.gcfw.constants.SelectorScreenStatus;
	import com.giab.games.gcfw.constants.SkillId;
	import com.giab.games.gcfw.constants.SkillType;
	import com.giab.games.gcfw.constants.StageType;
	import com.giab.games.gcfw.constants.StatId;
	import com.giab.games.gcfw.constants.StrikeSpellId;
	import com.giab.games.gcfw.constants.TalismanFragmentType;
	import com.giab.games.gcfw.constants.TalismanPropertyId;
	import com.giab.games.gcfw.constants.TargetPriorityId;
	import com.giab.games.gcfw.constants.TutorialId;
	import com.giab.games.gcfw.constants.Url;
	import com.giab.games.gcfw.constants.WaveFormation;
	import com.giab.games.gcfw.constants.WizLockType;
	import com.giab.games.gcfw.constants.WizStashStatus;

	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;

	/**
	 * The MainLoader for GemCraft: Frostborn Wrath.
	 * @author piepie62
	 */
	public class GCFWBezel extends MovieClip implements MainLoader
	{
		private var logger:Logger;

		internal static const defaultHotkeys:Object = createDefaultKeyConfiguration();

		internal static const RELOAD_HOTKEY:String = "GCFW Bezel: Reload all mods";
		internal static const ENUMBER_SETTING:String = "Optimize game numbers";
		internal static const HARD_RELOAD_HOTKEY:String = "GCFW Bezel: Hard reload";

		public function get gameClassFullyQualifiedName():String
		{
			return "com.giab.games.gcfw.Main";
		}
		public function get MOD_NAME():String
		{
			return "GCFW Bezel";
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

		public function GCFWBezel()
		{
			manager = Bezel.Bezel.instance.getSettingManager("GCFW Bezel");
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

			return {"name": "GCFW_BEZEL_MOD_LOADER", "version": GCFWCoreMod.VERSION + (doEnumberFix ? "" : "NOENUMBER"), "load": function (lattice:Lattice):void
				{
					GCFWCoreMod.installHooks(lattice, doEnumberFix);
				}
			};
		}

		// mainGame cannot be the proper type, for consistency with MainLoader interface
		public function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object):void
		{
			this.logger = bezel.getLogger("GCFW Bezel");

			gameObjects.main = mainGame;
			gameObjects.GV = GV;
			gameObjects.SB = SB;
			gameObjects.prefs = Prefs;
			gameObjects.mods = Mods;

			gameObjects.constants = new Object();
			gameObjects.constants.achievementIngameStatus = AchievementIngameStatus;
			gameObjects.constants.actionStatus = ActionStatus;
			gameObjects.constants.battleMode = BattleMode;
			gameObjects.constants.battleOutcome = BattleOutcome;
			gameObjects.constants.battleTraitId = BattleTraitId;
			gameObjects.constants.beaconType = BeaconType;
			gameObjects.constants.buildingType = BuildingType;
			gameObjects.constants.dropType = DropType;
			gameObjects.constants.epicCreatureType = EpicCreatureType;
			gameObjects.constants.gameMode = GameMode;
			gameObjects.constants.gemComponentType = GemComponentType;
			gameObjects.constants.gemEnhancementId = GemEnhancementId;
			gameObjects.constants.ingameStatus = IngameStatus;
			gameObjects.constants.monsterBodyPartType = MonsterBodyPartType;
			gameObjects.constants.monsterBuffId = MonsterBuffId;
			gameObjects.constants.monsterType = MonsterType;
			gameObjects.constants.pauseType = PauseType;
			gameObjects.constants.screenId = ScreenId;
			gameObjects.constants.selectorScreenStatus = SelectorScreenStatus;
			gameObjects.constants.skillId = SkillId;
			gameObjects.constants.skillType = SkillType;
			gameObjects.constants.stageType = StageType;
			gameObjects.constants.statId = StatId;
			gameObjects.constants.strikeSpellId = StrikeSpellId;
			gameObjects.constants.talismanFragmentType = TalismanFragmentType;
			gameObjects.constants.talismanPropertyId = TalismanPropertyId;
			gameObjects.constants.targetPriorityId = TargetPriorityId;
			gameObjects.constants.tutorialId = TutorialId;
			gameObjects.constants.url = Url;
			gameObjects.constants.waveFormation = WaveFormation;
			gameObjects.constants.wizLockType = WizLockType;
			gameObjects.constants.wizStashStatus = WizStashStatus;

			// checkForUpdates();

			this.logger.log("GCFW Bezel", "GCFW Bezel bound to game's objects!");

			GCFWEventHandlers.register();

			registerHotkeys();
			registerSettings();

			var version:String = GV.main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text;
			version = version.slice(0, version.search(' ') + 1) + Bezel.Bezel.prettyVersion();
			GV.main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = version;
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
			config["Throw gem bombs"] = new Keybind("b");
			config["Build tower"] = new Keybind("t");
			config["Build lantern"] = new Keybind("l");
			config["Build pylon"] = new Keybind("p");
			config["Build trap"] = new Keybind("r");
			config["Build wall"] = new Keybind("w");
			config["Build amplifier"] = new Keybind("a");
			config["Combine gems"] = new Keybind("g");
			config["Switch time speed"] = new Keybind("q");
			config["Pause time"] = new Keybind("space");
			config["Start next wave"] = new Keybind("n");
			config["Destroy gem for mana"] = new Keybind("x");
			config["Drop gem to inventory"] = new Keybind("tab");
			config["Duplicate gem"] = new Keybind("d");
			config["Upgrade gem"] = new Keybind("u");
			config["Cast freeze strike spell"] = new Keybind("number_1");
			config["Cast whiteout strike spell"] = new Keybind("number_2");
			config["Cast ice shards strike spell"] = new Keybind("number_3");
			config["Cast bolt enhancement spell"] = new Keybind("number_4");
			config["Cast beam enhancement spell"] = new Keybind("number_5");
			config["Cast barrage enhancement spell"] = new Keybind("number_6");
			config["Create Critical Hit gem"] = new Keybind("numpad_4");
			config["Create Mana Leeching gem"] = new Keybind("numpad_5");
			config["Create Bleeding gem"] = new Keybind("numpad_6");
			config["Create Armor Tearing gem"] = new Keybind("numpad_1");
			config["Create Poison gem"] = new Keybind("numpad_2");
			config["Create Slowing gem"] = new Keybind("numpad_3");
			config["Up arrow function"] = new Keybind("up");
			config["Down arrow function"] = new Keybind("down");
			config["Left arrow function"] = new Keybind("left");
			config["Right arrow function"] = new Keybind("right");
			config["Show/hide info panels"] = new Keybind("period");
			config["Toggle 'Hide monsters while time is frozen'"] = new Keybind("comma");

			return config;
		}

		public function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCFWSettingsHandler.registerBooleanForDisplay(mod, name, onSet, currentValue, description);
		}

		public function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCFWSettingsHandler.registerFloatRangeForDisplay(mod, name, min, max, step, onSet, currentValue, description);
		}

		public function deregisterOption(mod:String, name:String):void
		{
			GCFWSettingsHandler.deregisterOption(mod, name);
		}

		public function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCFWSettingsHandler.registerKeybindForDisplay(name, onSet, currentValue, description);
		}

		public function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCFWSettingsHandler.registerStringForDisplay(mod, name, validator, onSet, currentValue, description);
		}

		public function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCFWSettingsHandler.registerNumberForDisplay(mod, name, min, max, onSet, currentValue, description);
		}

		public function cleanupForFullReload():void
		{
			GCFWEventHandlers.unregister();
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, GV.main.ehExit);
			// Made public by coremod
			GV.main.loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, GV.main["uncaughtErrorHandler"]);
			if (GV.main.isSteamworksInitiated)
			{
				Main.steamworks.dispose();
			}

			Bezel.Bezel.instance.stage.removeEventListener(Event.RESIZE, GV.main.onResize);
			Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, GV.main.preventEsc, true);
			Key.deinitialize(Bezel.Bezel.instance.stage);
			if (GV.selectorCore != null)
			{
				if (GV.selectorCore.pnlSkills != null)
				{
					Bezel.Bezel.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, GV.selectorCore.pnlSkills.ehKeyDown);
				}
				if (GV.selectorCore.inputHandler != null)
				{
					Bezel.Bezel.instance.stage.removeEventListener(MouseEvent.MOUSE_UP, GV.selectorCore.inputHandler.ehCornerButtonUp);
				}
			}

			if (SB.scMusFadingIn != null)
			{
				SB.scMusFadingIn.removeEventListener(Event.SOUND_COMPLETE, SB.loopSound);
				SB.scMusFadingIn.stop();
			}
		}
	}
}
