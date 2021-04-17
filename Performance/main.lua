display.setStatusBar( display.HiddenStatusBar )

local composer = require( "composer" )
local demoUI = require( "demoUI.ui" )
demoUI.create()

-- Load and start the performance bar (located at the top centre of the screen by default).
local performance = require( "spyric.performance" )
performance:start()

local note = display.newText( "Tap the performance     >\nmeter to hide/reveal it.", 250, 120, composer.font, 20 )
note:setFillColor( unpack( composer.fontColour ) )

-- Create a simple infinite loop for adding and removing display objects to demonstrate the plugin.
local loopStart
local t = {}
local iterations = 50
local delay = 50

local function add()
	t[#t+1] = display.newText( "Hello!", math.random( 120, display.actualContentWidth-120), math.random(200, display.actualContentHeight-140), composer.font, math.random(30,120) )
end

local function remove()
	display.remove( t[#t] )
	t[#t] = nil
    if #t == 0 then
        timer.performWithDelay( 350, loopStart )
    end
end

function loopStart()
    timer.performWithDelay( delay, add, iterations )

    timer.performWithDelay( delay*iterations+25, function()
    	timer.performWithDelay( delay, remove, iterations )
    end )
end

loopStart()

-----------------------------------------------------------------------------------------------------------------------
-- Cheating a bit by moving the performance meter manually so that it fits the demoScene UI perfectly, but so that
-- moving it doesn't actually affect the performance meter's default position if someone copies it from here directly.
performance.text.y = performance.text.y + 80
performance.bg.y = performance.bg.y + 80
-----------------------------------------------------------------------------------------------------------------------
