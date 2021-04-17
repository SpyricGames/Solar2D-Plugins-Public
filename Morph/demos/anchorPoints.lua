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

	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local button = btn.new( title )
	sceneGroup:insert( button )

	local description = display.newText( sceneGroup, "The objects below are all morphed from the same original shape and they have custom anchor points.", display.contentCenterX, title.y + title.height*0.5 + 8, 600, 400, composer.font, composer.body.size )
	description.anchorY = 0

	-- All of the four triangles are creates using the same vertices.
	local vertices = { -40, 40,	40, -40, 40, 40	}

	local xCentre = display.contentCenterX
	local yCentre = display.contentCenterY + 40

	local triangleA = display.newPolygon( objectGroup, 300, 500, vertices )
	triangleA.anchorX, triangleA.anchorY = 1, 1
	triangleA:setFillColor( 0.8, 0, 0 )
	spyricMorph.addBody( triangleA, "static", { shape = vertices } )
	triangleA:morph( 2, 2 )

	local triangleB = display.newPolygon( objectGroup, 438, 500, vertices )
	triangleB.anchorX, triangleB.anchorY = 0, 1
	triangleB:setFillColor( 0, 0.8, 0 )
	spyricMorph.addBody( triangleB, "static", { shape = vertices } )
	triangleB:morph( -1.2, 2.4 )

	local triangleC = display.newPolygon( objectGroup, 164, 558, vertices )
	triangleC.anchorX, triangleC.anchorY = 0.4, 0.9
	triangleC:setFillColor( 0.8, 0.8, 0 )
	spyricMorph.addBody( triangleC, "static", { shape = vertices } )
	triangleC:morph( 2.8, -2 )

	local triangleD = display.newPolygon( objectGroup, 365, 585, vertices )
	triangleD.anchorX, triangleD.anchorY = 0.8, 0.2
	triangleD:setFillColor( 0, 0, 0.8 )
	spyricMorph.addBody( triangleD, "static", { shape = vertices } )
	triangleD:morph( -1.5, -0.7 )

	local disclaimer = display.newText( sceneGroup, "NB! Objects are morphed around their anchors. This is something to remember if you want to mirror/flip an object (see triangle for example).", display.contentCenterX, 720, 600, 400, composer.font, 26 )
	disclaimer.anchorY = 0

	local triangleE = display.newPolygon( objectGroup, 560, 550, vertices )
	triangleE.anchorY = 0
	triangleE:setFillColor( 0.8, 0, 0.8 )
	spyricMorph.addBody( triangleE, "static", { shape = vertices } )

	-- A simple function for flipping triangleE vertically. Do note that since triangleE's anchorY is 0,
	-- vertically flipping the object will do so over the anchor point instead of the object's center.
	local flipDirection = 1
	local function flip()
		triangleE:morph( 1, 2*flipDirection )
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
