package Bezel.GCFW 
{
	/**
	 * ...
	 * @author piepie62
	 */
	
	import Bezel.Bezel;
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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	public class GCFWBezel implements MainLoader
	{
		// Shortcuts to gameObjects
		private var _main:Object;/*Main*/
		private var GV:Object;/*GV*/
		private var SB:Object;/*SB*/
		private var prefs:Object;/*Prefs*/
		
		private var logger:Logger;
		private var bezel:Bezel;
		
		public function get MOD_NAME():String { return "GCFW Bezel"; }
		public function get VERSION():String { return Bezel.Bezel.VERSION; }
		public function get BEZEL_VERSION():String { return Bezel.Bezel.VERSION; }
		public function bind(b:Bezel, o:Object):void {}
		public function unload():void {}
		
		private static const hotkeysFile:File = Bezel.Bezel.bezelFolder.resolvePath("hotkeys.json");
		
		private var _defaultHotkeys:Object;
		private var _configuredHotkeys:Object;
		
		private function get defaultHotkeys():Object
		{
			if (_defaultHotkeys == null)
			{
				_defaultHotkeys = createDefaultKeyConfiguration();
			}
			return _defaultHotkeys;
		}
		
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
						_configuredHotkeys = JSON.parse(hotkeysStream.readUTFBytes(hotkeysStream.bytesAvailable));
						hotkeysStream.close();
					}
					catch (e:Error)
					{
						logger.log("configuredHotkeys", "Error reading hotkeys from disk, using default");
						_configuredHotkeys = createDefaultKeyConfiguration();
					}
				}
				else
				{
					_configuredHotkeys = createDefaultKeyConfiguration();
					this.saveHotkeys();
				}
			}
			return _configuredHotkeys;
		}
		
		public function GCFWBezel()
		{
		}
		
		public function set main(main:Object): void
		{
			this._main = main;
		}
		
		public function get coremodInfo(): Object
		{
			return {"name": "GCFW_BEZEL_MOD_LOADER", "version": GCFWCoreMod.VERSION, "load": GCFWCoreMod.installHooks};
		}
		
		public function loaderBind(bezel:Bezel, gameObjects:Object): void
		{
			this.logger = bezel.getLogger("GCFW Bezel");
			this.bezel = bezel;
			
			this.GV = getDefinitionByName("com.giab.games.gcfw.GV") as Class;
			this.SB = getDefinitionByName("com.giab.games.gcfw.SB") as Class;
			this.prefs = getDefinitionByName("com.giab.games.gcfw.Prefs") as Class;
			gameObjects.main = this._main;
			gameObjects.core = this.GV.ingameCore;
			gameObjects.GV = this.GV;
			gameObjects.SB = this.SB;
			gameObjects.prefs = this.prefs;

			gameObjects.mods = getDefinitionByName("com.giab.games.gcfw.Mods");
			gameObjects.constants = new Object();
			gameObjects.constants.achievementIngameStatus = getDefinitionByName("com.giab.games.gcfw.constants.AchievementIngameStatus");
			gameObjects.constants.actionStatus = getDefinitionByName("com.giab.games.gcfw.constants.ActionStatus");
			gameObjects.constants.battleMode = getDefinitionByName("com.giab.games.gcfw.constants.BattleMode");
			gameObjects.constants.battleOutcome = getDefinitionByName("com.giab.games.gcfw.constants.BattleOutcome");
			gameObjects.constants.battleTraitId = getDefinitionByName("com.giab.games.gcfw.constants.BattleTraitId");
			gameObjects.constants.beaconType = getDefinitionByName("com.giab.games.gcfw.constants.BeaconType");
			gameObjects.constants.buildingType = getDefinitionByName("com.giab.games.gcfw.constants.BuildingType");
			gameObjects.constants.dropType = getDefinitionByName("com.giab.games.gcfw.constants.DropType");
			gameObjects.constants.epicCreatureType = getDefinitionByName("com.giab.games.gcfw.constants.EpicCreatureType");
			gameObjects.constants.gameMode = getDefinitionByName("com.giab.games.gcfw.constants.GameMode");
			gameObjects.constants.gemComponentType = getDefinitionByName("com.giab.games.gcfw.constants.GemComponentType");
			gameObjects.constants.gemEnhancementId = getDefinitionByName("com.giab.games.gcfw.constants.GemEnhancementId");
			gameObjects.constants.ingameStatus = getDefinitionByName("com.giab.games.gcfw.constants.IngameStatus");
			gameObjects.constants.monsterBodyPartType = getDefinitionByName("com.giab.games.gcfw.constants.MonsterBodyPartType");
			gameObjects.constants.monsterBuffId = getDefinitionByName("com.giab.games.gcfw.constants.MonsterBuffId");
			gameObjects.constants.monsterType = getDefinitionByName("com.giab.games.gcfw.constants.MonsterType");
			gameObjects.constants.pauseType = getDefinitionByName("com.giab.games.gcfw.constants.PauseType");
			gameObjects.constants.screenId = getDefinitionByName("com.giab.games.gcfw.constants.ScreenId");
			gameObjects.constants.selectorScreenStatus = getDefinitionByName("com.giab.games.gcfw.constants.SelectorScreenStatus");
			gameObjects.constants.skillId = getDefinitionByName("com.giab.games.gcfw.constants.SkillId");
			gameObjects.constants.skillType = getDefinitionByName("com.giab.games.gcfw.constants.SkillType");
			gameObjects.constants.stageType = getDefinitionByName("com.giab.games.gcfw.constants.StageType");
			gameObjects.constants.statId = getDefinitionByName("com.giab.games.gcfw.constants.StatId");
			gameObjects.constants.strikeSpellId = getDefinitionByName("com.giab.games.gcfw.constants.StrikeSpellId");
			gameObjects.constants.talismanFragmentType = getDefinitionByName("com.giab.games.gcfw.constants.TalismanFragmentType");
			gameObjects.constants.talismanPropertyId = getDefinitionByName("com.giab.games.gcfw.constants.TalismanPropertyId");
			gameObjects.constants.targetPriorityId = getDefinitionByName("com.giab.games.gcfw.constants.TargetPriorityId");
			gameObjects.constants.tutorialId = getDefinitionByName("com.giab.games.gcfw.constants.TutorialId");
			gameObjects.constants.url = getDefinitionByName("com.giab.games.gcfw.constants.Url");
			gameObjects.constants.waveFormation = getDefinitionByName("com.giab.games.gcfw.constants.WaveFormation");
			gameObjects.constants.wizLockType = getDefinitionByName("com.giab.games.gcfw.constants.WizLockType");
			gameObjects.constants.wizStashStatus = getDefinitionByName("com.giab.games.gcfw.constants.WizStashStatus");

			var version:String = _main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text;
			version = version.slice(0, version.search(' ') + 1) + Bezel.Bezel.prettyVersion();
			_main.scrMainMenu.mc.mcBottomTexts.tfDateStamp.text = version;
			//checkForUpdates();

			GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

			this.logger.log("GCFW Bezel", "GCFW Bezel bound to game's objects!");
		}

		// Called after the gem's info panel has been formed but before it's returned to the game for rendering
		public function ingameGemInfoPanelFormed(infoPanel:Object, gem:Object, numberFormatter:Object): void
		{
			bezel.dispatchEvent(new IngameGemInfoPanelFormedEvent(EventTypes.INGAME_GEM_INFO_PANEL_FORMED, new IngameGemInfoPanelFormedEventArgs(infoPanel, gem, numberFormatter)));
		}

		// Called before any of the game's logic runs when starting to form an infopanel
		// This method is called before infoPanelFormed (which should be renamed to ingameGemInfoPanelFormed)
		public function ingamePreRenderInfoPanel(): Boolean
		{
			var eventArgs:IngamePreRenderInfoPanelEventArgs = new IngamePreRenderInfoPanelEventArgs(true);
			bezel.dispatchEvent(new IngamePreRenderInfoPanelEvent(EventTypes.INGAME_PRE_RENDER_INFO_PANEL, eventArgs));
			//logger.log("ingamePreRenderInfoPanel", "Dispatched event!");
			return eventArgs.continueDefault;
		}

		// Called immediately as a click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		public function ingameClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			bezel.dispatchEvent(new IngameClickOnSceneEvent(EventTypes.INGAME_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called immediately as a right click event is fired by the base game
		// set continueDefault to false to prevent the base game's handler from running
		public function ingameRightClickOnScene(event:MouseEvent, mouseX:Number, mouseY:Number, buildingX:Number, buildingY:Number): Boolean
		{
			var eventArgs:IngameClickOnSceneEventArgs = new IngameClickOnSceneEventArgs(true, event, mouseX, mouseY, buildingX, buildingY);
			bezel.dispatchEvent(new IngameRightClickOnSceneEvent(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eventArgs));
			return eventArgs.continueDefault;
		}

		// Called after the game checks that a key should be handled, but before any of the actual handling logic
		// Set continueDefault to false to prevent the base game's handler from running
		public function ingameKeyDown(e:KeyboardEvent): Boolean
		{
			var eventArgs:IngameKeyDownEventArgs = new IngameKeyDownEventArgs(e, true);
			bezel.dispatchEvent(new IngameKeyDownEvent(EventTypes.INGAME_KEY_DOWN, eventArgs));
			doHotkeyTransformation(e);
			return eventArgs.continueDefault;
		}

		public function stageKeyDown(e: KeyboardEvent): void
		{
			if (e.controlKey && e.altKey && e.shiftKey && e.keyCode == 36)
			{
				if (bezel.modsReloadedTimestamp + 10*1000 > getTimer())
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Please wait 10 secods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					return;
				}
				SB.playSound("sndalert");
				GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Reloading mods!",16768392,14,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
				bezel.reloadAllMods();
			}
		}

		// Called after the game is done loading its data
		public function loadSave(): void
		{
			bezel.dispatchEvent(new LoadSaveEvent(GV.ppd, EventTypes.LOAD_SAVE));
		}

		// Called after the game is done saving its data
		public function saveSave(): void
		{
			bezel.dispatchEvent(new SaveSaveEvent(GV.ppd, EventTypes.SAVE_SAVE));
		}

		// Called when a level is loaded or reloaded
		public function ingameNewScene(): void
		{
			bezel.dispatchEvent(new IngameNewSceneEvent(EventTypes.INGAME_NEW_SCENE));
		}
		
		private function createDefaultKeyConfiguration():Object
		{
			var config:Object = new Object();
			config["Throw gem bombs"] = 66;
			config["Build tower"] = 84;
			config["Build lantern"] = 76;
			config["Build pylon"] = 80;
			config["Build trap"] = 82;
			config["Build wall"] = 87;
			config["Combine gems"] = 71;
			config["Switch time speed"] = 81;
			config["Pause time"] = 32;
			config["Start next wave"] = 78;
			config["Destroy gem for mana"] = 88;
			config["Drop gem to inventory"] = 9;
			config["Duplicate gem"] = 68;
			config["Upgrade gem"] = 85;
			config["Show/hide info panels"] = 190;
			config["Cast freeze strike spell"] = 49;
			config["Cast whiteout strike spell"] = 50;
			config["Cast ice shards strike spell"] = 51;
			config["Cast bolt enhancement spell"] = 52;
			config["Cast beam enhancement spell"] = 53;
			config["Cast barrage enhancement spell"] = 54;
			config["Create Critical Hit gem"] = 100;
			config["Create Mana Leeching gem"] = 101;
			config["Create Bleeding gem"] = 102;
			config["Create Armor Tearing gem"] = 97;
			config["Create Poison gem"] = 98;
			config["Create Slowing gem"] = 99;
			config["Up arrow function"] = 38;
			config["Down arrow function"] = 40;
			config["Left arrow function"] = 37;
			config["Right arrow function"] = 39;

			return config;
		}
		
		private function doHotkeyTransformation(e:KeyboardEvent):void
		{
			for(var name:String in this.defaultHotkeys)
			{
				if(this.configuredHotkeys[name] == e.keyCode)
				{
					e.keyCode = this.defaultHotkeys[name];
					break;
				}
			}
		}
		
		public function registerHotkey(name:String, defaultVal:int):void
		{
			if (!(name in this.configuredHotkeys))
			{
				this.configuredHotkeys[name] = defaultVal;
				this.saveHotkeys();
			}
		}
		
		public function getHotkeyValue(name:String):int
		{
			return this.configuredHotkeys[name] || 0;
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
				logger.log("saveHotkeys", "Could not save hotkey information");
			}
		}
		
	}

}
