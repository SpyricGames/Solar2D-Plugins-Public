display.setStatusBar( display.HiddenStatusBar )
local composer = require( "composer" )

-- Remember to require physics and to call physics.start() before morphing!
local physics = require("physics")
physics.start()
physics.setDrawMode( "hybrid" )

local demoUI = require( "demoUI.ui" )
demoUI.create()

composer.recycleOnSceneChange = true
composer.gotoScene( "menu" )
