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
local demoScene = require( "demoScene.ui" ).create( "Spyric Print To Display", true )

-----------------------------------------------------------------------

-- All you need to do is require the plugin and start it.
local printToDisplay = require( "spyric.printToDisplay" )
-- Even setting the style is completely optional.
printToDisplay.setStyle({
    y = 80,
    font = "demoScene/font/Roboto-Regular.ttf",
    width = 300,
    height = 480,
    bgColor = {0,0,0,0.7},
    buttonSize = 40,
    fontSize = 13,
    paddingRow = 10,
})
-- After start(), the prints will appear
-- both on the screen and in the console (simulator).
printToDisplay.start()

-----------------------------------------------------------------------

-- Create rest of the demo display objects
-- so that there's something to print out.
local iterations, countdown, textCountdown = 1

local resumeText = display.newText( "< Pause/Resume autoscroll", display.screenOriginX+476, 100, "demoScene/font/Roboto-Regular.ttf", 20 )
local clearText = display.newText( "< Clear all outputs", display.screenOriginX+432, 150, "demoScene/font/Roboto-Regular.ttf", 20 )

local function startCountdown( event )
    if event.phase == "began" then
        if countdown then
            textCountdown.text = "Start Timer"
            timer.cancel( countdown )
            countdown = nil
        else
            textCountdown.text = "Stop Timer"
            countdown = timer.performWithDelay( 250, function()
                local a, b = math.modf( os.clock() )
                if b == 0 then
                    b = "000"
                else
                    b = tostring(b):sub(-3)
                end
                print( "iteration #" .. iterations .. " @ " .. os.date("%X", os.time() ) .. "." .. b )
                iterations = iterations+1
            end, 0 )
        end
    end
end

local commandText = display.newText( "Tap any block below to\nprint out event properties", 770, 120, "demoScene/font/Roboto-Regular.ttf", 24 )
commandText:setFillColor( 0.94, 0.67, 0.16 )

local buttonCountdown = display.newRect( 770, 500, 200, 60 )
buttonCountdown:addEventListener( "touch", startCountdown )
buttonCountdown:setFillColor( 0, 0.05, 0.1 )

textCountdown = display.newText( "Start Timer", buttonCountdown.x, buttonCountdown.y, "demoScene/font/Roboto-Regular.ttf", 32 )
textCountdown:setFillColor( 0.8 )

local function getProperties( event )
    if event.phase == "began" or event.phase == "ended" then
        print( "event phase = " .. event.phase .. ", event.target.id = " .. event.target.id )
    end
    return true
end

local function addRect(i)
    local rect = display.newRect(
        math.random(680,880),
        math.random(240,400),
        math.random(60,110),
        math.random(60,110)
    )
    rect.rotation = math.random(90)
    rect:setFillColor(math.random(),math.random(),math.random())
    rect.id = i
    rect:addEventListener( "touch", getProperties )
end

for i = 1, 10 do
    addRect(i)
end