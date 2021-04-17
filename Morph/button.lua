local composer = require( "composer" )
local widget = require( "widget" )

local button = {}

function button.new( title )

	local btn = widget.newButton(
		{
			label = "Back",
			shape = "rectangle",
			width = 160,
			height = 40,
			font = composer.font,
			fontSize = composer.body.size,
			alphaFade = false,
			fillColor = { default=composer.colourA, over=composer.colourAPress },
			labelColor = { default={ 0 }, over={ 0 } },
			onRelease = function() composer.gotoScene( "menu", { effect="slideRight", time=800 } ); end
		}
	)
	btn.x, btn.y = display.contentCenterX, title.y - title.height*0.5 - 16
	return btn
end

return button
