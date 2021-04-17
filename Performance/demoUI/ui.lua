local composer = require( "composer" )

local ui = {}

-- Simple function for creating backgrounds for demo scenes across Spyric plugins and code samples.
function ui.create( group )
	display.setDefault( "background", 0.12 )
	composer.fontColour = { 0.94, 0.67, 0.16 }
	composer.font = "demoUI/OpenSans/OpenSansRegular.ttf"

	local fadeAlpha = 0.5

	local spyricLogo = display.newImageRect( "demoUI/spyric.png", 512, 512 )
	spyricLogo.xScale, spyricLogo.yScale = 0.9, 0.9
	spyricLogo.x = display.contentCenterX
	spyricLogo.y = display.contentCenterY
	spyricLogo.alpha = fadeAlpha

	local topArea = display.newRect( display.contentCenterX, display.screenOriginY, display.actualContentWidth, 80 )
	topArea:setFillColor( 0, 0, 0, fadeAlpha )
	topArea.anchorY = 0

	local topText = display.newText( "Spyric Performance - Sample Project", topArea.x, topArea.y + topArea.height*0.5, composer.font, 20 )
	topText:setFillColor( unpack( composer.fontColour ) )

	local bottomArea = display.newRect( display.contentCenterX, display.contentHeight-display.screenOriginY, display.actualContentWidth, 80 )
	bottomArea:setFillColor( 0, 0, 0, fadeAlpha )
	bottomArea.anchorY = 1

	local contents =
	{
	    text = "Spyric Performance is a free plugin for Corona game engine.\nFor documentation, please visit www.spyric.com/docs.",
	    x = bottomArea.x,
	    y = bottomArea.y - bottomArea.height*0.5,
	    width = 800,
	    font = composer.font,
	    fontSize = 20,
	    align = "center"
	}

	local bottomText = display.newText( contents )
	bottomText:setFillColor( unpack( composer.fontColour ) )

	display.getCurrentStage():insert( composer.stage )
end

return ui
