---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 22 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Performance", true )

-- Require Spyric Performance.
local performance = require( "spyric.performance" )

-- Approach 1:
-- Start the performance meter & adjust its position later.
------------------------------------------------------------
performance.start()
-- By default, the performance meter will be horizontally centered at the top of the screen,
-- but you may optionally reposition it or insert into a specific display group, etc.
performance.meter.x = display.contentCenterX
performance.meter.y = display.minY + 20


-- Approach 2:
-- Visually customise and start the performance meter.
------------------------------------------------------------
-- local customStyle = {
-- 	paddingHorizontal = 10,
-- 	paddingVertical = 6,
-- 	bgColor = { 0.5, 0, 0 },
-- 	fontSize = 20,
-- 	anchorY = 1,
-- 	x = display.contentCenterX,
-- 	y = display.minY + 20,
-- 	font = "demoScene/font/Roboto-Black.ttf",
-- }
-- -- Also, don't make the performance meter visible on start.
-- performance.start( false, customStyle )


------------------------------------------------------------

-- Create group hierarchy to ensure the tooltip is always on top.
local group = display.newGroup()
local groupText = display.newGroup()
group:insert( groupText )

local tooltip = display.newText({
	parent = group,
	text = "▲\nTap the meter to hide/reveal it.\nThe values are 1) FPS, 2) texture memory use, 3) Lua memory use (in that order).",
	x = performance.meter.x,
	y = performance.meter.y + 50,
	font = "demoScene/font/Roboto-Black.ttf",
	fontSize = 20,
	align = "center",
})
tooltip.anchorY = 0
tooltip:setFillColor( 252/255, 186/255, 4/255 )

local tooltipBG = display.newRect( group, tooltip.x, tooltip.y + tooltip.height*0.5, tooltip.width+10, tooltip.height+10 )
tooltipBG:setFillColor( 0, 0, 0, 0.75 )
tooltip:toFront()

-- Create a simple loop for adding and removing display objects to demonstrate the plugin.
local loopStart
local t = {}
local iterations = 50
local delay = 50

local function add()
	t[#t+1] = display.newText( groupText, "Hello!", math.random( 120, display.actualContentWidth-120), math.random(200, display.actualContentHeight-140), "demoScene/font/Roboto-Black.ttf", math.random(30,120) )
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