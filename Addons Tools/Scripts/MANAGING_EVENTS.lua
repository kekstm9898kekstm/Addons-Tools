-----
--- managing addon events
-----------------------------
--- by icreator 2011.10.12
------------------------------------------------------------
------------------------------------------------------------
local ADDONname = common.GetAddonName()
local handlersRun, handlersWait = {},{}
local FUNCS, DESC

--[[ 
You need describe the functions:
	FUNCS.ThisAddonInit
	FUNCS.SaveToConfig
	FUNCS.LoadAllUnloadedAddons
	FUNCS.AOBClick
	FUNCS.AOBRightClick
	FUNCS.AOBDoubleClick
	FUNCS.AOCommand
	FUNCS.SetGameLocalization

You need describe the info:
	DESC.desc = some text
]]
local function setFUNCS()
	FUNCS = {
	ThisAddonInit = Init,
	SetGameLocalization = nil,
	SaveToConfig = nil,
	LoadAllUnloadedAddons = nil,
	AOBClick = nil,
	AOBRightClick = nil,
	AOBDoubleClick = nil,
	AOCommand = nil,
	}
end
local function setDESC()
	DESC = { 
	sender = ADDONname,
	desc = "...",
	abbrev = ".", --- abbreviation for button
	addonsBlocked = {}, -- ={ table of names unloaded addons }
	}
end

-------------------- RUN MODE -------------------------------
handlersRun[ 'ADDON_MEM_REQUEST' ] = function( pars )
	if pars.target ~= ADDONname then return end
	userMods.SendEvent( 'ADDON_MEM_RESPONSE', { sender = ADDONname, memUsage = gcinfo() } )
end
handlersRun[ 'ADDON_TOGGLE_UI' ] = function( pars ) mainForm:Show( pars.visible ) end
handlersRun[ 'ADDON_TOGGLE_DND' ] = function( pars )
	if pars.target ~= ADDONname then return end
	DnD:Enable( pars.state ) --- DnD_ic.lua need
end
local function unloadSelf()
	common.StateUnloadManagedAddon( "UserAddon/"..ADDONname )
	userMods.SendEvent( 'ADDON_UNLOADED', { sender = ADDONname } )
end
handlersRun[ 'ADDON_UNLOAD' ] = function( pars )
	if pars.target ~= ADDONname then return end

	if FUNCS and FUNCS.SaveToConfig then
		FUNCS.SaveToConfig()
	end
	if FUNCS and FUNCS.LoadAllUnloadedAddons then
		FUNCS.LoadAllUnloadedAddons()
	end

	unloadSelf()
end

handlersRun[ 'ADDON_INFO_REQUEST' ] = function( pars )
	if pars.target == ADDONname then

		setFUNCS()
		if FUNCS.SetGameLocalization then FUNCS.SetGameLocalization(pars.localization) end
		setDESC()
		userMods.SendEvent( 'ADDON_INFO_RESPONSE', DESC )
	end
end

--- will set new localizaation for your addon
handlersRun[ 'ADDON_SET_LOCALIZATION' ] = function( pars )
	if FUNCS.SetGameLocalization then FUNCS.SetGameLocalization( pars.localization ) end
end

handlersRun[ 'AOPANEL_BUTTON_LEFT_CLICK' ] = function( pars )
	if pars.target ==  ADDONname then
		if FUNCS and FUNCS.AOBClick then FUNCS.AOBClick( pars ) end
	end
end
handlersRun[ 'AOPANEL_BUTTON_RIGHT_CLICK' ] = function( pars )
	if pars.target ==  ADDONname then
		if FUNCS and FUNCS.AOBRightClick then FUNCS.AOBRightClick( pars ) end
	end
end
handlersRun[ 'AOPANEL_BUTTON_DOUBLE_CLICK' ] = function( pars )
	if pars.target ==  ADDONname then
		if FUNCS and FUNCS.AOBDoubleClick then FUNCS.AOBDoubleClick( pars ) end
	end
end

handlersRun[ 'AOPANEL_COMMAND' ] = function( pars )
	if pars.target ==  ADDONname then
		if FUNCS and FUNCS.AOCommand then FUNCS.AOCommand( pars ) end
	end
end
-------------------------------- WAIT MODE --------------------
handlersWait[ 'ADDON_INFO_REQUEST' ] = handlersRun[ 'ADDON_INFO_REQUEST' ]

--- when Addons Tool is started it send this event
handlersWait[ 'ADDON_AVATAR_CREATED' ] = function( pars )
	userMods.SendEvent( 'ADDON_START_REQUEST', { sender = ADDONname } )
end
--- if Your addon is ON in Addons List this event invoke it
handlersWait[ 'ADDON_START_CONFIRMED' ] = function( pars )
	if pars.target ~= ADDONname then return end

	if pars.unloaded then
		--- if start not confirmed
		unloadSelf()
		return
	end

	--- START CONFIRMED
	setFUNCS()
	--- set localization
	if FUNCS.SetGameLocalization then FUNCS.SetGameLocalization( pars.localization ) end
	setDESC()

	--- set events for RUN MODE
	for k, v in handlersRun do
		common.RegisterEventHandler( v, k )
	end
	--- remove events of WAIT MODE
	for k, v in handlersWait do
		common.UnRegisterEventHandler( v, k )
	end

	FUNCS.ThisAddonInit()

	userMods.SendEvent( 'ADDON_INFO_RESPONSE', DESC )

end

for k, v in handlersWait do
	common.RegisterEventHandler( v, k )
end
if avatar.IsExist() then handlersWait[ 'ADDON_AVATAR_CREATED' ]() end
