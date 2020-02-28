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

* Mods are loaded from the `Mods` folder in the game's folder. The only released mod under this system right now is [Gemsmith](https://github.com/gemforce-team/gemsmith)

* There are just a couple events provided by Bezel (the ones I use, currently) that mods can subscribe to to have some triggers. I believe you can also subscribe to game objects' events directly, but I haven't tested that yet.


# Installation
**To install Bezel** grab a release archive (links below) for your game version. Copy
```
applyDiff.bat
courgette64.exe
BezelModLoader-x.x.x-for-y.y.y.diff
"Mods" folder
```
from the archive into the game's folder (To navigate to the game's folder: rightclick the game in steam -> Manage -> Browse local files).

After that launch `applyDiff.bat`, your game will be patched and all unnecessary files deleted. Then launch the game normally through steam.

[More about Courgette](https://blog.chromium.org/2009/07/smaller-is-faster-and-safer-too.html)

[Courgette repo](https://chromium.googlesource.com/chromium/src/courgette/+/master)


## Installing mods
#Refer to individual mods' readme for instructions first!


At the moment you install mods by dropping their .swf into the `Mods` folder. Make sure there are no duplicates there (like two versions of the same mod), they will overwrite each other in alphabetical order (will be fixed later).


You can even do it on the fly, just press `Ctrl+Alt+Shift+Home` to reload all mods. **This is a development feature, it shouldn't crash but to be sure just restart the game if you add new mods.**


## Uninstalling Bezel
There are two ways to restore your original .swf
1) Delete "GemCraft Frostborn Wrath.swf" and rename "GemCraft Frostborn Wrath Backup.swf" to "GemCraft Frostborn Wrath.swf"
2) Run steam's "Verify integrity of game files" and it'll be redownloaded.

This will not remove any files, only restore the game's swf to baseline.


# Releases
[Link to the latest release](https://github.com/gemforce-team/BezelModLoader/releases/latest)

Release history: [Releases](https://github.com/gemforce-team/BezelModLoader/releases)


## Detailed features
## Hotkeys
At the moment there is only one key combination:
```
Ctrl+Alt+Shift+Home - reload all mods. Works only when in a field (playing a level). This is used for debugging.
```


# Bug reports and feedback
Please submit an issue to [The issue tracker](https://github.com/gemforce-team/BezelModLoader/issues) if you encounter a bug and there isn't already an open issue about it.

You can find me on GemCraft's Discord server: https://discord.gg/ftyaJhx - Hellrage#5076


# Disclaimer
This is not an official modification.

GemCraft - Frostborn Wrath is developed and owned by [gameinabottle](http://gameinabottle.com/)


# Credits
Bezel Mod Loader is developed by Hellrage

Special thanks to LA for automating swf patching and .diff generation!
