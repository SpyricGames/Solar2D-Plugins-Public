# spyricPerformance
[![License: MIT](https://xedur.com/img/License-MIT-yellow.svg)](https://github.com/XeduR/spyricPerformance/blob/master/LICENSE)

A simple and easily customisable performance meter to keep track of FPS, texture memory and memory usage in Corona projects. This module is heavily inspired by Sergey Lerg's original Performance.lua module for Corona.

## How to use
In order to use this module in your Corona projects, all you need to do is copy performance.lua to your project folder, then require it and start it once.
```lua
local performance = require( "spyric.performance" )
performance:start()
```
If you need to hide the performance meter at any point, simply tap it once, then tap it again if you want to reveal it.

## Visual customisation
You can customise the performance meter's appearance and change its location on the screen by simply modifying these variables within the module.
```lua
local x = display.contentCenterX
local y = display.screenOriginY
local paddingHorizontal = 20
local paddingVertical = 10
local fontColor = { 1 }
local bgColor = { 0 }
local fontSize = 28
local font = "Helvetica"
```

## Get in touch and support me
If you have ideas for small new projects, troubles with an existing one or if you just want to say hi, you can reach me easily via email at <a href="mailto: eetu.rantanen@spyric.com">eetu.rantanen@spyric.com</a>. I am also active at the <a href="https://forums.coronalabs.com/">Corona forums</a>. Finally, if any of my projects have helped or inspired you, then consider buying me a cup of coffee at <a href="https://ko-fi.com/xedur">Ko-fi</a>.

<a href="https://ko-fi.com/xedur"><img src="https://xedur.com/img/support-me.png" height="48"></a>
