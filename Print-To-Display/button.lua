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

-- Create buttons in a separate module to keep main.lua's sample code cleaner.

local button = {}

local widget = require( "widget" )

local timerID = nil
local timerIterations = 1
local touchIterations = 1

-- Label and onRelease listener for each button.
local buttonParams = {
    {
        label = "Print Touch Event",
        onRelease = function( event )
            print("")
            print( "== touch event #" .. touchIterations .. " ==")
            for i, v in pairs( event ) do
                print( i, v )
            end
            touchIterations = touchIterations+1
        end
    },
    {
        label = "Start Timer",
        onRelease = function( event )            
            if timerID then
                event.target:setLabel( "Start Timer" )
                timer.cancel( timerID )
                timerID = nil
            else
                event.target:setLabel( "Stop Timer" )
                timerID = timer.performWithDelay( 250, function()
                    local a, b = math.modf( os.clock() )
                    if b == 0 then
                        b = "000"
                    else
                        b = tostring(b):sub(-3)
                    end
                    print( "iteration #" .. timerIterations .. " @ " .. os.date("%X", os.time() ) .. "." .. b )
                    timerIterations = timerIterations+1
                end, 0 )
            end
        end
    }
}

function button.new( i )
    local button = widget.newButton(
        {
            label = buttonParams[i].label,
            id = buttonParams[i].label,
            shape = "rectangle",
            width = 320,
            height = 48,
            font = "demoScene/font/Roboto-Regular.ttf",
            fontSize = 24,
            fillColor = { default={252/255, 186/255, 4/255}, over={255/255, 200/255, 32/255} },
            labelColor = { default={ 0 }, over={ 0 } },
            onRelease = buttonParams[i].onRelease
        }
    )
    button.x = display.contentCenterX + 280
    button.y = 400 + i*60
    
    return button
end

return button