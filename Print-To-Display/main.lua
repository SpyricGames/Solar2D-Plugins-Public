---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.            Last Updated: 20 June 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Print To Display", true )

-----------------------------------------------------------------------

-- Require Spyric Print to Display.
local printToDisplay = require( "spyric.printToDisplay" )

-- Start the in-app console with custom visual settings.
printToDisplay.start({
    height = display.maxY - display.minY,
	y = display.minY,
    alpha=0.9,
})

-----------------------------------------------------------------------

-- You can write print() commands here and they'll appear in the in-app console.
print("This is the in-app console.")
print("")

-- Add simple one sentence explanations for what the in-app console buttons do.
local labelX = display.screenOriginX+display.actualContentWidth/3+40
local toggleText = display.newText( "❮  Hide/show the console", labelX, 95, "demoScene/font/Roboto-Regular.ttf", 20 )
toggleText.anchorX = 0
local resumeText = display.newText( "❮  Pause/Resume autoscroll", labelX, 137, "demoScene/font/Roboto-Regular.ttf", 20 )
resumeText.anchorX = 0
local clearText = display.newText( "❮  Clear all outputs", labelX, 179, "demoScene/font/Roboto-Regular.ttf", 20 )
clearText.anchorX = 0

local description = display.newText(
    "With Spyric Print To Display plugin, whenever you use the print() function, " ..
    "the output will be sent to the simulator console and to an in-app console.\n\n" .. 
    "Having an in-app console allows you to easily debug your apps on your devices during testing.",
    500, 280, 440, 0, "demoScene/font/Roboto-Regular.ttf", 20
)
description.anchorX, description.anchorY = 0, 0

-- Lazy, yet effective button creation.
local button = require("button")
for i = 1, 2 do
    local btn = button.new( i )
end
