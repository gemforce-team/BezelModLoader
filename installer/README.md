# Bezel Mod Loader Installer
### Compilation
Should be as simple as `cargo build --release`. Note that the target defaults to `i686-pc-windows-gnu`, which requires x86 mingw to be installed.
There likely isn't a point in building it for non-Windows targets, as it relies on getting %APPDATA% from environment variables.
