local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local spyricMorph = require("spyric.morph")

local objectGroup, flipTimer

function scene:create( event )
	local sceneGroup = self.view
	objectGroup = display.newGroup()
	sceneGroup:insert( objectGroup )

	local button = btn.new()
	sceneGroup:insert( button )

	local title = display.newText( sceneGroup, event.params[1], button.x - button.width*0.5, button.y + 80, "demoScene/font/Roboto-Regular.ttf", 40 )
	title:setFillColor( 252/255, 186/255, 4/255 )
	title.anchorX = 0

	local description = display.newText( sceneGroup,
		"These triangles here were all morphed from the same original shape and they each have a different anchor point.\n\n" ..
		"Note that objects are morphed around their anchors. See the pink triangle for an example.", 
		title.x, title.y + title.height + 12, 440, 0, "demoScene/font/Roboto-Regular.ttf", 24
	)
	description.anchorX, description.anchorY = 0, 0

	-- All of the four triangles are creates using the same vertices.
	local vertices = { -40, 40,	40, -40, 40, 40	}

	local xCentre = display.contentCenterX + 220
	local yCentre = display.contentCenterY

	local triangleRed = display.newPolygon( objectGroup, xCentre - 19, yCentre - 20, vertices )
	triangleRed.anchorX, triangleRed.anchorY = 1, 1
	triangleRed:setFillColor( 0.8, 0, 0 )
	spyricMorph.addBody( triangleRed, "static", { shape = vertices } )
	triangleRed:morph( 2, 2 )

	local triangleGreen = display.newPolygon( objectGroup, xCentre + 116, yCentre - 20, vertices )
	triangleGreen.anchorX, triangleGreen.anchorY = 0, 1
	triangleGreen:setFillColor( 0, 0.8, 0 )
	spyricMorph.addBody( triangleGreen, "static", { shape = vertices } )
	triangleGreen:morph( -1.2, 2.4 )

	local triangleYellow = display.newPolygon( objectGroup, xCentre - 154, yCentre + 35, vertices )
	triangleYellow.anchorX, triangleYellow.anchorY = 0.4, 0.9
	triangleYellow:setFillColor( 0.8, 0.8, 0 )
	spyricMorph.addBody( triangleYellow, "static", { shape = vertices } )
	triangleYellow:morph( 2.8, -2 )

	local triangleBlue = display.newPolygon( objectGroup, xCentre + 44, yCentre + 64, vertices )
	triangleBlue.anchorX, triangleBlue.anchorY = 0.8, 0.2
	triangleBlue:setFillColor( 0, 0, 0.8 )
	spyricMorph.addBody( triangleBlue, "static", { shape = vertices } )
	triangleBlue:morph( -1.5, -0.7 )

	local trianglePink = display.newPolygon( objectGroup, 900, yCentre, vertices )
	trianglePink.anchorY = 0
	trianglePink:setFillColor( 0.8, 0, 0.8 )
	spyricMorph.addBody( trianglePink, "static", { shape = vertices } )

	-- A simple function for flipping trianglePink vertically. Do note that since trianglePink's anchorY is 0,
	-- vertically flipping the object will do so over the anchor point instead of the object's center.
	local flipDirection = 1
	local function flip()
		trianglePink:morph( 1, 2*flipDirection )
		if flipDirection == 1 then
			flipDirection = -1
		else
			flipDirection = 1
		end
	end
	flipTimer = timer.performWithDelay( 350, flip, 0 )

	-- The lines between the triangles.
	local line1 = display.newLine( objectGroup, xCentre, yCentre-160, xCentre, yCentre+160 )
	line1.strokeWidth = 4
	local line2 = display.newLine( objectGroup, xCentre-160, yCentre, xCentre+160, yCentre )
	line2.strokeWidth = 4

	objectGroup.alpha = 0
	transition.to( objectGroup, { time=600, alpha=1, transition=easing.outQuad } )
end

function scene:hide( event )
	if ( event.phase == "will" ) then
		timer.cancel( flipTimer )
		transition.to( objectGroup, { time=600, alpha=0, delay=80, transition=easing.outQuad } )
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )

return scene
