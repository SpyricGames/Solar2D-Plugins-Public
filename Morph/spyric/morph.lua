---------------------------------------------------------------------------
--     _____                  _         ______                           --
--    / ___/____  __  _______(_)____   / ____/___ _____ ___  ___  _____  --
--    \__ \/ __ \/ / / / ___/ / ___/  / / __/ __ `/ __ `__ \/ _ \/ ___/  --
--   ___/ / /_/ / /_/ / /  / / /__   / /_/ / /_/ / / / / / /  __(__  )   --
--  /____/ .___/\__, /_/  /_/\___/   \____/\__,_/_/ /_/ /_/\___/____/    --
--      /_/    /____/                                                    --
--                                                                       --
--  © 2020-2022 Spyric Games Ltd.             Last Updated: 4 June 2022  --
---------------------------------------------------------------------------
--  License: MIT                                                         --
---------------------------------------------------------------------------

local morph = {}

local physics = physics or require( "physics" )

-- Localise global functions.
local pairs = pairs
local type = type
local unpack = unpack
local min = math.min
local max = math.max
local addBody = physics.addBody
local removeBody = physics.removeBody

local x, y = {}, {}

-- Translate given vertices into absolute coordinates.
local function getAbsoluteVertices( t )
	local n, len = 0, #t

	for i = 1, len, 2 do
		n = n+1
		x[n] = t[i]
		y[n] = t[i+1]
	end

	local xCentre = ( max( unpack(x) ) + min( unpack(x) ) )*0.5
	local yCentre = ( max( unpack(y) ) + min( unpack(y) ) )*0.5

	-- Reduce, reuse and recycle.
	for i = 1, n do
		x[i], y[i] = nil, nil
	end

	local v = {}
	for i = 1, len, 2 do
		v[i] = t[i] - xCentre
		v[i+1] = t[i+1] - yCentre
	end

	return v
end

-- Creates a standard Solar2D physics body for a given display object while also adding morph method to it.
function morph.addBody( ... )
	local t = { ... }

	if type( t[1] ) ~= "table" then
		print( "ERROR: bad argument #1 to 'addBody' (table expected, got " .. type( t[1] ) .. ")." )
		return
	end

	-- Create a local reference to the display object and add morph tables.
	local object = t[1]
	object.morphData = {}
	object.morphData.params = {}

	-- Determine the body type.
	local offset = 0
	if type( t[2] ) == "string" then
		object.morphData.bodyType = (t[2] == "static" or t[2] == "kinematic") and t[2] or "dynamic"
		offset = 1
	else
		object.morphData.bodyType = "dynamic"
	end

	-- Add all inputted bodies and their entries to the morph tables.
	local n = 1
	for bodyCount = 2+offset, #t do
		object.morphData.params[n] = {}
		for key, value in pairs( t[bodyCount] ) do
			if type( value ) == "table" then
				object.morphData.params[n][key] = {}
				if key == "outline" then
					print( "WARNING: Outline bodies are not supported by spyricMorph." )
				elseif key == "radius" then
					print( "WARNING: Circular bodies are not supported by spyricMorph." )
				else
					for i, v in pairs( value ) do
						object.morphData.params[n][key][i] = v
					end
				end
			else
				object.morphData.params[n][key] = value
			end
		end
		n = n+1
	end

	-- Morphing requires the bodies' vertices to use absolute coordinates (i.e. the body's centre is {0,0} position).
	if #object.morphData.params == 1 and (object.morphData.params[1].shape or object.morphData.params[1].chain) then
		local v = getAbsoluteVertices( object.morphData.params[1].shape or object.morphData.params[1].chain )
		local target
		if object.morphData.params[1].shape then
			target = object.morphData.params[1].shape
		else
			target = object.morphData.params[1].chain
		end

		for i = 1, #v do
			target[i] = v[i]
		end
	end

	-- Scale the object and recreate a matching physics body for it.
	function object:morph( xScale, yScale )
		local xScale = type(xScale) == "number" and xScale or 1
		local yScale = type(yScale) == "number" and yScale or xScale
		self.xScale, self.yScale = xScale, yScale

		-- If an object's anchor isn't centered, then adjust the offsets.
		local xOffset = 0
		if self.anchorX ~= 0.5 then
			xOffset = ( self.anchorX - 0.5 ) * ( 1 - xScale ) * self.width
		end
		local yOffset = 0
		if self.anchorY ~= 0.5 then
			yOffset = ( self.anchorY - 0.5 ) * ( 1 - yScale ) * self.height
		end

		-- Use the stored morph table data to calculate the new vertices for each body.
		local params, gotShape = {}, false
		for bodyCount = 1, #self.morphData.params do
			params[bodyCount] = {}
			for key, value in pairs( self.morphData.params[bodyCount] ) do
				if type( value ) == "table" then
					params[bodyCount][key] = {}
					for i, v in pairs( value ) do
						params[bodyCount][key][i] = v
					end
					if key == "shape" or key == "chain" then
						gotShape = true
						for l = 1, #params[bodyCount][key], 2 do
							params[bodyCount][key][l] = params[bodyCount][key][l] * xScale + xOffset
							params[bodyCount][key][l+1] = params[bodyCount][key][l+1] * yScale + yOffset
						end
					elseif key == "box" then
						gotShape = true
						params[bodyCount][key].halfWidth = params[bodyCount][key].halfWidth * xScale * 0.5
						params[bodyCount][key].halfHeight = params[bodyCount][key].halfHeight * yScale * 0.5
						params[bodyCount][key].x = params[bodyCount][key].x * xScale
						params[bodyCount][key].y = params[bodyCount][key].y * yScale
					end
				else
					params[bodyCount][key] = value
				end
			end
		end

		if self.bodyType then
			removeBody( self )
		end

		if gotShape then
			addBody( self, self.morphData.bodyType, unpack( params ) )
		else
			-- If no physics definitions are passed or the shape is missing, then the body is treated as a rect.
			local rectParams = {
				halfWidth = self.width * xScale * 0.5,
				halfHeight = self.height * yScale * 0.5,
				x = xOffset,
				y = yOffset
			}
			if #params == 0 then
				addBody( self, self.morphData.bodyType, { box=rectParams } )
			else
				params[1].box = rectParams
				addBody( self, self.morphData.bodyType, params[1] )
			end
		end
	end

	-- Create the initial body without any morphing.
	object:morph( 1, 1 )
end

return morph
