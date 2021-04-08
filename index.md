# Bezel Mod Loader

[Bezel Mod Loader](https://github.com/gemforce-team/bezelmodloader) (Bezel for short) is a modding API for GC:FW.

It was created to simplify updating mods for new game versions, loading them, ensuring compatibility, etc. 

I've aimed to make it flexible and expandable, so even in its current state it is capable of loading arbitrary mods (assuming they follow a certain internal structure, [documentation](https://github.com/gemforce-team/BezelModLoader/wiki) is a WIP). These mods then have access to the entire game's internals.

With the functionality added by Lattice by piepie62 modders can now specify regex replacements for the vanilla game that will be loaded & applied to the swf by Bezel. This allows mods to add their own hooks into the game or change hardcoded values, modify base game's functions, etc.

Head to the [Wiki](https://github.com/gemforce-team/BezelModLoader/wiki) to learn more about writing mods for Bezel.

## Installing mods
Installation is covered in the [readme of Bezel's repo.](https://github.com/gemforce-team/BezelModLoader/blob/master/README.md)

## List of known mods

Follows a (possibly incomplete) list of mods that can be installed on Bezel.

* [Autocast](https://github.com/gemforce-team/Autocast): Autocasting mod .
* [Gemsmith](https://github.com/gemforce-team/gemsmith): Automatically performs complex gem combinations.
* [ManaMason](https://github.com/gemforce-team/ManaMason): Quickly build arbitrary groups of structures (using blueprints).
* [Foresight](https://github.com/piepie62/Foresight): Place ghosts of buildings to plan your layout.
* [MichaelsMagic](https://github.com/gemforce-team/MichaelsMagic): Adds automation. You can specify which gems to automatically upgrade, spending mana accordingly.
* [Talismania](https://github.com/gemforce-team/Talismania): Allows you to reroll you talisman fragments or pay a large sum of SC to force a fragment with desired properties.
* [CoreModCollection](https://github.com/ZS-NVB/CoreModCollection): A variety of coremods bundled in a single package. Includes rotatable talisman fragments, tweaks to color stat scaling, lantern muter and various fixes among other things. You can choose which individual coremods to enable with a config file. 

Contact Bezel authors to get your mods added to the list!

## Discord
There is a [discord server](https://discord.gg/ftyaJhx) for Gemcraft games. There you'll find a community of players as well as a #modding channel where you can ask your questions and discuss mods & modding.
