---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 21 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Font Loader", true )

-- Require the Spyric Font Loader plugin.
local fontLoader = require( "spyric.fontLoader" )

local description = display.newText(
	"When Solar2D uses a font for the first time during runtime, it will cache the font. "..
	"Depending on what device and platform your game is running on, this may take between 3ms and 300ms per font.\n\n"..
	"By preloading your fonts before you actually need to use them, you can prevent these \"lag spikes\" by controlling when the caching occurs.\n\n"..
	"Total number of fonts loaded: ",
	display.contentCenterX, display.minY + 20, 820, 0, "demoScene/font/Roboto-Regular.ttf", 24
)
description.anchorY = 0

-- Run Spyric Font Loader and display preloading times.
local fontCount 
for i = 1, 5 do
	local loopStart = system.getTimer()
	
	if i == 1 then
		 -- Using consoleOutput will provide detailed console logs of what's happening.
		fontCount = fontLoader.preload( "fonts", {consoleOutput=true, deepScan=true} )
	else
		fontLoader.preload( "fonts", {deepScan=true} )
	end
	
	local loadTime, s = math.round((system.getTimer()-loopStart)*100)*0.01
	if i == 1 then
		s = "1st load time (preloading): " .. loadTime .. "ms"
	elseif i == 2 then
		s = "2nd load time: " .. loadTime .. "ms"
	elseif i == 3 then
		s = "3rd load time: " .. loadTime .. "ms"
	else
		s = i.."th load time: " .. loadTime .. "ms"
	end
	
	local text = display.newText( s, description.x - description.width*0.5, description.y + description.height + 40*i, "demoScene/font/Roboto-Regular.ttf", 24 )
	text:setFillColor( 252/255, 186/255, 4/255 )
	text.anchorX = 0
end

-- Dynamically show how many fonts in total were loaded.
description.text = description.text .. fontCount
