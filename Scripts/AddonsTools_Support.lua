function getAM_log()
	return false  ---- false or true:: log events|handlers in chat or not
end

function setAMSupport()
	if getAM_log() then LogToChat("setAMSupport") end

	return { 
-----------------------------------------------------------
------------------------------------------------- EDIT HERE:
-----------------------------------------------------------
	--- Insert here Your own functions
	-- initialize this addon when confirmed start:
		ThisAddonInit = nil, --mainInit,
	-- save a settings if need before unload:
		SaveToConfig = nil, --toConfig,
	-- if this addon unload any others addons then load they:
		LoadAllUnloadedAddons = nil, --loadUnloadedAddons,
	-- when clicked on a "Addons Menu" item - to show the mainForm
	---  pars = { sender = item.name, wBase = item.widgets["mnu_"] } : 
		AOBClick = nil, --mainMenuToggle,
	-- when right mouse clicked on a "Addons Menu" item:
	---  pars = { sender = item.name, wBase = item.widgets["mnu_"] } : 
		AOBRightClick = nil, --function() LogToChat(common.GetAddonName().." Right Click") end,
	-- when double clicked on a "Addons Menu" item:
	---  pars = { sender = item.name, wBase = item.widgets["mnu_"] } : 
		AOBDoubleClick = nil, --function() LogToChat(common.GetAddonName().." Double Click") end,
	},
--[[ DESCRIBE Your addon here.
	parameters:
	sender = common.GetAddonName() -- addon name
	desc - addon description
]]
 	{
	desc = L( 'myself' ),
	abbrev = "AT",
	vers = "r77",
	}
end

