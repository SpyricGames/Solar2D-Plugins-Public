---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2021 Spyric Games Ltd.                 Last Updated: 18 June 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Screen", true )

-- Require the screen module and set it to automatically monitor for resize events.
local screen = require("spyric.screen")

local group = nil

-- createUI is called after the screen properties have been updated.
local function createUI()
    display.remove(group)
    group = display.newGroup()
    
    -- Create red lines around the maximum screen bounds and a dot at the center of the screen:
    local fill = {1,0,0}
    local width = 8
    
    local tooltip = display.newText( group, "screen bounds (red)", screen.safe.minX + 20, 120, native.systemFontBold, 30 )
    tooltip.anchorX, tooltip.anchorY = 0, 0
    tooltip.fill = fill
    
    local minY = display.newLine( group, screen.minX, screen.minY, screen.maxX, screen.minY )
    minY.strokeWidth = width
    minY.stroke = fill
    
    local maxY = display.newLine( group, screen.minX, screen.maxY, screen.maxX, screen.maxY )
    maxY.strokeWidth = width
    maxY.stroke = fill
    
    local minX = display.newLine( group, screen.minX, screen.minY, screen.minX, screen.maxY )
    minX.strokeWidth = width
    minX.stroke = fill
    
    local maxX = display.newLine( group, screen.maxX, screen.minY, screen.maxX, screen.maxY )
    maxX.strokeWidth = width
    maxX.stroke = fill
    
    local center = display.newRect( group, screen.centerX, screen.centerY, width, width )
    center.fill = fill
    
    -- Create green lines around the safe area of the screen and a dot at the center of the safe area:
    local safe_fill = {0,1,0}
    local safe_width = 4
    
    local safe_tooltip = display.newText( group, "safe screen bounds (green)", screen.safe.minX + 20, tooltip.y + tooltip.height + 4, native.systemFontBold, 30 )
    safe_tooltip.anchorX, safe_tooltip.anchorY = 0, 0
    safe_tooltip.fill = safe_fill
    
    local safe_minY = display.newLine( group, screen.safe.minX, screen.safe.minY, screen.safe.maxX, screen.safe.minY )
    safe_minY.strokeWidth = safe_width
    safe_minY.stroke = safe_fill
    
    local safe_maxY = display.newLine( group, screen.safe.minX, screen.safe.maxY, screen.safe.maxX, screen.safe.maxY )
    safe_maxY.strokeWidth = safe_width
    safe_maxY.stroke = safe_fill
    
    local safe_minX = display.newLine( group, screen.safe.minX, screen.safe.minY, screen.safe.minX, screen.safe.maxY )
    safe_minX.strokeWidth = safe_width
    safe_minX.stroke = safe_fill
    
    local safe_maxX = display.newLine( group, screen.safe.maxX, screen.safe.minY, screen.safe.maxX, screen.safe.maxY )
    safe_maxX.strokeWidth = safe_width
    safe_maxX.stroke = safe_fill
    
    local safe_center = display.newRect( group, screen.safe.centerX, screen.safe.centerY, safe_width, safe_width )
    safe_center.fill = safe_fill
    
    local disclaimer = display.newText( group, "NB! The borders extend beyond the screens to make them easier to see. They their center points are on the edges.", screen.safe.minX + 20, safe_tooltip.y + safe_tooltip.height + 12, 400, 0, native.systemFont, 20 )
    disclaimer.anchorX, disclaimer.anchorY = 0, 0
end

-- Set a function that the screen module will call whenever the screen properties are updated.
screen.setCallback( createUI )
