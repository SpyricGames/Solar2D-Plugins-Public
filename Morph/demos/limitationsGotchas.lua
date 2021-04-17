local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local spyricMorph = require("spyric.morph")


function scene:create( event )

	local sceneGroup = self.view

	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local button = btn.new( title )
	sceneGroup:insert( button )

	local description = display.newText( sceneGroup,
		"1) \"Outline Body\" and \"Circular Body\" are special cases and they are not supported.\n\n"..
		"2) If you morph bodies too small, the body may become invalid, possibly due to holes or self-intersection (depends on the body).\n\n"..
		"3) If you morph bodies too large, too fast, then they may push away or get stuck to other nearby physics bodies.",
		display.contentCenterX, title.y + title.height*0.5 + 8, 600, 620, composer.font, composer.body.size-2
	)
	description.anchorY = 0

end

scene:addEventListener( "create", scene )

return scene
