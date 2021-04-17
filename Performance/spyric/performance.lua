local M = {}

----------------------------------
-- Customisable visual parameters:
----------------------------------
local x = display.contentCenterX
local y = display.screenOriginY
local paddingHorizontal = 20
local paddingVertical = 10
local fontColor = { 1 }
local bgColor = { 0 }
local fontSize = 28
local font = "Helvetica"
----------------------------------

-- Localising global functions.
local getTimer = system.getTimer
local getInfo = system.getInfo
local floor = math.floor

-- Constant is multiplied by 100 to allow for the use of floor() later on.
local C = 100 / 1024^2
local prevTime = 0
M.isActive = true
M.maxWidth = 0


local function update()
    local curTime = getTimer()
    collectgarbage( "collect" )

    M.text.text = tostring(floor( 1000 / (curTime - prevTime))) .. " " ..
    tostring(floor(getInfo( "textureMemoryUsed" ) * C) * 0.01) .. " " ..
    tostring(floor(collectgarbage( "count" )))

    -- Adjust the performance meter width if necessary.
    if M.text.width > M.maxWidth then
        M.maxWidth = M.text.width
        M.bg.width = M.text.width + paddingHorizontal*2
    end

    M.bg:toFront()
    M.text:toFront()
    prevTime = curTime
end


local function toggleMeter( event )
    if event.phase == "ended" or event.phase == "cancelled" then
        collectgarbage( "collect" )

        if M.isActive then
            Runtime:removeEventListener( "enterFrame", update )
        else
            Runtime:addEventListener( "enterFrame", update )
        end
        M.text.isVisible = not M.text.isVisible
        M.bg.isVisible = not M.bg.isVisible
        M.isActive = not M.isActive
    end
end


local function createMeter()
    M.text = display.newText( "00 0.00 0000", x, y + paddingVertical, font, fontSize )
    M.text:setFillColor( unpack( fontColor ) )
    M.text.anchorY = 0
    M.maxWidth = M.text.width

    M.bg = display.newRect( x, y, M.text.width + paddingHorizontal*2, M.text.height + paddingVertical*2 )
    M.bg:addEventListener( "touch", toggleMeter )
    M.bg:setFillColor( unpack( bgColor ) )
    M.bg.isHitTestable = true
    M.bg.anchorY = 0
end


function M:start( startVisible )
    createMeter()
    if type( startVisible ) == "boolean" and startVisible == false then
        M.text.isVisible = not M.text.isVisible
        M.bg.isVisible = not M.bg.isVisible
        M.isActive = not M.isActive
    else
        Runtime:addEventListener( "enterFrame", update )
    end
end


return M
