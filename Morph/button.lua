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

local button = {}

function button.new()

	local btn = widget.newButton(
		{
			label = "Back",
			shape = "rectangle",
			width = 160,
			height = 40,
			font = "demoScene/font/Roboto-Regular.ttf",
			fontSize = 24,
			fillColor = { default={252/255, 186/255, 4/255}, over={255/255, 200/255, 32/255} },
			labelColor = { default={ 0 }, over={ 0 } },
			onRelease = function()
				composer.gotoScene( "menu", { effect="slideRight", time=800 } )
			end
		}
	)
	btn.x, btn.y = btn.width*0.5 + 20, display.minY + btn.height*0.5 + 20
	
	return btn
end

return button
