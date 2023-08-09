--------------------------------------------------------------------------------
-- LibDnD.lua // "Drag&Drop Library" by SLA, version 2011-05-28
-- Help and Updates: http://alloder.pro/topic/260-how-to-libdndlua-biblioteka-dragdrop
--------------------------------------------------------------------------------
Global( "DnD", {} )
DnD.isEnabled  = true
local addonName = common.GetAddonName()

----------------------------------------------------------- icreator
local function OnResolutionChangedReplace(oldScreen, newScreen, wt)
	local plc = wt:GetPlacementPlain()
	for _, v in pairs({ "pos", "highPos" }) do
		for _, xy in pairs({ "X", "Y" }) do
			local k = v..xy
			plc[k] = plc[k]
				/ oldScreen["fullVirtualSize"..xy] * newScreen["fullVirtualSize"..xy]
				--/ (oldScreen.realSizeX / oldScreen.realSizeY / newScreen.realSizeX * newScreen.realSizeY)
		end
	end
	wt:SetPlacementPlain( plc )
end
local ADDONname = common.GetAddonName()
ADDON_LOCK_DND = function( pars )
	if pars.target ~= addonName then return end
	DnD:Enable( not pars.state )
end
common.RegisterEventHandler( ADDON_LOCK_DND, "ADDON_LOCK_DND" )

-----------------------------------------------------------
-----------------------------------------------------------
------------- from ScriptLIB.lua
--- возвращает размер виджета
local function wtGetSizeX(w, p)
--[[ она масштабирует до реальных точек	local rr = w:GetRealRect()
	return rr.x2-rr.x1, rr.y2-rr.y1
--]]
	if not w then return DnD.Screen.fullVirtualSizeX end
	if not p then p = w:GetPlacementPlain() end
	--LogIndo(w:GetName(),": sX=", p.sizeX,"  sY=",p.sizeY )

	if p.alignX == 3 then
		local parent = w.GetParent and w:GetParent()
		return wtGetSizeX(parent) - p.posX - p.highPosX
	
	elseif p.alignX == WIDGET_ALIGN_LOW_ABS then
		--exObj2("abs",p)
		return p.sizeX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX
	else
		return p.sizeX
	end

end
--- возвращает размер виджета
local function wtGetSizeY(w, p)
--[[ она масштабирует до реальных точек	local rr = w:GetRealRect()
	return rr.x2-rr.x1, rr.y2-rr.y1
--]]
	if not w then return DnD.Screen.fullVirtualSizeY end
	if not p then p = w:GetPlacementPlain() end
	if p.alignY == 3 then
		local parent = w.GetParent and w:GetParent()
		return wtGetSizeY(parent) - p.posY - p.highPosY
	
	elseif p.alignX == WIDGET_ALIGN_LOW_ABS then
		return p.sizeY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY
	else
		return p.sizeY
	end

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetFullName( widget, name )
	name = name or {}
	if not widget then return table.concat( name, '.' ) end
	table.insert( name, 1, widget:GetName() )
	return GetFullName( widget:GetParent(), name )
end
local function GetConfig( name )
	local config = userMods.GetGlobalConfigSection( addonName )
	if not name then return config end
	if config and type( config[ name ] ) == 'string' then
		--- тут минус норм обрабатывается
		local str = config[ name ]
		local i, posX, posY = string.find( str, ':' )
		posX = string.sub( str, 1, i-1 )
		posY = string.sub( str, i+1 )
		return tonumber( posX ), tonumber( posY )
	end
end
local function SetConfig( name, value )
	local config = userMods.GetGlobalConfigSection( addonName ) or {}
	if type( value ) == 'table' then
		config[ name ] = table.concat( value, ':' )
		userMods.SetGlobalConfigSection( addonName, config )
	end	
end
--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
---------------------------------

-----------------------------------------------------------------
---- additions by icreator - for get unique ID from AddonTools
-----------------------------------------------------------------
--- было ли окно когда-нибудь передвинуто и запомнено с новми координатами
function DnD:isSetted( w )
	if not DnD.Widgets then return end
	local ids = GetInstanceId(w)
	if not ids then return end
	for ID, info in pairs(DnD.Widgets) do
		if info.wtMovable:GetInstanceId() == ids then
			 return GetConfig( "w" .. ID .. "x" )
		end
	end
end
--------------------------------------------------------------

function DnD:Init( wtReacting, wtMovable, fUseCfg, fLockedToScreenArea, Padding,
		kbFlag, --[[ KBF_ANY, KBF_SHIFT, KBF_ALT, KBF_CTRL, KBF_NONE or nil -]]
		notCursor -- для слайдеров
		)

	if type(wtReacting) == "number" then
		--- если старая версия вызова то заменим параметры для новой
		wtReacting, wtMovable, fUseCfg, fLockedToScreenArea, Padding, kbFlag = wtMovable, fUseCfg, fLockedToScreenArea, Padding, kbFlag, notCursor
	end

	if not wtReacting then return end
	if not DnD.Widgets then
		DnD.Widgets = {}
		DnD.Screen = widgetsSystem:GetPosConverterParams()
		common.RegisterEventHandler( DnD.OnPickAttempt, "EVENT_DND_PICK_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnResolutionChanged, "EVENT_POS_CONVERTER_CHANGED" )
	end
	
	local ID = common.RequestIntegerByInstanceId( wtReacting:GetInstanceId() )
		
	DnD.Widgets[ ID ] = {}
	DnD.Widgets[ ID ].wtReacting = wtReacting
	DnD.Widgets[ ID ].wtMovable = wtMovable or wtReacting
	DnD.Widgets[ ID ].Enabled = DnD.isEnabled
	DnD.Widgets[ ID ].fUseCfg = fUseCfg or false
	DnD.Widgets[ ID ].fLockedToScreenArea = fLockedToScreenArea == nil and true or fLockedToScreenArea
	DnD.Widgets[ ID ].Padding = { 0, 0, 0, 0 } -- { T, R, B, L }
	DnD.Widgets[ ID ].notCursor = notCursor
	if type( Padding ) == "table" then
		for i = 1, 4 do
			DnD.Widgets[ ID ].Padding[ i ] = Padding[ i ] or 0
		end
	end
	DnD.Widgets[ ID ].kbFlag = type( kbFlag ) == 'number' and kbFlag or KBF_NONE
	
	local InitialPlace = DnD.Widgets[ ID ].wtMovable:GetPlacementPlain()
	
	DnD.Widgets[ ID ].fullName = GetFullName( DnD.Widgets[ ID ].wtMovable )

	if fUseCfg then
		local posX, posY = GetConfig( DnD.Widgets[ ID ].fullName )
		if posX and posY then
			InitialPlace.posX = posX
			InitialPlace.posY = posY
			DnD.Widgets[ ID ].wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
		end
	end
	DnD.Widgets[ ID ].Initial = {}
	DnD.Widgets[ ID ].Initial.X = InitialPlace.posX
	DnD.Widgets[ ID ].Initial.Y = InitialPlace.posY
	local mt = getmetatable( wtReacting )
	if not mt._Show then
		mt._Show = mt.Show
		mt.Show = function ( self, show )
			self:_Show( show ); DnD.Register( self, show )
		end
	end
	DnD.Register( wtReacting, true )
end

function DnD:Enable( fEnable )
	DnD.isEnabled = fEnable --- Для всех виджетов АДДОНА
	if not DnD.Widgets then return end
	for ID, item in pairs(DnD.Widgets) do
		if item.Enabled ~= fEnable then
			item.Enabled = fEnable
			DnD.Register( item.wtReacting, fEnable )
		end
	end

end
function DnD:IsDragging()
	return DnD.Dragging and true or false
end
-- INTERNAL FUNCTIONS
function DnD.GetWidgetID( wtWidget )
	local WtId = wtWidget:GetInstanceId()
	for ID, W in pairs(DnD.Widgets) do
		if W.wtReacting:GetInstanceId() == WtId or W.wtMovable:GetInstanceId() == WtId then
			return ID
		end
	end
end
function DnD.Register( wtWidget, fRegister )
	if not DnD.Widgets then return end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID then
		if fRegister and DnD.isEnabled and DnD.Widgets[ ID ].Enabled and DnD.Widgets[ ID ].wtReacting:IsVisible() then
			mission.DNDRegister( DnD.Widgets[ ID ].wtReacting, ID * DND_CONTAINER_STEP + DND_WIDGET_MOVE, true )
		elseif not fRegister then
			if DnD.Dragging == ID then DnD.OnDragCancelled() end
			mission.DNDUnregister( DnD.Widgets[ ID ].wtReacting )
		end
	end
end


function DnD.NormalizePlacement( Place, ID )
--[[ orig
	if Place.posX + Place.sizeX > DnD.Screen.fullVirtualSizeX - DnD.Widgets[ ID ].Padding[ 2 ] then
		Place.posX = math.ceil( DnD.Screen.fullVirtualSizeX ) - Place.sizeX - DnD.Widgets[ ID ].Padding[ 2 ] end
	if Place.posY + Place.sizeY > DnD.Screen.fullVirtualSizeY - DnD.Widgets[ ID ].Padding[ 3 ] then
		Place.posY = math.ceil( DnD.Screen.fullVirtualSizeY ) - Place.sizeY - DnD.Widgets[ ID ].Padding[ 3 ] end
	if Place.posX < DnD.Widgets[ ID ].Padding[ 4 ] then Place.posX = DnD.Widgets[ ID ].Padding[ 4 ] end
	if Place.posY < DnD.Widgets[ ID ].Padding[ 1 ] then Place.posY = DnD.Widgets[ ID ].Padding[ 1 ] end
]]
--- my - for Slider
	local wtParent = DnD.Widgets[ ID ].wtMovable:GetParent()
	local sizeXparent, sizeYparent = wtGetSizeX(wtParent), wtGetSizeY(wtParent)
	local sizeX = wtGetSizeX(DnD.Widgets[ ID ].wtMovable)
	local sizeY = wtGetSizeY(DnD.Widgets[ ID ].wtMovable)

	if Place.posX + sizeX > sizeXparent - DnD.Widgets[ ID ].Padding[ 2 ] then
		Place.posX = sizeXparent - DnD.Widgets[ ID ].Padding[ 2 ] - sizeX end
	if Place.posY + sizeY > sizeYparent - DnD.Widgets[ ID ].Padding[ 3 ] then
		Place.posY = sizeYparent - DnD.Widgets[ ID ].Padding[ 3 ] - sizeY end
	if Place.posX < DnD.Widgets[ ID ].Padding[ 4 ] then Place.posX = DnD.Widgets[ ID ].Padding[ 4 ] end
	if Place.posY < DnD.Widgets[ ID ].Padding[ 1 ] then Place.posY = DnD.Widgets[ ID ].Padding[ 1 ] end

	return Place
end
function DnD.OnPickAttempt( params )
	local Picking = ( params.srcId - DND_WIDGET_MOVE ) / DND_CONTAINER_STEP
	--print( common.GetBitAnd( params.kbFlags, DnD.Widgets[ Picking ].kbFlag ), ', params.kbFlags = ', params.kbFlags, ', DnD.Widgets[ Picking ].kbFlag = ', DnD.Widgets[ Picking ].kbFlag )
	if DnD.Widgets[ Picking ] and DnD.Widgets[ Picking ].Enabled and ( DnD.Widgets[ Picking ].kbFlag == KBF_NONE or common.GetBitAnd( params.kbFlags, DnD.Widgets[ Picking ].kbFlag ) ~=0 ) then
		DnD.Place = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
		DnD.Reset = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
		DnD.Screen = widgetsSystem:GetPosConverterParams()
		DnD.Delta = {}
		DnD.Delta.X = math.ceil( params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Place.posX )
		DnD.Delta.Y = math.ceil( params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Place.posY )

		local cursorName = DnD.Widgets[ Picking ].notCursor
		cursorName = cursorName == true and "default" or cursorName
		common.SetCursor( cursorName or "drag" )

		DnD.Dragging = Picking
		common.RegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
		common.RegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
		mission.DNDConfirmPickAttempt()
	end
end
function DnD.OnDragTo( params )
	if not DnD.Dragging then return end
	-- if common.GetBitAnd( params.kbFlags, DnD.Widgets[ DnD.Dragging ].kbFlag ) == 0 then DnD.StopDragging( true ) end
	DnD.Place.posX = math.ceil( params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Delta.X )
	DnD.Place.posY = math.ceil( params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Delta.Y )

	if DnD.Widgets[ DnD.Dragging ].fLockedToScreenArea then
		DnD.Place = DnD.NormalizePlacement( DnD.Place, DnD.Dragging )
	end
	DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Place )

		local cursorName = DnD.Widgets[ DnD.Dragging ].notCursor
		cursorName = cursorName == true and "default" or cursorName
		common.SetCursor( cursorName or "drag" )
	userMods.SendEvent( "DND_SLIDER_NEW_POS", { wt = DnD.Widgets[ DnD.Dragging ].wtMovable,
		place = { posX = DnD.Place.posX, posY = DnD.Place.posY } } )



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
		if DnD.Widgets[ DnD.Dragging ].fUseCfg then
			SetConfig( DnD.Widgets[ DnD.Dragging ].fullName, { DnD.Place.posX, DnD.Place.posY } )
		end
		DnD.Widgets[ DnD.Dragging ].Initial.X = DnD.Place.posX
		DnD.Widgets[ DnD.Dragging ].Initial.Y = DnD.Place.posY

		userMods.SendEvent( "DND_SET_NEW_POS", { wt = DnD.Widgets[ DnD.Dragging ].wtMovable,
			place = { posX = DnD.Place.posX, posY = DnD.Place.posY } } )

	else
		DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Reset )
	end
	DnD.Place = nil
	DnD.Reset = nil
	DnD.Delta = nil
	DnD.Dragging = nil
	common.SetCursor( "default" )
end
function DnD.OnResolutionChanged()
	DnD.OnDragCancelled()

	local Screen = widgetsSystem:GetPosConverterParams()
	--exObj2("oldScreen", DnD.Screen )
	--exObj2("newScreen", Screen )
	for ID, W in pairs(DnD.Widgets) do
		OnResolutionChangedReplace(DnD.Screen, Screen, W.wtMovable)
		local plc = W.wtMovable:GetPlacementPlain()
		W.Initial.X = plc.posX
		W.Initial.Y = plc.posY
	end
	
	DnD.Screen = Screen

	for ID, W in pairs(DnD.Widgets) do
		local InitialPlace = W.wtMovable:GetPlacementPlain()
		if W.fLockedToScreenArea then
			InitialPlace.posX = W.Initial.X
			InitialPlace.posY = W.Initial.Y
			W.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
		else
			
		end
	end
end
