---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 21 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local ui = {}

local headerHeight = 80
local footerHeight = 80

-- Create convenience properties for positioning the sample project contents.
local function onResize( event )
	display.minY = display.screenOriginY + headerHeight
	display.maxY = display.contentHeight - display.screenOriginY - footerHeight
end

-- Create the default UI that is shared by all Spyric Games sample project.
function ui.create( projectName, isFree )
	local projectName = projectName or "Untitled Project"
	local isFree = isFree and true or false
		
	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", 20/255, 21/255, 24/255 )
	
	local banner = display.newRect( display.contentCenterX, display.screenOriginY + headerHeight*0.5, display.actualContentWidth, headerHeight )
	banner:setFillColor( 0.03 )
	
	local spyricLogo = display.newImageRect( "demoScene/spyric-logo.png", 64, 64 )
	spyricLogo.x = display.contentWidth - display.screenOriginX - spyricLogo.width*0.5 - 4
	spyricLogo.y = banner.y

	local header = display.newText( projectName .. " - Sample Project", banner.x, banner.y, "demoScene/font/Roboto-Black.ttf", 32 )
	header:setFillColor( 252/255, 186/255, 4/255 )
	
	local footer = display.newRect( display.contentCenterX, display.contentHeight - display.screenOriginY - footerHeight*0.5, display.actualContentWidth, footerHeight )
	footer:setFillColor( 0.03 )

	local description = display.newText({
	    text = projectName .. " is a " .. (isFree and "free" or "premium") .. " plugin for Solar2D.\nFor documentation, please visit https://docs.spyric.com/.",
	    x = footer.x,
	    y = footer.y,
	    width = 560,
	    font = "demoScene/font/Roboto-Light.ttf",
	    fontSize = 20,
	    align = "center"
	})
	description:setFillColor( 252/255, 186/255, 4/255 )
	
	if system.getInfo( "environment" ) == "simulator" then
		description:addEventListener( "touch", function(event)
			if event.phase == "ended" then
				system.openURL( "https://docs.spyric.com" )
			end
			return true
		end )
	end
	
	Runtime:addEventListener( "resize", onResize )
	onResize()
end

return ui
