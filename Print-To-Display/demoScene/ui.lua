---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2022 Spyric Games Ltd.         Last Updated: 20 November 2022 --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local ui = {}

local spyricLogo, banner, header, footer, description

local headerHeight = 80
local footerHeight = 80
local minPadding = 20
local logoPadding = 4
local colorText = { 252/255, 186/255, 4/255 }
local colorBG = { 20/255, 21/255, 24/255 }
local colorBanner = { 8/255 }

ui.headerHeight = headerHeight
ui.footerHeight = footerHeight

local function onResize( event )
	-- Create convenience properties for positioning the sample project contents.
	ui.minY = display.screenOriginY + headerHeight
	ui.maxY = display.contentHeight - display.screenOriginY - footerHeight

	-- Update header elements:
	banner.x, banner.y = display.contentCenterX, display.screenOriginY + headerHeight*0.5
	header.x, header.y = banner.x, banner.y
	spyricLogo.x = display.contentWidth - display.screenOriginX - spyricLogo.width*0.5 - 4
	spyricLogo.y = banner.y
	banner.width = display.actualContentWidth

	local spaceTop = banner.width - (logoPadding + spyricLogo.width + minPadding)*2
	local scaleTop = math.min( 1, spaceTop / header.width )
	header.xScale, header.yScale = scaleTop, scaleTop

	-- Update footer elements:
	footer.x, footer.y = display.contentCenterX, display.contentHeight - display.screenOriginY - footerHeight*0.5
	footer.width = display.actualContentWidth
	description.x, description.y = footer.x, footer.y

	local spaceBottom = footer.width - minPadding*2
	local scaleBottom = math.min( 1, spaceBottom / description.width )
	description.xScale, description.yScale = scaleBottom, scaleBottom
end

-- Create the default UI that is shared by all Spyric Games sample project.
function ui.create( projectName )
	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", unpack(colorBG) )

	banner = display.newRect( display.contentCenterX, display.screenOriginY + headerHeight*0.5, display.actualContentWidth, headerHeight )
	banner:setFillColor( unpack(colorBanner) )

	spyricLogo = display.newImageRect( "demoScene/spyric-logo.png", 64, 64 )
	spyricLogo.x = display.contentWidth - display.screenOriginX - spyricLogo.width*0.5 - logoPadding
	spyricLogo.y = banner.y

	header = display.newText( projectName .. " - Sample Project", banner.x, banner.y, "demoScene/font/Roboto-Black.ttf", 32 )
	header:setFillColor( colorText[1], colorText[2], colorText[3] )

	footer = display.newRect( display.contentCenterX, display.contentHeight - display.screenOriginY - footerHeight*0.5, display.actualContentWidth, footerHeight )
	footer:setFillColor( unpack(colorBanner) )

	description = display.newText({
	    text = projectName .. " is a free plugin for Solar2D.\nFor documentation, please visit https://docs.spyric.com/.",
	    x = footer.x,
	    y = footer.y,
	    width = 560,
	    font = "demoScene/font/Roboto-Light.ttf",
	    fontSize = 20,
	    align = "center"
	})
	description:setFillColor( unpack(colorText) )

	description:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			system.openURL( "https://docs.spyric.com" )
		end
		return true
	end )

	Runtime:addEventListener( "resize", onResize )
	onResize()
end

return ui
