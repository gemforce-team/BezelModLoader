# Bezel Mod Loader
## Description
Bezel Mod Loader (Bezel for short) is a modding API for GC:FW.

It is very basic at the moment, created to simplify updating my mods for new game versions, loading them, ensuring compatibility, etc. 

Nevertheless, I've aimed to make it flexible and expandable, so even in its current state it is capable of loading arbitrary mods (assuming they follow a certain internal structure, documentation is a WIP). These mods then have access to the entire game's internals.

Check out [Gemsmith](https://github.com/gemforce-team/gemsmith)'s source for an example. More documentation will be created later.


# Changelog
https://github.com/gemforce-team/BezelModLoader/blob/master/Changelog.txt


## Files
Bezel keeps all its files in the game's Local Store folder. It's located in `%AppData%\com.giab.games.gcfw.steam\Local Store\Bezel Mod Loader` and it's generated on first launch. This folder is referred to as **storage folder** in this readme.

Mods are kept in the game's folder, in a `Mods` subfolder. Any `.swf`s placed there will be attempted to load into the game.


# Features
* Bezel keeps a log of the last session in its storage folder, in `Bezel_log.log`.

* Mods use a single logger provided by Bezel, so all mods' messages are written to the same log file.

* Mods are loaded from the `Mods` folder in the game's folder.

* There are a couple events provided by Bezel that mods can subscribe to. You can also subscribe to game objects' events directly.

* Coremods allow you to inject any changes into the game (such as new hooks or changing hardcoded values), take a look at [BezelCoreMod](https://github.com/gemforce-team/BezelModLoader/blob/master/src/Bezel/BezelCoreMod.as)


# Installation
## Windows
**To install Bezel** grab an [installer](https://github.com/gemforce-team/BezelModLoader/releases/latest) (links for other releases below) for your game version.

## If you had Bezel 0.2.x installed (via patching), you need to restore the original game's swf.
There are two ways to restore your original .swf
1) Delete "GemCraft Frostborn Wrath.swf" and rename "GemCraft Frostborn Wrath Backup.swf" to "GemCraft Frostborn Wrath.swf"
2) Run steam's "Verify integrity of game files" and it'll be redownloaded.
This will not remove any files, only restore the game's swf to baseline.

## After performing the above (or if you have the unmodded game)
Simply put the installer into your game's folder and launch it. You'll see a message that the installation was successful, then launch the game normally through steam. You'll see Bezel in the bottom right corner of the main menu:

![image](https://user-images.githubusercontent.com/5305748/110174231-e1ee4f00-7e10-11eb-875e-b2745214a07d.png)

## Linux
Put the installer in the game folder, then check the exact Proton version used to run the game, say it is `Proton A.BB.`

Then open a terminal and run:

```
cd ~/.steam/steam/steamapps/common/GemCraft\ Frostborn\ Wrath # go to the installation dir
WINEPREFIX=~/.steam/steam/steamapps/compatdata/1106530/pfx ../Proton\ A.BB/dist/bin/wine bezel-installer-vx.y.z.exe
```

# Installing mods
## Refer to individual mods' readme for instructions first!


At the moment you install mods by dropping their .swf into the `Mods` folder. Make sure there are no duplicates there (like two versions of the same mod), they will overwrite each other in alphabetical order (will be fixed later).


You can even do it on the fly, just press `Ctrl+Alt+Shift+Home` to reload all mods. **This is a development feature, it shouldn't crash but to be sure just restart the game if you add new mods.**


# Uninstalling Bezel
Run steam's "Verify integrity of game files".

This will not remove any files, only restore the game's .exe to baseline.


# Releases
[Link to the latest release](https://github.com/gemforce-team/BezelModLoader/releases/latest)

Release history: [Releases](https://github.com/gemforce-team/BezelModLoader/releases)


## Detailed features
## Hotkeys
At the moment there is only one key combination:
```
Ctrl+Alt+Shift+Home - reload all mods. This is used for debugging \ development. Does not reapply coremods, but will load additional mods were added to the `Mods` folder after starting the game.
```

Bezel manages hotkeys for itself, mods, and GCCS and GCFW. These hotkeys can be edited in Bezel's `hotkeys.json` (located in the game's Local Store folder)
by using strings like "ctrl+shift+alt+home", "CtRl+numpad_6", "alt+ctrl+k", or "f". Accepted modifiers are ctrl, shift, and alt, and accepted non-modifiers are listed
in [the AS3 Keyboard documentation](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html).


# Bug reports and feedback
Please submit an issue to [The issue tracker](https://github.com/gemforce-team/BezelModLoader/issues) if you encounter a bug and there isn't already an open issue about it.

You can find me on GemCraft's Discord server: https://discord.gg/ftyaJhx - Hellrage#5076

# Building
Building Bezel as a library requires [SwcBuild](https://github.com/wise0704/SwcBuild)

Building the game you are modding as a library requires [SwcBuild](https://github.com/wise0704/SwcBuild) and for the game's scripts
to be unpacked to GameScripts/scripts. One recommended tool for doing this is [JPEXS](https://github.com/jindrapetrik/jpexs-decompiler).

## Game type-checking in mods
To use a game as a library for type checking in your mod, first build it as described above, then add it as an **external** library to your FlashDevelop project.
This ensures that the game's data is not copied into your mod when built.
Note that because mods are loaded *before* the game, you cannot use any of the game's classes in your BezelMod's interface.
This include any accessibility of properties and arguments to functions.
They can be used for local variables within bind and other functions called after it.

# Disclaimer
This is not an official modification.

GemCraft - Frostborn Wrath is developed and owned by [gameinabottle](http://gameinabottle.com/)


# Credits
Hellrage - original developer.

Special thanks to:

LA for automating swf patching and .diff generation!

piepie62 for developing Lattice!

12345ieee for figuring out the installation process on Linux!
