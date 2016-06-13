--[[
	Define color constants for easier usage
	in debugPrint calls
]]--
local WHITE = Color.new(255,255,255)
local YELLOW = Color.new(255,205,66)
local RED = Color.new(255,0,0)
local GREEN = Color.new(55,255,0)

local selection = 1
local motd = ""
local size = 0
local usersize = 0

local home = "Homemenu"
if System.checkBuild() ~= 1 then
	home = "Homebrew Launcher"
end

local pad = Controls.read()
local oldpad = pad

--[[
	This function just presents an error to
	the user. Overriding the keypressFunction
	allows changing behavior of the error
]]--
function showError(errorMsg, keypressFunction)
	local function split(self, sep)
		local sep, fields = sep or ":", {}
		local pattern = string.format("([^%s]+)", sep)
		self:gsub(pattern, function(c) fields[#fields+1] = c end)
		return fields
	end
	keypressFunction = keypressFunction or function()
		pad = Controls.read()
			if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
				Screen.waitVblankStart()
				Screen.flip()
				main()
			end
			oldpad = pad
	end
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	local splitString = split(errorMsg, "\n")
	for k,v in pairs(splitString) do
		Screen.debugPrint(5, ((k-1)*15)+5, v, RED, TOP_SCREEN)
	end
	while true do
		keypressFunction()
	end
end

--[[
	This table contains a dynamically generated main menu
	Each Entry has a text and a callback property which is
	used to build the menu on runtime instead of hardcoding it
	Makes adding stuff to the menu very easy and is easy to manage
]]--
local menu_options = {
	{
		text = "Download latest encTitleKeys.bin",
		callback = function() update() end
	},
	{
		text = "Return to "..home,
		callback = System.exit
	}
}
--[[
	Launching CIAs does not seem to work from Ninjhax2
	This is why we only add the Launch freeShop option if
	we are on a .cia or .3ds build
]]--
if System.checkBuild() ~= 2 then
	menu_options[#menu_options+1] = {
		text = "Launch freeShop",
		callback = function()
			System.launchCIA(0x0f12ee00,SDMC)
		end
	}
end

function checkWifi()
	if not Network.isWifiEnabled() then
		showError("Wi-Fi is disabled. Restart and try again.\nPress A to go back to "..home..".", function()
			pad = Controls.read()
			oldpad = pad
			if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
				Screen.waitVblankStart()
				Screen.flip()
				System.exit()
			end
			oldpad = pad
		end)
	end
end

function update()
	checkWifi()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	Screen.debugPrint(5, 5, "Downloading...", GREEN, TOP_SCREEN)
	if System.doesFileExist("/encTitleKeys.zip") then System.deleteFile("/encTitleKeys.zip") end
	System.createDirectory("/freeShop")
	Network.downloadFile("http://matmaf.github.io/encTitleKeys.bin-Updater/f4g5h6.zip", "/encTitleKeys.zip")
	if not System.doesFileExist("/encTitleKeys.zip") then
		showError("EncTitleKeys.zip failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	Screen.debugPrint(5, 20, "Extracting...", GREEN, TOP_SCREEN)
	System.deleteFile("/freeShop/encTitleKeys.bin")
	System.extractFromZIP("/encTitleKeys.zip", "a1s2d3.bin", "/freeShop/encTitleKeys.bin")
	if not System.doesFileExist("/freeShop/encTitleKeys.bin") then
		showError("Failed to extract encTitleKeys.bin,\nplease try again.\n \nIf this keeps happening, please\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	Screen.debugPrint(5, 35, "Cleaning up...", GREEN, TOP_SCREEN)
	System.deleteFile("/encTitleKeys.zip")
	Screen.debugPrint(5, 50, "Done!", GREEN, TOP_SCREEN)
	if System.checkBuild() ~= 2 then Screen.debugPrint(5, 95, "Press A to launch freeShop", GREEN, TOP_SCREEN) end
	Screen.debugPrint(5, 110, "Press B to go back to "..home, GREEN, TOP_SCREEN)
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_B) then
			Screen.waitVblankStart()
			Screen.flip()
			System.exit()
		elseif Controls.check(pad, KEY_A) and System.checkBuild() ~= 2 then
			Screen.waitVblankStart()
			Screen.flip()
			System.launchCIA(0x0f12ee00,SDMC)
		end
	end
end


function init()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	checkWifi()
	motd = Network.requestString("http://matmaf.github.io/encTitleKeys.bin-Updater/motd")
	size = tonumber(Network.requestString("http://matmaf.github.io/encTitleKeys.bin-Updater/size"))
	if System.doesFileExist("/freeShop/encTitleKeys.bin") then
		local fileStream = io.open("/freeShop/encTitleKeys.bin", FREAD)
		usersize = tonumber(io.size(fileStream))
		io.close(fileStream)
	end
	main()
end

--[[
	Draw the Bottom Screen content with credits
	and the like
]]--
function printBottomScreen()
	Screen.clear(BOTTOM_SCREEN)
	Screen.debugPrint(5, 5, motd, WHITE, BOTTOM_SCREEN)
	if usersize == size then
		Screen.debugPrint(5, 20, "encTitleKeys.bin is up to date.", GREEN, BOTTOM_SCREEN)
	else
		Screen.debugPrint(5, 20, "encTitleKeys.bin is not up to date.", RED, BOTTOM_SCREEN)
	end
	Screen.debugPrint(5, 50, "Thanks to the following people:", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 65, "Cruel - For giving us FreeShop", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 80, "MatMaf - For the updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 95, "Rinnegatamante - For LPP3DS", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 110, "You - For using this tool at all", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 125, "Some other people I forgot", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 190, "v1.0.0", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 205, "by MatMaf", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 220, "forked by Wolvan", WHITE, BOTTOM_SCREEN)
end

--[[
	Draw the main menu on the top screen which gets
	dynamically built through the menu_options table
]]--
function printTopScreen()
	Screen.clear(TOP_SCREEN)
	Screen.debugPrint(5, 5, "encTitleKeysUpdater for freeShop", YELLOW, TOP_SCREEN)
	Screen.debugPrint(20, (selection * 15) + 5, ">", WHITE, TOP_SCREEN)
	for k,v in pairs(menu_options) do
		Screen.debugPrint(30, (k * 15) + 5, v.text, WHITE, TOP_SCREEN)
	end
end

--[[
	Loop for the main menu, just keeps drawing
	and checking for key input the entire time
]]--
function main()
	oldpad = pad
	Screen.waitVblankStart()
	Screen.refresh()
	printTopScreen()
	printBottomScreen()
	Screen.flip()

	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_DDOWN) and not Controls.check(oldpad, KEY_DDOWN) then
			selection = selection + 1
			if (selection > #menu_options) then
				selection = 1
			end
		elseif Controls.check(pad, KEY_DUP) and not Controls.check(oldpad, KEY_DUP) then
			selection = selection - 1
			if (selection < 1) then
				selection = #menu_options
			end
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
			oldpad = pad
			menu_options[selection].callback()
		elseif Controls.check(pad, KEY_HOME) and System.checkBuild() ~= 1 then
			System.exit()
		elseif Controls.check(pad, KEY_HOME) and System.checkBuild() == 1 then
			System.showHomeMenu()
		end
		oldpad = pad
		main()
	end
end

init()
