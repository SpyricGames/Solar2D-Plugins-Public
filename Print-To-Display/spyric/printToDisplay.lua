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

-- Localised functions.
local _print = print
local concat = table.concat
local find = string.find
local sub = string.sub
local tostring = tostring
local type = type

-- Localised console variables.
local maxTextureSize = system.getInfo( "maxTextureSize" ) or 1024
local blockTouch = true
local autoscroll = true
local canScroll = false
local printList = {}
local scrollThreshold = 0
local currentY = 0
local textX = 0
local textWidth = 0
local paddingRow = 0
local fontSize = 0
local font
local useHighlighting
local activeWhenHidden

-- Console display objects.
local container = nil
local background = nil
local output = nil
local buttonScroll = nil
local buttonToggle = nil
local buttonClear = nil

----------------------------------------------
-- Default visual parameters:
----------------------------------------------
-- NB! These should be edited only via passing
-- a table as an argument to start() function.
----------------------------------------------
local style = {
    -- Console (general):
    x = display.screenOriginX,
    y = display.screenOriginY,
    width = display.actualContentWidth/3,
    height = display.actualContentHeight,
    alpha = 0.9,
    bgColor = { 0 },
    anchorX = 0,
    anchorY = 0,
    -- Console (text):
    font = native.systemFont,
    fontSize = 14,
    textColor = { 0.9 },
    textColorError = { 0.9, 0, 0 },
    textColorWarning = { 0.9, 0.75, 0 },
    paddingRow = 4,
    paddingLeft = 10,
    paddingRight = 10,
    paddingTop = 10,
    paddingBottom = 10,
    -- Console (functional):
    useHighlighting = true,
    activeWhenHidden = true,
    blockTouch = true,
    -- Buttons:
    buttonPos = "right",
    buttonSize = 32,
    buttonRounding = 4,
    buttonPadding = 10,
    buttonBaseColor = { 0.2 },
    buttonIconColor = { 0.8 },
}
----------------------------------------------

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
                autoscroll = false
                buttonScroll.on.isVisible = false
                buttonScroll.off.isVisible = true
                output.y = toY
            else
                objectStart = output.y
                eventStart = event.y
                if toY <= 0 then
                    autoscroll = true
                    buttonScroll.on.isVisible = true
                    buttonScroll.off.isVisible = false
                end
            end
        end
    else
        display.getCurrentStage():setFocus( nil )
        event.target.isTouched = false
    end
    return blockTouch
end

local function printUnhandledError( event )
    print( event.errorMessage )
end

-- Output a print to the in-app console.
local function outputToConsole( ... )
    for i = 1, arg.n do
        printList[i] = tostring( arg[i] )
    end

    local log = display.newText({
        parent = output,
        text = concat( printList, "\t" ),
        x = textX,
        y = currentY,
        width = textWidth,
        align = "left",
        height = 0,
        font = font,
        fontSize = fontSize
    })
    
    -- Especially on mobile devices, if the user tries to print massive strings,
    -- such sending a network request to a page and then trying to print out the
    -- entire event.response, then the device may run out of texture memory.
    if log.width >= maxTextureSize or log.height >= maxTextureSize then
        display.remove(log)
        log = display.newText({
            parent = output,
            text = "WARNING: message is too long to print:\n\n" .. sub(log.text,1,32) .. "...",
            x = textX,
            y = currentY,
            width = textWidth,
            align = "left",
            height = 0,
            font = font,
            fontSize = fontSize
        })
    end
    log.anchorX, log.anchorY = 0, 0
    currentY = log.y + log.height + paddingRow
    
    -- Reduce, reuse and recycle.
    for i = 1, arg.n do
        printList[i] = nil
    end

    if useHighlighting then
        if find( log.text, "ERROR:" ) == 1 then
            log.fill = textColorError
        elseif find( log.text, "WARNING:" ) == 1 then
            log.fill = textColorWarning
        else
            log.fill = textColor
        end
    else
        log.fill = textColor
    end

    local newY = log.y + log.height
    if not canScroll and newY >= scrollThreshold then
        background:addEventListener( "touch", scroll )
        canScroll = true
    end
    
    if canScroll then
        maxY = newY - scrollThreshold
        if autoscroll then
            output.y = -maxY
        end
    end
end

local function consolePrint( start )
    if start then
        -- "Hijack" the global print function and add outputToConsole to it.
        function print( ... )
            outputToConsole( ... )
            _print( ... )
        end
        Runtime:addEventListener( "unhandledError", printUnhandledError )
    else
        print = _print -- Restore the normal global print function.
        Runtime:removeEventListener( "unhandledError", printUnhandledError )
    end
end

-- Button event listener.
local function controls( event )
    if event.phase == "began" then
        -- Toggle auto scroll on or off.
        if event.target.id == "autoscroll" then
            autoscroll = not autoscroll
            buttonScroll.on.isVisible = not buttonScroll.on.isVisible
            buttonScroll.off.isVisible = not buttonScroll.off.isVisible
            if autoscroll then output.y = -maxY end
        
        -- Toggle the console's visibility (and activity).
        elseif event.target.id == "toggle" then
            local isVisible = not container.isVisible
            container.isVisible = isVisible
            buttonScroll.isVisible = isVisible
            buttonClear.isVisible = isVisible
            
            if isVisible then
                buttonToggle.x = buttonToggle.xFrom
            else
                buttonToggle.x = buttonToggle.xTo
            end
            buttonToggle.xScale = buttonToggle.xScale*-1
            
            if not activeWhenHidden then
                if isVisible then
                    consolePrint(true)
                else
                    consolePrint()
                end
            end
            
        else -- Clear all text.
            background:removeEventListener( "touch", scroll )
            buttonScroll.on.isVisible = true
            buttonScroll.off.isVisible = false
            canScroll = false
            autoscroll = true
            
            display.remove( output )
            output = display.newGroup()
            container:insert( output, true )
            currentY = style.paddingTop-style.height*0.5
            output.y = 0
        end
    end
    return true
end

-- Create the in-app console and start sending print() to the in-app console as well.
function printToDisplay.start(...)
    if console then
        print( "\nSpyric Print to Display: console has already started.\n" )
    else
        local t = {...}
        local startVisible = type(t[1]) ~= "boolean" or t[1]
        local customStyle = type(t[#t]) == "table" and t[#t] or {}
        
        -- Update style with user input.
        for i, v in pairs( customStyle ) do
            style[i] = v
        end
        
        -- Localise style properties.
        local x = style.x
        local y = style.y
        local width = style.width
        local height = style.height
        local anchorX = style.anchorX
        local anchorY = style.anchorY
        local alpha = style.alpha
        local buttonSize = style.buttonSize
        local buttonRounding = style.buttonRounding
        local buttonPadding = style.buttonPadding
        local buttonBaseColor = style.buttonBaseColor
        local buttonIconColor = style.buttonIconColor
        local paddingTop = style.paddingTop
        local paddingBottom = style.paddingBottom
        local paddingLeft = style.paddingLeft
        local paddingRight = style.paddingRight
        
        -- Assign initial console properties (localised for speed).
        scrollThreshold = (height-(paddingTop+paddingBottom))*0.5
        currentY = paddingTop-height*0.5
        textWidth = width - (paddingLeft + paddingRight)
        paddingRow = style.paddingRow
        textX = paddingLeft-width*0.5
        textColor = style.textColor
        textColorError = style.textColorError
        textColorWarning = style.textColorWarning
        fontSize = style.fontSize
        font = style.font
        useHighlighting = style.useHighlighting
        activeWhenHidden = style.activeWhenHidden
        blockTouch = style.blockTouch
        autoscroll = true
        canScroll = false
        
        -- Create the console's container.
        container = display.newContainer( width, height )
        container.anchorX, container.anchorY = anchorX, anchorY
        container.x, container.y = x, y
        container.alpha = alpha
        
        -- Create the console's background.
        background = display.newRect( container, 0, 0, width, height )
        background.fill = style.bgColor
        
        -- Create the console output group.
        output = display.newGroup()
        container:insert( output, true )

        -- Calculate dynamic sizes for the icons.
        local SEG = buttonSize*0.2 -- Segment.
        local HW = buttonSize*0.4 -- (Approximate) half width of a button.

        -- Calculate the position of the buttons based on the style anchors and button positioning.
        local buttonY, buttonX = y-anchorY*height+buttonSize*0.5
        if style.buttonPos == "left" then
            buttonX = x-anchorX*width-buttonSize*0.5
        else
            buttonX = x+(1-anchorX)*width+buttonSize*0.5
        end

        -- Toggle visibility button:
        ----------------------------
        buttonToggle = display.newGroup()
        buttonToggle.x, buttonToggle.y = buttonX, buttonY
        buttonToggle.alpha = alpha
        buttonToggle:addEventListener( "touch", controls )
        buttonToggle.id = "toggle"
        
        buttonToggle.bg = display.newRoundedRect( buttonToggle, 0, 0, buttonSize, buttonSize, buttonRounding )
        buttonToggle.bg.fill = buttonBaseColor
        
        -- Toggle icon.
        buttonToggle.toggle = display.newPolygon( buttonToggle, 0, 0,
            {
                -HW,-HW+SEG,
                -HW+SEG,-HW,
                SEG,0,
                -HW+SEG,HW,
                -HW,HW-SEG,
                -SEG,0
            }
        )
        buttonToggle.toggle.fill = buttonIconColor
        
        -- Coordinates to move the toggle button to/from when toggling the console visibility.
        buttonToggle.xFrom = buttonX
        if style.buttonPos == "left" then
            buttonToggle.xTo = buttonX + container.width
            buttonToggle.toggle.xScale = 1
        else
            buttonToggle.xTo = buttonX - container.width
            buttonToggle.toggle.xScale = -1
        end
        
        -- Auto scroll button:
        ----------------------------
        buttonScroll = display.newGroup()
        buttonScroll.x, buttonScroll.y = buttonX, buttonToggle.y + buttonToggle.height + buttonPadding
        buttonScroll.alpha = alpha
        buttonScroll:addEventListener( "touch", controls )
        buttonScroll.id = "autoscroll"

        buttonScroll.bg = display.newRoundedRect( buttonScroll, 0, 0, buttonSize, buttonSize, buttonRounding )
        buttonScroll.bg.fill = buttonBaseColor
        
        -- Play icon.
        buttonScroll.on = display.newPolygon( buttonScroll, 0, 0,
            {
                -HW+SEG,-HW+SEG*0.5,
                HW,0,
                -HW+SEG,HW-SEG*0.5
            }
        )
        buttonScroll.on.fill = buttonIconColor
        
        -- Pause icon.
        buttonScroll.off = display.newGroup()
        buttonScroll:insert( buttonScroll.off )
        buttonScroll.off.isVisible = false
        local pauseLeft = display.newRect( buttonScroll.off, -SEG, 0, SEG, HW+SEG )
        pauseLeft.fill = buttonIconColor
        local pauseRight = display.newRect( buttonScroll.off, SEG, 0, SEG, HW+SEG )
        pauseRight.fill = buttonIconColor
        
        -- Clear button:
        ----------------------------
        buttonClear = display.newGroup()
        buttonClear.x, buttonClear.y = buttonX, buttonScroll.y + buttonScroll.height + buttonPadding
        buttonClear.alpha = alpha
        buttonClear:addEventListener( "touch", controls )
        buttonClear.id = "clear"
        
        buttonClear.bg = display.newRoundedRect( buttonClear, 0, 0, buttonSize, buttonSize, buttonRounding )
        buttonClear.bg.fill = buttonBaseColor
        
        -- Clear icon.
        local clear = display.newPolygon( buttonClear, 0, 0,
            {
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
        )
        clear.fill = buttonIconColor
        
        ----------------------------

        local parent = customStyle.parent
        if parent then
            parent:insert( container )
            parent:insert( buttonScroll )
            parent:insert( buttonToggle )
            parent:insert( buttonClear )
        end
        
        consolePrint(true)
        if not startVisible then
            controls( {phase="began",target={id="toggle"}} )
        end
    end
end

-- Remove the in-app console and restore normal print() functionality.
function printToDisplay.remove()
    if console then
        print( "\nSpyric Print to Display: console isn't running.\n" )
    else
        display.remove( container )
        container = nil
        output = nil
        background = nil
        display.remove( buttonScroll )
        buttonScroll = nil
        display.remove( buttonToggle )
        buttonToggle = nil
        display.remove( buttonClear )
        buttonClear = nil
        
        consolePrint()
    end
end

return printToDisplay
