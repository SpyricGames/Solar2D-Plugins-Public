local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local physicsData = (require "shapedefs").physicsData(1.0)
local spyricMorph = require("spyric.morph")

local random = math.random

local objectGroup, flipTimer

function scene:create( event )

	local sceneGroup = self.view
	objectGroup = display.newGroup()
	sceneGroup:insert( objectGroup )

	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local button = btn.new( title )
	sceneGroup:insert( button )

	local description = display.newText( sceneGroup, ":morph() can be used to create a new or to scale an existing physics body and its display object with a single line of code.", display.contentCenterX, title.y + title.height*0.5 + 8, 600, 400, composer.font, composer.body.size )
	description.anchorY = 0

	local chicken = display.newImage( objectGroup, "chicken.png")
	chicken.x = display.contentCenterX
	chicken.y =  display.contentCenterY + 80
	spyricMorph.addBody( chicken, "static", physicsData:get("chicken") )

	-- Randomly flip and morph the chicken.
	local function flip()
		local xMultiplier = random(1,2) -- check for mirroring horizontally
		if xMultiplier == 2 then
			xMultiplier = -1
		end
		local xScale = random(50,300)*0.01*xMultiplier

		local yMultiplier = random(1,2) -- check for mirroring vertically
		if yMultiplier == 2 then
			yMultiplier = -1
		end
		local yScale = random(50,300)*0.01*yMultiplier

		chicken:morph( xScale, yScale )
	end
	flipTimer = timer.performWithDelay( 350, flip, 0 )

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
