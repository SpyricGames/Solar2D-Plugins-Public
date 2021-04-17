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
	physics.setDrawMode( "normal" )

	local sceneGroup = self.view
	objectGroup = display.newGroup()
	sceneGroup:insert( objectGroup )

	local title = display.newText( sceneGroup, event.params[1], display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local button = btn.new( title )
	sceneGroup:insert( button )

	local description = display.newText( sceneGroup, "In order to morph an object, you must first prepare it by giving it a body. This function works identical to its standard physics library counterpart in Corona.", display.contentCenterX, title.y + title.height*0.5 + 8, 600, 400, composer.font, composer.body.size )
	description.anchorY = 0

	local starVertices = { 0, -100, 27, -25, 105, -25, 43, 26, 65, 100, 0, 55, -65, 100, -43, 25, -105, -25, -27, -25 }
	local vertices = { 40, -40, 40, 0, 0, 0 }

	-- Function for randomly spawning and morphing triangles and rectangles that then fall down.
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
			-- Creating a simple multi-element body.
			spyricMorph.addBody( object,
				{ shape = { -5, -10, 5, -10, 5, 10, -5, 10 }, filter = objectFilter },
				{ shape = { -10, -5, 10, -5, 10, 5, -10, 5 }, filter = objectFilter }
			)
			object:morph( 2+random(1,20)*0.1, 2+random(1,20)*0.1 )

		else
			object = display.newRect( objectGroup, 0, 0, 20, 20 )
			-- If no body is defined, then addBody will create a rectangular body it.
			spyricMorph.addBody( object, { filter = objectFilter } )
			object:morph( 2+random()*2, 2+random()*2 )

		end

		object.x, object.y = random( 80, 560 ), 480

		if whichFilter == "pass" then
			object:setFillColor( 0, 0.8, 0 )
			whichFilter = "block"
		else
			object:setFillColor( 0.8,  0, 0 )
			whichFilter = "pass"
		end
	end
	dropTimer = timer.performWithDelay( 450, dropObject, 100 )

	local star = display.newPolygon( objectGroup, 0, 760, starVertices )
	star:setFillColor( 0.8, 0, 0 )
	star.rotation = 20
	spyricMorph.addBody( star, "static",
		{
			chain = starVertices,
			connectFirstAndLastChainVertex = true,
			filter = redFilter
		}
	)
	star:morph( -1.8, 0.8 )

	local platform = display.newRect( objectGroup, display.contentCenterX, display.contentCenterY+240, 600, 40 )
	platform:setFillColor( 0, 0.8, 0 )
	platform.rotation = 15
	physics.addBody( platform, "static", { bounce=0.5, filter=platformFilter } )

	objectGroup.alpha = 0
	transition.to( objectGroup, { time=600, alpha=1, transition=easing.outQuad } )
end

function scene:hide( event )
	if ( event.phase == "will" ) then
		timer.cancel( dropTimer )
		physics.setDrawMode( "hybrid" )
		transition.to( objectGroup, { time=600, alpha=0, delay=80, transition=easing.outQuad } )
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )

return scene
