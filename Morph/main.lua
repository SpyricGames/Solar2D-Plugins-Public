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

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Morph", true )

-- Create a global property to check if the sample project is on HTML5 platform.
_G.isHTML5 = (system.getInfo( "platform" ) == "html5")

-- Use nearest filtering mode to keep the chicken graphic looking crisp.
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )

-- Remember to require physics and to call physics.start() before morphing!
local physics = require("physics")
physics.start()
if not _G.isHTML5 then
    physics.setDrawMode( "hybrid" )
end

local composer = require( "composer" )
composer.recycleOnSceneChange = true
composer.gotoScene( "menu" )
