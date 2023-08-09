--------------------------------------------------------------------------------
-- LibDnD.lua // "Drag&Drop Library" by SLA, version 2011-05-27
-- Help and Updates: http://ui9.ru/forum/develop/topic/950
--------------------------------------------------------------------------------
--- edited by icreator 2011/09/23

--- DnD:Init( wtReacting, wtMovable, fUseCfg, fLockedToScreenArea, Padding )

-----------------------------

Global( "DnD", {} )


-------------------------------------------- code from icreator
local queryDnD = {} --- здесь храним массив запросов на ДнД
local ADDON = common.GetAddonName()

local function GetConfig( name )
	local cfg = userMods.GetGlobalConfigSection( ADDON )
	return name == nil and cfg or cfg and cfg[ name ]
end

local function SetConfig( name, value )
	local cfg = userMods.GetGlobalConfigSection( ADDON ) or {}
	if type( name ) == "table" then
		for i, v in pairs( name ) do cfg[ i ] = v end
	elseif name ~= nil then
		cfg[ name ] = value
	end
	userMods.SetGlobalConfigSection( ADDON, cfg )
end

-- PUBLIC FUNCTIONS
local localIndex = 0 --- он может быть любой, поэтому при освобождении не обзяательно искать свободные - просо инкремент всегда делаем
function DnD:Init( wtReacting, wtMovable, fUseCfg, fLockedToScreenArea, Padding )
--- default params:
--- wtMovable == nil = wtReacting
--- fLockedToScreenArea == nil = true
--- Padding == nil = { 0,0,0,0} -- { T, R, B, L }
	localIndex = localIndex + 1
	queryDnD[localIndex] = { wtReacting=wtReacting, wtMovable=wtMovable, fUseCfg=fUseCfg,
		 fLockedToScreenArea=fLockedToScreenArea, Padding=Padding, ID = nil }
	--- тут запрос делаем сразу - если АТ уже был запущен то он пришлет ответ сразу
	userMods.SendEvent( "EVENT_GET_UNIQUE_DND_NUMBER", { addon = ADDON, index = localIndex } )
end

--- for all wtReacting that has same wtMovable set new params
local function setNewPosForWTMovable( w )
	local inst = w:GetInstanceId()
	for ID, elem in DnD.Widgets do
		if inst == elem.wtMovable:GetInstanceId() then
			if elem.fUseCfg then
				SetConfig( { [ "w"..ID.."x" ] = DnD.Place.posX, [ "w"..ID.."y" ] = DnD.Place.posY } )
			end
			elem.Initial.X = DnD.Place.posX
			elem.Initial.Y = DnD.Place.posY

			--- сообщим другим аддонам что наше окно поменяло положение ( GetInstanceId() не передается в параметрах! )
			userMods.SendEvent( "DND_SET_NEW_POS", { wt = w, place = { posX = DnD.Place.posX, posY = DnD.Place.posY } } )

		end
	end
end

---------------------------------------------------------------------------------------
-------- original code
------------------------------------------------------------------------------------
function DnD:IsDragging()
	return DnD.Dragging and true or false
end
-- INTERNAL FUNCTIONS
function DnD.GetWidgetID( wtWidget )
	local WtId = wtWidget:GetInstanceId()
	for ID, W in DnD.Widgets do
		if W.wtReacting:GetInstanceId() == WtId or W.wtMovable:GetInstanceId() == WtId then
			return ID
		end
	end
end

function DnD.Register( wtWidget, fRegister )
	if not DnD.Widgets then return end
	local ID = DnD.GetWidgetID( wtWidget )
	if not ID then
		-- оказывается меняется статический метод Show - который для всех виджетов аддона перезаписывается!
		-- поэтому нужна проверка тут
		--LogToChat(wtWidget:GetName().." ID nil!")
		--LogInfo(wtWidget:GetName().." ID nil!")
		return end
	if fRegister and DnD.Widgets[ ID ].Enabled and DnD.Widgets[ ID ].wtReacting:IsVisible() then
		if mission.GetLocalTimeHMS then -- AO 2.0.01+
			mission.DNDRegister( DnD.Widgets[ ID ].wtReacting, ID * DND_CONTAINER_STEP + DND_WIDGET_MOVE, true )
		else -- AO 1.1.02-2.0.00
			mission.DNDRegister( DnD.Widgets[ ID ].wtReacting, DND_WIDGET_MOVE * DND_CONTAINER_STEP + ID, true )
		end
	elseif not fRegister then
		if DnD.Dragging == ID then DnD.OnDragCancelled() end
		mission.DNDUnregister( DnD.Widgets[ ID ].wtReacting )
		userMods.SendEvent( "EVENT_DND_NUMBER_RELEASED", { addon = ADDON, index = DnD.Widgets[ ID ].localIndex } )
		------- снятие регистрации - это временное дело поэтому нельзя обнулять! DnD.Widgets[ ID ] = nil
	end
end

function DnD:Enable( wtWidget, fEnable )
	if not DnD.Widgets then return end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID and DnD.Widgets[ ID ].Enabled ~= fEnable then
		DnD.Widgets[ ID ].Enabled = fEnable
		DnD.Register( wtWidget, fEnable )
	end
end
function DnD.NormalizePlacement( Place, ID )
	if Place.posX + Place.sizeX > DnD.Screen.fullVirtualSizeX - DnD.Widgets[ ID ].Padding[ 2 ] then
		--Place.posX = math.ceil( DnD.Screen.fullVirtualSizeX ) - Place.sizeX - DnD.Widgets[ ID ].Padding[ 2 ]
		Place.posX = DnD.Screen.fullVirtualSizeX - Place.sizeX - DnD.Widgets[ ID ].Padding[ 2 ]
	end
	if Place.posY + Place.sizeY > DnD.Screen.fullVirtualSizeY - DnD.Widgets[ ID ].Padding[ 3 ] then
		--Place.posY = math.ceil( DnD.Screen.fullVirtualSizeY ) - Place.sizeY - DnD.Widgets[ ID ].Padding[ 3 ]
		Place.posY = DnD.Screen.fullVirtualSizeY - Place.sizeY - DnD.Widgets[ ID ].Padding[ 3 ]
	end
	if Place.posX < DnD.Widgets[ ID ].Padding[ 4 ] then Place.posX = DnD.Widgets[ ID ].Padding[ 4 ] end
	if Place.posY < DnD.Widgets[ ID ].Padding[ 1 ] then Place.posY = DnD.Widgets[ ID ].Padding[ 1 ] end
	return Place
end
function DnD.OnPickAttempt( params )
	--LogToChat("OnPickAttempt")
--[[
Info: addon AddonsTools: params{
Info: addon AddonsTools: params.srcId=14361
Info: addon AddonsTools: params.srcWidget=userdata: 2EF90710{userdata}
Info: addon AddonsTools: params.kbFlags=0
Info: addon AddonsTools: params.posY=670
Info: addon AddonsTools: params.posX=152
Info: addon AddonsTools: params}
]]
	local Picking
	if mission.GetLocalTimeHMS then -- AO 2.0.01+
		Picking = ( params.srcId - DND_WIDGET_MOVE ) / DND_CONTAINER_STEP
	else -- AO 1.1.02-2.0.00
		Picking = math.mod( params.srcId, DND_CONTAINER_STEP )
	end
	if not DnD.Widgets[ Picking ] then
		--- это системные окна двигаются - например в сумке шмотки
		--- кстати 1 = это в сумке двигают шмотки мышкой
		---LogInfo("wrong Picking:", Picking )
		return
	end
	if DnD.Widgets[ Picking ].Enabled then
		DnD.Place = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
		DnD.Reset = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
		DnD.Screen = widgetsSystem:GetPosConverterParams()
		DnD.Delta = {}
		DnD.Delta.X = params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Place.posX --- без округлений тут надо!
		DnD.Delta.Y = params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Place.posY --- без округлений тут надо!
		common.SetCursor( "drag" )
		DnD.Dragging = Picking
		common.RegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
		common.RegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
		mission.DNDConfirmPickAttempt()
	end
end

local DnDStep = 20
function DnD.OnDragTo( params )
	if not DnD.Dragging then return end
	DnD.Place.posX = params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Delta.X
	DnD.Place.posY = params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Delta.Y

	--DnD.Place.posX = DnDStep*math.floor(DnD.Place.posX/DnDStep)
	--DnD.Place.posY = DnDStep*math.floor(DnD.Place.posY/DnDStep)

	if DnD.Widgets[ DnD.Dragging ].fLockedToScreenArea then
		DnD.Place = DnD.NormalizePlacement( DnD.Place, DnD.Dragging )
	end
	DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Place )
	common.SetCursor( "drag" )
end
function DnD.OnDropAttempt()
	DnD.StopDragging( true )
end
function DnD.OnDragCancelled()
	DnD.StopDragging( false )
end


function DnD.StopDragging( fSuccess )
	if not DnD.Dragging then return end

	common.UnRegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
	common.UnRegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
	common.UnRegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
	if fSuccess then
		mission.DNDConfirmDropAttempt()
		setNewPosForWTMovable( DnD.Widgets[ DnD.Dragging ].wtMovable )
--[[		if DnD.Widgets[ DnD.Dragging ].fUseCfg then
--- тут надо все остальные окна тоже поменять
			SetConfig( { [ "w"..DnD.Dragging.."x" ] = DnD.Place.posX, [ "w"..DnD.Dragging.."y" ] = DnD.Place.posY } )
		end
		DnD.Widgets[ DnD.Dragging ].Initial.X = DnD.Place.posX
		DnD.Widgets[ DnD.Dragging ].Initial.Y = DnD.Place.posY
]]
	else
		mission.DNDCancelDrag()
		--DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Reset )
	end

	DnD.Place = nil
	DnD.Reset = nil
	DnD.Delta = nil
	DnD.Dragging = nil
	common.SetCursor( "default" )
end
function DnD.OnResolutionChanged()
	DnD.OnDragCancelled()
	DnD.Screen = widgetsSystem:GetPosConverterParams()
	for ID, W in DnD.Widgets do

--[[
DnD.Place.posX = (DnD.Screen.fullVirtualSizeX > (DnD.Place.posX + 0.5 * DnD.Place.sizeX)) and DnD.Place.posX or DnD.Screen.fullVirtualSizeX - 0.5 * DnD.Place.sizeX
DnD.Place.posY = (DnD.Screen.fullVirtualSizeY > (DnD.Place.posY + 50)) and DnD.Place.posY or DnD.Screen.fullVirtualSizeY - 50
DnD.Place.posX = ((DnD.Place.posX - DnD.Place.sizeX) > 1.5 * -DnD.Place.sizeX) and DnD.Place.posX or 0
DnD.Place.posY = (DnD.Place.posY > 0) and DnD.Place.posY or 0
]]
		if W.fLockedToScreenArea then
			local InitialPlace = W.wtMovable:GetPlacementPlain()
			InitialPlace.posX = W.Initial.X
			InitialPlace.posY = W.Initial.Y
			W.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
		end
	end
end
-----------------------------------------------------------------
---- additions by icreator - for get unique ID from AddonTools
-----------------------------------------------------------------
--- было ли окно когда-нибудь передвинуто и запомнено с новми координатами
function DnD:isSetted( w )
	if not DnD.Widgets then return end
	local ids = w:GetInstanceId()
	for ID, info in DnD.Widgets do
		if info.wtMovable:GetInstanceId() == ids then
			 return GetConfig( "w" .. ID .. "x" )
		end
	end
end

--- повторно запустит если нициализация после произошла - просто продублирует номера
function onEVENT_ADDONS_TOOLS_STARTED ()
	for i, q in queryDnD do
		if not q.ID then
			--- если ИД еще не получили то пошлем запрос
			userMods.SendEvent( "EVENT_GET_UNIQUE_DND_NUMBER", { addon = ADDON, index = i } )
		end
	end
end

function onUniqueNumberReceived( pars )

	if pars.addon ~= ADDON then return end
	local ID, localIndex = pars.id, pars.index
	if not ID or not localIndex then return end


	local query0 = queryDnD[localIndex]
	query0.ID = ID --- запомним что этот запрос уже обработан

	--LogToChat("for localIndex:".. localIndex.." receive ID:"..ID.. " wtReacting:"..query0.wtReacting:GetName())

	if not DnD.Widgets then
		DnD.Widgets = {}
		DnD.Screen = widgetsSystem:GetPosConverterParams()
		common.RegisterEventHandler( DnD.OnPickAttempt, "EVENT_DND_PICK_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnResolutionChanged, "EVENT_POS_CONVERTER_CHANGED" )
	end

	local elem = {}
	DnD.Widgets[ ID ] = elem
	elem.localIndex = localIndex
	elem.wtReacting = query0.wtReacting
	elem.wtMovable = query0.wtMovable or query0.wtReacting
	elem.Enabled = true
	elem.fUseCfg = query0.fUseCfg or false
	elem.fLockedToScreenArea = query0.fLockedToScreenArea == nil and true
		 or query0.fLockedToScreenArea
	elem.Padding = query0.Padding or { 0, 0, 0, 0 } -- { T, R, B, L }
	if type( query0.Padding ) == "table" then
		for i = 1, 4 do
			elem.Padding[ i ] = query0.Padding[ i ] or 0
		end
	end
	local InitialPlace = elem.wtMovable:GetPlacementPlain()
	if query0.fUseCfg then
		local CfgX = GetConfig( "w" .. ID .. "x" )
		local CfgY = GetConfig( "w" .. ID .. "y" )
		if CfgX and CfgY then
			InitialPlace.posX = CfgX
			InitialPlace.posY = CfgY
			elem.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
		end
	end
	elem.Initial = {}
	elem.Initial.X = InitialPlace.posX
	elem.Initial.Y = InitialPlace.posY

	--- ситема отключает регистрацию при скрытии окна
	--- поэтому надо заново включать
	local mt = getmetatable( query0.wtReacting )
	if not mt._Show then
		-- оказывается меняется статический метод Show - который для всех виджетов аддона перезаписывается!
		-- поэтому нужна проверка там
		mt._Show = mt.Show
		mt.Show = function ( self, show )
			self:_Show( show ); DnD.Register( self, show )
		end
	end

	DnD.Register( query0.wtReacting, true )
end

common.RegisterEventHandler( onUniqueNumberReceived, "EVENT_UNIQUE_DND_NUMBER_RECEIVED" )
common.RegisterEventHandler( onEVENT_ADDONS_TOOLS_STARTED, "EVENT_ADDONS_TOOLS_STARTED" )

