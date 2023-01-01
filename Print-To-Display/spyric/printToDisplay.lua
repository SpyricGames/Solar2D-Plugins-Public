---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2023 Spyric Games Ltd.          Last Updated: 1 January 2023  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

-- Spyric Print To Display is a simple to use Solar2D plugin for displaying
-- print() outputs on an in-app console as well as in the simulator console.
-- This makes debugging on devices easier as no external tools are needed.

--==============================================================================
-- Important! Important! Important! Important! Important! Important! Important!
--==============================================================================
-- If you want to make changes to this module and you need to use debug prints,
-- then make sure to use _print() inside of these functions because using the
-- regular print() inside the wrong function will result in an infinite loop.
--==============================================================================

local printToDisplay = {}

-- Localised functions.
local _print = print
local concat = table.concat
local match = string.match
local find = string.find
local gsub = string.gsub
local sub = string.sub
local len = string.len
local tostring = tostring
local type = type

-- Determine the project's build directory so that the developer may optionally
-- output minimised information on where the original print function was called.
local moduleLocation = ...
local buildDirectory = gsub( debug.getinfo(1).source, "%\\", "/" )

-- If debug info has been stripped from the project, then there is no information
-- available on the build directory, so there's no text to format.
if buildDirectory == "=?" then
	buildDirectory = nil
else
	moduleLocation = gsub( moduleLocation, "%p", "/" )
	local start = find( buildDirectory, moduleLocation )
	buildDirectory = sub( buildDirectory, 1, start-2 )
	start = find(buildDirectory, "/[^/]*$")
	buildDirectory = sub( buildDirectory, start+1 )
end
moduleLocation = nil

local platform = system.getInfo( "platform" )
local mouseSupport = system.getInfo( "environment" ) == "simulator" or (platform == "win32" or platform == "macos" or platform == "linux")

-- Localised console variables.
local blockTouch = true
local autoscroll = true
local canScroll = false
local printList = {}
local scrollThreshold = 0
local currentY = 0
local textX = 0
local textWidth = 0
local paddingRow = 0
local fontSize = 0
local textColor
local textColorError
local textColorWarning
local font
local useHighlighting
local activeWhenHidden
local printSourceLevel

-- Console display objects.
local container = nil
local background = nil
local output = nil
local buttonGroup = nil
local buttonScroll = nil
local buttonToggle = nil
local buttonClear = nil
local buttonCustom = nil

-- Print console controls.
local controls
local errorHandling = {}

----------------------------------------------
-- Default visual parameters:
----------------------------------------------
-- NB! These should be edited only via passing
-- a table as an argument to start() function.
----------------------------------------------
local style = {
	-- Console (general):
	x = display.screenOriginX,
	y = display.screenOriginY,
	width = display.actualContentWidth/3,
	height = display.actualContentHeight,
	alpha = 0.9,
	bgColor = { 0 },
	anchorX = 0,
	anchorY = 0,
	-- Console (text):
	font = native.systemFont,
	fontSize = 14,
	textColor = { 0.9 },
	textColorError = { 0.9, 0, 0 },
	textColorWarning = { 0.9, 0.75, 0 },
	paddingRow = 4,
	paddingLeft = 10,
	paddingRight = 10,
	paddingTop = 10,
	paddingBottom = 10,
	-- Console (functional):
	scrollSpeed = 120,
	enableMouseScroll = true,
	hideControls = false,
	useHighlighting = true,
	activeWhenHidden = true,
	blockTouch = true,
	-- Buttons:
	buttonPos = "right",
	buttonSize = 32,
	buttonRounding = 4,
	buttonPadding = 10,
	buttonBaseColor = { 0.2 },
	buttonIconColor = { 0.8 },
}
----------------------------------------------

-- Scroll the text in the console.
local maxY, objectStart, eventStart = 0
local function scroll( event )
	if canScroll then
		if event.phase == "began" then
			display.getCurrentStage():setFocus( event.target )
			event.target.isTouched = true
			objectStart, eventStart = output.y, event.y
		elseif event.target.isTouched then
			if event.phase == "moved" then
				local d = event.y - eventStart
				local toY = objectStart + d

				-- Cap the scrollable area.
				if toY <= 0 and toY >= -maxY then
					output.y = toY
				else
					if toY < -maxY then
						output.y = -maxY
					else
						output.y = 0
					end
					objectStart = output.y
					eventStart = event.y
				end

				-- Turn autoscroll on when near enough to the bottom.
				if output.y + maxY < 10 then
					if not autoscroll then
						autoscroll = true
						buttonScroll.on.isVisible = true
						buttonScroll.off.isVisible = false
					end
				else
					if autoscroll then
						autoscroll = false
						buttonScroll.on.isVisible = false
						buttonScroll.off.isVisible = true
					end
				end
			else
				display.getCurrentStage():setFocus( nil )
				event.target.isTouched = false
			end
		end
	end
	return blockTouch
end

local function mouseScroll( event )
	if event.scrollY ~= 0 then
		local x, y = event.x, event.y

		if x >= container.x and x <= container.x + container.width and y >= container.y and y <= container.y + container.height then
			-- Fake a series of touch events to scroll.
			local fakeEvent = { phase="began", y=0, target=background }
			scroll( fakeEvent )

			fakeEvent.phase = "moved"
			fakeEvent.y = event.scrollY < 0 and style.scrollSpeed or -style.scrollSpeed
			scroll( fakeEvent )

			fakeEvent.phase = "ended"
			scroll( fakeEvent )
		end
	end
end


local function unhandledError( event )
	if errorHandling.open and not container.isVisible then
		controls( {phase="began",target={id="toggle"}} )
	end
	if errorHandling.output then
		print( "" )
		print( "ERROR: " .. event.errorMessage )
		print( event.stackTrace )
		print( "" )
	end
	return errorHandling.suppress
end


-- Output a print to the in-app console.
local function outputToConsole( toPrint )
	-- Break the console outputs to separate lines to prevent running out of texture memory.
	local tempString, paragraph, finalParagraph = gsub( concat( toPrint, "    " ), "\t", "    " ), "", ""
	local singleParagraph = not find( tempString, "([^\n]*)\n(.*)" )
	repeat
		-- If there is only a single paragraph, then there will be no looping.
		if singleParagraph then
			paragraph, tempString = tempString or "", nil
		else
			paragraph, tempString = match( tempString, "([^\n]*)\n(.*)" )
			-- During the final loop, there's a chance that match will not return a paragraph
			-- even though there would be one more to go. For these cases, we'll store the last
			-- tempString and use it as the finalParagraph if one can't be found via match.
			if tempString then
				finalParagraph = tempString
			end
			if not paragraph then
				paragraph = finalParagraph
			end
		end

		if paragraph then
			local log = display.newText({
				parent = output,
				text = paragraph,
				x = textX,
				y = currentY,
				width = textWidth,
				align = "left",
				height = 0,
				font = font,
				fontSize = fontSize
			})

			log.anchorX, log.anchorY = 0, 0
			currentY = log.y + log.height + paddingRow

			if useHighlighting then
				if find( log.text, "ERROR:" ) == 1 then
					log.fill = textColorError
				elseif find( log.text, "WARNING:" ) == 1 then
					log.fill = textColorWarning
				else
					log.fill = textColor
				end
			else
				log.fill = textColor
			end

			local newY = log.y + log.height
			if newY >= scrollThreshold then
				canScroll = true
			end

			if canScroll then
				maxY = newY - scrollThreshold
				if autoscroll then
					output.y = -maxY
				end
			end
		end

	until tempString == nil or len( tempString ) == 0
end

local function consolePrint( start )
	if start then
		-- "Hijack" the global print function and add outputToConsole to it.
		function print( ... )
			for i = 1, arg.n do
				printList[i] = tostring( arg[i] )
			end

			-- Without debug info, there's no information on the print source, name or line.
			if printSourceLevel and buildDirectory then
				local info = debug.getinfo(printSourceLevel)
				if not info then
					print( "WARNING: Spyric Print to Display: 'printSourceLevel' value is set too high." )
				else
					local source = info.source    -- the filepath where the called function is.
					local name = info.name or "?" -- the name of the called function (unknown for anonymous functions).
					local line = info.currentline -- the line number the function was called.

					-- Clean up any possible unnecessary information from source string.
					local _, sourceEnd = find( source, buildDirectory )
					if not sourceEnd then
						_, sourceEnd = find( source, "corona" )
					end
					if sourceEnd then
						printList[arg.n+1] = "[" .. sub( source, sourceEnd+2 ) .. ":" .. name .. ":" .. line .. "]"
					else
						printList[arg.n+1] = "[" .. source .. ":" .. name .. ":" .. line .. "]"
					end
				end
			end

			outputToConsole( printList )
			_print( unpack(printList) )

			-- Reduce, reuse and recycle.
			for i = 1, arg.n+1 do
				printList[i] = nil
			end
		end
	else
		print = _print -- Restore the normal global print function.
	end
end

-- Button event listener.
function controls( event )
	if event.phase == "began" then
		-- Toggle auto scroll on or off.
		if event.target.id == "autoscroll" then
			autoscroll = not autoscroll
			buttonScroll.on.isVisible = not buttonScroll.on.isVisible
			buttonScroll.off.isVisible = not buttonScroll.off.isVisible
			if autoscroll then output.y = -maxY end

		-- Toggle the console's visibility (and activity).
		elseif event.target.id == "toggle" then
			local makeVisible = not container.isVisible
			container.isVisible = makeVisible
			buttonGroup.isVisible = makeVisible

			if makeVisible then
				buttonToggle.x = buttonToggle.xFrom
			else
				buttonToggle.x = buttonToggle.xTo
			end
			buttonToggle.xScale = buttonToggle.xScale*-1

			if not activeWhenHidden then
				if makeVisible then
					consolePrint(true)
				else
					consolePrint()
				end
			end

		-- Clear all text.
		elseif event.target.id == "clear" then
			buttonScroll.on.isVisible = true
			buttonScroll.off.isVisible = false
			canScroll = false
			autoscroll = true

			display.remove( output )
			output = display.newGroup()
			container:insert( output )
			currentY = style.paddingTop
			output.y = 0

		-- Handle custom button event.
		elseif event.target.listener then
			event.target.listener()

		end
	end
	return true
end

-- Add debug information to the end of each print() call with information on where
-- the print call originates from, i.e. "[filename:functionName:lineNumber]".
function printToDisplay.printSourceLevel( level )
	if not buildDirectory then
		print(
			"WARNING: Spyric Print to Display: 'printSourceLevel' cannot be used without debug info. " ..
			"You may be seeing this warning because you are running a release build on a device and " ..
			"you haven't explictly set 'neverStripDebugInfo = true' in build.settings."
		)
		return
	end

	-- If the input isn't a number, then disable printing the debug information.
	level = tonumber( level )
	if level then
		-- Don't allow a stack level below 2 as they'd only point to the debug.getinfo
		-- function or the Print to Display module's print function, making them useless.
		printSourceLevel = math.max( level, 2 )
	else
		printSourceLevel = nil
	end
end

-- Create the in-app console and start sending print() to the in-app console as well.
function printToDisplay.start(...)
	if container then
		print( "\nSpyric Print to Display: console has already started.\n" )
	else
		local t = {...}
		local startVisible = type(t[1]) ~= "boolean" or t[1]
		local customStyle = type(t[#t]) == "table" and t[#t] or {}

		-- Use customStyle table to pass along configurations for
		-- whether or not, and how to use unhandledError listener.
		errorHandling.activate = type( customStyle.errorHandling ) == "table"

		-- Update style with user input.
		for i, v in pairs( customStyle ) do
			style[i] = v
		end
		style.errorHandling = nil

		-- Localise style properties.
		local x = style.x
		local y = style.y
		local width = style.width
		local height = style.height
		local anchorX = style.anchorX
		local anchorY = style.anchorY
		local alpha = style.alpha
		local buttonSize = style.buttonSize
		local buttonRounding = style.buttonRounding
		local buttonPadding = style.buttonPadding
		local buttonBaseColor = style.buttonBaseColor
		local buttonIconColor = style.buttonIconColor
		local paddingTop = style.paddingTop
		local paddingBottom = style.paddingBottom
		local paddingLeft = style.paddingLeft
		local paddingRight = style.paddingRight

		-- Assign initial console properties (localised for speed).
		scrollThreshold = height-(paddingTop+paddingBottom)
		currentY = paddingTop
		textWidth = width - (paddingLeft + paddingRight)
		paddingRow = style.paddingRow
		textX = paddingLeft
		textColor = style.textColor
		textColorError = style.textColorError
		textColorWarning = style.textColorWarning
		fontSize = style.fontSize
		font = style.font
		useHighlighting = style.useHighlighting
		activeWhenHidden = style.activeWhenHidden
		blockTouch = style.blockTouch
		autoscroll = true
		canScroll = false

		-- Create the console's container.
		container = display.newContainer( width, height )
		container.anchorX, container.anchorY = anchorX, anchorY
		container.anchorChildren = false
		container.x, container.y = x, y
		container.alpha = alpha

		-- Create the console's background.
		background = display.newRect( container, 0, 0, width, height )
		background.anchorX, background.anchorY = anchorX, anchorY
		background.fill = style.bgColor
		background:addEventListener( "touch", scroll )

		-- Create the console output group.
		output = display.newGroup()
		container:insert( output )

		-- Calculate dynamic sizes for the icons.
		local SEG = buttonSize*0.2 -- Segment.
		local HW = buttonSize*0.4 -- (Approximate) half width of a button.

		-- Calculate the position of the buttons based on the style anchors and button positioning.
		local buttonY, buttonX = y-anchorY*height+buttonSize*0.5
		if style.buttonPos == "left" then
			buttonX = x-anchorX*width-buttonSize*0.5
		else
			buttonX = x+(1-anchorX)*width+buttonSize*0.5
		end

		-- Toggle visibility button:
		----------------------------
		buttonToggle = display.newGroup()
		buttonToggle.x, buttonToggle.y = buttonX, buttonY
		buttonToggle.alpha = alpha
		buttonToggle:addEventListener( "touch", controls )
		buttonToggle.id = "toggle"

		buttonToggle.bg = display.newRoundedRect( buttonToggle, 0, 0, buttonSize, buttonSize, buttonRounding )
		buttonToggle.bg.fill = buttonBaseColor

		-- Toggle icon.
		buttonToggle.toggle = display.newPolygon( buttonToggle, 0, 0,
			{
				-HW,-HW+SEG,
				-HW+SEG,-HW,
				SEG,0,
				-HW+SEG,HW,
				-HW,HW-SEG,
				-SEG,0
			}
		)
		buttonToggle.toggle.fill = buttonIconColor

		-- Coordinates to move the toggle button to/from when toggling the console visibility.
		buttonToggle.xFrom = buttonX
		if style.buttonPos == "left" then
			buttonToggle.xTo = buttonX + container.width
			buttonToggle.toggle.xScale = 1
		else
			buttonToggle.xTo = buttonX - container.width
			buttonToggle.toggle.xScale = -1
		end

		-- Add all other buttons inside a single group to easily control them.
		buttonGroup = display.newGroup()

		-- Auto scroll button:
		----------------------------
		buttonScroll = display.newGroup()
		buttonGroup:insert( buttonScroll )
		buttonScroll.x, buttonScroll.y = buttonX, buttonToggle.y + buttonToggle.height + buttonPadding
		buttonScroll.alpha = alpha
		buttonScroll:addEventListener( "touch", controls )
		buttonScroll.id = "autoscroll"

		buttonScroll.bg = display.newRoundedRect( buttonScroll, 0, 0, buttonSize, buttonSize, buttonRounding )
		buttonScroll.bg.fill = buttonBaseColor

		-- Play icon.
		buttonScroll.on = display.newPolygon( buttonScroll, 0, 0,
			{
				-HW+SEG,-HW+SEG*0.5,
				HW,0,
				-HW+SEG,HW-SEG*0.5
			}
		)
		buttonScroll.on.fill = buttonIconColor

		-- Pause icon.
		buttonScroll.off = display.newGroup()
		buttonScroll:insert( buttonScroll.off )
		buttonScroll.off.isVisible = false
		local pauseLeft = display.newRect( buttonScroll.off, -SEG, 0, SEG, HW+SEG )
		pauseLeft.fill = buttonIconColor
		local pauseRight = display.newRect( buttonScroll.off, SEG, 0, SEG, HW+SEG )
		pauseRight.fill = buttonIconColor

		-- Clear button:
		----------------------------
		buttonClear = display.newGroup()
		buttonGroup:insert( buttonClear )
		buttonClear.x, buttonClear.y = buttonX, buttonScroll.y + buttonScroll.height + buttonPadding
		buttonClear.alpha = alpha
		buttonClear:addEventListener( "touch", controls )
		buttonClear.id = "clear"

		buttonClear.bg = display.newRoundedRect( buttonClear, 0, 0, buttonSize, buttonSize, buttonRounding )
		buttonClear.bg.fill = buttonBaseColor

		-- Clear icon.
		local clear = display.newPolygon( buttonClear, 0, 0,
			{
				-HW,-HW+SEG,
				-HW+SEG,-HW,
				0,-SEG,
				HW-SEG,-HW,
				HW,-HW+SEG,
				SEG,0,
				HW,HW-SEG,
				HW-SEG,HW,
				0,SEG,
				-HW+SEG,HW,
				-HW,HW-SEG,
				-SEG,0
			}
		)
		clear.fill = buttonIconColor


		-- Custom buttons (optional):
		----------------------------
		local lastY = buttonClear.y + buttonClear.height + buttonPadding

		local customParams = customStyle.customButton
		if type( customParams ) == "table" then
			buttonCustom = {}

			for i = 1, #customParams do
				if type(customParams[i].listener) ~= "function" then
					print( "WARNING: invalid customButton listener to 'start' (function expected, got " .. type(customParams[i].listener) .. ")" )
				else
					local button = display.newGroup()
					buttonGroup:insert( button )
					button.x, button.y = buttonX, lastY
					button.alpha = alpha
					button:addEventListener( "touch", controls )
					button.id = "custom"

					button.bg = display.newRoundedRect( button, 0, 0, buttonSize, buttonSize, buttonRounding )
					button.bg.fill = buttonBaseColor

					button.text = display.newText( button, customParams[i].id or "?", 0, 0, customParams[i].font or font, customParams[i].fontSize or fontSize )
					button.text.fill = buttonIconColor

					lastY = button.y + button.height + buttonPadding
					button.listener = customParams[i].listener

					buttonCustom[#buttonCustom+1] = button
				end
			end
		end

		----------------------------

		local parent = customStyle.parent
		if parent then
			parent:insert( container )
			parent:insert( buttonGroup )
			parent:insert( buttonToggle )
		end

		if style.hideControls then
			buttonToggle.isVisible = false
			buttonGroup.isVisible = false
		end

		consolePrint(true)
		if not startVisible then
			controls( {phase="began",target={id="toggle"}} )
		end

		if errorHandling.activate then
			-- [suppress] defaults to false. [output] and [open] default to true.
			errorHandling.suppress = type( customStyle.errorHandling.suppress ) == "boolean" and customStyle.errorHandling.suppress
			errorHandling.output = type( customStyle.errorHandling.output ) ~= "boolean" or customStyle.errorHandling.output
			errorHandling.open = type( customStyle.errorHandling.open ) ~= "boolean" or customStyle.errorHandling.open

			Runtime:addEventListener( "unhandledError", unhandledError )
		end

		if mouseSupport and style.enableMouseScroll then
			Runtime:addEventListener( "mouse", mouseScroll )
		end
	end
end

-- A convenience function to programmatically clear the console.
function printToDisplay.clear()
	if container then
		controls( {phase="began",target={id="clear"}} )
	end
end

-- Remove the in-app console and restore normal print() functionality.
function printToDisplay.remove()
	if container then
		print( "\nSpyric Print to Display: console isn't running.\n" )
	else
		display.remove( container )
		container = nil
		output = nil
		background = nil
		display.remove( buttonToggle )
		buttonToggle = nil
		display.remove( buttonGroup )
		buttonGroup = nil
		buttonScroll = nil
		buttonClear = nil

		if errorHandling.activate then
			errorHandling.activate = false
			Runtime:removeEventListener( "unhandledError", unhandledError )
		end

		if mouseSupport and style.enableMouseScroll then
			Runtime:removeEventListener( "mouse", mouseScroll )
		end

		consolePrint()
	end
end

function printToDisplay.resize( params )
	params = params or {}

	-- Readjust the console and button positions.
	if params.x or params.y then
		local x = params.x or container.x
		local y = params.y or container.y
		local dx, dy = x - container.x, y - container.y
		style.x, style.y = x, y

		container.x, container.y = x, y
		buttonToggle.x = buttonToggle.x + dx
		buttonToggle.y = buttonToggle.y + dy
		buttonGroup.x = buttonGroup.x + dx
		buttonGroup.y = buttonGroup.y + dy

		-- Update toggle button's open/close locations.
		if style.buttonPos == "left" then
			buttonToggle.xFrom = x-style.anchorX*style.width-style.buttonSize*0.5
			buttonToggle.xTo = buttonToggle.xFrom + container.width
		else
			buttonToggle.xFrom = x+(1-style.anchorX)*style.width+style.buttonSize*0.5
			buttonToggle.xTo = buttonToggle.xFrom - container.width
		end
	end

	-- Update the console's height and update scroll properties.
	if params.height then
		local height = params.height
		style.height = height

		container.height = height
		background.height = height

		-- Determine if the console should be scrollable after its size change.
		scrollThreshold = height-(style.paddingTop+style.paddingBottom)

		local newY = currentY - paddingRow
		if not canScroll and newY >= scrollThreshold then
			canScroll = true
		elseif canScroll and newY < scrollThreshold then
			-- The console is tall enough to fit in the entire output.
			canScroll = false
		end

		if canScroll then
			-- Update the max scroll distance.
			maxY = newY - scrollThreshold
			if autoscroll then
				-- Snap to end.
				output.y = -maxY
			end
		else
			-- Snap to start.
			output.y = 0
		end
	end
end

return printToDisplay
