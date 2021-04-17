local composer = require( "composer" )

local ui = {}

-- Simple function for creating backgrounds for demo scenes across Spyric plugins and code samples.
function ui.create( group )
	display.setDefault( "background", 0.12 )
	composer.colourA = { 0.94, 0.67, 0.16 }
	composer.colourAPress = { 1, 0.78, 0.12 }
	composer.font = "demoUI/OpenSans/OpenSansRegular.ttf"
	composer.header = { y = 140, size = 46 }
	composer.body = { size = 24 }

	display.setDefault( "magTextureFilter", "nearest" )
	display.setDefault( "minTextureFilter", "nearest" )

	local fadeAlpha = 0.5

	local spyricLogo = display.newImageRect( "demoUI/spyric.png", 512, 512 )
	spyricLogo.alpha = fadeAlpha
	spyricLogo.x = display.contentCenterX
	spyricLogo.y = display.contentCenterY

	local topArea = display.newRect( display.contentCenterX, display.screenOriginY, display.actualContentWidth, 60 )
	topArea:setFillColor( 0, 0, 0, fadeAlpha )
	topArea.anchorY = 0

	local topText = display.newText( "Spyric Morph - Sample Project", topArea.x, topArea.y + topArea.height*0.5, composer.font, 28 )
	topText:setFillColor( unpack( composer.colourA ) )

	local bottomArea = display.newRect( display.contentCenterX, display.contentHeight-display.screenOriginY, display.actualContentWidth, 120 )
	bottomArea:setFillColor( 0, 0, 0, fadeAlpha )
	bottomArea.anchorY = 1

	local contents =
	{
	    text = "Spyric Morph is a free plugin for Corona SDK.\nFor documentation, please visit www.spyric.com.",
	    x = bottomArea.x,
	    y = bottomArea.y - bottomArea.height*0.5,
	    width = 560,
	    font = composer.font,
	    fontSize = 24,
	    align = "center"
	}

	local bottomText = display.newText( contents )
	bottomText:setFillColor( unpack( composer.colourA ) )

	display.getCurrentStage():insert( composer.stage )
end

return ui
