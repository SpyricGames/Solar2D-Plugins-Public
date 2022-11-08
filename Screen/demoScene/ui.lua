---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2022 Spyric Games Ltd.         Last Updated: 8 November 2022  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local ui = {}

local spyricLogo, banner, header, footer, description

local headerHeight = 80
local footerHeight = 80

-- Create convenience properties for positioning the sample project contents.
-- (Note: this onResize function works by using the screen module's callback.)
function ui.onResize()
	-- Update header elements:
	banner.x, banner.y = display.contentCenterX, display.screenOriginY + headerHeight*0.5
	header.x, header.y = banner.x, banner.y
	spyricLogo.x = display.contentWidth - display.screenOriginX - spyricLogo.width*0.5 - 4
	spyricLogo.y = banner.y
	banner.width = display.actualContentWidth

	-- Update footer elements:
	footer.x, footer.y = display.contentCenterX, display.contentHeight - display.screenOriginY - footerHeight*0.5
	footer.width = display.actualContentWidth
	description.x, description.y = footer.x, footer.y
end

-- Create the default UI that is shared by all Spyric Games sample project.
function ui.create( projectName )
	projectName = projectName or "Untitled Project"

	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", 20/255, 21/255, 24/255 )

	-- Create header elements:
	banner = display.newRect( display.contentCenterX, display.screenOriginY + headerHeight*0.5, display.actualContentWidth, headerHeight )
	banner:setFillColor( 0.03 )

	header = display.newText( projectName .. " - Sample Project", banner.x, banner.y, "demoScene/font/Roboto-Black.ttf", 32 )
	header:setFillColor( 252/255, 186/255, 4/255 )

	spyricLogo = display.newImageRect( "demoScene/spyric-logo.png", 64, 64 )

	-- Create footer elements:
	footer = display.newRect( display.contentCenterX, display.contentHeight - display.screenOriginY - footerHeight*0.5, display.actualContentWidth, footerHeight )
	footer:setFillColor( 0.03 )

	description = display.newText({
	    text = projectName .. " is a free plugin for Solar2D.\nFor documentation, please visit https://docs.spyric.com/.",
	    x = footer.x,
	    y = footer.y,
	    width = 560,
	    font = "demoScene/font/Roboto-Light.ttf",
	    fontSize = 20,
	    align = "center"
	})
	description:setFillColor( 252/255, 186/255, 4/255 )

	description:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			system.openURL( "https://docs.spyric.com" )
		end
		return true
	end )
end

return ui
