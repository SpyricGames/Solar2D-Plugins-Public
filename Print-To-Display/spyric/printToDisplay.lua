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

--==============================================================================
-- Important! Important! Important! Important! Important! Important! Important!
--==============================================================================
-- If you want to make changes to this module and you need to use debug prints,
-- then make sure to use _print() inside of thse functions because using the 
-- regular print() inside the wrong function will result in an infinite loop.
--==============================================================================

local M = {}

-- Localised functions.
local _print = print
local _type = type
local _unpack = unpack
local _tostring = tostring
local _concat = table.concat

M.autoscroll = true
local canScroll = false
local started = false
local output

-- Visual customisation variables.
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
                M.autoscroll = false
                M.controls.symbolAutoscrollOn.isVisible = false
                M.controls.symbolAutoscrollOffA.isVisible = true
                M.controls.symbolAutoscrollOffB.isVisible = true
                output.y = toY
            else
                objectStart = output.y
                eventStart = event.y
                if toY <= 0 then
                    M.autoscroll = true
                    M.controls.symbolAutoscrollOn.isVisible = true
                    M.controls.symbolAutoscrollOffA.isVisible = false
                    M.controls.symbolAutoscrollOffB.isVisible = false
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
            M.autoscroll = not M.autoscroll
            M.controls.symbolAutoscrollOn.isVisible = not M.controls.symbolAutoscrollOn.isVisible
            M.controls.symbolAutoscrollOffA.isVisible = not M.controls.symbolAutoscrollOffA.isVisible
            M.controls.symbolAutoscrollOffB.isVisible = not M.controls.symbolAutoscrollOffB.isVisible
            if M.autoscroll then output.y = -maxY end
        else -- Clear all text.
            M.ui.bg:removeEventListener( "touch", scroll )
            canScroll = false
            M.autoscroll = true
            M.controls.symbolAutoscrollOn.isVisible = true
            M.controls.symbolAutoscrollOffA.isVisible = false
            M.controls.symbolAutoscrollOffB.isVisible = false
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
local function printToDisplay( ... )
    local t = {...}
    for i = 1, #t do
        t[i] = _tostring( t[i] )
    end
    local text = _concat( t, "    " )

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
            output.row[#output.row]:setFillColor( _unpack( textColorError ) )
        elseif output.row[#output.row].text:sub(1,8) == "WARNING:" then
            output.row[#output.row]:setFillColor( _unpack( textColorWarning ) )
        else
            output.row[#output.row]:setFillColor( _unpack( textColor ) )
        end
    else
        output.row[#output.row]:setFillColor( _unpack( textColor ) )
    end

    if not canScroll and output.row[#output.row].y + output.row[#output.row].height >= scrollThreshold then
        M.ui.bg:addEventListener( "touch", scroll )
        canScroll = true
    end

    if canScroll then
        maxY = output.row[#output.row].y + output.row[#output.row].height - scrollThreshold
        if M.autoscroll then
            output.y = -maxY
        end
    end
end

-- Optional function that will customise any or all visual features of the module.
function M.setStyle( s )
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
        -- If printToDisplay is already running, then clear it.
        if started then
            M.stop()
            M.start()
        end
    end
end

-- Create the UI and make the default print() calls also "print" on screen.
function M.start()
    if not started then
        started = true
        -- Create container where the background and text are added.
        M.ui = display.newContainer( width, height )
        if parent then parent:insert( M.ui ) end
        M.ui.anchorX, M.ui.anchorY = anchorX, anchorY
        M.ui.x, M.ui.y = x, y
        M.ui.alpha = alpha
        -- Create the background.
        M.ui.bg = display.newRect( M.ui, 0, 0, width, height )
        M.ui.bg:setFillColor( _unpack( bgColor ) )
        -- All rows of text are added to output group.
        output = display.newGroup()
        M.ui:insert( output, true )
        output.row = {}
        -- Create external control buttons
        M.controls = display.newGroup()
        if parent then parent:insert( M.controls ) end

        local SEG = buttonSize*0.2 -- Segment.
        local HW = buttonSize*0.4 -- (Approximate) half width.
        local buttonOffsetX = (1-anchorX)*width
        local buttonOffsetY = anchorY*height

        M.controls.scroll = display.newRect( M.controls, x+buttonOffsetX+buttonSize*0.5, y-buttonOffsetY+buttonSize*0.5, buttonSize, buttonSize )
        M.controls.scroll:setFillColor( _unpack( buttonBaseColor ) )
        M.controls.scroll:addEventListener( "touch", controls )
        M.controls.scroll.id = "autoscroll"

        local play = {
            -HW+SEG,-HW+SEG*0.5,
            HW,0,
            -HW+SEG,HW-SEG*0.5
        }
        -- This has a "play" symbol and pressing it will pause autoscroll.
        M.controls.symbolAutoscrollOn = display.newPolygon( M.controls, M.controls.scroll.x, M.controls.scroll.y, play )
        M.controls.symbolAutoscrollOn:setFillColor( _unpack( buttonImageColor ) )
        -- This has the "pause" symbol and pressing it will resume autoscroll.
        M.controls.symbolAutoscrollOffA = display.newRect( M.controls, M.controls.scroll.x, M.controls.scroll.y, HW+SEG, HW+SEG )
        M.controls.symbolAutoscrollOffA:setFillColor( _unpack( buttonImageColor ) )
        M.controls.symbolAutoscrollOffA.isVisible = false
        M.controls.symbolAutoscrollOffB = display.newRect( M.controls, M.controls.scroll.x, M.controls.scroll.y, SEG, HW+SEG )
        M.controls.symbolAutoscrollOffB:setFillColor( _unpack( buttonBaseColor ) )
        M.controls.symbolAutoscrollOffB.isVisible = false

        M.controls.clear = display.newRect( M.controls, x+buttonOffsetX+buttonSize*0.5, y-buttonOffsetY+buttonSize*1.5 + 10, buttonSize, buttonSize )
        M.controls.clear:setFillColor( _unpack( buttonBaseColor ) )
        M.controls.clear:addEventListener( "touch", controls )
        M.controls.clear.id = "clear"

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

        M.controls.symbolClear = display.newPolygon( M.controls, M.controls.clear.x, M.controls.clear.y, cross )
        M.controls.symbolClear:setFillColor( _unpack( buttonImageColor ) )

        -- Finally, "hijack" the global print function and add the printToDisplay functionality.
        function print( ... )
            printToDisplay( ... )
            _print( ... )
        end
        Runtime:addEventListener( "unhandledError", printUnhandledError )
    end
end

-- Restore the normal functionality to print() and clean up the UI.
function M.stop()
    if started then
        started = false
        canScroll = false
        display.remove( output )
        output = nil
        display.remove( M.controls )
        M.controls = nil
        display.remove( M.ui )
        M.ui = nil
        print = _print -- Restore the normal global print function.
        Runtime:removeEventListener( "unhandledError", printUnhandledError )
    end
end

return M
