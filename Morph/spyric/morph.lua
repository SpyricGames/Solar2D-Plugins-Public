local M = {}

local physics = physics or require( "physics" )

-- Localise global functions.
local pairs = pairs
local type = type
local unpack = unpack
local min = math.min
local max = math.max
local sort = table.sort
local addBody = physics.addBody
local removeBody = physics.removeBody

-- -- Find and return vertices relative to the given vertices' centre.
local x, y = {}, {} -- Re-use these tables for improved performance.
local function getRelativeVertices( t )
	local n, l = 1, #t

	for i = 1, l, 2 do
		x[n] = t[i]
		y[n] = t[i+1]
		n = n+1
	end

	local xCentre = ( max( unpack(x) ) + min( unpack(x) ) )*0.5
	local yCentre = ( max( unpack(y) ) + min( unpack(y) ) )*0.5

	-- Clean up and keep the tables for faster future usage.
	for i = 1, n-1 do
		x[i], y[i] = nil, nil
	end

	local v = {}
	for i = 1, l, 2 do
		v[i] = t[i] - xCentre
		v[i+1] = t[i+1] - yCentre
	end

	return v
end

-- adds the :morph() function to the display object
function M.addBody( ... )
	local t = { ... }

	if type( t[1] ) ~= "table" then
		print( "WARNING: bad argument #1 to 'spyricMorph.addBody' (table expected, got " .. type( t[1] ) .. ")." )
		return
	end

	-- bodyType and all other parameters passed to addBody() are stored for later use with morphing.
	local offset, n = 0, 1
	t[1].morphData = {}
	if type( t[2] ) == "string" then
		t[1].morphData.bodyType = t[2]
		offset = 1
	else
		t[1].morphData.bodyType = "dynamic"
	end
	t[1].morphData.params = {}
	for i = 2+offset, #t do
		t[1].morphData.params[n] = {}
		for j, k in pairs( t[i] ) do
			if type( k ) == "table" then
				t[1].morphData.params[n][j] = {}
				if j == "outline" then
					print( "WARNING: Outline bodies are not supported by spyricMorph." )
				elseif j == "radius" then
					print( "WARNING: Circular bodies are not supported by spyricMorph." )
				else
					for l, m in pairs( k ) do
						t[1].morphData.params[n][j][l] = m
					end
				end
			else
				t[1].morphData.params[n][j] = k
			end
		end
		n = n+1
	end

	-- spyricMorph requires for all shapes and chains to be oriented around the object's centre, so in the case that only one
	-- params table that contains shape or chain table is passed to the function, the vertices need to be oriented correctly.
	if #t[1].morphData.params == 1 and (t[1].morphData.params[1].shape or t[1].morphData.params[1].chain) then
		local v = getRelativeVertices( t[1].morphData.params[1].shape or t[1].morphData.params[1].chain )
		local target
		if t[1].morphData.params[1].shape then
			target = t[1].morphData.params[1].shape
		else
			target = t[1].morphData.params[1].chain
		end

		for i = 1, #v do
			target[i] = v[i]
		end
	end

	-- A method for scaling (morphing) both the display object and its physics body.
	t[1].morph = function( self, xScale, yScale )
		local xScale, xOffset = xScale or 1, 0
		local yScale, yOffset = yScale or 1, 0
		self.xScale, self.yScale = xScale, yScale

		-- If an object's anchor isn't centered, then its shapes need to be offset accordingly.
		if self.anchorX ~= 0.5 then
			xOffset = ( self.anchorX - 0.5 ) * ( 1 - xScale ) * self.width
		end
		if self.anchorY ~= 0.5 then
			yOffset = ( self.anchorY - 0.5 ) * ( 1 - yScale ) * self.height
		end

		-- Use the stored data to form the parameters necessary to morphing the display object.
		local params, gotShape = {}, false
		for i = 1, #self.morphData.params do
			params[i] = {}
			for j, k in pairs( self.morphData.params[i] ) do
				if type( k ) == "table" then
					params[i][j] = {}
					for l, m in pairs( k ) do
						params[i][j][l] = m
					end
					if j == "shape" or j == "chain" then
						gotShape = true
						for l = 1, #params[i][j], 2 do
							params[i][j][l] = params[i][j][l] * xScale + xOffset
							params[i][j][l+1] = params[i][j][l+1] * yScale + yOffset
						end
					elseif j == "box" then
						gotShape = true
						params[i][j].halfWidth = params[i][j].halfWidth * xScale * 0.5
						params[i][j].halfHeight = params[i][j].halfHeight * yScale * 0.5
						params[i][j].x = params[i][j].x * xScale
						params[i][j].y = params[i][j].y * yScale
					end
				else
					params[i][j] = k
				end
			end
		end

		if self.bodyType then
			removeBody( self )
		end

		if gotShape then
			addBody( self, self.morphData.bodyType, unpack( params ) )
		else -- If no physics definitions are passed or a shape is missing, then the body is treated as a rect.
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
	t[1]:morph( 1, 1 )
end

return M
