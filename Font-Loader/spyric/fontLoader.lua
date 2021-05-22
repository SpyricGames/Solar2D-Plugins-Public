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
local newText = display.newText
local dRemove = display.remove
local pathForFile = system.pathForFile

--[[
	In Solar2D, a font is cached when it is used for the first time during runtime. The speed of this process varies greatly across
	operating systems and fonts. This function will locate all fonts in a given folder, and optionally within its subfolders, and
	then this function will use the fonts once so that they are cached for faster use later.
]]--
fontLoader.preload = function(...)
	local t = {...}
	local folder = type(t[1]) == "string" and t[1] or ""
	local params = type(t[#t]) == "table" and t[#t] or {}
	local directory = params.directory or system.ResourceDirectory

	local path = pathForFile( folder, directory )
	if not path then
		print( "ERROR: Spyric Font Loader - folder \"" .. (folder and folder or "") .. "\" not found." )
	else
		-- fontCount starts at 2 because it includes native.systemFont and native.systemFontBold.
		local fontCount, time, filetype, font = 2
		local deepScan = not not params.deepScan
		local consoleOutput = not not params.consoleOutput
		-- A list of subfolders to go through with deepScan.
		local sub = {}

		if consoleOutput then
			time = system.getTimer()
		end

		local function checkFolder( sub, path, folder )
			if consoleOutput then print( "SEARCHING FOR FONTS IN \"" .. folder .. "/\":" ) end
			local folderEmpty = true
			local folder = folder .. "/"
			sub.sub = {}

			for file in lfs.dir( path ) do
				-- Ignore the current folder and its parent folder.
				if file ~= "." and file ~= ".." then
					local filepath = folder .. file
					filetype = file:sub( -4 ):lower()
					if filetype == ".otf" or filetype == ".ttf" then
						font = newText( "", 0, 0, filepath, 12 )
						dRemove( font )
						fontCount = fontCount+1
						if consoleOutput then
							folderEmpty = false
							print( fontCount .. ":\t\"" .. filepath .. "\" preloaded." )
						end
					else
						-- With deepScan, check if there are other subfolders inside the current
						-- directory that also need to be scanned for .otf and .ttf font files.
						if deepScan then
							local subfolder = pathForFile( filepath, directory )
							if lfs.attributes( subfolder, "mode" ) == "directory" then
								sub.sub[#sub.sub+1] = { subfolder, filepath }
							end
						end
					end
				end
			end

			if folderEmpty and consoleOutput then print( " \tNo fonts found." ) end
			-- If deepScan is enabled, then Loop through all newly found subfolders.
			for i = 1, #sub.sub do
				if consoleOutput then print( "" ) end
				local t = sub.sub[i]
				checkFolder( t, t[1], t[2] )
			end
		end

		-- Start by preloading native.systemFont and native.systemFontBold.
		font = newText( "", 0, 0, native.systemFont, 12 )
		dRemove( font )
		font = newText( "", 0, 0, native.systemFontBold, 12 )
		dRemove( font )

		if consoleOutput then
			print( "-------------------------------------------\nSpyric Font Loader - https://www.spyric.com\n-------------------------------------------" )
			print( path .. "\n-------------------------------------------\n" )
			print( "PRELOADING NATIVE SYSTEM FONTS:" )
			print( "1:\tnative.systemFont preloaded." )
			print( "2:\tnative.systemFontBold preloaded.\n" )
		end

		-- Load all custom fonts found inside the target folder (and its subfolders).
		checkFolder( sub, path, folder )

		if consoleOutput then
			print( "\n-------------------------------------------\nCompleted: " .. fontCount .. " fonts preloaded in " .. math.round((system.getTimer()-time)*100)*0.01 .. "ms\n-------------------------------------------" )
		end
		return fontCount
	end
end

return fontLoader
