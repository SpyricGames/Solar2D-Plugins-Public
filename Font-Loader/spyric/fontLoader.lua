---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2021 Spyric Games Ltd.             Last Updated: 21 May 2021  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local fontLoader = {}

local lfs = require( "lfs" )

-- Localise global functions.
local type = type
local print = print
local sub = string.sub
local lower = string.lower
local newText = display.newText
local dRemove = display.remove
local pathForFile = system.pathForFile

local fontCount = 0
local fontTypes = {
	[".ttf"] = true,
	[".otf"] = true
}

local function getFonts( folder, directory, deepScan, consoleOutput )	
	local path = pathForFile( folder, directory )
	for file in lfs.dir( path ) do
		if file ~= "." and file ~= ".." then
			if fontTypes[lower(sub(file,-4))] then
				local font = newText( "", 0, 0, folder .. "/" .. file, 12 )
				dRemove( font )
				
				if consoleOutput then
					fontCount = fontCount+1
					print( fontCount .. ":\t\"" .. folder .. "/" .. file .. "\" preloaded." )
				end
			elseif deepScan then
				-- Check if it's a subfolder and recursively check it for font files.
				if lfs.attributes( path .. "/" .. file, "mode" ) == "directory" then
					getFonts( folder .."/".. file, directory, deepScan, consoleOutput )
				end
			end
		end
	end
end


--[[
	In Solar2D, a font is cached when it is used for the first time during runtime. The speed of this process varies greatly across
	operating systems and fonts. This function will locate all fonts in a given folder, and optionally within its subfolders, and
	then this function will use the fonts once so that they are cached for faster use later.
]]--
function fontLoader.preload(...)
	local t = {...}
	local folder = type(t[1]) == "string" and t[1] or ""
	local params = type(t[#t]) == "table" and t[#t] or {}
	local directory = params.directory or system.ResourceDirectory
	
	local path = pathForFile( folder, directory )
	if not path then
		print( "ERROR: Spyric Font Loader - folder \"" .. (folder and folder or "") .. "\" not found." )
	else
		local deepScan = not not params.deepScan
		local consoleOutput = not not params.consoleOutput
		
		local time
		if consoleOutput then
			time = system.getTimer()
		end

		-- Start by preloading native.systemFont and native.systemFontBold.
		local font = newText( "", 0, 0, native.systemFont, 12 )
		dRemove( font )
		font = newText( "", 0, 0, native.systemFontBold, 12 )
		dRemove( font )
		fontCount = 2
		
		if consoleOutput then
			print( "-------------------------------------------\nSpyric Font Loader - https://www.spyric.com\n-------------------------------------------" )
			print( "PRELOADING NATIVE SYSTEM FONTS:" )
			print( "1:\tnative.systemFont preloaded." )
			print( "2:\tnative.systemFontBold preloaded.\n\nPRELOADING CUSTOM OTF/TTF FONTS:" )
		end
		
		getFonts( folder, directory, deepScan, consoleOutput )

		if consoleOutput then
			print( "\n-------------------------------------------\nCompleted: " .. fontCount .. " fonts preloaded in " .. math.round((system.getTimer()-time)*100)*0.01 .. "ms\n-------------------------------------------" )
		end
		return fontCount
	end
	return 0
end

return fontLoader
