local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local spyricMorph = require("spyric.morph")


function scene:create( event )

	local sceneGroup = self.view
	
	local button = btn.new()
	sceneGroup:insert( button )
		
	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, 180, "demoScene/font/Roboto-Regular.ttf", 46 )
	title:setFillColor( 252/255, 186/255, 4/255 )

	local description = display.newText( sceneGroup,
		"1) \"Outline Body\" and \"Circular Body\" are special cases and they are not supported.\n\n"..
		"2) If you morph bodies too small, the body may become invalid, possibly due to holes or self-intersection (depends on the body).\n\n"..
		"3) If you morph bodies too large, too fast, then they may push away other nearby physics bodies or get stuck to them.",
		display.contentCenterX, title.y + title.height*0.5 + 20, 600, 620, "demoScene/font/Roboto-Regular.ttf", 24-2
	)
	description.anchorY = 0

end

scene:addEventListener( "create", scene )

return scene
