local ui = {}

-- simple function for creating backgrounds for demo scenes across Spyric plugins and code samples
function ui.create()
	display.setDefault( "background", 0.12 )

	display.setDefault( "background", 0.12 )
	local textColour = { 0.94, 0.67, 0.16 }
	local font = "fonts/OpenSans/OpenSansRegular.ttf"
	local fadeAlpha = 0.5

	local spyricLogo = display.newImageRect( "demoScene/spyric.png", 512, 512 )
	spyricLogo.alpha = fadeAlpha
	spyricLogo.x = display.contentCenterX
	spyricLogo.y = display.contentCenterY

	local topArea = display.newRect( display.contentCenterX, display.screenOriginY, display.actualContentWidth, 60 )
	topArea:setFillColor( 0, 0, 0, fadeAlpha )
	topArea.anchorY = 0

	local topText = display.newText( "Spyric Font Loader - Demo", topArea.x, topArea.y + topArea.height*0.5, font, 28 )
	topText:setFillColor( unpack( textColour ) )

	local bottomArea = display.newRect( display.contentCenterX, display.contentHeight-display.screenOriginY, display.actualContentWidth, 120 )
	bottomArea:setFillColor( 0, 0, 0, fadeAlpha )
	bottomArea.anchorY = 1

	local contents = {
	    text = "Spyric Font Loader is a free plugin for Corona SDK.\nFor documentation, please visit www.spyric.com.",
	    x = bottomArea.x,
	    y = bottomArea.y - bottomArea.height*0.5,
	    width = 560,
	    font = font,
	    fontSize = 24,
	    align = "center"
	}

	local bottomText = display.newText( contents )
	bottomText:setFillColor( unpack( textColour ) )
end

return ui
