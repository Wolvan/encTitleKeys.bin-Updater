--[[
	Define some constants for easier usage
	later on
]]--
local WHITE = Color.new(255,255,255)
local YELLOW = Color.new(255,205,66)
local RED = Color.new(255,0,0)
local GREEN = Color.new(55,255,0)

local APP_VERSION = "1.2.0"
local APP_DIR = "/encTitleKeysUpdater"
local APP_CONFIG = APP_DIR.."/config.json"

--[[
	Libraries that I use get defined here
	Unfortunately I can not simply load them
	with require or dofile since those do not
	read from romfs
]]--
--dkjson by David Kolf, http://dkolf.de/src/dkjson-lua.fsl/ for full source
function jsonfunction()
	local a=true;local b=false;local c='json'local pairs,type,tostring,tonumber,getmetatable,setmetatable,rawset=pairs,type,tostring,tonumber,getmetatable,setmetatable,rawset;local error,require,pcall,select=error,require,pcall,select;local d,e=math.floor,math.huge;local f,g,h,i,j,k,l,m=string.rep,string.gsub,string.sub,string.byte,string.char,string.find,string.len,string.format;local n=string.match;local o=table.concat;local p={version="dkjson 2.5"}if b then _G[c]=p end;local q=nil;pcall(function()local r=require"debug".getmetatable;if r then getmetatable=r end end)p.null=setmetatable({},{__tojson=function()return"null"end})local function s(t)local u,v,w=0,0,0;for x,y in pairs(t)do if x=='n'and type(y)=='number'then w=y;if y>u then u=y end else if type(x)~='number'or x<1 or d(x)~=x then return false end;if x>u then u=x end;v=v+1 end end;if u>10 and u>w and u>v*2 then return false end;return true,u end;local z={["\""]="\\\"",["\\"]="\\\\",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t"}local function A(B)local C=z[B]if C then return C end;local D,E,F,G=i(B,1,4)D,E,F,G=D or 0,E or 0,F or 0,G or 0;if D<=0x7f then C=D elseif 0xc0<=D and D<=0xdf and E>=0x80 then C=(D-0xc0)*0x40+E-0x80 elseif 0xe0<=D and D<=0xef and E>=0x80 and F>=0x80 then C=((D-0xe0)*0x40+E-0x80)*0x40+F-0x80 elseif 0xf0<=D and D<=0xf7 and E>=0x80 and F>=0x80 and G>=0x80 then C=(((D-0xf0)*0x40+E-0x80)*0x40+F-0x80)*0x40+G-0x80 else return""end;if C<=0xffff then return m("\\u%.4x",C)elseif C<=0x10ffff then C=C-0x10000;local H,I=0xD800+d(C/0x400),0xDC00+C%0x400;return m("\\u%.4x\\u%.4x",H,I)else return""end end;local function J(K,L,M)if k(K,L)then return g(K,L,M)else return K end end;local function N(C)C=J(C,"[%z\1-\31\"\\\127]",A)if k(C,"[\194\216\220\225\226\239]")then C=J(C,"\194[\128-\159\173]",A)C=J(C,"\216[\128-\132]",A)C=J(C,"\220\143",A)C=J(C,"\225\158[\180\181]",A)C=J(C,"\226\128[\140-\143\168-\175]",A)C=J(C,"\226\129[\160-\175]",A)C=J(C,"\239\187\191",A)C=J(C,"\239\191[\176-\191]",A)end;return"\""..C.."\""end;p.quotestring=N;local function O(K,P,v)local Q,R=k(K,P,1,true)if Q then return h(K,1,Q-1)..v..h(K,R+1,-1)else return K end end;local S,T;local function U()S=n(tostring(0.5),"([^05+])")T="[^0-9%-%+eE"..g(S,"[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%0").."]+"end;U()local function V(W)return O(J(tostring(W),T,""),S,".")end;local function X(K)local W=tonumber(O(K,".",S))if not W then U()W=tonumber(O(K,".",S))end;return W end;local function Y(Z,_,a0)_[a0+1]="\n"_[a0+2]=f("  ",Z)a0=a0+2;return a0 end;function p.addnewline(a1)if a1.indent then a1.bufferlen=Y(a1.level or 0,a1.buffer,a1.bufferlen or#a1.buffer)end end;local a2;local function a3(a4,C,a5,a6,Z,_,a0,a7,a8,a1)local a9=type(a4)if a9~='string'and a9~='number'then return nil,"type '"..a9 .."' is not supported as a key by JSON."end;if a5 then a0=a0+1;_[a0]=","end;if a6 then a0=Y(Z,_,a0)end;_[a0+1]=N(a4)_[a0+2]=":"return a2(C,a6,Z,_,a0+2,a7,a8,a1)end;local function aa(ab,_,a1)local a0=a1.bufferlen;if type(ab)=='string'then a0=a0+1;_[a0]=ab end;return a0 end;local function ac(ad,C,a1,_,a0,ae)ae=ae or ad;local af=a1.exception;if not af then return nil,ae else a1.bufferlen=a0;local ag,ah=af(ad,C,a1,ae)if not ag then return nil,ah or ae end;return aa(ag,_,a1)end end;function p.encodeexception(ad,C,a1,ae)return N("<"..ae..">")end;a2=function(C,a6,Z,_,a0,a7,a8,a1)local ai=type(C)local aj=getmetatable(C)aj=type(aj)=='table'and aj;local ak=aj and aj.__tojson;if ak then if a7[C]then return ac('reference cycle',C,a1,_,a0)end;a7[C]=true;a1.bufferlen=a0;local ag,ah=ak(C,a1)if not ag then return ac('custom encoder failed',C,a1,_,a0,ah)end;a7[C]=nil;a0=aa(ag,_,a1)elseif C==nil then a0=a0+1;_[a0]="null"elseif ai=='number'then local al;if C~=C or C>=e or-C>=e then al="null"else al=V(C)end;a0=a0+1;_[a0]=al elseif ai=='boolean'then a0=a0+1;_[a0]=C and"true"or"false"elseif ai=='string'then a0=a0+1;_[a0]=N(C)elseif ai=='table'then if a7[C]then return ac('reference cycle',C,a1,_,a0)end;a7[C]=true;Z=Z+1;local am,v=s(C)if v==0 and aj and aj.__jsontype=='object'then am=false end;local ah;if am then a0=a0+1;_[a0]="["for Q=1,v do a0,ah=a2(C[Q],a6,Z,_,a0,a7,a8,a1)if not a0 then return nil,ah end;if Q<v then a0=a0+1;_[a0]=","end end;a0=a0+1;_[a0]="]"else local a5=false;a0=a0+1;_[a0]="{"local an=aj and aj.__jsonorder or a8;if an then local ao={}v=#an;for Q=1,v do local x=an[Q]local y=C[x]if y then ao[x]=true;a0,ah=a3(x,y,a5,a6,Z,_,a0,a7,a8,a1)a5=true end end;for x,y in pairs(C)do if not ao[x]then a0,ah=a3(x,y,a5,a6,Z,_,a0,a7,a8,a1)if not a0 then return nil,ah end;a5=true end end else for x,y in pairs(C)do a0,ah=a3(x,y,a5,a6,Z,_,a0,a7,a8,a1)if not a0 then return nil,ah end;a5=true end end;if a6 then a0=Y(Z-1,_,a0)end;a0=a0+1;_[a0]="}"end;a7[C]=nil else return ac('unsupported type',C,a1,_,a0,"type '"..ai.."' is not supported by JSON.")end;return a0 end;function p.encode(C,a1)a1=a1 or{}local ap=a1.buffer;local _=ap or{}a1.buffer=_;U()local ag,ah=a2(C,a1.indent,a1.level or 0,_,a1.bufferlen or 0,a1.tables or{},a1.keyorder,a1)if not ag then error(ah,2)elseif ap==_ then a1.bufferlen=ag;return true else a1.bufferlen=nil;a1.buffer=nil;return o(_)end end;local function aq(K,ar)local as,at,au=1,1,0;while true do at=k(K,"\n",at,true)if at and at<ar then as=as+1;au=at;at=at+1 else break end end;return"line "..as..", column "..ar-au end;local function av(K,aw,ar)return nil,l(K)+1,"unterminated "..aw.." at "..aq(K,ar)end;local function ax(K,at)while true do at=k(K,"%S",at)if not at then return nil end;local ay=h(K,at,at+1)if ay=="\239\187"and h(K,at+2,at+2)=="\191"then at=at+3 elseif ay=="//"then at=k(K,"[\n\r]",at+2)if not at then return nil end elseif ay=="/*"then at=k(K,"*/",at+2)if not at then return nil end;at=at+2 else return at end end end;local az={["\""]="\"",["\\"]="\\",["/"]="/",["b"]="\b",["f"]="\f",["n"]="\n",["r"]="\r",["t"]="\t"}local function aA(C)if C<0 then return nil elseif C<=0x007f then return j(C)elseif C<=0x07ff then return j(0xc0+d(C/0x40),0x80+d(C)%0x40)elseif C<=0xffff then return j(0xe0+d(C/0x1000),0x80+d(C/0x40)%0x40,0x80+d(C)%0x40)elseif C<=0x10ffff then return j(0xf0+d(C/0x40000),0x80+d(C/0x1000)%0x40,0x80+d(C/0x40)%0x40,0x80+d(C)%0x40)else return nil end end;local function aB(K,at)local aC=at+1;local _,v={},0;while true do local aD=k(K,"[\"\\]",aC)if not aD then return av(K,"string",at)end;if aD>aC then v=v+1;_[v]=h(K,aC,aD-1)end;if h(K,aD,aD)=="\""then aC=aD+1;break else local aE=h(K,aD+1,aD+1)local C;if aE=="u"then C=tonumber(h(K,aD+2,aD+5),16)if C then local aF;if 0xD800<=C and C<=0xDBff then if h(K,aD+6,aD+7)=="\\u"then aF=tonumber(h(K,aD+8,aD+11),16)if aF and 0xDC00<=aF and aF<=0xDFFF then C=(C-0xD800)*0x400+aF-0xDC00+0x10000 else aF=nil end end end;C=C and aA(C)if C then if aF then aC=aD+12 else aC=aD+6 end end end end;if not C then C=az[aE]or aE;aC=aD+2 end;v=v+1;_[v]=C end end;if v==1 then return _[1],aC elseif v>1 then return o(_),aC else return"",aC end end;local aG;local function aH(aw,aI,K,aJ,aK,aL,aM)local aN=l(K)local t,v={},0;local at=aJ+1;if aw=='object'then setmetatable(t,aL)else setmetatable(t,aM)end;while true do at=ax(K,at)if not at then return av(K,aw,aJ)end;local aO=h(K,at,at)if aO==aI then return t,at+1 end;local aP,aQ;aP,at,aQ=aG(K,at,aK,aL,aM)if aQ then return nil,at,aQ end;at=ax(K,at)if not at then return av(K,aw,aJ)end;aO=h(K,at,at)if aO==":"then if aP==nil then return nil,at,"cannot use nil as table index (at "..aq(K,at)..")"end;at=ax(K,at+1)if not at then return av(K,aw,aJ)end;local aR;aR,at,aQ=aG(K,at,aK,aL,aM)if aQ then return nil,at,aQ end;t[aP]=aR;at=ax(K,at)if not at then return av(K,aw,aJ)end;aO=h(K,at,at)else v=v+1;t[v]=aP end;if aO==","then at=at+1 end end end;aG=function(K,at,aK,aL,aM)at=at or 1;at=ax(K,at)if not at then return nil,l(K)+1,"no valid JSON value (reached the end)"end;local aO=h(K,at,at)if aO=="{"then return aH('object',"}",K,at,aK,aL,aM)elseif aO=="["then return aH('array',"]",K,at,aK,aL,aM)elseif aO=="\""then return aB(K,at)else local aS,aT=k(K,"^%-?[%d%.]+[eE]?[%+%-]?%d*",at)if aS then local aU=X(h(K,aS,aT))if aU then return aU,aT+1 end end;aS,aT=k(K,"^%a%w*",at)if aS then local aV=h(K,aS,aT)if aV=="true"then return true,aT+1 elseif aV=="false"then return false,aT+1 elseif aV=="null"then return aK,aT+1 end end;return nil,at,"no valid JSON value at "..aq(K,at)end end;local function aW(...)if select("#",...)>0 then return...else return{__jsontype='object'},{__jsontype='array'}end end;function p.decode(K,at,aK,...)local aL,aM=aW(...)return aG(K,at,aK,aL,aM)end;function p.use_lpeg()local aX=require("lpeg")if aX.version()=="0.11"then error"due to a bug in LPeg 0.11, it cannot be used for JSON matching"end;local aY=aX.match;local aZ,a_,b0=aX.P,aX.S,aX.R;local function b1(K,at,ah,a1)if not a1.msg then a1.msg=ah.." at "..aq(K,at)a1.pos=at end;return false end;local function b2(ah)return aX.Cmt(aX.Cc(ah)*aX.Carg(2),b1)end;local b3=aZ"//"*(1-a_"\n\r")^0;local b4=aZ"/*"*(1-aZ"*/")^0*aZ"*/"local b5=(a_" \n\r\t"+aZ"\239\187\191"+b3+b4)^0;local b6=1-a_"\"\\\n\r"local b7=aZ"\\"*aX.C(a_"\"\\/bfnrt"+b2"unsupported escape sequence")/az;local b8=b0("09","af","AF")local function b9(ba,at,bb,bc)bb,bc=tonumber(bb,16),tonumber(bc,16)if 0xD800<=bb and bb<=0xDBff and 0xDC00<=bc and bc<=0xDFFF then return true,aA((bb-0xD800)*0x400+bc-0xDC00+0x10000)else return false end end;local function bd(be)return aA(tonumber(be,16))end;local bf=aZ"\\u"*aX.C(b8*b8*b8*b8)local bg=aX.Cmt(bf*bf,b9)+bf/bd;local bh=bg+b7+b6;local bi=aZ"\""*aX.Cs(bh^0)*(aZ"\""+b2"unterminated string")local bj=aZ"-"^-1*(aZ"0"+b0"19"*b0"09"^0)local bk=aZ"."*b0"09"^0;local bl=a_"eE"*a_"+-"^-1*b0"09"^1;local bm=bj*bk^-1*bl^-1/X;local bn=aZ"true"*aX.Cc(true)+aZ"false"*aX.Cc(false)+aZ"null"*aX.Carg(1)local bo=bm+bi+bn;local bp,bq;local function br(K,at,aK,a1)local bs,bt;local bu;local bv,bw={},0;repeat bs,bt,bu=aY(bp,K,at,aK,a1)if not bu then break end;at=bu;bw=bw+1;bv[bw]=bs until bt=='last'return at,setmetatable(bv,a1.arraymeta)end;local function bx(K,at,aK,a1)local bs,a4,bt;local bu;local bv={}repeat a4,bs,bt,bu=aY(bq,K,at,aK,a1)if not bu then break end;at=bu;bv[a4]=bs until bt=='last'return at,setmetatable(bv,a1.objectmeta)end;local by=aZ"["*aX.Cmt(aX.Carg(1)*aX.Carg(2),br)*b5*(aZ"]"+b2"']' expected")local bz=aZ"{"*aX.Cmt(aX.Carg(1)*aX.Carg(2),bx)*b5*(aZ"}"+b2"'}' expected")local bA=b5*(by+bz+bo)local bB=bA+b5*b2"value expected"bp=bA*b5*(aZ","*aX.Cc'cont'+aX.Cc'last')*aX.Cp()local bC=aX.Cg(b5*bi*b5*(aZ":"+b2"colon expected")*bB)bq=bC*b5*(aZ","*aX.Cc'cont'+aX.Cc'last')*aX.Cp()local bD=bB*aX.Cp()function p.decode(K,at,aK,...)local a1={}a1.objectmeta,a1.arraymeta=aW(...)local bs,bE=aY(bD,K,at,aK,a1)if a1.msg then return nil,a1.pos,a1.msg else return bs,bE end end;p.use_lpeg=function()return p end;p.using_lpeg=true;return p end;if a then pcall(p.use_lpeg)end;return p
end
local json = jsonfunction()

local config = {
	downloadRetryCount = {
		text = "Download Retries"
		value = 3,
		minValue = 1,
		maxValue = 10
	}
}

local selection = 1
local option_selection = 1
local localSize = 0
local parsed = {}
local config_backup = {}

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
		msg = "ZTD Leak when",
		color = WHITE
	},
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
	local jsonString = json.encode(config, { indent = true })
	System.createDirectory(APP_DIR)
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
	local loaded_config = json.decode(file_contents)
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

function update()
	local function tryDownload()
		System.deleteFile("/freeShop/encTitleKeys.bin")
		Network.downloadFile("http://enctitlekeys.wolvan.at/", "/freeShop/encTitleKeys.bin")
		local filesize = 0
		if System.doesFileExist("/freeShop/encTitleKeys.bin") then
			local encTitleKeys = io.open("/freeShop/encTitleKeys.bin", FREAD)
			filesize = tonumber(io.size(encTitleKeys))
			io.close(encTitleKeys)
		end
		if filesize == 0 then
			return false
		end
		return true
	end
	checkWifi()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	Screen.debugPrint(5, 5, "Downloading encTitleKeys.bin...", GREEN, TOP_SCREEN)
	System.createDirectory("/freeShop")
	
	local tries = 0
	local success = false
	while (tries < config.downloadRetryCount.value) and (not success) do
		tries = tries + 1
		success = tryDownload()
	end
	
	if not success then
		showError("encTitleKeys.bin failed to download,\nplease try again.\n \nIf this keeps happening, check\nyour internet connection.\n \nIf you believe this is a bug,\nopen an issue on my Github.\n \nPress A to return to the Main Menu")
	end
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
	local function tryDownload()
		local remoteData = Network.requestString("http://enctitlekeys.wolvan.at/meta.php")
		if remoteData ~= "" and remoteData ~= nil and type(remoteData) == "string" then
			parsed = json.decode(remoteData)
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
	Screen.debugPrint(5, line, "Loading config...", WHITE, TOP_SCREEN)
	if loadConfig() then
		config_backup = deepcopy(config)
		Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	else
		Screen.debugPrint(270, line, "[FAILED]", RED, TOP_SCREEN)
	end
	
	line = 35
	Screen.debugPrint(5, line, "Checking Wi-Fi...", WHITE, TOP_SCREEN)
	checkWifi()
	Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	
	line = 50
	Screen.debugPrint(5, line, "Checking encTitleKeys.bin...", WHITE, TOP_SCREEN)
	if System.doesFileExist("/freeShop/encTitleKeys.bin") then
		local encTitleKeys = io.open("/freeShop/encTitleKeys.bin", FREAD)
		localSize = io.size(encTitleKeys)
		io.close(encTitleKeys)
		Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	else
		Screen.debugPrint(270, line, "[File not found]", YELLOW, TOP_SCREEN)
	end
	
	line = 65
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
	
	line = 80
	Screen.debugPrint(5, line, "Checking for Updates...", WHITE, TOP_SCREEN)
	locVer = parseVersion(APP_VERSION)
	remVer = parseVersion(parsed.current_version)
	canUpdate = isUpdateAvailable(locVer, remVer)
	Screen.debugPrint(270, line, "[OK]", GREEN, TOP_SCREEN)
	
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
	Screen.debugPrint(5, 95, "MatMaf - For the first updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 110, "Rinnegatamante - For LPP3DS", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 125, "You - For using this tool at all", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 140, "AFgt - For testing the updater", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 155, "Some other people I forgot", WHITE, BOTTOM_SCREEN)
	Screen.debugPrint(5, 190, "v"..APP_VERSION, WHITE, BOTTOM_SCREEN)
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
