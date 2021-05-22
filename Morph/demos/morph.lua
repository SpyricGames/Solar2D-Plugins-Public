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

	local button = btn.new()
	sceneGroup:insert( button )

	local title = display.newText( sceneGroup, event.params[1], button.x - button.width*0.5, button.y + 80, "demoScene/font/Roboto-Regular.ttf", 40 )
	title:setFillColor( 252/255, 186/255, 4/255 )
	title.anchorX = 0

	local description = display.newText( sceneGroup,
		"With morph, you can scale and flip display objects and their associated physics bodies with a single line of code.\n\n" .. 
		"object:morph( 1, 1 )",
		title.x, title.y + title.height + 12, 440, 0, "demoScene/font/Roboto-Regular.ttf", 24
	)
	description.anchorX, description.anchorY = 0, 0

	local chicken = display.newImage( objectGroup, "chicken.png")
	chicken.x = display.contentCenterX + 220
	chicken.y =  display.contentCenterY
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
		
		-- Update the description text to match the on-going scaling values.
		description.text = description.text:sub(1,130) .. xScale .. ", " .. yScale .. " )"

		chicken:morph( xScale, yScale )
	end
	flipTimer = timer.performWithDelay( 500, flip, 0 )

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
