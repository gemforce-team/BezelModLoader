package Bezel.GCCS 
{
	import Bezel.Bezel;
	import Bezel.Logger;
	import Bezel.MainLoader;
	import Bezel.Utils.Keybind;
	
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.Mods;
	import com.giab.games.gccs.steam.Prefs;
	import com.giab.games.gccs.steam.SB;
	import com.giab.games.gccs.steam.constants.AchievementIngameStatus;
	import com.giab.games.gccs.steam.constants.ActionStatus;
	import com.giab.games.gccs.steam.constants.BattleDifficulty;
	import com.giab.games.gccs.steam.constants.BattleOutcome;
	import com.giab.games.gccs.steam.constants.BattleTraitId;
	import com.giab.games.gccs.steam.constants.BeaconType;
	import com.giab.games.gccs.steam.constants.BuildingType;
	import com.giab.games.gccs.steam.constants.DropType;
	import com.giab.games.gccs.steam.constants.GameMode;
	import com.giab.games.gccs.steam.constants.GemComponentType;
	import com.giab.games.gccs.steam.constants.GemEnhancementId;
	import com.giab.games.gccs.steam.constants.IngameStatus;
	import com.giab.games.gccs.steam.constants.MonsterBodyPartType;
	import com.giab.games.gccs.steam.constants.MonsterBuffId;
	import com.giab.games.gccs.steam.constants.MonsterType;
	import com.giab.games.gccs.steam.constants.PauseType;
	import com.giab.games.gccs.steam.constants.ScreenId;
	import com.giab.games.gccs.steam.constants.SelectorScreenStatus;
	import com.giab.games.gccs.steam.constants.ShrineType;
	import com.giab.games.gccs.steam.constants.SkillId;
	import com.giab.games.gccs.steam.constants.SkillType;
	import com.giab.games.gccs.steam.constants.SparkType;
	import com.giab.games.gccs.steam.constants.StageType;
	import com.giab.games.gccs.steam.constants.StatId;
	import com.giab.games.gccs.steam.constants.StrikeSpellId;
	import com.giab.games.gccs.steam.constants.TalismanFragmentType;
	import com.giab.games.gccs.steam.constants.TalismanPropertyId;
	import com.giab.games.gccs.steam.constants.TargetPriorityId;
	import com.giab.games.gccs.steam.constants.TutorialId;
	import com.giab.games.gccs.steam.constants.Url;
	import com.giab.games.gccs.steam.constants.WaveFormation;
	import com.giab.games.gccs.steam.constants.WizLockType;

	import flash.display.MovieClip;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import Bezel.Utils.SettingManager;
	import Bezel.Lattice.Lattice;
	
	/*
	 * The MainLoader for GemCraft: Chasing Shadows.
	 * @author piepie62
	 */
	public class GCCSBezel extends MovieClip implements MainLoader
	{
		private var logger:Logger;

		internal static const defaultHotkeys:Object = createDefaultKeyConfiguration();
		
		public function get gameClassFullyQualifiedName():String { return "com.giab.games.gccs.steam.Main"; }
		public function get MOD_NAME():String { return "GCCS Bezel"; }
		public function get VERSION():String { return Bezel.Bezel.VERSION; }
		public function get BEZEL_VERSION():String { return Bezel.Bezel.VERSION; }

		private var manager:SettingManager;

		public function GCCSBezel()
		{
			manager = Bezel.Bezel.instance.getSettingManager("GCCS Bezel");
		}
		
		public function get coremodInfo(): Object
		{
			// This may not be registered, so default to true if not
			var doEnumberFix:Boolean = true;
			try {
				doEnumberFix = manager.retrieveBoolean("Optimize game numbers");
			}
			catch (e:*) {}

			return {"name": "GCCS_BEZEL_MOD_LOADER", "version": GCCSCoreMod.VERSION + (doEnumberFix ? "" : "NOENUMBER"), "load": function(lattice:Lattice):void {GCCSCoreMod.installHooks(lattice, doEnumberFix)}};
		}
		
		// mainGame cannot be the proper type, for consistency with MainLoader interface
		public function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object): void
		{
			this.logger = bezel.getLogger("GCCS Bezel");
			
			gameObjects.main = mainGame;
			gameObjects.GV = GV;
			gameObjects.SB = SB;
			gameObjects.prefs = Prefs;
			gameObjects.mods = Mods;

			gameObjects.constants = new Object();
			gameObjects.constants.achievementIngameStatus = AchievementIngameStatus;
			gameObjects.constants.actionStatus = ActionStatus;
			gameObjects.constants.battleDifficulty = BattleDifficulty;
			gameObjects.constants.battleOutcome = BattleOutcome;
			gameObjects.constants.battleTraitId = BattleTraitId;
			gameObjects.constants.beaconType = BeaconType;
			gameObjects.constants.buildingType = BuildingType;
			gameObjects.constants.dropType = DropType;
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
			gameObjects.constants.shrineType = ShrineType;
			gameObjects.constants.skillId = SkillId;
			gameObjects.constants.skillType = SkillType;
			gameObjects.constants.sparkType = SparkType;
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

			//checkForUpdates();

			this.logger.log("GCCS Bezel", "GCCS Bezel bound to game's objects!");

			GCCSEventHandlers.register();

			registerHotkeys();
			registerSettings();
		}

		internal static function registerHotkeys():void
		{
			for (var hotkey:String in defaultHotkeys)
			{
				Bezel.Bezel.instance.keybindManager.registerHotkey(hotkey, defaultHotkeys[hotkey]);
			}
			
			Bezel.Bezel.instance.keybindManager.registerHotkey("GCCS Bezel: Reload all mods", new Keybind("ctrl+alt+shift+home"));
			// Bezel.Bezel.instance.keybindManager.registerHotkey("GCCS Bezel: Hard reload", new Keybind("ctrl+alt+shift+f12"));
		}

		internal function registerSettings():void
		{
			manager.registerBoolean("Optimize game numbers", function(...args):void {}, true, "Makes the game faster by optimizing away some useless memory obfuscation code. Probably don't disable unless you're a developer making a coremod that's frustrated by long loading times.");
		}
		
		private static function createDefaultKeyConfiguration():Object
		{
			var config:Object = new Object();
			config["Throw gem bombs"] = new Keybind("b");
			config["Build tower"] = new Keybind("t");
			config["Build trap"] = new Keybind("r");
			config["Build wall"] = new Keybind("w");
			config["Combine gems"] = new Keybind("g");
			config["Switch time speed"] = new Keybind("q");
			config["Pause time"] = new Keybind("space");
			config["Start next wave"] = new Keybind("n");
			config["Destroy gem for mana"] = new Keybind("x");
			config["Drop gem to inventory"] = new Keybind("tab");
			config["Duplicate gem"] = new Keybind("d");
			config["Upgrade gem"] = new Keybind("u");
			config["Show/hide info panels"] = new Keybind("period");
			config["Cast freeze strike spell"] = new Keybind("number_1");
			config["Cast curse strike spell"] = new Keybind("number_2");
			config["Cast wake of eternity strike spell"] = new Keybind("number_3");
			config["Cast bolt enhancement spell"] = new Keybind("number_4");
			config["Cast beam enhancement spell"] = new Keybind("number_5");
			config["Cast barrage enhancement spell"] = new Keybind("number_6");
			config["Create Mana Leeching gem"] = new Keybind("numpad_7");
			config["Create Critical Hit gem"] = new Keybind("numpad_8");
			config["Create Poolbound gem"] = new Keybind("numpad_9");
			config["Create Chain Hit gem"] = new Keybind("numpad_4");
			config["Create Poison gem"] = new Keybind("numpad_5");
			config["Create Suppression gem"] = new Keybind("numpad_6");
			config["Create Bloodbound gem"] = new Keybind("numpad_1");
			config["Create Slowing gem"] = new Keybind("numpad_2");
			config["Create Armor Tearing gem"] = new Keybind("numpad_3");
			config["Up arrow function"] = new Keybind("up");
			config["Down arrow function"] = new Keybind("down");
			config["Left arrow function"] = new Keybind("left");
			config["Right arrow function"] = new Keybind("right");

			return config;
		}

		public function registerBooleanForDisplay(mod:String, name:String, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCCSSettingsHandler.registerBooleanForDisplay(mod, name, onSet, currentValue, description);
		}

		public function registerFloatRangeForDisplay(mod:String, name:String, min:Number, max:Number, step:Number, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCCSSettingsHandler.registerFloatRangeForDisplay(mod, name, min, max, step, onSet, currentValue, description);
		}

		public function deregisterOption(mod:String, name:String):void
		{
			GCCSSettingsHandler.deregisterOption(mod, name);
		}

		public function registerKeybindForDisplay(name:String, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCCSSettingsHandler.registerKeybindForDisplay(name, onSet, currentValue, description);
		}

		public function registerStringForDisplay(mod:String, name:String, validator:Function, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCCSSettingsHandler.registerStringForDisplay(mod, name, validator, onSet, currentValue, description);
		}

		public function registerNumberForDisplay(mod:String, name:String, min:Number, max:Number, onSet:Function, currentValue:Function, description:String = null):void
		{
			GCCSSettingsHandler.registerNumberForDisplay(mod, name, min, max, onSet, currentValue, description);
		}

		public function cleanupForFullReload():void
		{
			GCCSEventHandlers.unregister();
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, GV.main.ehExit);
			if (GV.main.isSteamworksInitiated)
			{
				GV.main.steamworks.dispose();
			}
		}
	}

}
