package Bezel.GCCS 
{
	import Bezel.Bezel;
	import Bezel.Utils.Keybind;
	import Bezel.bezel_internal;
	import Bezel.Events.EventTypes;
	import Bezel.Events.IngameClickOnSceneEvent;
	import Bezel.Events.IngameGemInfoPanelFormedEvent;
	import Bezel.Events.IngameKeyDownEvent;
	import Bezel.Events.IngameNewSceneEvent;
	import Bezel.Events.IngamePreRenderInfoPanelEvent;
	import Bezel.Events.IngameRightClickOnSceneEvent;
	import Bezel.Events.LoadSaveEvent;
	import Bezel.Events.Persistence.IngameClickOnSceneEventArgs;
	import Bezel.Events.Persistence.IngameGemInfoPanelFormedEventArgs;
	import Bezel.Events.Persistence.IngameKeyDownEventArgs;
	import Bezel.Events.Persistence.IngamePreRenderInfoPanelEventArgs;
	import Bezel.Events.SaveSaveEvent;
	import Bezel.Logger;
	import Bezel.MainLoader;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	use namespace bezel_internal;
	
	/*
	 * ...
	 * @author piepie62
	 */
	public class GCCSBezel implements MainLoader
	{
		// Shortcuts to gameObjects
		private var GV:Object;/*GV*/
		private var SB:Object;/*SB*/
		private var prefs:Object;/*Prefs*/
		
		private var bezel:Bezel;
		private var logger:Logger;

		private static const defaultHotkeys:Object = createDefaultKeyConfiguration();
		
		public function GCCSBezel() 
		{
		}
		
		public function get MOD_NAME():String { return "GCCS Bezel"; }
		public function get VERSION():String { return Bezel.Bezel.VERSION; }
		public function get BEZEL_VERSION():String { return Bezel.Bezel.VERSION; }
		
		public function bind(b:Bezel, o:Object):void
		{
			for (var hotkey:String in defaultHotkeys)
			{
				b.keybindManager.registerHotkey(hotkey, defaultHotkeys[hotkey]);
			}
			
			b.keybindManager.registerHotkey("GCCS Bezel: Reload all mods", new Keybind(36, true, true, true));
		}
		public function unload():void {}
		
		public function loaderBind(bezel:Bezel, mainGame:Object, gameObjects:Object): void
		{
			this.logger = bezel.getLogger("GCCS Bezel");
			this.bezel = bezel;
			
			this.GV = getDefinitionByName("com.giab.games.gccs.steam.GV") as Class;
			this.SB = getDefinitionByName("com.giab.games.gccs.steam.SB") as Class;
			this.prefs = getDefinitionByName("com.giab.games.gccs.steam.Prefs") as Class;
			gameObjects.main = mainGame;
			gameObjects.core = this.GV.ingameCore;
			gameObjects.GV = this.GV;
			gameObjects.SB = this.SB;
			gameObjects.prefs = this.prefs;
			gameObjects.mods = getDefinitionByName("com.giab.games.gccs.steam.Mods");

			gameObjects.constants = new Object();
			gameObjects.constants.achievementIngameStatus = getDefinitionByName("com.giab.games.gccs.steam.constants.AchievementIngameStatus");
			gameObjects.constants.actionStatus = getDefinitionByName("com.giab.games.gccs.steam.constants.ActionStatus");
			gameObjects.constants.battleDifficulty = getDefinitionByName("com.giab.games.gccs.steam.constants.BattleDifficulty");
			gameObjects.constants.battleOutcome = getDefinitionByName("com.giab.games.gccs.steam.constants.BattleOutcome");
			gameObjects.constants.battleTraitId = getDefinitionByName("com.giab.games.gccs.steam.constants.BattleTraitId");
			gameObjects.constants.beaconType = getDefinitionByName("com.giab.games.gccs.steam.constants.BeaconType");
			gameObjects.constants.buildingType = getDefinitionByName("com.giab.games.gccs.steam.constants.BuildingType");
			gameObjects.constants.dropType = getDefinitionByName("com.giab.games.gccs.steam.constants.DropType");
			gameObjects.constants.gameMode = getDefinitionByName("com.giab.games.gccs.steam.constants.GameMode");
			gameObjects.constants.gemComponentType = getDefinitionByName("com.giab.games.gccs.steam.constants.GemComponentType");
			gameObjects.constants.gemEnhancementId = getDefinitionByName("com.giab.games.gccs.steam.constants.GemEnhancementId");
			gameObjects.constants.ingameStatus = getDefinitionByName("com.giab.games.gccs.steam.constants.IngameStatus");
			gameObjects.constants.monsterBodyPartType = getDefinitionByName("com.giab.games.gccs.steam.constants.MonsterBodyPartType");
			gameObjects.constants.monsterBuffId = getDefinitionByName("com.giab.games.gccs.steam.constants.MonsterBuffId");
			gameObjects.constants.monsterType = getDefinitionByName("com.giab.games.gccs.steam.constants.MonsterType");
			gameObjects.constants.pauseType = getDefinitionByName("com.giab.games.gccs.steam.constants.PauseType");
			gameObjects.constants.screenId = getDefinitionByName("com.giab.games.gccs.steam.constants.ScreenId");
			gameObjects.constants.selectorScreenStatus = getDefinitionByName("com.giab.games.gccs.steam.constants.SelectorScreenStatus");
			gameObjects.constants.shrineType = getDefinitionByName("com.giab.games.gccs.steam.constants.ShrineType");
			gameObjects.constants.skillId = getDefinitionByName("com.giab.games.gccs.steam.constants.SkillId");
			gameObjects.constants.skillType = getDefinitionByName("com.giab.games.gccs.steam.constants.SkillType");
			gameObjects.constants.sparkType = getDefinitionByName("com.giab.games.gccs.steam.constants.SparkType");
			gameObjects.constants.stageType = getDefinitionByName("com.giab.games.gccs.steam.constants.StageType");
			gameObjects.constants.statId = getDefinitionByName("com.giab.games.gccs.steam.constants.StatId");
			gameObjects.constants.strikeSpellId = getDefinitionByName("com.giab.games.gccs.steam.constants.StrikeSpellId");
			gameObjects.constants.talismanFragmentType = getDefinitionByName("com.giab.games.gccs.steam.constants.TalismanFragmentType");
			gameObjects.constants.talismanPropertyId = getDefinitionByName("com.giab.games.gccs.steam.constants.TalismanPropertyId");
			gameObjects.constants.targetPriorityId = getDefinitionByName("com.giab.games.gccs.steam.constants.TargetPriorityId");
			gameObjects.constants.tutorialId = getDefinitionByName("com.giab.games.gccs.steam.constants.TutorialId");
			gameObjects.constants.url = getDefinitionByName("com.giab.games.gccs.steam.constants.Url");
			gameObjects.constants.waveFormation = getDefinitionByName("com.giab.games.gccs.steam.constants.WaveFormation");
			gameObjects.constants.wizLockType = getDefinitionByName("com.giab.games.gccs.steam.constants.WizLockType");

			//checkForUpdates();

			mainGame.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

			this.logger.log("GCCS Bezel", "GCCS Bezel bound to game's objects!");
		}
		
		public function get coremodInfo():Object 
		{
			return {"name": "GCCS_BEZEL_MOD_LOADER", "version": GCCSCoreMod.VERSION, "load": GCCSCoreMod.installHooks};
		}
		
		bezel_internal function setVersion(mcmainmenu:Object): void
		{
			var versionText:TextField = new TextField();
			versionText.selectable = false;
			versionText.text = Bezel.Bezel.prettyVersion();
			versionText.setTextFormat(new TextFormat("Celtic Garamond for GemCraft", 10, 0xFFFFFF, null, null, null, null, null, "center"));
			mcmainmenu.mcBottomTexts.addChild(versionText);
			versionText.width = versionText.parent.width;
			//var version:String = GV.main.scrMainMenu.mc.mcBottomTexts.getChildAt(0).text;
			//version = version.slice(0, version.search(' ') + 1) + Bezel.Bezel.prettyVersion();
			//GV.main.scrMainMenu.mc.mcBottomTexts.getChildAt(0).text = version;
		}

		// Called after the gem's info panel has been formed but before it's returned to the game for rendering
		bezel_internal function ingameGemInfoPanelFormed(infoPanel:Object, gem:Object, numberFormatter:Object): void
		{
			bezel.dispatchEvent(new IngameGemInfoPanelFormedEvent(EventTypes.INGAME_GEM_INFO_PANEL_FORMED, new IngameGemInfoPanelFormedEventArgs(infoPanel, gem, numberFormatter)));
		}

		// Called before any of the game's logic runs when starting to form an infopanel
		// This method is called before infoPanelFormed (which should be renamed to ingameGemInfoPanelFormed)
		bezel_internal function ingamePreRenderInfoPanel(): Boolean
		{
			var eventArgs:IngamePreRenderInfoPanelEventArgs = new IngamePreRenderInfoPanelEventArgs(true);
			bezel.dispatchEvent(new IngamePreRenderInfoPanelEvent(EventTypes.INGAME_PRE_RENDER_INFO_PANEL, eventArgs));
			//logger.log("ingamePreRenderInfoPanel", "Dispatched event!");
			return eventArgs.continueDefault;
		}

		// Called immediately as a click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		bezel_internal function ingameClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			bezel.dispatchEvent(new IngameClickOnSceneEvent(EventTypes.INGAME_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called immediately as a right click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		bezel_internal function ingameRightClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			bezel.dispatchEvent(new IngameRightClickOnSceneEvent(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called after the game checks that a key should be handled, but before any of the actual handling logic
		// Set continueDefault to false to prevent the base game's handler from running
		bezel_internal function ingameKeyDown(e:KeyboardEvent): Boolean
		{
			var eventArgs:IngameKeyDownEventArgs = new IngameKeyDownEventArgs(e, true);
			bezel.dispatchEvent(new IngameKeyDownEvent(EventTypes.INGAME_KEY_DOWN, eventArgs));
			doHotkeyTransformation(e);
			return eventArgs.continueDefault;
		}

		bezel_internal function stageKeyDown(e: KeyboardEvent): void
		{
			if (this.bezel.keybindManager.getHotkeyValue("GCCS Bezel: Reload all mods").matches(e))
			{
				if (bezel.modsReloadedTimestamp + 10*1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Please wait 10 secods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					return;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Reloading mods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
				bezel.reloadAllMods();
			}
		}

		// Called after the game is done loading its data
		bezel_internal function loadSave(): void
		{
			bezel.dispatchEvent(new LoadSaveEvent(GV.ppd, EventTypes.LOAD_SAVE));
		}

		// Called after the game is done saving its data
		bezel_internal function saveSave(): void
		{
			bezel.dispatchEvent(new SaveSaveEvent(GV.ppd, EventTypes.SAVE_SAVE));
		}

		// Called when a level is loaded or reloaded
		bezel_internal function ingameNewScene(): void
		{
			bezel.dispatchEvent(new IngameNewSceneEvent(EventTypes.INGAME_NEW_SCENE));
		}
		
		private static function createDefaultKeyConfiguration():Object
		{
			var config:Object = new Object();
			config["Throw gem bombs"] = new Keybind(66);
			config["Build tower"] = new Keybind(84);
			config["Build trap"] = new Keybind(82);
			config["Build wall"] = new Keybind(87);
			config["Combine gems"] = new Keybind(71);
			config["Switch time speed"] = new Keybind(81);
			config["Pause time"] = new Keybind(32);
			config["Start next wave"] = new Keybind(78);
			config["Destroy gem for mana"] = new Keybind(88);
			config["Drop gem to inventory"] = new Keybind(9);
			config["Duplicate gem"] = new Keybind(68);
			config["Upgrade gem"] = new Keybind(85);
			config["Show/hide info panels"] = new Keybind(190);
			config["Cast freeze strike spell"] = new Keybind(49);
			config["Cast curse strike spell"] = new Keybind(50);
			config["Cast wake of eternity strike spell"] = new Keybind(51);
			config["Cast bolt enhancement spell"] = new Keybind(52);
			config["Cast beam enhancement spell"] = new Keybind(53);
			config["Cast barrage enhancement spell"] = new Keybind(54);
			config["Create Mana Leeching gem"] = new Keybind(103);
			config["Create Critical Hit gem"] = new Keybind(104);
			config["Create Poolbound gem"] = new Keybind(105);
			config["Create Chain Hit gem"] = new Keybind(100);
			config["Create Poison gem"] = new Keybind(101);
			config["Create Suppression gem"] = new Keybind(102);
			config["Create Bloodbound gem"] = new Keybind(97);
			config["Create Slowing gem"] = new Keybind(98);
			config["Create Armor Tearing gem"] = new Keybind(99);
			config["Up arrow function"] = new Keybind(38);
			config["Down arrow function"] = new Keybind(40);
			config["Left arrow function"] = new Keybind(37);
			config["Right arrow function"] = new Keybind(39);

			return config;
		}
		
		private function doHotkeyTransformation(e:KeyboardEvent):void
		{
			for(var name:String in defaultHotkeys)
			{
				if(this.bezel.keybindManager.getHotkeyValue(name).matches(e))
				{
					e.keyCode = defaultHotkeys[name].key;
					e.altKey = defaultHotkeys[name].alt;
					e.ctrlKey = defaultHotkeys[name].ctrl;
					e.shiftKey = defaultHotkeys[name].shift;
					break;
				}
			}
		}
		
	}

}
