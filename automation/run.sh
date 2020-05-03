#!/usr/bin/env bash

docker run \
  --name bezelmaker \
  -it \
  --rm \
  --mount type=bind,source="$(pwd)/actions.json",target="/input/actions.json",readonly \
  --mount type=bind,source="$(pwd)/GemCraft Frostborn Wrath.swf",target="/input/GemCraft Frostborn Wrath.swf",readonly \
  --mount type=bind,source="$(pwd)/abc/",target="/input/abc",readonly \
  --mount type=bind,source="$(pwd)/output/",target="/output/" \
  loganavatar/bezel:latest \
  create_patch.sh
