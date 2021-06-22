---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2021 Spyric Games Ltd.                  Last Updated: 22 June 2021 --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

--[[
	Spyric Installation Identifier (SIID) for Solar2D is very similar to UUID,
	but the identifiers that SSID generates are of varying lengths and they are
	intended to be used to identify specific installations of Solar2D apps.
	
	Spyric Installation Identifier consists of three parts:

	1) Platform identifier.
		A single letter to identify the user's platform.
		"a" = Android
		"i" = iOS
		"w" = Win32
		"m" = MacOS
		"h" = HTML5
		"t" = tvOS

	2) Epoch (unix) time.
		Retrieved using socket.gettime() (or os.time() for HTML5 builds).
		With sockets, the epoch time will be fractional and the dot will
		be replaced by a hyphen (-) in the final SIID.
			
	3) Time to execution.
		How many milliseconds have passed between when this file was
		first required and when the SIID is generated.

		NB! For the best possible result, you should require this SIID
		plugin at the very start of your main.lua. That way, more time
		will pass before you create the SIID, which will result in a
		more random SIID. Requiring any plugins, modules or libraries,
		such as ad networks, Composer, Physics, JSON, etc. will each
		take at least some milliseconds or tens of milliseconds to
		complete. This, paired with epoch time, makes SIID more
		unique than most UUID implementations for Lua.
		
	--------------------------------------------------------------------
	The only possible case where two users could have the same SIID is if
	they started your application at the same time, down to a millisecond
	(or down to a second if sockets aren't supported), and if the users
	are running the app on the same platform, and had identical times to
	execution. In other words, if properly set up, the probability of
	having two SIIDs for your app collide/overlap is practically zero.
	--------------------------------------------------------------------
]]

---------------------------------------------------------------------------

local SIID = {}

local t = {  true, true, true }
local startTime = system.getTimer()*10

-- The socket library is not included on HTML5 builds.
local platform, socket = system.getInfo( "platform" )
if platform ~= "html5" then
	-- Sockets require the Internet, so check for INTERNET permission on Android.
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
		socket = require( "socket" )
	end
end

-- Create a new SIID (string) and return it.
function SIID.new()
	t[1] = platform:sub(1,1)
	t[2] = socket and socket.gettime() or os.time()
	t[3] = system.getTimer()*10 - startTime
	return table.concat( t, "-" ):gsub("%.","-")
end

return SIID
