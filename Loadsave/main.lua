---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2021 Spyric Games Ltd.                  Last Updated: 1 June 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Set up the demo scene UI.
local demoScene = require( "demoScene.ui" ).create( "Spyric Loadsave", true )

-- Require Spyric Loadsave.
local loadsave = require( "spyric.loadsave" )

-- Optionally enable verbose debug prints for the plugin (default is false).
loadsave.debugMode( true )

-- Optionally disable data protection for the files in order to make the files
-- human-readable  (default is true). Not that you cannot load protected data
-- if the setting is off and vice versa. This could be useful during development.
loadsave.protectData( true )

-- Optional: set custom pepper - https://en.wikipedia.org/wiki/Pepper_(cryptography)
loadsave.setPepper( "some secret text" )


print("")


-- Approach 1: Saving a Lua table to a file.
------------------------------------------------
local playerData = {
	userID = 1512,
	avatar = "myPhoto.jpg",
	currency = 2940,
	password = "p@ssW0rd"
}

-- Save table to file:
local success = loadsave.save( playerData, "myData.json", "abc" )
print( "Data saved:", success )

-- Load the table from the file:
local data = loadsave.load( "myData.json", "abc" )
-- Show the data table contents upon a successful load.
if data then
	print( "Decoded data = {" )
	for i, v in pairs( data ) do
		print( "\t[\"" .. i .. "\"] = " .. v .. "," )
	end
	print( "}" )
else
	print( "Failed to load data." )
end

------------------------------------------------


print("")


-- Approach 2: Saving a single string to a file.
------------------------------------------------
local message = "Hello World!"

-- Save string to file:
local success = loadsave.save( message, "myString.txt", "abc" )
print( "Message saved:", success )

-- Load the string from the file:
local decodedMessage = loadsave.load( "myString.txt", "abc" )
print( "decodedMessage =", decodedMessage )


------------------------------------------------


local description = display.newText(
	"The main purpose of this module is to be a fast and easy way to obfuscate "..
	"save files while also providing reasonable protection against data tampering "..
	"and a basic save data backup feature against possible file errors/problems.\n\n"..
	"You can use Spyric Loadsave to save and load Lua tables and individual strings to/from a file.\n\n"..
	"For instructions on how to use this module, please check out the sample project's code or read the documentation.",
	display.contentCenterX, display.minY + 20, 800, 0, "demoScene/font/Roboto-Regular.ttf", 30
)
description.anchorY = 0