---------------------------------------------------------------------------------------------------
-- updated by icreator
local currentLocalization

--- autor:Ciuine
function GetGameLocalization()
	if currentLocalization then return currentLocalization end
         return common.GetLocalization()
		 --[[
		 local LocOption = options.GetOptionsByCustomType("interface_option_localization")
		 
         if LocOption then
		for i, v in pairs(LocOption) do
			for j, x in pairs(options.GetOptionInfo(v)) do
				if j == "values" then
					for k, y in pairs(x) do
						for l, z in pairs(y) do
							if l == "name" then
								--LogInfo(z)
								return userMods.FromWString(z)
							end
						end
					end
				end
			end
		end
	end
	]]--
end
--- autor:Ciuine


-- AO game Localization detection by SLA. Version 2011-02-05.
local dateAbbr = {
	rus = { map="\203\232\227\224", name = "Русский"},
	eng = { map="Holy Land", name = "English"},
	ger = { map="Heiliges Land", name = "German"},
	fra = { map="Terre Sacr\233e", name = "Francaise"},
	jpn = { map="\131\74\131\106\131\65", name = "Japan"},
	br = { map="", name = "Brazilian"},
	chn = { map="", name = "China"},
	esp = { map="", name = "Spain"},
	id = { map="", name = "Indonesia"},
	kr = { map="", name = "Korea"},
	tr = { map="", name = "Turkey"},
	tw = { map="", name = "Taiwan"},
	}
--[[
CHN is China, ID is Indonesia (the "Philippines client"), ESP is Spain, KR is Korea, JPN is Japan (no longer operational last I checked), TR is Turkey,
 and TW is Taiwan. Just lowercase them and you have your localization globals.
]]

function GetGameLocalizationAbbrevs()
	return dateAbbr
end
--[[

function GetGameLocalization()
	if currentLocalization then return currentLocalization end
	local B = cartographer.GetMapBlocks()
	for b in B do for l,t in pairs(GetGameLocalizationAbbrevs()) do
	if userMods.FromWString( cartographer.GetMapBlockInfo(B [b] ).name ) == t.map
	then return l end; end end; return "eng"
end
-- AO game Localization detection by SLA. Version 2011-02-05.
]]

local Ldata
--- icreator: set new Localization table
function SetGameLocalization( set )
currentLocalization = set or GetGameLocalization()
	Ldata = getLocales()[currentLocalization]
end

--- return localised text or origin text
local txts = {}
function listTexts()
	for k,_ in pairs(txts) do
		LogInfo("[ '"..k.."' ]=''," )
	end
end

function L(txt)
	local trans = Ldata and Ldata[txt] or txt
	if trans == txt then
		txts[ txt ] = 1
	end

	return trans
end
