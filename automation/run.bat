docker run ^
  --name bezelmaker ^
  -it ^
  --rm ^
  --mount type=bind,source="%~dp0actions.json",target="/input/actions.json",readonly ^
  --mount type=bind,source="%~dp0GemCraft Frostborn Wrath.swf",target="/input/GemCraft Frostborn Wrath.swf",readonly ^
  --mount type=bind,source="%~dp0abc/",target="/input/abc",readonly ^
  --mount type=bind,source="%~dp0output/",target="/output/" ^
  loganavatar/bezel:latest ^
  create_patch.sh
