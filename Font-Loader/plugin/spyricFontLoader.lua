local M = {}

-- Require Lua File System.
local lfs = require( "lfs" )

-- Localise global functions.
local _type = type
local _print = print
local _getTimer = system.getTimer
local newText = display.newText
local remove = display.remove
local pathForFile = system.pathForFile

local title = "Spyric Font Loader - "

--[[
	In Solar2D, a font is cached when it is used for the first time during runtime. The speed of this process varies greatly across
	operating systems and fonts. This function will locate all fonts in a given folder, and optionally within its subfolders, and
	then this function will use the fonts once so that they are cached for faster use later.
]]--
M.preload = function( folder, params )
	local deepScan, consoleOutput, directory

	-- Validate the folder and all optional parameters.
	if _type( folder ) ~= "string" then
		_print( "ERROR: " .. title .. "bad argument #1 to 'preload' (string expected, got " .. _type( folder ) .. ")" )
		return
	end

	if _type( params ) == "table" then
		if params.deepScan and _type( params.deepScan ) ~= "boolean" then
			_print( "WARNING: " .. title .. "bad argument #2 'deepScan' to 'preload' (boolean expected, got " .. _type( params.deepScan ) .. ", defaulting to false)" )
			deepScan = false
		else
			deepScan = params.deepScan or false
		end

		if params.consoleOutput and _type( params.consoleOutput ) ~= "boolean" then
			_print( "WARNING: " .. title .. "bad argument #2 'consoleOutput' to 'preload' (boolean expected, got " .. _type( params.consoleOutput ) .. ", defaulting to false)" )
			consoleOutput = false
		else
			consoleOutput = params.consoleOutput or false
		end

		if params.directory and _type( params.directory ) ~= "userdata" then
			_print( "WARNING: " .. title .. "bad argument #2 'directory' to 'preload' (userdata expected, got " .. _type( params.directory ) .. ", defaulting to system.ResourceDirectory)" )
			directory = system.ResourceDirectory
		else
			directory = params.directory or system.ResourceDirectory
		end
	else
		-- Default settings if no params table is passed.
		deepScan, consoleOutput, directory = false, false, system.ResourceDirectory
	end

	local path = pathForFile( folder, directory )
	if path then
		local fontCount, time, file_type, font

		if consoleOutput then
			-- fontCount starts at 2 because native.systemFont and native.systemFontBold will always exist.
			fontCount, time = 2, _getTimer()
		end

		local t = {}
		local function checkFolder( t, path, folder )
			if consoleOutput then _print( "SEARCHING FOR FONTS IN \"" .. folder .. "/\":" ) end
			local folderEmpty = true
			t.t = {}

			for file in lfs.dir( path ) do
				-- Ignore the current folder and its parent folder.
				if file ~= "." and file ~= ".." then
					file_type = file:sub( -4 ):lower() -- use lowercase to capture case sensitive filenames.
					-- Instead, check for any .otf and .ttf font files.
					if file_type == ".otf" or file_type == ".ttf" then
						font = newText( "", 0, 0, folder .. "/" .. file, 12 )
						remove( font )
						if consoleOutput then folderEmpty = false; fontCount = fontCount+1; _print( fontCount .. ":\t\"" .. folder .. "/".. file .. "\" preloaded." ) end
					else
						if deepScan then
							-- If the 4th last symbol in the name of the file/folder is a dot ".", then it is likely not a folder and it will be ignored.
							-- NB! If you use weird naming conventions and have a folder with a name like "folder.gfx", then said folder would be ignored.
							if file_type:sub( 1, 1 ) ~= "." then
								local subfolder = pathForFile( folder .. "/" .. file, system.ResourceDirectory )
								-- Create a table reference for
								t.t[#t.t+1] = { subfolder, folder .. "/" .. file }
							end
						end
					end
				end
			end

			if folderEmpty and consoleOutput then _print( " \t No fonts found." ) end
			-- If deepScan is enabled, then Loop through all subfolders and load all fonts found inside them.
			for i = 1, #t.t do
				if consoleOutput then _print( "" ) end -- Add an empty line after each subfolder.
				checkFolder( t.t[i], t.t[i][1], t.t[i][2] )
			end
		end

		-- Start by preloading native.systemFont and native.systemFontBold.
		font = newText( "", 0, 0, native.systemFont, 12 )
		remove( font )
		font = newText( "", 0, 0, native.systemFontBold, 12 )
		remove( font )

		if consoleOutput then
			_print( "-------------------------------------------\n    " .. title .. "www.spyric.com\n-------------------------------------------" )
			_print( path .. "\n-------------------------------------------\n" )
			_print( "PRELOADING NATIVE SYSTEM FONTS:" )
			_print( "1:\tnative.systemFont preloaded." )
			_print( "2:\tnative.systemFontBold preloaded.\n" )
		end

		-- Then load all custom fonts found inside the target folder (and its subfolders).
		checkFolder( t, path, folder )

		if consoleOutput then _print( "\n-------------------------------------------\n Completed: " .. fontCount .. " fonts preloaded in " .. _getTimer()-time .. "ms\n-------------------------------------------" ) end
	else
		_print( "ERROR: " .. title .. "folder \"" .. folder .. "\" not found." )
	end
end

return M
