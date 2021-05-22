# Spyric Font Loader

When Solar2D uses a font for the first time during runtime, the engine will cache the font.

Depending on what device and platform your game (or app) is running on, this may take between 3ms and 300ms per font. By preloading your fonts before you actually need to use them, you can prevent these "lag spikes" by controlling when the caching occurs.

---

## How To Use

To use Spyric Font Loader in your own projects, simply copy the [spyricFontLoader.lua](https://github.com/SpyricGames/Solar2D-Plugins-Public/blob/main/Font-Loader/plugin/spyricFontLoader.lua) file from this repository (found inside the plugin folder) and require it in your own project. Then run the function 

The preload function will also return the number of fonts that it preloaded.

### Syntax
```lua
fontLoader.preload( [folder] [, params] )
```
**folder** (string) - The folder to scan for .otf and .ttf font files. If no folder is passed, it will default to `baseDirectory`.

**params** (table) - Optional parameters are: directory, deepScan, and consoleOutput.

- *directory* (userdata) - can be system.ResourceDirectory (default) or system.DocumentsDirectory.

- *deepScan* (boolean) - If set to `true`, then the fontLoader will scan all subfolders as well. Default is `false`.

- *consoleOutput* (boolean) - If set to `true`, then the fontLoader will output console logs of its operations. Default is `false`.


### Example
Preload all font files inside "fonts" folder and output console logs.
```lua
local fontLoader = require( "plugin.spyricFontLoader" )
fontLoader.preload( "fonts", {consoleOutput=true, deepScan=true} )
```
