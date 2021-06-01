---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 29 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Spyric Print To Display is a simple to use Solar2D plugin for displaying
-- print() outputs on an in-app console as well as in the simulator console.
-- This makes debugging on devices easier as no external tools are needed.

--==============================================================================
-- Important! Important! Important! Important! Important! Important! Important!
--==============================================================================
-- If you want to make changes to this module and you need to use debug prints,
-- then make sure to use _print() inside of these functions because using the 
-- regular print() inside the wrong function will result in an infinite loop.
--==============================================================================

local printToDisplay = {}

--[[
    TODO:
    - Add button for "jump to newest entry"
    - Add button for "hide console"
    - Performance improvements!
    - Move the stylise to start (have option to start open or closed).
    - Copy code from Solar2D Playground version.
]]

-- Localised functions.
local _print = print
local tConcat = table.concat
local tostring = tostring
local unpack = unpack
local type = type

printToDisplay.autoscroll = true
local canScroll = false
local started = false
local output

-- Visual customisation variables.
local style = {
    
}

local parent
local font = native.systemFont
local buttonSize = 32
local buttonBaseColor = { 0.2 }
local buttonImageColor = { 0.8 }
local textColor = { 0.9 }
local textColorError = { 0.9, 0, 0 }
local textColorWarning = { 0.9, 0.75, 0 }
local bgColor = { 0 }
local fontSize = 20
local alpha = 1
local width = 200
local height = 100
local anchorX = 0
local anchorY = 0
local x = display.screenOriginX
local y = display.screenOriginY
local paddingRow = 4
local paddingLeft = 10
local paddingRight = 10
local paddingTop = 10
local paddingBottom = 10
local scrollThreshold = (height-(paddingTop+paddingBottom))*0.5
local useHighlighting = true

local function printUnhandledError( event )
    print( event.errorMessage )
end

-- Scroll the text in the console.
local maxY, objectStart, eventStart = 0
local function scroll( event )
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.isTouched = true
        objectStart, eventStart = output.y, event.y
    elseif event.phase == "moved" then
        if event.target.isTouched then
            local d = event.y - eventStart
            local toY = objectStart + d
            if toY <= 0 and toY >= -maxY then
                printToDisplay.autoscroll = false
                printToDisplay.controls.symbolAutoscrollOn.isVisible = false
                printToDisplay.controls.symbolAutoscrollOffA.isVisible = true
                printToDisplay.controls.symbolAutoscrollOffB.isVisible = true
                output.y = toY
            else
                objectStart = output.y
                eventStart = event.y
                if toY <= 0 then
                    printToDisplay.autoscroll = true
                    printToDisplay.controls.symbolAutoscrollOn.isVisible = true
                    printToDisplay.controls.symbolAutoscrollOffA.isVisible = false
                    printToDisplay.controls.symbolAutoscrollOffB.isVisible = false
                end
            end
        end
    else
        display.getCurrentStage():setFocus( nil )
        event.target.isTouched = false
    end
    return true
end

-- Handles the console's two buttons.
local function controls( event )
    if event.phase == "began" then
        if event.target.id == "autoscroll" then
            printToDisplay.autoscroll = not printToDisplay.autoscroll
            printToDisplay.controls.symbolAutoscrollOn.isVisible = not printToDisplay.controls.symbolAutoscrollOn.isVisible
            printToDisplay.controls.symbolAutoscrollOffA.isVisible = not printToDisplay.controls.symbolAutoscrollOffA.isVisible
            printToDisplay.controls.symbolAutoscrollOffB.isVisible = not printToDisplay.controls.symbolAutoscrollOffB.isVisible
            if printToDisplay.autoscroll then output.y = -maxY end
        else -- Clear all text.
            printToDisplay.ui.bg:removeEventListener( "touch", scroll )
            canScroll = false
            printToDisplay.autoscroll = true
            printToDisplay.controls.symbolAutoscrollOn.isVisible = true
            printToDisplay.controls.symbolAutoscrollOffA.isVisible = false
            printToDisplay.controls.symbolAutoscrollOffB.isVisible = false
            output.y = 0
            for i = 1, #output.row do
                display.remove( output.row[i] )
                output.row[i] = nil
            end
        end
    end
    return true
end

-- Add a new chunk of text to the output window.
local function outputToConsole( ... )
    local t = {...}
    for i = 1, #t do
        t[i] = tostring( t[i] )
    end
    local text = tConcat( t, "    " )

    local _y
    if #output.row > 0 then
        _y = output.row[#output.row].y + output.row[#output.row].height + paddingRow
    else
        _y = y+paddingTop - height*0.5
    end

    output.row[#output.row+1] = display.newText( {
        parent = output,
        text = text,
        x = output.row[#output.row] and output.row[#output.row].x or paddingLeft-width*0.5,
        y = output.row[#output.row] and output.row[#output.row].y+output.row[#output.row].height+paddingRow or paddingTop-height*0.5,
        width = width - (paddingLeft + paddingRight),
        height = 0,
        font = font,
        fontSize = fontSize
    } )
    output.row[#output.row].anchorX, output.row[#output.row].anchorY = 0, 0

    if useHighlighting then
        if output.row[#output.row].text:sub(1,6) == "ERROR:" then
            output.row[#output.row]:setFillColor( unpack( textColorError ) )
        elseif output.row[#output.row].text:sub(1,8) == "WARNING:" then
            output.row[#output.row]:setFillColor( unpack( textColorWarning ) )
        else
            output.row[#output.row]:setFillColor( unpack( textColor ) )
        end
    else
        output.row[#output.row]:setFillColor( unpack( textColor ) )
    end

    if not canScroll and output.row[#output.row].y + output.row[#output.row].height >= scrollThreshold then
        printToDisplay.ui.bg:addEventListener( "touch", scroll )
        canScroll = true
    end

    if canScroll then
        maxY = output.row[#output.row].y + output.row[#output.row].height - scrollThreshold
        if printToDisplay.autoscroll then
            output.y = -maxY
        end
    end
end

-- Optional function that will customise any or all visual features of the module.
function printToDisplay.setStyle( s )
    if type( s ) ~= "table" then
        print( "WARNING: bad argument to 'setStyle' (table expected, got " .. type( s ) .. ")." )
    else -- Validate all and update only valid, passed parameters.
        if type( s.buttonSize ) == "number" then buttonSize = s.buttonSize end
        if type( s.parent ) == "table" and s.parent.insert then parent = s.parent end
        if type( s.useHighlighting ) == "boolean" then useHighlighting = s.useHighlighting end
        if type( s.buttonBaseColor ) == "table" then buttonBaseColor = s.buttonBaseColor end
        if type( s.buttonImageColor ) == "table" then buttonImageColor = s.buttonImageColor end
        if type( s.font ) == "string" or type( s.font ) == "userdata" then font = s.font end
        if type( s.fontSize ) == "number" then fontSize = s.fontSize end
        if type( s.width ) == "number" then width = s.width end
        if type( s.height ) == "number" then height = s.height end
        if type( s.anchorX ) == "number" then anchorX = s.anchorX end
        if type( s.anchorY ) == "number" then anchorY = s.anchorY end
        if type( s.x ) == "number" then x = s.x end
        if type( s.y ) == "number" then y = s.y end
        if type( s.paddingRow ) == "number" then paddingRow = s.paddingRow end
        if type( s.paddingLeft ) == "number" then paddingLeft = s.paddingLeft end
        if type( s.paddingRight ) == "number" then paddingRight = s.paddingRight end
        if type( s.paddingTop ) == "number" then paddingTop = s.paddingTop end
        if type( s.textColor ) == "table" then textColor = s.textColor end
        if type( s.bgColor ) == "table" then bgColor = s.bgColor end
        if type( s.alpha ) == "number" then alpha = s.alpha end
        scrollThreshold = (height-(paddingTop+paddingBottom))*0.5
        -- If outputToConsole is already running, then clear it.
        if started then
            printToDisplay.stop()
            printToDisplay.start()
        end
    end
end

-- Create the UI and make the default print() calls also "print" on screen.
function printToDisplay.start()
    if not started then
        started = true
        -- Create container where the background and text are added.
        printToDisplay.ui = display.newContainer( width, height )
        if parent then parent:insert( printToDisplay.ui ) end
        printToDisplay.ui.anchorX, printToDisplay.ui.anchorY = anchorX, anchorY
        printToDisplay.ui.x, printToDisplay.ui.y = x, y
        printToDisplay.ui.alpha = alpha
        -- Create the background.
        printToDisplay.ui.bg = display.newRect( printToDisplay.ui, 0, 0, width, height )
        printToDisplay.ui.bg:setFillColor( unpack( bgColor ) )
        -- All rows of text are added to output group.
        output = display.newGroup()
        printToDisplay.ui:insert( output, true )
        output.row = {}
        -- Create external control buttons
        printToDisplay.controls = display.newGroup()
        if parent then parent:insert( printToDisplay.controls ) end

        local SEG = buttonSize*0.2 -- Segment.
        local HW = buttonSize*0.4 -- (Approximate) half width.
        local buttonOffsetX = (1-anchorX)*width
        local buttonOffsetY = anchorY*height

        printToDisplay.controls.scroll = display.newRect( printToDisplay.controls, x+buttonOffsetX+buttonSize*0.5, y-buttonOffsetY+buttonSize*0.5, buttonSize, buttonSize )
        printToDisplay.controls.scroll:setFillColor( unpack( buttonBaseColor ) )
        printToDisplay.controls.scroll:addEventListener( "touch", controls )
        printToDisplay.controls.scroll.id = "autoscroll"

        local play = {
            -HW+SEG,-HW+SEG*0.5,
            HW,0,
            -HW+SEG,HW-SEG*0.5
        }
        -- This has a "play" symbol and pressing it will pause autoscroll.
        printToDisplay.controls.symbolAutoscrollOn = display.newPolygon( printToDisplay.controls, printToDisplay.controls.scroll.x, printToDisplay.controls.scroll.y, play )
        printToDisplay.controls.symbolAutoscrollOn:setFillColor( unpack( buttonImageColor ) )
        -- This has the "pause" symbol and pressing it will resume autoscroll.
        printToDisplay.controls.symbolAutoscrollOffA = display.newRect( printToDisplay.controls, printToDisplay.controls.scroll.x, printToDisplay.controls.scroll.y, HW+SEG, HW+SEG )
        printToDisplay.controls.symbolAutoscrollOffA:setFillColor( unpack( buttonImageColor ) )
        printToDisplay.controls.symbolAutoscrollOffA.isVisible = false
        printToDisplay.controls.symbolAutoscrollOffB = display.newRect( printToDisplay.controls, printToDisplay.controls.scroll.x, printToDisplay.controls.scroll.y, SEG, HW+SEG )
        printToDisplay.controls.symbolAutoscrollOffB:setFillColor( unpack( buttonBaseColor ) )
        printToDisplay.controls.symbolAutoscrollOffB.isVisible = false

        printToDisplay.controls.clear = display.newRect( printToDisplay.controls, x+buttonOffsetX+buttonSize*0.5, y-buttonOffsetY+buttonSize*1.5 + 10, buttonSize, buttonSize )
        printToDisplay.controls.clear:setFillColor( unpack( buttonBaseColor ) )
        printToDisplay.controls.clear:addEventListener( "touch", controls )
        printToDisplay.controls.clear.id = "clear"

        local cross = {
            -HW,-HW+SEG,
            -HW+SEG,-HW,
            0,-SEG,
            HW-SEG,-HW,
            HW,-HW+SEG,
            SEG,0,
            HW,HW-SEG,
            HW-SEG,HW,
            0,SEG,
            -HW+SEG,HW,
            -HW,HW-SEG,
            -SEG,0
        }

        printToDisplay.controls.symbolClear = display.newPolygon( printToDisplay.controls, printToDisplay.controls.clear.x, printToDisplay.controls.clear.y, cross )
        printToDisplay.controls.symbolClear:setFillColor( unpack( buttonImageColor ) )

        -- Finally, "hijack" the global print function and add the outputToConsole functionality.
        function print( ... )
            outputToConsole( ... )
            _print( ... )
        end
        Runtime:addEventListener( "unhandledError", printUnhandledError )
    end
end

-- Restore the normal functionality to print() and clean up the UI.
function printToDisplay.remove()
    if started then
        started = false
        canScroll = false
        display.remove( output )
        output = nil
        display.remove( printToDisplay.controls )
        printToDisplay.controls = nil
        display.remove( printToDisplay.ui )
        printToDisplay.ui = nil
        print = _print -- Restore the normal global print function.
        Runtime:removeEventListener( "unhandledError", printUnhandledError )
    end
end

function printToDisplay.show()
    
end

function printToDisplay.hide()
    
end

return printToDisplay
