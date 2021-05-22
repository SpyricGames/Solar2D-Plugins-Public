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

local physicsData = (require "shapedefs").physicsData(1.0)
local spyricMorph = require("spyric.morph")

local objectGroup

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
		"You can load any shape created using the PhysicsEditor software and morph them with only only a few lines of code.", 
		title.x, title.y + title.height + 12, 440, 0, "demoScene/font/Roboto-Regular.ttf", 24
	)
	description.anchorX, description.anchorY = 0, 0

	local codeExample = display.newText( sceneGroup,
		"local object = display.newImage( \"chicken.png\")\n" ..
		"spyricMorph.addBody( object, physicsData:get(\"chicken\") )\n" ..
		"object:morph( 1, 1 )",
		title.x, description.y + description.height + 26, 460, 0, "demoScene/font/Roboto-Black.ttf", 17
	)
	codeExample.anchorX, codeExample.anchorY = 0, 0

	local xCentre = display.contentCenterX + 220
	local yCentre = display.contentCenterY 
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
	local line1 = display.newLine( objectGroup, xCentre, yCentre-220, xCentre, yCentre+220 )
	line1.strokeWidth = 4
	local line2 = display.newLine( objectGroup, xCentre-220, yCentre, xCentre+220, yCentre )
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
