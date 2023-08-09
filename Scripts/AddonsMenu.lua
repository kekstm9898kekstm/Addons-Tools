--- by icreator 2011.09.18
--- посылать сразу несколько событий параллельно нельзя - чать не обработается
--- поэтому в одном событии надо посылать максиму информауии - напримерп ризапуске аддона
--- сразу локализацию, скин, текстуры ему слать а не отдельно по событиям

local LogVal_ = false --true --- для отладки
local function Log(str, pars )
	if LogVal_ then
		if pars then exObj2( str, pars )
		else LogInfo( str )
		end
	end
end

local SendEvent = userMods.SendEvent

local excludeList = { parentObj = true, parentItem = true, parent = true } --- cancel recursion for indexes

local addons = {}
local SysStates
local onEvent, onReact = {}, {}
local dsc, mnu, mPars, n, addonsTemp, CMD, wBase
local RELOAD = "_rld"
local SINGLE_RELOAD = "_sgl_rld"
local userPREFIX = 'UserAddon/'
local tipFrmt = "<html alignx='left' aligny='middle' fontsize='14' shadow='1'><log_dark_white>"
	.."<tip_blue><r name='wsName'/></tip_blue> <r name='wsDescription'/>"
	.." <tip_blue><r name='memTxt'/></tip_blue> <tip_golden><r name='memVal'/></tip_golden>K."
	.." <r name='descr'/></log_dark_white>"
	.." <r name='addonsBlockedTxt'/> <tip_red><r name='addonsBlocked'/></tip_red>"
	.." Vers: <tip_golden><r name='vers'/></tip_golden>"
	.." Lib: <tip_green><r name='lib'/></tip_green>"
	.."</html>"
local valFormats = { 
	ON = "<html alignx='right' fontsize='14'><tip_green><r name='value'/></tip_green></html>",
	OFF = "<html alignx='right' fontsize='12'><r name='value'/></html>",
	--- чтобы не сдигало влево и было серым:
	---OFF = "<html><log_dark_white><body alignx='right' fontsize='14'><r name='value'/></body></log_dark_white></html>",
	}
--------------------------------------------------

--- есть ли встроеный менеджер аддонв
local newSysManager = stateMainForm:GetChildUnchecked("UserAddonManager", false)

local function reFormatSysTab( sAddon )
	sAddon.sysName = sAddon.name --- тут обычная строка
	sAddon.name = nil --- тут должно быть локализованное имя потом
	return sAddon
end

local function valOnOff( value )
	return value and "ON" or "OFF"
end
local function valOnOffAuto( val )
	--return val == 1 and "SELF" or val and "ON" or "OFF"
	return val
end


local function valGetState( item )
	local state = getStateAddon( item.name )
	item.parent:ItemFade( item, state and 1 or 0.5 )
	return state --- and "ON" or "OFF"
end

local function setItemValue( sysName, item, state )
	addons[sysName].unloaded = not state
	item.value = state
	--if mnu then
	item.parent:Update( { item } )
	--end
end

local currentTipName, FUNC_tipRun_
local function makeTip( addon )
	local mem, descr = addon.memUsage, addon.desc
	--exObj("addon", addon, nil, excludeList )
	if mem then
		local vers =  addon.vers or  addon.version
		local lib =  addon.lib or  addon.library

		local vals = { wsName = FromWS(addon.name), wsDescription = FromWS(addon.description),
			memTxt = L("Used memory:"), memVal = mem.."", descr = descr,
			vers = vers,
			lib = lib }
		local tipFrmt = "<html alignx='left' aligny='middle' fontsize='14' shadow='1'><log_dark_white>"
			.."<tip_blue><r name='wsName'/></tip_blue>. <r name='wsDescription'/>"
			.." <tip_blue><r name='memTxt'/></tip_blue> <tip_golden><r name='memVal'/></tip_golden>K."
			.." <r name='descr'/></log_dark_white>"
			.." <r name='addonsBlockedTxt'/> <tip_red><r name='addonsBlocked'/></tip_red>"
		if addon.addonsBlocked then
			vals.addonsBlockedTxt = L("Addons Blocked:")
			if type(addon.addonsBlocked) == "function" then
				vals.addonsBlocked = table.concat( addon.addonsBlocked(), ", " )
			else
				vals.addonsBlocked = table.concat( addon.addonsBlocked, ", " )
			end
			--LogInfo("vals.addonsBlocked:", vals.addonsBlocked)
		else
			vals.addonsBlockedTxt = ""
			vals.addonsBlocked = ""
		end
		tipFrmt = tipFrmt .. ( vers and L(" Vers:").." <tip_golden><r name='vers'/></tip_golden>" or "" )
		tipFrmt = tipFrmt .. ( lib and L(" Lib:").." <tip_green><r name='lib'/></tip_green>" or "" )

		tipFrmt = tipFrmt .."</html>"
		return { format = tipFrmt, values = vals, len = 4 }
	else
		return descr
	end
end
local function getTip( item, FUNC_tipRun, on )
	FUNC_tipRun_ = FUNC_tipRun
	local sysName = item.name
	local tipStr = makeTip( addons[sysName] )
	
	if not tipStr then return end
	if on then
		if sysName == ADDONname then
			addons[sysName].desc = L(" * ")
			addons[sysName].memUsage = gcinfo()
		else
			SendEvent( "ADDON_MEM_REQUEST", { target = sysName } )
			currentTipName = sysName
		end
	else
		currentTipName = nil
	end
	FUNC_tipRun(item.wtItemPan, tipStr, on, item.parent.wtMenu:GetPriority() )
end
local function repaintTip(sysName)
	if currentTipName and currentTipName == sysName then
		FUNC_tipRun_( nil, makeTip( addons[ sysName ]), true )
	end
end

local function infoRequest( sysName )
	SendEvent( 'ADDON_INFO_REQUEST', { target = sysName, sender = ADDONname, localization = GetGameLocalization() } )
end

--- set state: Unload/Load
local function SetState( sysName, state )
	if state then
		--- загрузим тут
		common.StateLoadManagedAddon( userPREFIX.. sysName )
		--- заново запроим инфо от аддона - мож его переделали
		addons[sysName].rmMenu = nil --- сбросим меню так ка там может быть исправленый аддон
		--infoRequest( sysName )
	elseif sysName == ADDONname then
		--LogToChat(L("I can't uload myself!"))
		return
	else
		--exObj("addons[ "..sysName.." ]",addons[ sysName ])
		if addons[ sysName ] and addons[ sysName ].desc and addons[ sysName ].unloadSelf then
			--- этот аддон поддерживает текущую библиотеку
			--- то для выгрузки пошлем ему команду
			--LogInfo( "ADDON_UNLOAD -->>", sysName )
			SendEvent(  "ADDON_UNLOAD", {  target = sysName } )
		else
			--- этот аддон не поддерживает текщую библиотеку
			--LogInfo("StateUnloadManagedAddon - ", userPREFIX..sysName)
			common.StateUnloadManagedAddon( userPREFIX..sysName )
		end
	end
	---setItemValue( sysName, item, state )
end

local function getSysAddons()
	local val = {}
	local s
	for _, v in pairs(common.GetStateManagedAddons()) do
		v = reFormatSysTab( v )
		if not string.find( v.sysName, userPREFIX ) then
			s = SysStates[v.sysName]
			if s == nil then
				--- авто режим - пользователь ничего не указывал
				val[v.sysName] = "SELF" ---v.isLoaded
			else
				val[v.sysName] = s
			end
		end
	end
	return val
end


local function valGetSysState( item )
	local sysName = item.name
	local state = getStateSysAddon( sysName )
	local sysState = SysStates[ sysName ]
	if sysState then
		--- если пользователь принудительно установил выгрузку/загрузку, то
		item.parent:ItemFade( item, state and 1 or 0.5 )
		return sysState
	else
		item.parent:ItemFade( item, state and 1 or 0.5 )
		return "SELF"
	end
end

local function valOnSetSysState( item )
	local sysName = item.name
	--LogToChat(sysName)
	local val = item.value
	---LogToChat(sysName..":"..val)
	SysStates[ sysName ] = val
	if val == "ON" then
		--- загрузим тут
		common.StateLoadManagedAddon( sysName )
		item.parent:ItemFade( item, 1 )
	elseif val == "OFF" then
		common.StateUnloadManagedAddon( sysName )
		item.parent:ItemFade( item, 0.5 )
	else
		SysStates[ sysName ] = nil
		item.parent:ItemFade( item, getStateSysAddon( sysName ) and 1 or 0.5 )
	end
	
end

--==============================================================
local makeRMenu, ToggleState

local function FUNC_valOnSet( item, pars )
	--- это клик по пункту меню
	SendEvent( "ATPANEL_BUTTON_LEFT_CLICK", { sender = ADDONname, target = item.name, reaction = pars } )

	local addon = addons[item.name]
	if addon.on_click_hide and mnu then mnu:Show( false, true ) end
end

local function FUNC_click( item, pars )
	FUNC_valOnSet( item, pars )
end

local function FUNC_r_click( item, pars )
	--exObj2( "pars", pars )
	if item.cmd then
	else
		if pars.kbFlags == 1 then
			--- Shift-Right-Click
			ToggleState( item )
		elseif pars.kbFlags == 0 then
			local addon = addons[item.name]
			if not addon.rmMenu then addon.rmMenu = makeRMenu( item, pars )
			end
			if not addon.rmMenu then
				--- на себя нарвались
				return
			end
			SendEvent( "ADDON_GET_PARAMS", { target = item.name } )

			addon.rmMenu.parentObj = item.parent --- тут зададим кто родитель у контестного меню
			addon.rmMenu.priority = item.parent.wtMenu:GetPriority() + 10
			--LogInfo("FUNC_r_click Show with parent:", item.parent.name )
			addon.rmMenu:Show( true )
			wtChain( addon.rmMenu.wtMenu, pars.widget, 10, -20)
		else
			--LogToChat(pars.kbFlags .. "")
		end
		SendEvent( "ATPANEL_BUTTON_RIGHT_CLICK", { sender = ADDONname, target = item.name, reaction = pars } )
	--SendEvent( "ATPANEL_BUTTON_LEFT_CLICK", {  sender = ADDONname, target = item.name, reaction = pars } )
	--SendEvent( 'SCRIPT_SHOW_SETTINGS', { target = item.name } )
	end
end

local function FUNC_dbl_click( item, pars )
	if item.cmd then
	else
		SendEvent( "ATPANEL_BUTTON_DOUBLE_CLICK", { sender = ADDONname, target = item.name, reaction = pars } )
	end
end


------------------------------------------------------------------------------------------
local menuFB, wtFBhidethPan1, wtFBhidethPan2, wtFBhideth, FBhidethSizeX, FBhidethSizeY
local FBhidethVal, FBhidethEFF, FBhidethStop = true, nil
local menuFBstruc = {}
local FBlist = {}
local FBhide_dxy, FBhide_PTdxy = 28, 60
local FBh_fadeTo, FBh_dx = 0.2, 68

--- если окно потаскали то поменять окна внутри
local function rePlaceFBhideth()
	Log("rePlaceFBhideth")

	local ppP1, ppP2 = wtFBhidethPan1:GetPlacementPlain(), wtFBhidethPan2:GetPlacementPlain()
	local wtPT = W("PhanTime", wtFBhidethPan1 )
	local pp, ppPT = wtFBhideth:GetPlacementPlain(), wtPT:GetPlacementPlain()
	if ppP1.posX + ppP1.sizeX/2 > DnD.Screen.fullVirtualSizeX/2 then
		pp.alignX = 2
	else
		pp.alignX = 2
	end
	if ppP1.posY + ppP1.sizeY/2 > DnD.Screen.fullVirtualSizeY/2 then
		pp.alignY = 0
		ppP2.alignY = 1
		ppP2.highPosY = FBhide_PTdxy
		ppPT.alignY = 1
		--ppP2.posY = 40
	else
		pp.alignY = 1
		ppP2.alignY = 0
		ppP2.posY = FBhide_PTdxy/2
		ppPT.alignY = 0
		--ppP2.highPosY = 40
	end
	wtSetPlace(wtPT, ppPT)
	wtSetPlace(wtFBhidethPan2, ppP2)
	wtSetPlace(wtFBhideth, pp)
	return ppP1, ppP2, pp
end
local function reSizeFBhideth()
	Log("reSizeFBhideth")
	local ppP1, ppP2 = wtFBhidethPan1:GetPlacementPlain(), wtFBhidethPan2:GetPlacementPlain()
	local pp = wtFBhideth:GetPlacementPlain()

	--if FBhidethSizeY > 200 then retww() end
	ppP1.sizeY 	= FBhidethSizeY + FBhide_PTdxy
	ppP2.sizeY 	= FBhidethSizeY
	pp.sizeY 	= FBhidethSizeY
	--LogInfo("reSizeFBhideth ->FBhidethSizeY:",FBhidethSizeY)
	wtFBhidethPan1:SetPlacementPlain(ppP1)
	wtFBhidethPan2:SetPlacementPlain(ppP2)
	wtFBhideth:SetPlacementPlain(pp)
	return ppP1, ppP2, pp
end

local function FBhidethRun0()

	Log("FBhidethRun0")

	--if FBhidethStop then return end

	local on = FBhidethVal
	local ppP1, ppP2, pp = rePlaceFBhideth()

	local ppTo, ppP2To = Clone ( pp ), Clone(ppP2)

	if not FBhidethEFF then FBhidethEFF = 1
	else FBhidethEFF = FBhidethEFF + 1
	end
	--exObj2("pp", pp)
	--- нормализуем положение что окно не ерзало у края
	if on then
		if false then
		elseif FBhidethEFF == 1 then
			menuFB:Show( true )
			--- сперва вылет вверх - низ
			ppP2To.sizeY = pp.sizeY
			wtFBhidethPan2:PlayResizeEffect( ppP2, ppP2To, 200, EA_MONOTONOUS_INCREASE )
		elseif FBhidethEFF == 2 then
			--- потом раздвигаем створки
			ppTo.sizeX = FBhidethSizeX
			wtFBhideth:PlayResizeEffect( pp, ppTo, 200, EA_MONOTONOUS_INCREASE )
		end
	else
		if false then
		elseif FBhidethEFF == 1 then
			--- сперва задвигаем створки
			ppTo.sizeX = FBh_dx
			wtFBhideth:PlayResizeEffect( pp, ppTo, 600, EA_MONOTONOUS_INCREASE )
 		elseif FBhidethEFF == 2 then
			--- потом прячем вверх - низ
			ppP2To.sizeY = 0
			wtFBhidethPan2:PlayResizeEffect( ppP2, ppP2To, 600, EA_MONOTONOUS_INCREASE )
		end
	end
	--LogInfo( "on:",on," FBhidethEFF:",FBhidethEFF)
end

onEvent["EVENT_EFFECT_FINISHED"] = function( pars )
	Log("EVENT_EFFECT_FINISHED:"..pars.wtOwner:GetName(), pars )
	local wt = pars.wtOwner
	if wt:GetName() == "FBhideth_pan" or wt:GetName() == "FBhideth2" then
		if pars.effectType == ET_RESIZE  then
			--- вернем обратно - чтоюы ДнД работал
			local pp = wt:GetPlacementPlain()
			if pp.alignX == 1 then
				pp.alignX = 0
				pp.posX = DnD.Screen.fullVirtualSizeX - pp.sizeX - pp.highPosX
				wt:SetPlacementPlain(pp)
			end
		end
		FBhidethRun0()
	end
end

local function FBhidethRun( on )
	if not FBhidethVal == on then
		FBhidethVal = on
		FBhidethEFF = nil --- старт последовательности
		FBhidethRun0()
	end
end

--[[
--- если начали часы таскать то закрыть
onEvent["EVENT_DND_PICK_ATTEMPT"] = function( pars )
	--FBhidethRun(false)
end
]]
--- если окно потаскали то переопределить 
onEvent["EVENT_DND_DROP_ATTEMPT"] = function( pars )
	Log("EVENT_DND_DROP_ATTEMPT", pars )
	rePlaceFBhideth()
end

local function menuFB_repaint()
	if FBhidethStop then return end --- не перерисовывать меню пока идет обработка загрузки

	Log("menuFB_repaint")

	if menuFB then
		menuFB:repaint() --- тут оно нарисовыввается закрытым столбиком
		menuFB:Update() --- поэтому ниже его закроме в любом случае
		local p = menuFB.wtMenu:GetPlacementPlain()
		FBhidethSizeY = p.sizeY --+ FBhide_dxy
		--LogInfo("menuFB_repaint :FBhidethSizeY=",FBhidethSizeY)

		reSizeFBhideth()
		--rePlaceFBhideth()
		
		--if menuFB.strucMenu[1] then
			--LogToChat(" next ")
		--	FBhidethEFF = nil
		--	FBhidethVal = false
		--	FBhidethRun( true )
		--else
			--LogToChat(" not next ")
			FBhidethEFF = nil
			FBhidethVal = true
			FBhidethRun( false )
		--end

	end
end

local function FBmenuShow()
	if menuFB.strucMenu[1] and not FBhidethStop then
		FBhidethRun( true )
	end
end

local function makeFButton( addon )
	--WCD(descr, name, parent, place, show )
	--exObj( "addon", addon, nil, excludeList )
	if not addon.sysName then
		return
	end

	Log("makeFButton:"..addon.sysName)

	if addon.fbutton == "OFF" then
		FBlist[ addon.sysName ] = nil
	elseif addon.fbutton == "ON" then
		FBlist[ addon.sysName ] = addon
	elseif addon.make_FButton then --- авторежим когда сам аадон говрит
		FBlist[ addon.sysName ] = addon
	end

	--- чтобы дубляжей не было
	local found
	for i, val in pairs(menuFBstruc) do
		if val.name == addon.sysName then
			found = i
			break
		end
	end
	if FBlist[ addon.sysName ] then
		local item = {name = addon.sysName, type = "_cmd", icon = addon.icon, value = addon.state }
		item.label = "<html fontname='AllodsWest' fontsize='14' alignx='left' shadow='2'><tip_golden>"..(addon.abbrev or addon.sysName).."</tip_golden></html>"
		if found then
			menuFBstruc[ found ] = item
		else
			table.insert(menuFBstruc, item )
		end
	else
		if found then
			menuFB:removeItem( found )
		end
	end
	table.sort( menuFBstruc, function( A, B ) return A.name < B.name end )
	menuFB_repaint()
end

local function FBhidethTexturs()
	local t = get_PS("FBhideth_texture") or "hideth1"
	wtFBhideth:SetBackgroundTexture(common.GetAddonRelatedTexture(t.."B")) --,"hideth1B"))
	W("mask2a", W("mask1a",wtFBhideth)):SetBackgroundTexture(common.GetAddonRelatedTexture(t)) ---"hideth1"))
	W("mask2b", W("mask1b",wtFBhideth)):SetBackgroundTexture(common.GetAddonRelatedTexture(t)) ---"hideth1"))
end

function FBmenuInit(wt, wtBtn)
	menuFB = menu{ strucMenu = menuFBstruc, priority = 100, fadeOff = 100, itemSizeX = 130, itemSizeY = 27,  }
	menuFB:init({
		priority = 10,
		notSkinned = true, --- не подпадать под общие скины
		valGet = valGetState,
		cols = 1,

		valOnSet = FUNC_valOnSet, --- при изменении значений будет вызвано (параметры)
		onClick = FUNC_click, --- при выборе пункта меню без значений (команды)
		mouse_right_click = FUNC_r_click,
		mouse_double_click = FUNC_dbl_click,

		texture = "Empty_Tiled",
		item_texture = get_PS("FB_item_texture"),
		item_color = get_PS("FB_item_color"),
		fadeOff = 500,
		place = { posX = 0, posY = 0, alignY = 2, alignX = 2 },
		})
	local p = menuFB.wtMenu:GetPlacementPlain()
	FBhidethSizeX = p.sizeX + FBhide_dxy
	FBhidethSizeY = p.sizeY
		--- создадим общюю панель
	wtFBhidethPan1 = WCD( dsc.Panel, "FBhideth1", nil, { sizeX = FBhidethSizeX }, true )
	--- в нее запихнем часы с невидимой кнопкой для ДнД
	wtFBhidethPan1:AddChild( wt )
	wtSetPlace( wt, { posX=0, posY = 0, alignY=2, alignX = 2} )
	DnD:Init( wtBtn, wtFBhidethPan1, true, true , { 5, 0, 30, 0} )

	--- теперь создадим панель для створок - которая будет вылеттать вниз вверх
	wtFBhidethPan2 = WCD( dsc.Panel, "FBhideth2", wtFBhidethPan1,
		{ sizeX = FBhidethSizeX, posX=0, highPosX=0, posY=0, highPosY=0, alignX=0, alignY=0 }, true )

	wtFBhideth = WCD( dsc.Menu200, "FBhideth_pan", wtFBhidethPan2,
		{ sizeX = FBhidethSizeX, posX=0, highPosX=0, posY=0, highPosY=0, alignX=0, alignY=0 }, true )
	wtFBhideth:AddChild(menuFB.wtMenu)
	menuFB.wtMenu:Show( true )
	
	local w, n
	w = WCD( dsc.Panel, "mask1a", wtFBhideth, { alignX=0, sizeX = 33, alignY =3 }, true )
	w:SetPriority( 500 )
	n = WCD( dsc.Border200, "mask2a", w, { alignX=0, sizeX = 400, alignY =3 }, true )
	n:SetPriority( 500 )
	local w, n = WCD( dsc.Panel, "mask1b", wtFBhideth, { alignX=1, sizeX = 33, alignY =3 }, true )
	w:SetPriority( 500 )
	n = WCD( dsc.Border200, "mask2b", w, { alignX=1, sizeX = 400, alignY =3 }, true )

	reSizeFBhideth()
	rePlaceFBhideth()
	FBhidethRun( false )
	FBhidethTexturs()

end

--- просто загрузка/выгрузка для автоматичческого режима - без принуждения от пользователя
local function ToggleSysState( item )
	local sysName = item.name
	local state = not getStateSysAddon( sysName )
	if state then
		--- загрузим тут
		common.StateLoadManagedAddon( sysName )
	else
		common.StateUnloadManagedAddon( sysName )
	end
	item.parent:ItemFade( item, state and 1 or 0.5 )
end

--- toggle state
ToggleState = function( item )
	local sysName = item.name
	if sysName == ADDONname then return end
	local state = not getStateAddon( sysName )
	SetState( sysName, state )
	--- тут надо явно значение взять так как событи на загрузку не приходит (
	setItemValue( sysName, item, state )
	makeFButton( addons[ sysName ] )

end

--------------------------- R_MENU ----------------------------------------
local function ADDONtoConfigGLB(item)
	local sysName = item.parent.name
	local cfg = userMods.GetAvatarConfigSection( sysName ) or {}
	userMods.SetGlobalConfigSection( sysName, cfg )
	LogToChat(L("Settings of addon '")..sysName..L("' saved to GLOBAL section"))
end
local function ADDONfromConfigGLB(item)
	local sysName = item.parent.name
	local cfg = userMods.GetGlobalConfigSection( sysName ) or {}
	userMods.SetAvatarConfigSection( sysName, cfg )
	LogToChat(L("Settings of addon '")..sysName..L("' loaded from GLOBAL section"))
	CMD = SINGLE_RELOAD
	common.StateUnloadManagedAddon( userPREFIX..sysName )
end
local function ADDONclearConfig(item)
	local sysName = item.parent.name
	userMods.SetAvatarConfigSection( sysName, {} ) -- сбросим для этого перса
	userMods.SetGlobalConfigSection( sysName, {} ) -- сбросим глобальную тоже
	LogToChat(L("Settings of addon '")..sysName..L("' is cleared"))
	CMD = SINGLE_RELOAD
	common.StateUnloadManagedAddon( userPREFIX..sysName )
end


local function valGetFButton( item ) return addons[item.parent.name].fbutton end
local function valOnSetFButton( item )
	local addon = addons[item.parent.name]
	addon.fbutton = item.value
	makeFButton( addon )
end

local function addonSetPar( item )
	SendEvent( "ADDON_SET_PARAM", { target = item.parent.name, name = item.name, value = item.value } )
end

local function valOnLockAddonDnD( item )
	local val = item.value
	addons[item.parent.name].PS[item.name] = val
	--SendEvent( "SCRIPT_TOGGLE_DND", { target = item.parent.name, state = val == "OFF" } )
	SendEvent( "ADDON_LOCK_DND", { target = item.parent.name, state = val == "ON" } )
end
local function SendShowButton( target, val )
	--- сюда НИЛ приходит вместо SELF
	if val == "ON" or val == "OFF" then
		--SendEvent( "SCRIPT_TOGGLE_VISIBILITY", { target = target, state = val == "ON" } )
		SendEvent( "ADDON_SHOW_BUTTON", { target = target, state = val == "ON" } )
	end
end
local function valOnSetAddonButton( item )
	local val = item.value
	addons[item.parent.name].PS[item.name] = val
	SendShowButton( item.parent.name, val )
end
local function valGetAddonPS( item ) return addons[item.parent.name].PS[item.name] end
local function onClickRMenuAddon( item ) SendEvent( "ATPANEL_COMMAND", { target = item.parent.name, command = item.name, } ) end
makeRMenu = function( item, pars )
	local sysName = item.name
	if sysName == ADDONname then return end
	local strucMenu = {
		--- список пунктов который не меняется и не сортируется
		{ name = "SaveG", label = L("Save Settings to GLOBAL"), onClick = ADDONtoConfigGLB },
		{ name = "LoadG", label = L("Load Settings from GLOBAL"), onClick = ADDONfromConfigGLB },
		{ name = "ClearG", label = L("Clear Settings"), onClick = ADDONclearConfig },
		{ name = "lockDnD", label = L("Lock Dnd"), type = "_txt", tip="Lock Addon DnD mode", valGet = valGetAddonPS, valOnSet = valOnLockAddonDnD,
			listVals = { "ON", "OFF" }, valFormats = valFormats, defaultVal = "OFF",
			},
		{ name = "showButton", label = L("Show Button"), type = "_txt", tip="Show single Addon Button", valGet = valGetAddonPS, valOnSet = valOnSetAddonButton,
			listVals = { "SELF", "ON", "OFF" }, valFormats = valFormats, defaultVal = "SELF",
			},
		{ name = "Button", label = L("Fast Button"), type = "_txt", tip="Show Fast Button", valGet = valGetFButton, valOnSet = valOnSetFButton,
			listVals = { "SELF", "ON", "OFF" }, valFormats = valFormats, defaultVal = "SELF",
			icon = common.GetAddonRelatedTexture("FastButton"),
			},
	}

	local addon = addons[sysName]
	if not addon then
		--LogInfo(sysName.." addon - not found" )
		--LogToChat(sysName.." addon - not found" )
		return
	end
		--- настройки аддонов тут можно задавать
	local sets = addon.settings
	if sets then
		table.insert(strucMenu, { token = "1", label = "" } )
		table.insert(strucMenu, { token = "1", label = L("SETTINGS") } )
		for i, menuItem in pairs(sets) do
			local item = Clone( menuItem )
			item.valOnSet = addonSetPar
			table.insert(strucMenu, item )
		end
	end
	local cmds = addon.commands
	if cmds then
		table.insert(strucMenu, { token = "1", label = "" } )
		table.insert(strucMenu, { token = "1", label = L("COMMANDS") } )
		for i, menuItem in pairs(cmds) do
			table.insert(strucMenu, { name = menuItem.name, label = menuItem.label, onClick = onClickRMenuAddon } )
		end
	end
	local m = menu{ name = sysName, --- важно имено имя аддона - чтобы его потом по событию послать
		strucMenu = strucMenu,
		parentObj = nil, --- это менб открываться будет и из главного и из FB
		}
	m:init({
		--RowsColsRate = 10,
		--valOnSet = FUNC_valOnSet, --- при изменении значений будет вызвано (параметры)
		--onClick = FUNC_click, --- при выборе пункта меню без значений (команды)
		--mouse_right_click = FUNC_r_click,
		--mouse_double_click = FUNC_dbl_click,
		valShapes = L,
		mouse_overRun = true,
		fadeOff = 500, fadeVal = 0.7,
		itemSizeX = 300,
		texture = get_PS("MY_texture"),
		color = get_PS("MY_color"),
		item_texture = get_PS("MY_item_texture"),
		item_color = get_PS("MY_item_color"),
		--bottomTip = { label = L("Help"), text = L("Click on menu item for show MainPanel or Settings of addon. Shift-Right-Mouse - for load/unload it") },
	})
	return m
end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local function reloadAllAddons()

	CMD = RELOAD
	
	LogToChat(L("Realoadding all addons, please wait..."))
	--- нельзя делать как Клон там рекурсия по пунтам меню addonsTemp = Clone( addons ) - и функция зацикливается
	addonsTemp = {}
	for sysName,_ in pairs(addons) do
		if sysName ~= ADDONname and getStateAddon( sysName ) then addonsTemp[sysName] = 1 end
	end
	for sysName,_ in pairs(addons) do
		if sysName ~= ADDONname then common.StateUnloadManagedAddon( userPREFIX..sysName ) end
	end
	--- далее по событию что аддоны все выгружены - пойдет их загрузка
	--- см. EVENT_ADDON_LOAD_STATE_CHANGED
end


-------------------------------- MENU
local function newAddon( sysName )
	return { sysName = sysName, PS = {} }
end
local strucMenu = {}
local function AddButton(sysName, repaint)
	Log("AddButton:"..sysName)

	local item
	if not addons[sysName] then
		addons[sysName] = newAddon( sysName )
	end
	local addonInfo = addons[sysName]

	infoRequest( sysName )

	if not repaint or not addonInfo.item then
		item = {name = sysName, label = sysName, type = "_txt", icon = addonInfo.icon, tip=getTip, valGet = valGetState, valLabels = valOnOff, valFormats = valFormats }
		table.insert( strucMenu, item )
		addonInfo.item = item
	else
		item = addonInfo.item
	end

	local state = getStateAddon( sysName )
	if newSysManager then
		--- если есть встроеный менеджер то игнорим настройки нашего АддонсМену
		addonInfo.unloaded = nil
	else
		if state == false and not addonInfo.unloaded then
			--- if addon already unloaded but we not known it - remember it
			addonInfo.unloaded = true
		end
	end

	--setItemValue( sysName, item, not addonInfo.unloaded )
	if ADDONname == sysName then
		addonInfo.unloaded = nil
		addonInfo.item.valGet = nil
		addonInfo.item.valLabels = nil
		addonInfo.item.value = "MYSELF"
		addonInfo.item.label = ADDONname.." "..AT_Vers().version
	else 
		if state ~= not addonInfo.unloaded then
			--- если наше загруженное значение не совпадает с текущим - изменим аддон
			SetState( sysName, not addonInfo.unloaded )
		end

		--makeFButton( addonInfo ) --- in SetState
	end
end

---
local function AddonsMenuAddItem( addon, peraint )

	local sysName = addon.sysName
	local _, userAddon = string.find( sysName, userPREFIX )
	userAddon = userAddon and string.sub( sysName, userAddon + 1 )
	if userAddon then
		AddButton( userAddon, peraint )
	else
		--- это системный аддон - его в соотвествии с настройкамип пользователя
		local state = SysStates[ sysName ]
		if state == "ON" then
			--- загрузим тут
			common.StateLoadManagedAddon( sysName )
		elseif state == "OFF" then
			common.StateUnloadManagedAddon( sysName )
		end
	end
end

local function itemsRestate( peraint )
	--exObj("fromConfig", addons, nil, { item = 1} )
	for _, v in pairs(common.GetStateManagedAddons()) do
		v = reFormatSysTab( v )
		AddonsMenuAddItem( v, peraint ) end
	--exObj("fromConfig1", addons, nil, { item = 1} )
	if mnu then mnu:Update() end
end

local function reMakeMenu()
	---addons = {}
	strucMenu = {}
	if mnu then
		mnu:Show( false )
		---mnu:destroy()
	end
	mnu = nil
	itemsRestate( false )
end

local function setTestTexture( item )
	--- сначала сделаем общее действие с параметром - там он сохранится
	item.parent.valOnSet( item )
	item.icon = common.GetAddonRelatedTexture(item.value),
	item.parent:repaint()
end


local function FB_repaint( item )
	--- сначала сделаем общее действие с параметром - там он сохранится
	item.parent.valOnSet( item )
	--- а теперь сделаем что нам надо с панелью быстрых клавиш
	if menuFB then
		local key = string.sub( item.name, 4)
		menuFB[key] = get_PS( item.name )
		
		menuFB_repaint()
	end
end

local function setSkin()
	skin.texture = get_PS("MY_texture") and common.GetAddonRelatedTexture (get_PS("MY_texture"))
	skin.color = get_PS("MY_color") or {a=1,b=1,g=1,r=1}
	skin.item_texture = get_PS("MY_item_texture") and common.GetAddonRelatedTexture(get_PS("MY_item_texture"))
	skin.item_color = get_PS("MY_item_color") or {a=1,b=1,g=1,r=1}
end
function sendSKIN()
	setSkin()
	SendEvent("ADDON_AT_MENUS_SKIN_CHANGED", skin )
end

local function MY_repaint( item )
	--- сначала сделаем общее действие с параметром - там он сохранится
	item.parent.valOnSet( item )
	--exObj2("get_PS", get_PS() )
	sendSKIN()
	item.parent:repaint()
	item.parent.parentObj:repaint()
	--- а теперь сделаем что нам надо с панелью быстрых клавиш
--[[
	if mnu then
		local key = string.sub( item.name, 4)
		--LogToChat(key.. ":".. get_PS( item.name ))
		mnu[key] = get_PS( item.name )
		mnu:repaint()
	end
]]
	--repaint_all_menus()
	--repaint_all_GUI()

end

--local function setTextureItems( sysName ) return common.GetAddonRelatedTexture( sysName ) end
local function getFrames( size )
	local tab = {}
	for i, t in pairs(get_Textures()) do
		if t.sizeX and t.sizeY and t.sizeX == size and t.sizeY == size then
			tab[t.name] = t.name
		end
	end
	return tab
end
local function getButtons()
	local tab = {}
	for i, t in pairs(get_Textures()) do
		if t.sizeX and t.sizeY and t.sizeX == 128 and t.sizeY == 30 then
			tab[t.name] = t.name
		end
	end
	return tab
end
local function getIcons()
	local tab = {}
	for i, t in pairs(get_Textures()) do
		tab[i] = { name = t.name, label = t.name .. (t.sizeX and t.sizeY and ( " "..t.sizeX.."x"..t.sizeY ) or ""),
			value = t.name, --common.GetAddonRelatedTexture(t.name),
			type = "_icn" }
	end
	--exObj2("getIcons", tab)
	return tab
end

local wtCI = stateMainForm:GetChildUnchecked("ChatInput", false)
wtCI = wtCI and wtCI:GetChildUnchecked("ChatInput", false)
wtCI = wtCI and wtCI:GetChildUnchecked("Field", false)
wtCI = wtCI and wtCI:GetChildUnchecked("Input", false)

local messToChatVal
local messToChat

--[[ что это вешает ]]
messToChat = function(pars)
	--- это если ввод чата еще НЕ открыт энтером - то прямо в функцию катаем текст
	wtCI:SetText(ToWS(L("Press {Enter}")))--messToChatVal))
	mission.SetChatInputText(ToWS(messToChatVal), string.len(messToChatVal))
	common.UnRegisterEventHandler(messToChat, "EVENT_SLASH_COMMAND_PREFIX_CHANGED")
end


local function logLAddons()
	local t = {}
	for sysName, item in pairs(addons) do
		if getStateAddon(sysName) then
			table.insert( t, sysName)
		end
	end
	table.sort( t )
	messToChatVal = L("I use addons: ")..table.concat( t, ", ").."."
	if wtCI:GetParent():GetParent():IsVisible() then
		--- это если ввод чата уже открыт энтером - то прямо в EditLine
		wtCI:SetText(ToWS(L("Press {Enter}")))--messToChatVal))
		mission.SetChatInputText(ToWS(messToChatVal), string.len(messToChatVal))
	else
		common.RegisterEventHandler(messToChat, "EVENT_SLASH_COMMAND_PREFIX_CHANGED")
	end

end

local createMenu
local function reLocalize(item, pars)
	--exObj2("eeee", item.parent, nil, excludeList )
	item.parent.toClose = true
	item.parent.mouse_overRun = false
	--item.parent.wtMenu:FinishFadeEffect()
	--LogInfo(item.parent.wtMenu:GetName())
	--item.parent.wtMenu:Show( false )
	--item.parent.parentObj.wtMenu:FinishFadeEffect()
	--item.parent.parentObj.wtMenu:Show( false )
	set_PS(item.name, item.value)
	SetGameLocalization(item.value)
	mnu:Show( false, true )
	--mnu = nil
	--mnu = createMenu()
	reloadAllAddons()
end
createMenu = function()

	table.sort( strucMenu, function( A, B ) return A.label < B.label end )
	--- добавим к постоянному меню найденные аддоны
	local LocAbbrevs = {}
	for n,_ in pairs(GetGameLocalizationAbbrevs()) do
		LocAbbrevs[ n ] = ""
	end
	local LocAbbrevNames = {}
	for n, val in pairs(GetGameLocalizationAbbrevs()) do
		LocAbbrevNames[n] = val.name
	end

	local strucMenuConst = {
		--- список пунктов который не меняется и не сортируется
		{ token = "1", label = L("COMMANDS") },
		{ name = "Save", label = L("Save Settings"), onClick = toConfig },
		{ name = "Load", label = L("Load Settings"), onClick = function() fromConfig() itemsRestate( true ) end },
		{ token = "1", label = "" },
		{ name = "SaveGlb", label = L("Save Settings to GLOBAL"), onClick = toConfigGlobal },
		{ name = "LoadGlb", label = L("Load Settings from GLOBAL"), onClick = function() fromConfigGlobal() itemsRestate( true ) end },
		{ name = "ReLoad", label = L("ReLoad User's Addons"), onClick = reloadAllAddons },
		{ name = "Localize", label = L("Set Localization"), type="_txt",
			valGet = GetGameLocalization,
			icon = common.GetAddonRelatedTexture("Will"),
			menuItems = LocAbbrevs, valShapes = LocAbbrevNames,
			list = { numberKeys = false, edited = false },
			valOnSet = reLocalize,
			tip = L("Select other localization. All addons will be reloaded.")
			},
		{ name = "Pars", label = L("Parameters"), 
			--button_texture = common.GetAddonRelatedTexture("ButtonRegular1-Normal"),
			recurseCount = 1, --- 0 у главного меню
			--button_color = {a=1,r=0.6,g=1,b=1},
			--item_desc = dsc.Panel,
			item_texture = "ButtonEmpty",
			button_desc = dsc.Button,
			icon = common.GetAddonRelatedTexture("TokenBattleStation"), -- TokenBattleStation TitanToken
			onClick = function(item, pars) wtChain(mPars.wtMenu, pars.widget, 10, 10 )
				mPars.texture = get_PS("MY_texture")
				mPars.color = get_PS("MY_color")
				mPars.item_texture = get_PS("MY_item_texture")
				mPars.item_color = get_PS("MY_item_color")
				mPars:repaint() mPars:Show(true)
				--FBhidethRun( true )
				end
		},

		{ name = "SysAddons", label = L("Show System Addons"), type ="_lst", valGet = getSysAddons,
				list = { type = "_txt",
					listVals = { "SELF", "ON", "OFF" },
					hide_set_button = true,
					valGet = valGetSysState,
					valOnSet = valOnSetSysState,
					--valLabels = valOnOffAuto,
					valFormats = valFormats,
					mouse_right_click = ToggleSysState,
					place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
					bottomTip = { label = L("Help"), text = L("Click - toggle ON/OFF/AUTO the system-Addon. AUTO mode - not do anything with system-Addon. Right-Mouse - for temporarily load/unload addon.") },
					DnD = { false, false, nil },
					},
			},
		{ token = "1", label = "" },
		{ token = "1", label = L("ADDONS") },
	}
	for k, v in pairs(strucMenu) do
		table.insert( strucMenuConst, v )
	end
	local m = menu{ name = L("Addons List"), strucMenu = strucMenuConst }
	m:init({
		--button_texture = common.GetAddonRelatedTexture("FrameRed"), --DeskInspectNormal-104"),
		--texture = common.GetAddonRelatedTexture("RacePlateSelectedFR-104"), --DeskInspectNormal-104"),
		
		desc = dsc.Menu200, --- для текстур 200х200 красивых
		--RowsColsRate = 10,
		valOnSet = FUNC_valOnSet, --- при изменении значений будет вызвано (параметры)
		onClick = FUNC_click, --- при выборе пункта меню без значений (команды)
		mouse_right_click = FUNC_r_click,
		mouse_double_click = FUNC_dbl_click,
		valShapes = L,
		mouse_overRun = true,
		fadeOff = 700, fadeVal = 0.7,
		itemSizeX = 300, --itemSizeY = 30,
		texture = get_PS("MY_texture"),
		color = get_PS("MY_color"),
		item_texture = get_PS("MY_item_texture"),
		item_color = get_PS("MY_item_color"),
		bottomTip = { label = L("Help"), text = L("Click on menu item for show MainPanel or Settings of addon. Shift-Right-Mouse - for load/unload it") },
	})
	DnD:Init( m.wtMenu, m.wtMenu, true, false )
	m:Update()

	local struc = {
		{ name ="TimeZoneOffset", label = L("Time Zone Offset"), type = "_edl", chars = 2,
			valOnSet = function(item) set_PS(item.name, tonumber(item.value) and item.value or 0) SetCurrentTime( mission.GetWorldTimeHMS() ) end, --- on change value will call it function
			tip = L('If your local time is 7 hours LATER than server time, set "seven". If your local time is 2 hours EARLIER than server time, set "minus two".') },--- =0

		{ name = "DnDWorldLock", label = L("Global Lock DnD"), type = "_txt", tip="Lock DnD in World",
			listVals = { "ON", "OFF" }, valFormats = valFormats, defaultVal = "OFF",
			valOnSet =  function(item) set_PS(item.name, item.value) DnDWorldLock() end,
			},
		{ name = "logLAddons", label = L("Log used Addons in chat"), type = "_cmd", tip="Press {Enter} for send data",
			onClick = logLAddons},
		{ token = "", label = "" },
		{ token = "", label = L("MySelf SKIN") },
		{ name = "MY_item_texture", label = L("Self buttons Texture"), type="_icn",
			icon = common.GetAddonRelatedTexture("ButtonRegular1-Normal"),
			menuItems = getButtons(), -- as complex data
			list = { itemSizeY = 30, numberKeys = false, edited = false,
				place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
				--item_texture = "=name", --- same as neme  setTextureItems,
				},
			valOnSet = MY_repaint,
			tip = L("")
			},
		{ name ="MY_item_color", label = L("Self buttons Color"), type = "_clr",
			valOnSet = MY_repaint,
			tip = L("") },
		{ name = "MY_texture", label = L("Self Frame"), type="_icn",
			icon = common.GetAddonRelatedTexture("Frame104"),
			menuItems = getFrames(200), -- as simple list
			list = { itemSizeY = 40, numberKeys = false, edited = false,
				place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
				--icon = "=name", --- same as neme  setTextureItems,
				},
			valOnSet = MY_repaint,
			tip = L("")
			},
		{ name ="MY_color", label = L("Self Color"), type = "_clr",
			valOnSet = MY_repaint,
			tip = L("") },
		{ name = "test_texture", label = L("List of textrures"), type="_icn",
			--icon = common.GetAddonRelatedTexture("Will"),
			menuItems = getIcons(), -- as complex data
			list = { itemSizeY = 30, numberKeys = false, edited = false,
				place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
--				icon = "=name", --- same as neme  setTextureItems,
				DnD = {},
				},
			valOnSet = MY_repaint, -- test_texture
			tip = L("Select texture from list for test icon")
			},
		{ token = "", label = "" },
		{ token = "", label = L("FastButtons SKIN") },
		{ name = "FB_item_texture", label = L("FB buttons Texture"), type="_icn",
			icon = common.GetAddonRelatedTexture("Will"),
			menuItems = getButtons(), -- as complex data
			list = { itemSizeY = 30, numberKeys = false, edited = false,
				place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
				--item_texture = "=name", --- same as neme  setTextureItems,
				},
			valOnSet = FB_repaint,
			tip = L("Select texture from list of my owned textures")
			},
		{ name ="FB_item_color", label = L("FB buttons Color"), type = "_clr",
			valOnSet = FB_repaint,
			tip = L("Color") },
		--[[{ name = "FB_texture", label = L("FB Panel Frame"), type="_icn",
			icon = common.GetAddonRelatedTexture("Frame104"),
			menuItems = getFrames(104), -- as simple list
			list = { itemSizeY = 40, numberKeys = false, edited = false,
				place = { posX = 0, posY = 0, alignX = 2, alignY = 2 },
--				icon = "=name", --- same as neme  setTextureItems,
				},

			valOnSet = FB_repaint,
			tip = L("Select Frame for Fast Buttons Panel")
			},
		{ name ="FB_color", label = L("FB Color"), type = "_clr",
			valOnSet = FB_repaint,
			tip = L("Color") },
		]]
	}
	mPars = menu{ strucMenu = struc, priority = m.wtMenu:GetPriority()+100, fadeOff = 500,  }
	local p =  m.wtMenu:GetPlacementPlain()
	mPars:init({  parentObj = m, name = L("Parameters"), 
		mouse_overRun = true,
		recurseCount = 1,
		valGet = function( item ) return get_PS(item.name) end,
		valOnSet = function( item, pars ) set_PS(item.name, item.value)
				--exObj2(item.name, get_PS( item.name ) )
				end,
		texture = get_PS("MY_texture"),
		color = get_PS("MY_color"),
		item_texture = get_PS("MY_item_texture"),
		item_color = get_PS("MY_item_color"),
		place = p,
		valShapes = L,
		})
	return m
end

function AddonsMenuShow( w, on )
	if not mnu then
		mnu = createMenu()
	end
	if on then
		if w then
			wBase = w
		end
		if not DnD:isSetted( mnu.wtMenu ) then
			--- если окно еще не передвигали и не запомнили с новыми координатами, 
			--- то задаим свои
			wtChain( mnu.wtMenu, wBase, 10, 10 )
			DnD:Init( mnu.wtMenu, mnu.wtMenu, true, false )
		end
	end
	mnu:Show( on )
end

local mnuOld
local function LoadAllAddons()
	local p = mnu.wtMenu:GetPlacementPlain()
	mnu:Show( false, true )
	mnuOld = mnu

	--for sysName, pars in pairs({} or addons) do -- pairs({} or addons) - WTF???
	for sysName, pars in pairs(addons or {}) do
		SetState( sysName, not pars.unloaded )
	end
	---  авообщето там на автомате если аватар создан то само событие пошлеи
	---StartToDo( function() SendEvent( "ADDON_AVATAR_CREATED", {} ) end, {}, 1 )
	reMakeMenu()
	mnu = createMenu()
	mnu.wtMenu:SetPlacementPlain(p)
	mnu:Show( true )
	mnuOld:Show( false, true )
	mnuOld = nil
end

------------------------------------------------------
---- EVENTS
------------------------------------------------------
local function info_response( pars )
	local addonElem = addons[pars.sender]
	if not addonElem then
		LogToChat("addnon "..pars.sender.." not found (ADDON_INFO_RESPONSE)")
		LogInfo("addnon "..pars.sender.." not found (ADDON_INFO_RESPONSE)")
		return
	end

	--exObj2("INFO_RESPONSE", pars )

	for k, v in pairs(pars) do
		--- чтобы внешняя информация не вмешивалась к нам - проверим
		if k ~= "sender" or k ~= "unloaded" then addonElem[k] = v end
	end
	addonElem.item.icon = addonElem.icon
	--exObj2("ADDON", addonElem, nil, excludeList )

	--exObj2(addonElem.sysName, addonElem, nil, { rmMenu=1, item=1 } ) -- explore with excludes
	--- может получили версию так переримуем наклейку
	addonElem.item.label = addonElem.item.name .. ( addonElem.vers and " ".. addonElem.vers or "")
	if addonElem.item.parent then addonElem.item.parent:Update( { addonElem.item} ) end

	-- аддон запустился надо ему сказать его настройки
	local targ = addonElem.sysName
	local val = addonElem.PS.lockDnD == "ON"
	if val then
		--- толькое сли запрет то пошлем
		SendEvent( 'ADDON_LOCK_DND', { target = targ, state = val } )
		SendEvent( 'SCRIPT_TOGGLE_DND', { target = targ, state = not val } )
	end

	SendShowButton( addonElem.sysName, addonElem.PS.showButton )

	repaintTip(addonElem)
	--LogToChat("repaintTip")
	makeFButton( addonElem )
end

function makeTextures()
	local textures = {}
	for i, tab in pairs(get_Textures()) do
		textures[ tab.name ] = tab
		textures[ tab.name ].texture = common.GetAddonRelatedTexture(tab.name)
	end
	return textures
end
--- поделиться текстурами
onEvent["ADDON_TEXTURES_REQUEST"] = function ( pars )
	Log("ADDON_TEXTURES_REQUEST", pars )
	if pars.target and pars.target ~= ADDONname then return end

	--LogToChat("ADDON_TEXTURES_REQUEST <-"..(pars.sender or "?"))
	SendEvent( 'ADDON_TEXTURES_RESPONSE',
		{ sender = ADDONname, target = pars.sender, textures = makeTextures() } )
end

onEvent["ADDON_INFO_RESPONSE"] = function( pars )
	Log("ADDON_INFO_RESPONSE", pars )
	info_response( pars )
end

-- получены настройки от аддона
onEvent["ADDON_GET_PARAMS_RESPONSE"] = function( pars )
	Log("ADDON_GET_PARAMS_RESPONSE", pars )
	local addonElem = addons[pars.sender]
	if not addonElem then
		--LogToChat("addnon "..pars.sender.." not found (ADDON_GET_PARAMS_RESPONSE)")
		--LogInfo("addnon "..pars.sender.." not found (ADDON_GET_PARAMS_RESPONSE)")
		return
	end
	for parName, parValue in pairs(pars.params) do
		for i, item in pairs(addonElem.rmMenu.strucMenu) do
			if item.name == parName then
				item.value = parValue
				break
			end
		end
	end
	addonElem.rmMenu:Update()
end

onEvent["ADDON_START_REQUEST"] = function( pars )
	Log("ADDON_START_REQUEST", pars )

	local unloaded

	if newSysManager then
		--- в новой версии где аддоны загружаются системным менеджером не нужно запускать их - они сами запускаются
		SendEvent("ADDON_START_CONFIRMED", { target = pars.sender, unloaded = nil,
			skin = skin, localization = GetGameLocalization(), textures = makeTextures() } )

	else
		local addonElem = pars.sender and addons[pars.sender]
		if not addonElem then
			--LogToChat("addnon "..pars.sender.." not found (ADDON_GET_PARAMS_RESPONSE)")
			--LogInfo("addnon "..pars.sender.." not found (ADDON_GET_PARAMS_RESPONSE)")
			return
		end

		unloaded = addonElem.unloaded
		SendEvent("ADDON_START_CONFIRMED", { target = pars.sender, unloaded = unloaded,	
				skin = skin, localization = GetGameLocalization(), textures = makeTextures() } )
	end

end

onEvent["EVENT_ADDON_LOAD_STATE_CHANGED"] = function( pars )
	Log("EVENT_ADDON_LOAD_STATE_CHANGED", pars )
	--exObj("EVENT_ADDON_LOAD_STATE_CHANGED", pars)

	local n = pars.name
	--LogToChat("EVENT_ADDON_LOAD_STATE_CHANGED ".. n)
	local _, userAddon = string.find( n, userPREFIX )
	userAddon = userAddon and string.sub( n, userAddon + 1 )

	if CMD == RELOAD then
		if pars.loading then return end
		--- команда перезагрузить все что загружено
		addonsTemp[ userAddon ] = nil
		if IsEmptyTable(addonsTemp) then
			CMD = nil
			--- все выгрузили теперь загрузим что нужно
			LoadAllAddons()
		end
	elseif CMD == SINGLE_RELOAD then
		CMD = nil
		--- одиночная перезагрузка - по изменению конфига аддона
		local item = addons[userAddon]
		--exObj( "addon", addon )
		SetState( userAddon, not item.unloaded )
	else
		local item = addons[userAddon]
		local itemMnu = item and item.item
		menuFB_repaint()
		--pars.loading
		--pars.unloading
		if mnu then
			if itemMnu then
				---LogInfo("EVENT_ADDON_LOAD_STATE_CHANGED")
				setItemValue( userAddon, itemMnu, pars.loading )
				---mnu:Update( { itemMnu } )
			else
			end
		end
	end
end

local function mem_response( pars )
	--exObj("ADDON_MEM_RESPONSE", pars)
	--LogToChat(pars.sender..":"..pars.memUsage)
	if not pars.sender or not pars.memUsage then return end
	local addonElem = pars.sender and addons[pars.sender]
	if not addonElem then
		--LogToChat("addnon "..pars.sender.." not found (ADDON_MEM_RESPONSE)")
		--LogInfo("addnon "..pars.sender.." not found (ADDON_MEM_RESPONSE)")
		return
	end

	addonElem.memUsage = pars.memUsage
	repaintTip(pars.sender)
end

onEvent["ADDON_MEM_RESPONSE"] = function( pars )
	Log("ADDON_MEM_RESPONSE", pars )
	mem_response( pars )
end

--============================================================================================

onReact["mouse_over"] = function ( pars )
	if DnD:IsDragging() then return end
	local wt = pars.widget
	local name = wt:GetName()
	if name == "FBhideth_pan" and not pars.active then
		--- только на закрытие
		FBhidethRun( false )
	elseif name == "PT_buton" then
		---menuCls3 - tipRun(wBase, tip, active, prior)
		tipRun( wt, L("Double click on o'clock open a Addons Menu. Click for see FastButtons Panel"), pars.active )
	end

end

onReact["mouse_left_click"] = function ( pars )
	if DnD:IsDragging() then return end
	local wt = pars.widget
	local name = wt:GetName()
	if name == "PT_buton" then
		if FBhidethStop then
			FBhidethStop = nil
			rePlaceFBhideth()
			menuFB_repaint()
		end
		FBmenuShow()
	end
end
--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------
function reset_addons()
	addons = {}
end
function addons_toConfig()
	local am, fb = {}, {}
	for sysName, pars in pairs(addons) do
		--am[sysName] = pars.unloaded and 1 or nil --- если выгружен то запомнит иначе нет - чтобы не засорять конфиг
		am[sysName] = {}
		for k, v in pairs(pars.PS) do
			am[sysName][k] = v == "ON" and 1 or v == "OFF" and 0 or nil --- SELF - не запоминаем
		end
		local v = pars.fbutton
		fb[sysName] = v == "ON" and 1 or v == "OFF" and 0 or nil --- SELF - не запоминаем
	end

	return am, fb, SysStates
end
function addons_fromConfig( am, fb, amSys )
	--exObj2("am",am)
	for sysName, pars in pairs(am or {}) do
		if not addons[sysName] then addons[sysName] = newAddon( sysName ) end
		if type(pars) == "table" then
			for k, v in pairs(pars) do
				addons[sysName].PS[k] = v == 1 and "ON" or v == 0 and "OFF"
			end
		end
	end
	--- тут на выходе все значения вместо SELF будет НИЛ, так как в конфиге все таблицы пустые
	--exObj2("addons",addons)
	
	for sysName, v in pairs(fb or {}) do
		if not addons[sysName] then addons[sysName] = newAddon( sysName ) end
		addons[sysName].fbutton = v == 1 and "ON" or v == 0 and "OFF" or "SELF"
	end
	if not SysStates then SysStates = {} end
	--- тут надо добавлять к тому что уже есть
	for sysName, pars in pairs(amSys or {}) do
		SysStates[sysName] = pars
	end
end

local avatarIsExist = avatar.IsExist()

function AddonsMenuInit()
	--- тут мы сами себя иницализируем все виджеты и класс меню
	dsc = menuDscInit(mainForm)

	RegisterEventHandlers( onEvent )

	RegisterReactionHandlers( onReact )
	--exObj("_PS", get_PS())
	---reMakeMenu()
	FBhidethStop = true
	itemsRestate( true )
	--FBhidethStop = nil
	--menuFB_repaint()
	--FBhidethRun( true )

	--- пошлем 1 раз всем свои текстуры
	onEvent.ADDON_TEXTURES_REQUEST( {} )

	--sendSKIN()
	if avatarIsExist then
		--- значит этот аддон перегрузили - пошлем запрос на инфо от всех аддонов
		SendEvent("ADDON_INFO_REQUEST", { sender = ADDONname  } )
	end

	return dsc
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------