---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2021-2022 Spyric Games Ltd.            Last Updated: 30 April 2022 --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

--[[
	Spyric Universally Unique Identifier (UUID) for Solar2D creates an UUID
	solely using time. Spyric UUID consists of three parts:

	1) Epoch (unix) time:
		Retrieved using socket.gettime() (or by using os.time() on builds
		that don't have access to sockets). With sockets, the epoch time
		will be fractional and the dot will be replaced by a hyphen (-)
		in the final UUID.

	2) Time to execution:
		How many milliseconds have passed between when this module was
		first required and when the UUID is generated.

	3) Frame time (optional):
		How many milliseconds it took for Solar2D to get to the next
		frame since requiring this module. Frame time is only available
		if there was at least 1 frame of delay between requiring this
		module and in creating the UUID.

	--------------------------------------------------------------------

		NB! For the best possible result, you should require this UUID
		plugin at the very start of your main.lua. That way, more time
		will pass before you create the UUID, which will result in a
		more random UUID. Requiring any plugins, modules or libraries,
		such as ad networks, Composer, Physics, etc. will each take at
		least some milliseconds or tens of milliseconds to complete.

	--------------------------------------------------------------------
]]

---------------------------------------------------------------------------

local UUID = {}

local startTime = system.getTimer()*10

-- If there's at least 1 frame of delay between requiring this module
-- and in creating a new UUID, then add that frame time to the UUID.
local frameTime
timer.performWithDelay( 1, function()
	frameTime = system.getTimer()*10 - startTime
end )

---------------------------------------------------------------------------

local platform, socket = system.getInfo( "platform" )
if platform == "android" and system.getInfo( "environment" ) ~= "simulator" then
	local permissions = system.getInfo( "androidGrantedAppPermissions")
	if permissions then
		for i = 1, #permissions do
			if permissions[i] == "android.permission.INTERNET" then
				socket = require( "socket" )
				break
			end
		end
	end
else
	if platform ~= "html5" then
		socket = require( "socket" )
	end
end

---------------------------------------------------------------------------

-- Optionally specify an algorithm (string) to hash the UUID.
function UUID.new( hash )
	local t = {
		socket and socket.gettime() or os.time(),
		system.getTimer()*10 - startTime,
		frameTime
	}

	local output = table.concat( t, "-" ):gsub("%.","-")

	if type(hash) == "string" then
		local cleanup = not _G.package.loaded["crypto"]
		local crypto = require( "crypto" )

		if not crypto[hash] then
			print( "WARNING: crypto.digest() unknown message digest algorithm. UUID not hashed." )
		else
			output = crypto.digest( crypto[hash], output )
		end

		if cleanup then
			_G.package.loaded["crypto"] = nil
		end
	end

	return output
end

---------------------------------------------------------------------------

return UUID
