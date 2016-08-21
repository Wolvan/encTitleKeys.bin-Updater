--[[
	Define some constants for easier usage
	later on
]]--
local WHITE = Color.new(255,255,255)
local YELLOW = Color.new(255,205,66)
local RED = Color.new(255,0,0)
local GREEN = Color.new(55,255,0)

local APP_VERSION = "1.5.0"
local APP_DIR = "/3ds/data/titlekeysTools"
local APP_CONFIG = APP_DIR.."/config.json"
local APP_LIBS_DIR = APP_DIR.."/Libraries"
local APP_TEMP_DIR = APP_DIR.."/tmp"
local API_URL = "https://3ds.titlekeys.com/"

local LIB_TYPES = {
	LIBRARY = 1,
	ARCHIVE = 2
}

--[[
	Defined libraries that the tool needs here. There are 2 formats for libraries available:
	Both types share the following key/value pairs:
		name			--Defined the name the library is going to be available as later. Also gets shown when downloading library
		filename		--Name the file will be saved as under APP_DIR/Libraries. Can be any name
		downloadPath	--The URL the library's package will be downloaded from
		type			--The type of library that can be used. Can either be LIB_TYPES.LIBRARY for unzipped or LIB_TYPES.ARCHIVE for zipped libraries
	Zipped libraries also has 1 more key/value pair that needs to be defined:
		fileToExtract	--The filename of the file inside of the archive that needs to be extracted to APP_DIR/Libraries
	
	Example library definitions:
	{
		name = "dkjson",
		filename = "dklibraries["dkjson"].lua",
		downloadPath = "http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=16cbc26080996d9da827df42cb0844a25518eeb3",
		type = LIB_TYPES.LIBRARY
	},
	{
		name = "luaqrcode",
		filename = "qrencode.lua",
		downloadPath = "https://github.com/speedata/luaqrcode/zipball/master",
		type = LIB_TYPES.ARCHIVE,
		fileToExtract = "speedata-luaqrcode-726a866/qrencode.lua"
	}
]]--
local REQUIRED_LIBRARIES = {
	{
		name = "dkjson",
		filename = "dkjson.lua",
		downloadPath = "http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=16cbc26080996d9da827df42cb0844a25518eeb3",
		type = LIB_TYPES.LIBRARY
	}
}

local config = {
	enableUpdateCheck = {
		text = "Enable Update Check",
		value = true
	},
	autoUpdateTitleKeysOnStartup = {
		text = "Auto update encTitleKeys.bin",
		value = false
	},
	useFreeShop1Path = {
		text = "Use Freeshop 1.x Path",
		value = false
	},
	downloadRetryCount = {
		text = "Download Retries",
		value = 3,
		minValue = 1,
		maxValue = 10
	},
	launchFreeshopAfterUpdate = {
		text = "Launch Freeshop automatically",
		value = false
	}
}

local selection = 1
local option_selection = 1
local localSize = 0
local parsed = {}
local config_backup = {}
local libraries = {}

local remVer = nil
local locVer = nil
local canUpdate = nil

local home = "Homemenu"
if System.checkBuild() ~= 1 then
	home = "Homebrew Launcher"
end

local pad = Controls.read()
local oldpad = pad

--[[
	String manipulation functions that Lua unfortunately
	does not natively support.
]]--
function string.split(self, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
function string.startsWith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end

--[[
	A way to copy tables without linking them through
	references
]]--
function deepcopy(orig)
	local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
	A function to give the actual number of elements
	in a table compared to # which returns the last
	number index
]]--
function countTableElements(tbl)
	local i = 0
	for k,v in pairs(tbl) do
		i = i + 1
	end
	return i
end

--[[
	This function just presents an error to
	the user. Overriding the keypressFunction
	allows changing behavior of the error
]]--
function showError(errorMsg, keypressFunction)
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
	local splitString = errorMsg:split("\n")
	for k,v in pairs(splitString) do
		Screen.debugPrint(5, ((k-1)*15)+5, v, RED, TOP_SCREEN)
	end
	Screen.debugPrint(5, 95, "GitHub can be found at", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 110, "https://github.com/Wolvan", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 125, "/encTitleKeys.bin-Updater", WHITE, BOTTOM_SCREEN)
	while true do
		keypressFunction()
	end
end

--[[
	Messages of the day which one gets randomly
	printed on App Init
]]--
local motds = {
	{
		msg = "Tool presented by Wolvan",
		color = WHITE
	},
	{
		msg = ">bricked",
		color = GREEN
	},
	{
		msg = "freeshop? More like fREEEEEshop",
		color = RED
	},
	{
		msg = "In 5 hours",
		color = WHITE
	},
	{
		msg = "Can I install DS cias?",
		color = WHITE
	},
	{
		msg = "How can I downgrade from 11.0?",
		color = WHITE
	}
}

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
		text = "Download latest decTitleKeys.bin",
		callback = function() downloadDecTitleKeys() end
	},
	{
		text = "Download decTitleKeys.bin to encrypt",
		callback = function() downloadDecTitleKeysForEnc() end
	},
	{
		text = "Download latest seeddb.bin",
		callback = function() downloadSeedDB() end
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

--[[
	Only add the Settings Menu if there are actually
	settings
]]--
if countTableElements(config) > 0 then
	menu_options[#menu_options+1] = {
		text = "Settings",
		callback = function() optionsMenu() end
	}
end

--[[
	Make sure the Return Button is the last option
	in the list
]]--
	menu_options[#menu_options+1] = {
		text = "Return to "..home,
		callback = System.exit
	}

--[[
	Functions to save and load config from a config
	file. The config table (which gets set further
	up in this file) gets encoded as JSON file and
	saved to the SD. 
	Loading reads that file (or creates it if it 
	doesn't exist before reading), decodes the JSON
	and then overwrites each value of the config
	table that is defined in the decoded JSON Object.
	This way, settings that are not stored in the config
	yet just use the default value set in the config table.
]]--
function saveConfig()
	local jsonString = libraries["dkjson"].encode(config, { indent = true })
	System.createDirectory(APP_DIR)
	System.deleteFile(APP_CONFIG)
	local file = io.open(APP_CONFIG, FCREATE)
	io.write(file, 0, jsonString, jsonString:len())
	io.close(file)
end
function loadConfig()
	local configPath = APP_CONFIG
	if not System.doesFileExist(configPath) then
		saveConfig()
	end
	local file = io.open(configPath, FREAD)
	
	local filesize = 0
	filesize = tonumber(io.size(file))
	if filesize == 0 then
		io.close(file)
		saveConfig()
		file = io.open(configPath, FREAD)
	end
	
	local file_contents = io.read(file, 0, tonumber(io.size(file)))
	io.close(file)
	local loaded_config = libraries["dkjson"].decode(file_contents)
	if type(loaded_config) == "table" then
		for k,v in pairs(loaded_config) do
			config[k] = v
		end
	else
		return false
	end
	return true
end


--[[
	Check if the User has Wi-Fi disabled and an
	Internet connection is available
]]--
function checkWifi()
	if not Network.isWifiEnabled() then
		showError("Wi-Fi is disabled. Restart and try again.\nPress A to go back to "..home..".", function()
			pad = Controls.read()
			if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
				Screen.waitVblankStart()
				Screen.flip()
				System.exit()
			end
			oldpad = pad
		end)
	end
end

--[[
	Functions to parse and compare SemVer compliant
	versions. parseVersion accepts and parses Strings
	in the format MAJOR.MINOR.PATCH and returns a table
	{major, minor, version} which can be used by
	isUpdateAvailable
]]--
function parseVersion(verString)
	if verString == nil or verString == "" then
		verString = "0.0.0"
	end
	
	verString = verString:gsub(" ", "")
	local version = {}
	local splitVersion = verString:split(".")
	if splitVersion[1]:lower():startsWith("v") then
		splitVersion[1] = splitVersion[1]:sub(2)
	end
	
	version.major = tonumber(splitVersion[1]) or 0
	version.minor = tonumber(splitVersion[2]) or 0
	version.patch = tonumber(splitVersion[3]) or 0
	
	return version
end
function isUpdateAvailable(localVersion, remoteVersion)
	if remoteVersion.major > localVersion.major then
		return true
	end
	if (remoteVersion.minor > localVersion.minor) and (remoteVersion.major >= localVersion.major) then
		return true
	end
	if (remoteVersion.patch > localVersion.patch) and (remoteVersion.major >= localVersion.major) and (remoteVersion.minor >= localVersion.minor) then
		return true
	end
	return false
end


--[[
	Check App State to close the App in case
	of exitting from home menu
]]--
function checkForExit()
	if System.checkStatus() == APP_EXITING then
		System.exit()
	end
end

function tryDownloadFile(path, downloadURL)
	System.deleteFile(path)
	Network.downloadFile(downloadURL, path, "User-Agent: TitleKeysTools/"..APP_VERSION, "GET")
	local filesize = 0
	if System.doesFileExist(path) then
		local encTitleKeys = io.open(path, FREAD)
		filesize = tonumber(io.size(encTitleKeys))
		io.close(encTitleKeys)
	end
	if filesize == 0 then
		return false
	end
	return true
end

function prepareFileDownload(filename)
	checkWifi()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	Screen.debugPrint(5, 5, "Downloading "..filename.."...", GREEN, TOP_SCREEN)
end

--[[
	Download missing libraries that are needed
]]--
function checkLibraries()
	local function getLib(lib)
		System.createDirectory(APP_DIR)
		System.createDirectory(APP_LIBS_DIR)
		local path = APP_LIBS_DIR.."/"..lib.filename
		if lib.type == LIB_TYPES.ARCHIVE then
			System.createDirectory(APP_TEMP_DIR)
			path = APP_TEMP_DIR.."/"..lib.filename..".zip"
		end
		local downloadURL = lib.downloadPath
		local success = tryDownloadFile(path, downloadURL)
		local tries = 0
		while (tries < config.downloadRetryCount.value) and (not success) do
			success = tryDownloadFile(path, downloadURL)
			tries = tries + 1
		end
		if success then
			if lib.type == LIB_TYPES.ARCHIVE then
				System.extractFromZIP(path, lib.fileToExtract, APP_LIBS_DIR.."/"..lib.filename)
				System.deleteFile(path)
				System.deleteDirectory(APP_TEMP_DIR)
			end
		end
		return success
	end
	for k,v in pairs(REQUIRED_LIBRARIES) do
		Screen.clear(BOTTOM_SCREEN)
		Screen.debugPrint(5, 5, "Checking library "..k.." of "..#REQUIRED_LIBRARIES.."...", WHITE, BOTTOM_SCREEN)
		if not System.doesFileExist(APP_LIBS_DIR.."/"..v.filename) then
			Screen.debugPrint(5, 20, "Downloading "..v.name, WHITE, BOTTOM_SCREEN)
			if not getLib(v) then
				showError("Failed to download library!\nUnable to continue, please\ntry restarting the app and\ntry again.\n \nPress A to go back to "..home..".", function()
					pad = Controls.read()
					if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
						System.exit()
					end
					oldpad = pad
				end)
			end
		end
	end
	Screen.clear(BOTTOM_SCREEN)
end

function update()
	prepareFileDownload("encTitleKeys.bin")
	local freeshopPath = "/3ds/data/freeShop"
	if config.useFreeShop1Path.value then
		freeshopPath = "/freeShop"
	else
		System.createDirectory("/3ds")
		System.createDirectory("/3ds/data")
	end
	System.createDirectory(freeshopPath)
	
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownloadFile(freeshopPath.."/encTitleKeys.bin", API_URL.."downloadenc")
	end
	
	if not success then
		showError("encTitleKeys.bin failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	local encTitleKeys = io.open(freeshopPath.."/encTitleKeys.bin", FREAD)
	localSize = io.size(encTitleKeys)
	io.close(encTitleKeys)
	Screen.debugPrint(5, 50, "Done!", GREEN, TOP_SCREEN)
	if System.checkBuild() == 1 and config.launchFreeshopAfterUpdate.value then
		pad = Controls.read()
		if not Controls.check(pad, KEY_SELECT) then
			System.launchCIA(0x0f12ee00,SDMC)
		end
	end
	if System.checkBuild() ~= 2 then Screen.debugPrint(5, 95, "Press A to launch freeShop", GREEN, TOP_SCREEN) end
	Screen.debugPrint(5, 110, "Press B to go back to "..home, GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 125, "Press X to go back to the menu", GREEN, TOP_SCREEN)
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			Screen.waitVblankStart()
			Screen.flip()
			System.exit()
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) and System.checkBuild() ~= 2 then
			Screen.waitVblankStart()
			Screen.flip()
			System.launchCIA(0x0f12ee00,SDMC)
		elseif Controls.check(pad, KEY_X) and not Controls.check(oldpad, KEY_X) then
			Screen.waitVblankStart()
			Screen.flip()
			main()
		end
		oldpad = pad
	end
end
function downloadSeedDB()
	prepareFileDownload("seeddb.bin")
	
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownloadFile("/seeddb.bin", API_URL.."seeddb")
	end
	
	if not success then
		showError("seeddb.bin failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	Screen.debugPrint(5, 50, "Done!", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 95, "Press A to go back to the menu", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 110, "Press B to return to "..home, GREEN, TOP_SCREEN)
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			Screen.waitVblankStart()
			Screen.flip()
			System.exit()
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
			Screen.waitVblankStart()
			Screen.flip()
			main()
		end
		oldpad = pad
	end
end
function downloadDecTitleKeys()
	prepareFileDownload("decTitleKeys.bin")
	
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownloadFile("/decTitleKeys.bin", API_URL.."download")
	end
	
	if not success then
		showError("decTitleKeys.bin failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	Screen.debugPrint(5, 50, "Done!", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 95, "Press A to go back to the menu", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 110, "Press B to return to "..home, GREEN, TOP_SCREEN)
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			Screen.waitVblankStart()
			Screen.flip()
			System.exit()
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
			Screen.waitVblankStart()
			Screen.flip()
			main()
		end
		oldpad = pad
	end
end
function downloadDecTitleKeysForEnc()
	prepareFileDownload("decTitleKeys_forEnc.bin")
	
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownloadFile("/decTitleKeys_forEnc.bin", API_URL.."downloadmissingforencryption")
	end
	
	if not success then
		showError("decTitleKeys_forEnc.bin failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
	Screen.debugPrint(5, 50, "Done!", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 95, "Press A to go back to the menu", GREEN, TOP_SCREEN)
	Screen.debugPrint(5, 110, "Press B to return to "..home, GREEN, TOP_SCREEN)
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			Screen.waitVblankStart()
			Screen.flip()
			System.exit()
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
			Screen.waitVblankStart()
			Screen.flip()
			main()
		end
		oldpad = pad
	end
end

function init()
	System.createDirectory("/3ds")
	System.createDirectory("/3ds/data")
	System.renameDirectory("/encTitleKeysUpdater", APP_DIR)
	System.renameDirectory("/titlekeysTools", APP_DIR)
	local function tryDownload()
		local remoteData = Network.requestString("http://enctitlekeys.wolvan.at/meta.php")
		if remoteData ~= "" and remoteData ~= nil and type(remoteData) == "string" then
			parsed = libraries["dkjson"].decode(remoteData)
		else
			return false
		end
		return true
	end
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	local line = 5
	Screen.debugPrint(5, line, "Initialising Updater, please wait...", WHITE, TOP_SCREEN)
	
	local h,m,s = System.getTime()
	local seed = (h * 60 * 60) + (m * 60) + s
	math.randomseed(seed)
	local motd = motds[math.random(#motds)]
	Screen.debugPrint(5, 110, motd.msg, motd.color, BOTTOM_SCREEN)
	
	line = 20
	Screen.debugPrint(5, line, "Checking Wi-Fi...", WHITE, TOP_SCREEN)
	checkWifi()
	Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	
	line = 35
	Screen.debugPrint(5, line, "Checking Libraries...", WHITE, TOP_SCREEN)
	checkLibraries()
	for k,v in pairs(REQUIRED_LIBRARIES) do
		libraries[v.name] = dofile(APP_LIBS_DIR.."/"..v.filename)
	end
	Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	
	line = 50
	Screen.debugPrint(5, line, "Loading config...", WHITE, TOP_SCREEN)
	if loadConfig() then
		config_backup = deepcopy(config)
		Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	else
		Screen.debugPrint(270, line, "[FAILED]", RED, TOP_SCREEN)
	end
	
	line = 65
	Screen.debugPrint(5, line, "Checking encTitleKeys.bin...", WHITE, TOP_SCREEN)
	local freeshopPath = "/3ds/data/freeshop"
	if config.useFreeShop1Path.value then freeshopPath = "/freeshop" end
	if System.doesFileExist(freeshopPath.."/encTitleKeys.bin") then
		local encTitleKeys = io.open(freeshopPath.."/encTitleKeys.bin", FREAD)
		localSize = io.size(encTitleKeys)
		io.close(encTitleKeys)
		Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	else
		Screen.debugPrint(270, line, "[File not found]", YELLOW, TOP_SCREEN)
	end
	
	line = 80
	Screen.debugPrint(5, line, "Retrieving data from Server...", WHITE, TOP_SCREEN)
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownload()
	end
	
	if not success then
		showError("Error occured while fetching remote data\nPress A to try again\nPress B to return to "..home..".", function()
			pad = Controls.read()
			if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
				Screen.waitVblankStart()
				Screen.flip()
				init()
			elseif Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
				Screen.waitVblankStart()
				Screen.flip()
				System.exit()
			end
			oldpad = pad
		end)
	end
	Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	
	line = 95
	Screen.debugPrint(5, line, "Checking for Updates...", WHITE, TOP_SCREEN)
	if config.enableUpdateCheck.value then
		locVer = parseVersion(APP_VERSION)
		remVer = parseVersion(parsed.current_version)
		canUpdate = isUpdateAvailable(locVer, remVer)
		Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	else
		Screen.debugPrint(270, line, "[SKIPPED]", YELLOW, TOP_SCREEN)
	end
	
	if config.autoUpdateTitleKeysOnStartup.value then
		if localSize ~= parsed.size then
			update()
		end
	end
	
	main()
end

--[[
	Draw the Bottom Screen content with credits
	and the like
]]--
function printBottomScreen()
	Screen.clear(BOTTOM_SCREEN)
	Screen.debugPrint(5, 5, "The latest .bin has "..parsed.keys.." keys!", WHITE, BOTTOM_SCREEN)
	if localSize ~= parsed.size then
		Screen.debugPrint(5, 20, "Your encTitleKeys.bin is out of date!", RED, BOTTOM_SCREEN)
	else
		Screen.debugPrint(5, 20, "Your encTitleKeys.bin is up to date!", GREEN, BOTTOM_SCREEN)
	end
	if canUpdate then
		Screen.debugPrint(5, 220, "Updater version "..remVer.major.."."..remVer.minor.."."..remVer.patch.." now available!", RED, TOP_SCREEN)
	end
	Screen.debugPrint(5, 65, "Thanks to the following people:", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 80, "Cruel - For giving us FreeShop", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 95, "MatMaf - For the original updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 110, "Rinnegatamante - For LPP3DS", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 125, "You - For using this tool at all", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 140, "AFgt - For testing the updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 155, "Nai - For testing the updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 170, "Some other people I forgot", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 205, "v"..APP_VERSION, WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 220, "forked by Wolvan", WHITE, BOTTOM_SCREEN)
end

--[[
	Draw the main menu on the top screen which gets
	dynamically built through the menu_options table
]]--
function printTopScreen()
	Screen.clear(TOP_SCREEN)
	Screen.debugPrint(5, 5, "Titlekeys Tools", YELLOW, TOP_SCREEN)
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
		checkForExit()
		oldpad = pad
		main()
	end
end

function optionsMenu()
	oldpad = pad
	Screen.waitVblankStart()
	Screen.refresh()
	
	Screen.clear(TOP_SCREEN)
	Screen.debugPrint(5, 5, "Options", YELLOW, TOP_SCREEN)
	Screen.debugPrint(20, (option_selection * 15) + 5, ">", WHITE, TOP_SCREEN)
	local config_keys = {}
	local i = 1
	for k,v in pairs(config) do
		Screen.debugPrint(30, (i * 15) + 5, v.text, WHITE, TOP_SCREEN)
		if type(v.value) == "boolean" then
			if v.value then
				Screen.debugPrint(350, (i * 15) + 5, "On", GREEN, TOP_SCREEN)
			else
				Screen.debugPrint(350, (i * 15) + 5, "Off", RED, TOP_SCREEN)
			end
		elseif type(v.value) == "number" then
			Screen.debugPrint(350, (i * 15) + 5, v.value, YELLOW, TOP_SCREEN)
		end
		
		config_keys[#config_keys+1] = k
		i = i + 1
	end
	
	Screen.clear(BOTTOM_SCREEN)
	Screen.debugPrint(5, 110, "up/down - Select option", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 125, "left/right - Change setting", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 140, "A - Save", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 155, "B - Cancel", WHITE, BOTTOM_SCREEN)
	
	Screen.flip()
	
	while true do
		pad = Controls.read()
		if Controls.check(pad, KEY_DDOWN) and not Controls.check(oldpad, KEY_DDOWN) then
			option_selection = option_selection + 1
			if (option_selection > #config_keys) then
				option_selection = 1
			end
		elseif Controls.check(pad, KEY_DUP) and not Controls.check(oldpad, KEY_DUP) then
			option_selection = option_selection - 1
			if (option_selection < 1) then
				option_selection = #config_keys
			end
		elseif Controls.check(pad, KEY_DLEFT) and not Controls.check(oldpad, KEY_DLEFT) then
			local currentSetting = config[config_keys[option_selection]]
			if type(currentSetting.value) == "boolean" then
				currentSetting.value = not currentSetting.value
			elseif type(currentSetting.value) == "number" then
				currentSetting.value = currentSetting.value - 1
				if currentSetting.minValue then
					if currentSetting.value < currentSetting.minValue then currentSetting.value = currentSetting.minValue end
				end
				config[config_keys[option_selection]].value = currentSetting.value
			end
		elseif Controls.check(pad, KEY_DRIGHT) and not Controls.check(oldpad, KEY_DRIGHT) then
			local currentSetting = config[config_keys[option_selection]]
			if type(currentSetting.value) == "boolean" then
				currentSetting.value = not currentSetting.value
			elseif type(currentSetting.value) == "number" then
				currentSetting.value = currentSetting.value + 1
				if currentSetting.maxValue then
					if currentSetting.value > currentSetting.maxValue then currentSetting.value = currentSetting.maxValue end
				end
				config[config_keys[option_selection]].value = currentSetting.value
			end
		elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
			oldpad = pad
			config_backup = deepcopy(config)
			saveConfig()
			main()
		elseif Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			oldpad = pad
			config = deepcopy(config_backup)
			main()
		end
		oldpad = pad
		optionsMenu()
	end
end

init()
