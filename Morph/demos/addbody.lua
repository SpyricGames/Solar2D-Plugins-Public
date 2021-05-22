---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 22 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require( "widget" )
local btn = require( "button" )

local scene = composer.newScene()

local spyricMorph = require("spyric.morph")

local platformFilter = { categoryBits=1, maskBits=4 }
local greenFilter = { categoryBits=2, maskBits=4 }
local redFilter = { categoryBits=4, maskBits=3 }

local random = math.random

local objectGroup, dropTimer

function scene:create( event )
	if not _G.isHTML5 then
		physics.setDrawMode( "normal" )
	end

	local sceneGroup = self.view
	objectGroup = display.newGroup()
	sceneGroup:insert( objectGroup )

	local button = btn.new()
	sceneGroup:insert( button )

	local title = display.newText( sceneGroup, event.params[1], button.x - button.width*0.5, button.y + 80, "demoScene/font/Roboto-Regular.ttf", 40 )
	title:setFillColor( 252/255, 186/255, 4/255 )
	title.anchorX = 0

	local description = display.newText( sceneGroup,
		"In order to morph an object, you must first give it a physics body using the spyricMorph.addBody() function.\n\n" ..
		"This function works identical to its standard Solar2D physics library counterpart.\n\n" ..
		"The only difference is that it adds the morph method to the object.",
		title.x, title.y + title.height + 12, 440, 0, "demoScene/font/Roboto-Regular.ttf", 24
	)
	description.anchorX, description.anchorY = 0, 0

	local starVertices = { 0, -100, 27, -25, 105, -25, 43, 26, 65, 100, 0, 55, -65, 100, -43, 25, -105, -25, -27, -25 }
	local vertices = { 40, -40, 40, 0, 0, 0 }

	-- Spawn rectangles, triangles and crosses at random and morph them to different sizes.
	local whichFilter = "pass"
	local function dropObject()
		local object, objectFilter

		if whichFilter == "pass" then
			objectFilter = greenFilter
		else
			objectFilter = redFilter
		end

		if random() < 0.3 then
			object = display.newPolygon( objectGroup, 0, 0, vertices )
			spyricMorph.addBody( object, { shape = vertices, filter = objectFilter } )
			object:morph( 1.5+random()*1.5, 1.5+random()*1.5 )

		elseif random() < 0.6 then
			object = display.newPolygon( objectGroup, 0, 0,
				{ -10, -5, -5, -5, -5, -10, 5, -10, 5, -5, 10, -5, 10, 5, 5, 5, 5, 10, -5, 10, -5, 5, -10, 5 }
			)
			-- Creating a simple cross-shaped multi-element body.
			spyricMorph.addBody( object,
				{ shape = { -5, -10, 5, -10, 5, 10, -5, 10 }, filter = objectFilter },
				{ shape = { -10, -5, 10, -5, 10, 5, -10, 5 }, filter = objectFilter }
			)
			object:morph( 2+random(1,20)*0.1, 2+random(1,20)*0.1 )

		else
			object = display.newRect( objectGroup, 0, 0, 20, 20 )
			-- If no shape is defined, then addBody() will create a rectangular body for the object.
			spyricMorph.addBody( object, { filter = objectFilter } )
			object:morph( 2+random()*2, 2+random()*2 )

		end

		object.x, object.y = random( 460, 900 ), 160

		if whichFilter == "pass" then
			object:setFillColor( 0, 0.8, 0 )
			whichFilter = "block"
		else
			object:setFillColor( 0.8,  0, 0 )
			whichFilter = "pass"
		end
	end
	dropTimer = timer.performWithDelay( 450, dropObject, 100 )

	local star = display.newPolygon( objectGroup, display.contentCenterX + 40, 500, starVertices )
	star:setFillColor( 0.8, 0, 0 )
	star.rotation = -15
	spyricMorph.addBody( star, "static",
		{
			chain = starVertices,
			connectFirstAndLastChainVertex = true,
			filter = redFilter
		}
	)
	star:morph( -0.8, 0.4 )

	local platform = display.newRect( objectGroup, display.contentCenterX + 220, display.contentCenterY+160, 500, 20 )
	platform:setFillColor( 0, 0.8, 0 )
	platform.rotation = 15
	physics.addBody( platform, "static", { bounce=0.5, filter=platformFilter } )

	objectGroup.alpha = 0
	transition.to( objectGroup, { time=600, alpha=1, transition=easing.outQuad } )
end

function scene:hide( event )
	if ( event.phase == "will" ) then
		timer.cancel( dropTimer )
		if not _G.isHTML5 then
			physics.setDrawMode( "hybrid" )
		end
		transition.to( objectGroup, { time=600, alpha=0, delay=80, transition=easing.outQuad } )
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )

return scene
