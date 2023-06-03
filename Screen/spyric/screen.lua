---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2023 Spyric Games Ltd.              Last Updated: 3 June 2023 --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- A simple module with easy to use & descriptive display properties for
-- creating dynamically/statically positioned display objects in Solar2D.

---------------------------------------------------------------------------

local screen = {}
screen.safe = {}

local androidAPI
if system.getInfo("platform") == "android" then
    androidAPI = system.getInfo( "androidApiLevel" )
end

-- Add/update screen table's properties.
local function update()
	screen.minX = display.screenOriginX
	screen.maxX = display.contentWidth - display.screenOriginX
	screen.minY = display.screenOriginY
	screen.maxY = display.contentHeight - display.screenOriginY
	screen.width = display.actualContentWidth
	screen.height = display.actualContentHeight
	screen.centerX = display.contentCenterX
	screen.centerY = display.contentCenterY
	screen.diagonal = math.sqrt( display.actualContentWidth^2+ display.actualContentHeight^2)

	screen.safe.minX = display.safeScreenOriginX
	screen.safe.maxX = display.safeScreenOriginX + display.safeActualContentWidth
	screen.safe.minY = display.safeScreenOriginY
	screen.safe.maxY = display.safeScreenOriginY + display.safeActualContentHeight
	screen.safe.width = display.safeActualContentWidth
	screen.safe.height = display.safeActualContentHeight
	screen.safe.centerX = (screen.safe.minX + screen.safe.maxX)*0.5
	screen.safe.centerY = (screen.safe.minY + screen.safe.maxY)*0.5

	if screen.callback then
		screen.callback()
	end
end
-- Obtain the initial screen properties.
update()

-- Manually update screen properties.
function screen.update()
	update()
end

-- Set a callback function to call when update has finished.
function screen.setCallback( f )
	if type( f ) == "function" then
		screen.callback = f
	end
end

function screen.removeCallback()
	screen.callback = nil
end

-- On Android devices with software keys, hiding them using the immersiveSticky mode may take a couple of frames
-- until Solar2D update's its screen. If you are using this module to handle screen resize events, then you may
-- wish to wait until the screen has finished updating in certain cases before you start creating your app's UI.
function screen.waitUntilReady( callback, maxWaitTime )
	-- Android 4.4 KitKat (API 19): first version to support immersive navbar.
	if androidAPI and androidAPI >= 19 and system.getInfo( "hasSoftwareKeys" ) then
		local startWidth = screen.width

		-- Ensure a maximum of 50 iterations at 10ms. The screen should update within a few frames. If it hasn't
		-- updated in 500ms, then the function has been called after the screen has already been resized.
		local iterations = math.min( maxWaitTime and math.max(math.floor(math.abs(maxWaitTime)/10), 1) or 50, 50 )
		timer.performWithDelay( 10, function( event )
			if screen.width ~= startWidth or event.count == 50 then
				timer.cancel( event.source )
				callback()
			end
		end, iterations )
	else
		-- On all other devices/platforms, the callback is triggered instantly.
		callback()
	end
end

---------------------------------------------------------------------------

-- Automatically hide the Android navbar & iOS status bar on system events.
local function toggleSystemUI()
    display.setStatusBar( display.HiddenStatusBar )
	update()

    if androidAPI then
        -- Android 4.4 KitKat (API 19): first version to support immersive navbar.
        if androidAPI >= 19 then
            native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
        else
            native.setProperty( "androidSystemUiVisibility", "lowProfile" )
        end
    end
end

local function onSystemEvent(event)
    if event.type == "applicationStart" then
        toggleSystemUI()
    elseif event.type == "applicationResume" then
        toggleSystemUI()
    end
end

Runtime:addEventListener( "resize", update )
Runtime:addEventListener( "system", onSystemEvent )

---------------------------------------------------------------------------

return screen
