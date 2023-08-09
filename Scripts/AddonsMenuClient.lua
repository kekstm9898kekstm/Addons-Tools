if not dsc then return end


local ToDoTab = {}
local function ToDo( func )
	table.insert( ToDoTab, func )
end
local function ToDoResume()
	for i, func in pairs(ToDoTab) do
		func()
	end
	ToDoTab = {}
end
--- by icreator 2011.09.18
------------------------------------------------------------
------------------------------------------------------------
local ADDONname = common.GetAddonName()
local handlersRun, handlersWait = {},{}
local FUNCS, DESC = nil, nil

local function descMake()
	local userDesc
	-- берем инфо системное об аддоне
	DESC = common.GetAddonInfo()
	FUNCS, userDesc = setAMSupport()
	--exObj2("FUNCS", FUNCS)
	for k, v in pairs(userDesc) do
		DESC[k]=v
	end
	DESC.sender = ADDONname
	DESC.lib = DESC.lib or "AddonsTools" -- чью библиотеку использует
	DESC.unloadSelf = true
end

local function Log(mess)
	if getAM_log() then 
		LogToChat(mess)
		LogInfo(mess)
	end
end
-------------------- RUN MODE -------------------------------
local WorldTextutes
local function updateWorldTextutes(tab)
	if not WorldTextutes then WorldTextutes = {} end

	if not tab then return end

	for k, v in pairs(tab) do
		WorldTextutes[ k ] = v
	end
end
function getWorldTextutes() return WorldTextutes end

handlersRun[ "ADDON_TEXTURES_RESPONSE" ] = function( pars )
	--LogToChat("ADDON_TEXTURES_RESPONSE "..(pars.sender or "?") .." -> "..(pars.target or "?"))
	if pars.target and pars.target ~= ADDONname then return end

	Log("ADDON_TEXTURES_RESPONSE from:"..(pars.sender or "?").." to:"..(pars.target or "?"))

	updateWorldTextutes(pars.textures)

end
handlersRun[ "ADDON_AT_MENUS_SKIN_CHANGED" ] = function( pars )
	Log("ADDON_AT_MENUS_SKIN_CHANGED")
	skin = pars
	--LogInfo("ADDON_AT_MENUS_SKIN_CHANGED")
	repaint_all_menus()
	repaint_all_GUI()
end
handlersRun[ 'ADDON_MEM_REQUEST' ] = function( pars )
	if pars.target ~= ADDONname then return end
	Log("ADDON_MEM_REQUEST")
	userMods.SendEvent( 'ADDON_MEM_RESPONSE', { sender = ADDONname, memUsage = gcinfo() } )
end
handlersRun[ 'ADDON_TOGGLE_UI' ] = function( pars ) mainForm:Show( pars.visible ) end

local function unloadSelf()
	Log("Unload self")
	common.StateUnloadManagedAddon( "UserAddon/"..ADDONname )
	userMods.SendEvent( 'ADDON_UNLOADED', { sender = ADDONname } )
end
handlersRun[ 'ADDON_UNLOAD' ] = function( pars )
	if pars.target ~= ADDONname then return end
	Log("ADDON_UNLOAD")

	if FUNCS and FUNCS.SaveToConfig then
		Log("SaveToConfig()")
		FUNCS.SaveToConfig()
	end
	if FUNCS and FUNCS.LoadAllUnloadedAddons then
		Log("LoadAllUnloadedAddons()")
		FUNCS.LoadAllUnloadedAddons()
	end

	unloadSelf()
end

function responseAddonInfo(target)
	descMake()
	DESC.target = target
	userMods.SendEvent( 'ADDON_INFO_RESPONSE', DESC )
end

handlersRun[ 'ADDON_INFO_REQUEST' ] = function( pars )
	if not pars.target or pars.target == ADDONname then
		SetGameLocalization(pars.localization)
		Log("ADDON_INFO_REQUEST for localize:"..GetGameLocalization())
		responseAddonInfo(pars.sender)

	end
end
--[[handlersRun[ 'SCRIPT_ADDON_INFO_REQUEST' ] = function( pars )
	if not pars.target or pars.target == ADDONname then
		SetGameLocalization(pars.localization)
		Log("SCRIPT_ADDON_INFO_REQUEST for localize:"..GetGameLocalization())
		responseAddonInfo(pars.sender)
	end
end
]]

--- will set new localizaation for your addon
handlersRun[ 'ADDON_SET_LOCALIZATION' ] = function( pars )
	Log("ADDON_SET_LOCALIZATION:"..(pars.localizationor "NIL"))
	SetGameLocalization( pars.localization )
end

handlersRun[ 'ATPANEL_BUTTON_LEFT_CLICK' ] = function( pars )
	--exObj2("ATPANEL_BUTTON_LEFT_CLICK", pars )
	if pars.target ==  ADDONname then
		Log("ATPANEL_BUTTON_LEFT_CLICK")
		if FUNCS and FUNCS.AOBClick then FUNCS.AOBClick( pars ) end
	end
end
handlersRun[ 'ATPANEL_BUTTON_RIGHT_CLICK' ] = function( pars )
	--exObj2("ATPANEL_BUTTON_RIGHT_CLICK", pars )
	if pars.target == ADDONname then
		--exObj2("pars",pars)
		if pars.reaction and pars.reaction.kbFlags == 0 then
			Log("ATPANEL_BUTTON_RIGHT_CLICK")
			if FUNCS and FUNCS.AOBRightClick then
				Log("AOBRightClick()")
				FUNCS.AOBRightClick( pars )
			end
		end
	end
end
handlersRun[ 'ATPANEL_BUTTON_DOUBLE_CLICK' ] = function( pars )
	if pars.target ==  ADDONname then
		Log("ATPANEL_BUTTON_DOUBLE_CLICK")
		if FUNCS and FUNCS.AOBDoubleClick then
			Log("AOBDoubleClick()")
			FUNCS.AOBDoubleClick( pars )
		end
	end
end

handlersRun[ 'ATPANEL_COMMAND' ] = function( pars )
	if pars.target ==  ADDONname then
		Log("ATPANEL_COMMAND")
		if FUNCS and FUNCS.AOCommand then
			Log("AOCommand()")
			FUNCS.AOCommand( pars )
		end
	end
end
handlersRun[ 'ADDON_GET_PARAMS' ] = function( pars )
	if pars.target ~=  ADDONname then return end
	Log("ADDON_GET_PARAM -> GetParams()")
	pars.params = FUNCS.GetParams and FUNCS.GetParams() or {}
	pars.sender = ADDONname
	pars.target = nil
	userMods.SendEvent( 'ADDON_GET_PARAMS_RESPONSE', pars )
end
handlersRun[ 'ADDON_SET_PARAM' ] = function( pars )
	if pars.target ~=  ADDONname then return end
	Log("ADDON_SET_PARAM")

	if FUNCS and FUNCS.SetParam then
		Log("SetParam()")
		FUNCS.SetParam( pars )
	end
end
-------------------------------- WAIT MODE --------------------
--- так нельз€! регистратор событий кос€чит! handlersWait[ 'ADDON_INFO_REQUEST' ] = handlersRun[ 'ADDON_INFO_REQUEST' ]
handlersWait[ 'ADDON_INFO_REQUEST' ] = function ( pars )
	handlersRun[ 'ADDON_INFO_REQUEST' ]( pars )
end
--[[
--- так нельз€! регистратор событий кос€чит! handlersWait[ 'SCRIPT_ADDON_INFO_REQUEST' ] = handlersRun[ 'SCRIPT_ADDON_INFO_REQUEST' ]
handlersWait[ 'SCRIPT_ADDON_INFO_REQUEST' ] = function ( pars )
	handlersRun[ 'SCRIPT_ADDON_INFO_REQUEST' ]( pars )
end
]]

--- when Addons Tool is started it send this event
handlersWait[ 'EVENT_ADDONS_TOOLS_AVATAR_CREATED' ] = function( pars )
	Log("EVENT_ADDONS_TOOLS_AVATAR_CREATED --> ADDON_START_REQUEST")
	userMods.SendEvent( 'ADDON_START_REQUEST', { sender = ADDONname,
			--- если текстур еще у нас нет то пошлем запрос и на них
			getTextures = not WorldTextutes,
		} )
end
--- if Your addon is ON in Addons List this event invoke it
handlersWait[ 'ADDON_START_CONFIRMED' ] = function( pars )
	if pars.target ~= ADDONname then return end

	Log("ADDON_START_CONFIRMED: "..( pars.unloaded and "unloaded" or "ok") )

	if pars.unloaded then
		--- if start not confirmed
		unloadSelf()
		return
	end
	--if getAM_log() then exObj("ADDON_START_CONFIRMED pars", pars) end
	if getAM_log() then exObj("dsc", dsc) end

	--- set localization
	SetGameLocalization( pars.localization )

	--- set events for RUN MODE
	for k, v in pairs(handlersRun) do
		common.RegisterEventHandler( v, k )
	end
	--- remove evnts of WAIT MODE
	for k, v in pairs(handlersWait) do
		common.UnRegisterEventHandler( v, k )
	end

	--- сначала щапомним все текстуры а потом будеи описание на аддон сосдавать
	updateWorldTextutes( pars.textures )

	handlersRun[ "ADDON_AT_MENUS_SKIN_CHANGED" ]( pars.skin )

	--- тут создаетс€ список функций, поэтому нельз€ ниже вставл€ть
	-- тут создаетс€ описание аддона
	handlersRun[ 'ADDON_INFO_REQUEST' ]( pars )

	if FUNCS and FUNCS.ThisAddonInit then 
		Log("FUNCS.ThisAddonInit()")
		skin = pars.skin or {}
		repaint_all_menus()
		repaint_all_GUI()

		FUNCS.ThisAddonInit()
		ToDoResume()
	else
		Log("FUNCS.ThisAddonInit = nil... stoped!" )
	end

end

--==============================================
--- ATPanel
function ATPanelSend()
	if DESC.notATPanel then return end
	local param = { ptype = "button" }
	local icon = DESC.icon
	if icon then
		if type(icon) == "string" then
			icon = WorldTextutes[icon].texture
		else
		end
	end
	userMods.SendEvent( "ATPANEL_SEND_ADDON",
		{ sysName = ADDONname, label = DESC.abbrev, image = icon, tip = DESC.desc } )
end
handlersWait[ 'ATPANEL_START' ] = function( pars )
	if DESC and WorldTextutes then
		ATPanelSend()
	else
		ToDo(ATPanelSend)
		return
	end
end
handlersRun[ 'ATPANEL_START' ] = function ( pars )
	handlersWait[ 'ATPANEL_START' ]( pars )
end

--==============================================


--- set widgets descriprions for menu class and get its:
--dsc = menuDscInit(wAddonsTools)
for k, v in pairs(handlersWait) do
	common.RegisterEventHandler( v, k )
end

if avatar.IsExist() then
	handlersWait[ 'EVENT_ADDONS_TOOLS_AVATAR_CREATED' ]()
	end
