local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

local function onButtonRelease( event )
	composer.gotoScene( "demos." .. event.target.id, { effect="slideLeft", params={ event.target.name }, time=800 } )
end

function scene:create( event )
	local sceneGroup = self.view

	local title = display.newText( sceneGroup, "SELECT A DEMO", display.contentCenterX, 140, "demoScene/font/Roboto-Black.ttf", 46 )
	title:setFillColor( 252/255, 186/255, 4/255 )

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
				font = "demoScene/font/Roboto-Regular.ttf",
				fontSize = 24,
				fillColor = { default={252/255, 186/255, 4/255}, over={255/255, 200/255, 32/255} },
				labelColor = { default={ 0 }, over={ 0 } },
				onRelease = onButtonRelease
			}
		)
		
		button.name = buttonLabel[i]
		button.x = display.contentCenterX
		button.y = 140 + i*60
		sceneGroup:insert( button )
	end
	
	if _G.isHTML5 then
		local htmlDisclaimer = display.newText( sceneGroup,
			"Important: HTML5 builds don't currently support debug or hybrid physics draw mode.\n" .. 
			"In order to see the physics body manipulations, run this project on another platform.",
			display.contentCenterX, display.maxY - 50, "demoScene/font/Roboto-Regular.ttf", 20
		)
	end
end

scene:addEventListener( "create", scene )

return scene
