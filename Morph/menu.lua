local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

local function onButtonRelease( event )
	composer.gotoScene( "demos." .. event.target.id, { effect="slideLeft", params={ event.target.name }, time=800 } )
end

function scene:create( event )
	local sceneGroup = self.view

	local title = display.newText( sceneGroup, "SELECT A DEMO", display.contentCenterX, composer.header.y, composer.font, composer.header.size )
	title:setFillColor( composer.colourA[1], composer.colourA[2], composer.colourA[3] )

	local buttonLabel = {
		"object:morph()",
		"spyricMorph.addBody()",
		"Anchor Points",
		"PhysicsEditor support",
		"Limitations & Gotchas"
	}

	local buttonTarget = {
		"morph",
		"addbody",
		"anchorPoints",
		"physicsEditor",
		"limitationsGotchas"
	}

	for i = 1,#buttonLabel do
		local button = widget.newButton(
			{
				label = buttonLabel[i],
				id = buttonTarget[i],
				shape = "rectangle",
				width = 400,
				height = 48,
				font = composer.font,
				fontSize = composer.body.size,
				fillColor = { default=composer.colourA, over=composer.colourAPress },
				labelColor = { default={ 0 }, over={ 0 } },
				onRelease = onButtonRelease
			}
		)
		print( composer.body.size )
		button.name = buttonLabel[i]
		button.x = display.contentCenterX
		button.y = composer.header.y + i*60
		sceneGroup:insert( button )
	end
end

scene:addEventListener( "create", scene )

return scene
