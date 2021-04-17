local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local physicsData = (require "shapedefs").physicsData(1.0)
local spyricMorph = require("spyric.morph")

local objectGroup

function scene:create( event )

	local sceneGroup = self.view
	objectGroup = display.newGroup()
	sceneGroup:insert( objectGroup )

	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local button = btn.new( title )
	sceneGroup:insert( button )

	local description = display.newText( sceneGroup, "You can load any shape made using the PhysicsEditor and morph them freely.", display.contentCenterX, title.y + title.height*0.5 + 8, 600, 400, composer.font, composer.body.size )
	description.anchorY = 0

	local xCentre = display.contentCenterX
	local yCentre = display.contentCenterY + 80
	local imageOffset = 140
	local imageScale = 1.4

	-- Original image scaled based on imageScale variable.
	local chickenNormal = display.newImage( objectGroup, "chicken.png")
	chickenNormal.x = xCentre - imageOffset
	chickenNormal.y = yCentre - imageOffset
	spyricMorph.addBody( chickenNormal, "static", physicsData:get("chicken") )
	chickenNormal:morph( imageScale, imageScale )

	-- Horizontally mirrored/flipped.
	local chickenMirrorH = display.newImage( objectGroup, "chicken.png")
	chickenMirrorH.x = xCentre + imageOffset
	chickenMirrorH.y = yCentre - imageOffset
	spyricMorph.addBody( chickenMirrorH, "static", physicsData:get("chicken") )
	chickenMirrorH:morph(-imageScale, imageScale )

	-- Vertically mirrored/flipped.
	local chickenMirrorV = display.newImage( objectGroup, "chicken.png")
	chickenMirrorV.x = xCentre - imageOffset
	chickenMirrorV.y = yCentre + imageOffset
	spyricMorph.addBody( chickenMirrorV, "static", physicsData:get("chicken") )
	chickenMirrorV:morph( imageScale, -imageScale )

	-- Horizontally and vertically flipped/mirrored.
	local chickenMirrorHV = display.newImage( objectGroup, "chicken.png")
	chickenMirrorHV.x = xCentre + imageOffset
	chickenMirrorHV.y = yCentre + imageOffset
	spyricMorph.addBody( chickenMirrorHV, "static", physicsData:get("chicken") )
	chickenMirrorHV:morph( -imageScale, -imageScale )

	-- The lines between the chickens.
	local line1 = display.newLine( objectGroup, xCentre, yCentre-240, xCentre, yCentre+240 )
	line1.strokeWidth = 4
	local line2 = display.newLine( objectGroup, xCentre-240, yCentre, xCentre+240, yCentre )
	line2.strokeWidth = 4

	objectGroup.alpha = 0
	transition.to( objectGroup, { time=600, alpha=1, transition=easing.outQuad } )
end

function scene:hide( event )
	if ( event.phase == "will" ) then
		transition.to( objectGroup, { time=600, alpha=0, delay=80, transition=easing.outQuad } )
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )

return scene
