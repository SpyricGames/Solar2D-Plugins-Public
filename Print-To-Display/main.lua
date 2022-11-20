---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2022 Spyric Games Ltd.         Last Updated: 20 November 2022 --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local ui = require( "demoScene.ui" )
ui.create( "Spyric Print To Display" )

-----------------------------------------------------------------------

-- Require Spyric Print to Display.
local printToDisplay = require( "spyric.printToDisplay" )
local consoleWidth = 300

-- Start the in-app console with custom visual settings.
printToDisplay.start({
    width = consoleWidth,
    height = ui.maxY - ui.minY,
    x = display.screenOriginX,
	y = ui.minY,
    alpha = 0.9,

    -- Create a single custom button, just to show how it can be done.
    customButton = {
        {
            listener = function()
                -- You could run some ad, analytics, debugging tests here, print the contents of some table, etc.
                print( "Running a custom function." )
            end,
            fontSize = 24,
            id = "⭐"
        },
    }
})


-----------------------------------------------------------------------


-- After Print To Display has been started, whenever you call the normal print() function,
-- its output will be displayed both in the Solar2D console and in the in-app console.
print("This is the in-app console.")
print("")
print("Using this plugin makes wireless on-device debugging quick and easy.")
print("")


-----------------------------------------------------------------------

-- Add simple instructions.
local textX = display.screenOriginX + consoleWidth + 40
local toggleText = display.newText( "❮  Hide/show the console", textX, ui.minY+15, "demoScene/font/Roboto-Regular.ttf", 20 )
toggleText.anchorX = 0
local resumeText = display.newText( "❮  Pause/Resume autoscroll", textX, ui.minY+57, "demoScene/font/Roboto-Regular.ttf", 20 )
resumeText.anchorX = 0
local clearText = display.newText( "❮  Clear all outputs", textX, ui.minY+99, "demoScene/font/Roboto-Regular.ttf", 20 )
clearText.anchorX = 0
local userFunction = display.newText( "❮  Run a custom function.", textX, ui.minY+143, "demoScene/font/Roboto-Regular.ttf", 20 )
userFunction.anchorX = 0

local description = display.newText({
    text = "Whenever you use print(), the output is displayed both in the Solar2D console and in the in-app console to the left.",
    x = textX - 20,
    y = ui.minY+200,
    width = 260,
    font = "demoScene/font/Roboto-Regular.ttf",
    fontSize = 20,
})
description.anchorX, description.anchorY = 0, 0


-----------------------------------------------------------------------

Runtime:addEventListener( "resize", function()

    -------------------------------------------------------------------
    -- The resize function can update the console's height and x/y position,
    -- which is useful if you wish to support multiple orientations.

    printToDisplay.resize({
        -- This height is equal to display.actualContentHeight, minus the demoScene banners.
        height = ui.maxY - ui.minY,
        x = display.screenOriginX,
        -- This y is equal to display.screenOriginY, plus the top banner's height.
        y = ui.minY,
    })
    -------------------------------------------------------------------

    -- Update the text positions.
    local textX = display.screenOriginX + consoleWidth + 40
    toggleText.x, toggleText.y = textX, ui.minY+15
    resumeText.x, resumeText.y = textX, ui.minY+57
    clearText.x, clearText.y = textX, ui.minY+99
    userFunction.x, userFunction.y = textX, ui.minY+143

    description.x, description.y = textX - 20, ui.minY+200
end )
