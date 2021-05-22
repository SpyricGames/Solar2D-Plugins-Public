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

local ui = {}

local textColour = { 0.94, 0.67, 0.16 }
local font = "fonts/OpenSans/OpenSansRegular.ttf"
local fadeAlpha = 0.5

local headerHeight = 20
local footerHeight = 20

-- Create a default UI for the sample project.
function ui.create()
	display.setDefault( "background", 0.12 )

	local spyricLogo = display.newImageRect( "demoScene/spyric.png", 512, 512 )
	spyricLogo.alpha = fadeAlpha
	spyricLogo.x = display.contentCenterX
	spyricLogo.y = display.contentCenterY

	local banner = display.newRect( display.contentCenterX, display.screenOriginY, display.actualContentWidth, headerHeight )
	banner:setFillColor( 0, 0, 0, fadeAlpha )
	banner.anchorY = 0

	local header = display.newText( "Spyric Font Loader - Demo", banner.x, banner.y + banner.height*0.5, font, 28 )
	header:setFillColor( unpack( textColour ) )

	local footer = display.newRect( display.contentCenterX, display.contentHeight-display.screenOriginY, display.actualContentWidth, footerHeight )
	footer:setFillColor( 0, 0, 0, fadeAlpha )
	footer.anchorY = 1

	local contents = {
	    text = "Spyric Font Loader is a free plugin for Corona SDK.\nFor documentation, please visit www.spyric.com.",
	    x = footer.x,
	    y = footer.y - footer.height*0.5,
	    width = 560,
	    font = font,
	    fontSize = 24,
	    align = "center"
	}

	local description = display.newText( contents )
	description:setFillColor( unpack( textColour ) )
end

return ui
