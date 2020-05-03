# BezelModLoader automation

This directory holds the automation components that enable quick and consistent injection of the Bezel Mod Loader into the .swf.

This has only been tested up to GCFW `1.0.20c`.  Additional versions might need some `.abc` file or `actions.json` manipulation

## Building the image

If you want to use an existing pre-built image, skip to the Running section.

The automation runs in docker. In order to build it, make sure you have docker installed and a connection to the internet to pull community images and build components.

Run the `./build.sh` script to build a docker container.  It will be tagged `loganavatar/bezel:latest`

## Running

To run the patch process, you will need the following:
- This repo, navigated into the `automation` directory
- Docker
- (if you didn't build an image) Internet connection to pull the existing docker image.
- The Unpatched `GemCraft Frostborn Wrath.swf` named exactly that in the `automation` directory. A patched `.swf` will get re-patched and will be unusable.

If you are on windows, you should be able to execute `run.bat`. If you are on linux/macos you should be able to execute `run.sh`. This will generate a `GemCraft Frostborn Wrath.swf` in your `output` directory.

Your existing `GemCraft Frostborn Wrath.swf` in the `automation` directory will not be modified.

If you want to run commands inside of the container (ex: debugging), just replace the `create_patch.sh` command with `/bin/bash`. You can then run `create_patch.sh` (it is available through the container's PATH var) to run the patch process.

## Under the hood

The patch process is run by a few different components

### RABCDAsm

[RABCDAsm](https://github.com/CyberShadow/RABCDAsm) is an application suite created to manipulate `.swf` files. we are using a docker multistage build to build these apps and then copy them into our final image.

### create_patch.sh

This has the overall logic for the patching:
1. cleanup work and output directories
1. export and disassemble the swf
1. Invoke the rules engine to modify the ABC files
1. assemble and replace a copy of the .swf

### rules_engine.sh

This script uses the `actions.json` file as a guide on where and how to modify the ABC files. It currently supports 4 action types:
- replace - a regex find/replace.
- replaceline - replaces a line using a regex search and an offset to move either down lines (positive numbers) or up (negative numbers). Ex: an offset of -2 would **replace** the line 2 up from the found regex match.
- inject - injects a single line using a regex search and an offset to move either down lines (positive numbers) or up (negative numbers). Ex: an offset of 7 would **add** the value in a new line AFTER the 7th line down from the found regex match.
- insert - inserts an entire block from a file in the `abc` directory. This also uses a regex search and an offset to move either down lines (positive numbers) or up (negative numbers). Ex: an offset of 7 would **add** the block AFTER the 7th line down from the found regex match.

This script runs the actions in the order they are found in the `actions.json` file.

## TODO

- lots.
- try to switch to alpine linux as a
- build and integrate courgette so a diff is generated at the same time
