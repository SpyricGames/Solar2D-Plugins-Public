display.setStatusBar( display.HiddenStatusBar )
local demoScene = require( "demoScene.ui" )
demoScene.create()

-- require the Spyric Font Loader plugin
local fontLoader = require("plugin.spyricFontLoader")
fontLoader.preload( "fonts", {consoleOutput=true, deepScan=true} ) 

--[[
	This sample project is just for informational purposes. In order to use the plugin
	and to preload your fonts, all you need to do is run the following function ONCE:

	fontLoader.preload( folder, deepScan, [directory], [consoleOutput] )

	where,

	folder = folder with the fonts (string)
	deepScan = option to scan all possible subfolders of the given folder (boolean)
	[directory] = (optional) you can specify the directory, e.g. ResourceDirectory (default) or DocumentsDirectory, etc. (userdata)
	[consoleOutput] = (optional) if true, the plugin will output a detailed event log into console (boolean)
]]--

local font = "fonts/OpenSans/OpenSansRegular.ttf"
local textColour = { 0.94, 0.67, 0.16 }


local description = display.newText(
	"When you use a font for the very first time after your Corona project starts, "..
	"Corona will first cache that font. Depending on the device and platform, this will roughly take between 3ms and 300ms per font file.",
	display.contentCenterX, 74, 608, 400, font, 30
)
description.anchorY = 0


-- creating the load times as well as the bottom paragraph
local round, getTimer = math.round, system.getTimer
local startTime, str
local txt, loadTime = {}, {}


for i = 1, 8 do
	startTime = system.getTimer()
	if i == 1 then
		fontLoader.preload( "fonts", {consoleOutput=true, deepScan=true} ) -- provide console output for the first preload
	else
		fontLoader.preload( "fonts", {deepScan=true} )
	end
	loadTime[i] = round((getTimer()-startTime)*100)*0.01
	if i == 1 then
		str = "1st load time (preload): "..loadTime[i].."ms"
	elseif i == 2 then
		str = "2nd load time: "..loadTime[i].."ms"
	elseif i == 3 then
		str = "3rd load time: "..loadTime[i].."ms"
	else
		str = i.."th load time: "..loadTime[i].."ms"
	end
	txt[i] = display.newText( str, 40, 270 + 40*i, font, 30 )
	txt[i]:setFillColor( unpack( textColour ) )
	txt[i].anchorX = 0
end


-- calculate the average load time and see how much faster creating text objects is after preloading
local averageTime = 0
for i = 2, #loadTime do
	averageTime = averageTime + loadTime[i]
end
averageTime =  averageTime/(#loadTime-1)
local comparison = round( loadTime[1] / averageTime * 10 )*0.1


local bottomParagraph = display.newText(
	"Loading all of this demo's fonts, as well as two native system fonts, for the first time took "..loadTime[1].."ms. "..
	"After preloading, loading the same fonts was "..comparison.." times faster. "..
	"Is this enough for you to preload your fonts?",
	display.contentCenterX, 624, 608, 400, font, 30
)
bottomParagraph.anchorY = 0
