--- author icreator
--- UPDATED: 2011.09.19

--- ��� ����-���� ���� ���������/����� ����� ���������
--- ����� ��������  parentObj
--- ��������� item.value item.offset -  ����� ���� ��������� ��� ��������������� ���������� ��� menu:Update()

---- ����� ��� ���� ������� - ��� �� ������ ���� ������� � ������� ������ ����� ��� ���� �����������
--- value = "-" - ��� nil - ��� ���� �� ��� ��������� ���������: setPS(name, nil)
local o, logOn --- �������� ����� � ��� 
Global("skin", {} )

local selfs = {} --- ������ ������ �� �������, ��� ��������� �� � ��������
Class( "menu", {} )
--[[
nemu = {
---wtMenu,
---menuItems,
---showOn,

	strucMenu = { menuItems ...},
	mouse_left_click, --- ��� ������� ��������� ��������� ��� ������� �� ����
	on_enter, --- ��� ������� ��������� ��������� ������� enter ��� ����� �������� � ���� ����
	valFormats = formats for :SetFormat()
	valShapes = function( item.name, item, value ) or table [item,value] - for make shape for SetVal() (( ������� ��� ������� ��� ������������� �������� ))
}
]]


--[[ SCHEME:
strucMenu = {
	{ token ="_0", label = L("*** MAIN SETTINGS ***") },
	{ name ="itemName", label = L("Item Label"), type = "_txt", listVals =onoff, chars = 10, offset = 20, valFormats},
	{ name ="itemName", label = L("Item Label"), type ="_lst", 
			list = { type = "_txt", labels = getAllTypes(), vals = sortVals,
				edited = true, --- ����� ������������� ������
				numberKeys = true, --- ������ ������� �� ������������ ������� - ����������� ��������� ������ �� ���������� � �� ����� ������ �������
				},
			offset = 15 },
	{ name ="itemName", label = L("Item Label"), type ="_txt", menuItems=... }

	{ name ="myTargMarkName", label = L("MTM Name"), type ="_edl", offset = 15 },
}
--]]


--- ����������� ���������� - ���� �� ���� �����
local onEvent = {}
local onReaction = {}

local excludeList = { parentObj = true, parentItem = true, parent = true } --- cancel recursion for indexes
function menu.GetExludeList()
	return excludeList
end

local dsc = {}
local wTip, wTipTxt
local tipFormat = ToWS("<html alignx='left' aligny='middle' fontname='AllodsWest' fontsize='14' shadow='1'><log_dark_white><r name='value'/></log_dark_white></html>")

function repaint_all_menus()
	--- ��������
end

function menuDscInit( wAddonsTools )
	--- ������� �������� �� ��������
	local name = {}
	for _, w in wAddonsTools:GetNamedChildren() do
		name = w:GetName()
		if string.sub(name,1,3) == "dsc" then
			dsc[string.sub(name,4)] = w:GetWidgetDesc()
		end
	end
	wTip = mainForm:CreateWidgetByDesc( dsc.Border )
	wTipTxt = mainForm:CreateWidgetByDesc( dsc.Text )
	wTip:AddChild(wTipTxt) wTipTxt:Show(true)
	wTipTxt:SetMultiline( true )
	wtSetPlace( wTipTxt, { posX=20, highPosX=20, posY=20, highPosY=20, alignX = 3, alignY = 3 } )
	return dsc
end


local valuedText = common.CreateValuedText()
local format = "<html fontname='AllodsWest' fontsize='14' shadow='1'><tip_blue><r name='text'/></tip_blue></html>"
valuedText:SetFormat(ToWS(format))

local TipShink = 2
-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------
--[[
local function makeItemValue( v )
--	return names[v] or v or "-"
	return v or "-"
end
]]

local function tipRun(wBase, tip, active, prior)
	if active == true then
		wTipTxt:ClearValues()
		local tipTxt
		local len, lenX, lenY
		if type(tip) == "table" then
			tipTxt = tip.values
			len = tip.len or 0 --- ���������� ����� � ������� ����� ���� �������
			for _, v in tipTxt do
				len = len + string.len(v)
			end
			--- ��� ����� ��������� � ��������
			wTipTxt:SetFormat(ToWS(tip.format))
			for r, v in tipTxt do
				wTipTxt:SetVal(r,ToWS(v))
			end
		else
			wTipTxt:SetFormat( tipFormat )
			tipTxt = tip
			len = string.len(tipTxt)
			--- ��������� ������ ��� �������
			wTipTxt:SetVal("value",ToWS(tipTxt))
		end
		lenX = math.ceil(len^0.5 *TipShink)
		if lenX < 40 then lenX = 40 end
		lenY = math.ceil(len/lenX)
		wtSetPlace( wTip, { sizeX = lenX*9+60, sizeY=lenY*16 + 60 } )
		if wBase then
			wtChain( wTip, wBase, 10, 30)
			wTip:SetPriority( prior + 100 ) ---or .wtMenu:GetPriority())+100)
		end
		wTip:Show( true )
	else
		wTip:Show( false )
	end
end


---ButtonToggle(obj, obj.wtEdited.del, "[-]")
local function ButtonToggle(obj, wtReact, LabelNormal, LabelPusshed, PROC)
	local vart = wtReact:GetVariant()
	wtReact:SetVariant( vart == 1 and 0 or 1)
	if vart == 0 then
		--- �������� ������� �� ������
		obj.mouse_overRun_temp = obj.mouse_overRun
		obj.mouse_overRun = false
		--- �������� ������ �������� ���
		obj:enableEdited(false, { wtReact } )
		obj.mouse_left_click_instead = PROC
		wtReact:SetVal("button_label", ToWS(LabelPusshed) )
	else
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_left_click_instead = nil
		obj:enableEdited(true, { wtReact } )
		wtReact:SetVal("button_label", ToWS(LabelNormal) )
	end
end

local function tuneRowsCols(Len,R,C)
	C = math.ceil ( Len / R )
	if C <= 0 then C = 1 end
	R = math.ceil ( Len / C )
	if R <= 0 then R = 1 end
	return R, C
end

local function menuClose( obj )
	obj.showOn = false
	obj.wtMenu:Show( false )
	if obj.parentObj then
		--- ������ �������� ��� ������� �������
		obj.parentObj.childsActive = nil
		obj.parentObj.mouse_overRun = true
	end
end

local function PlayFade(obj, fadeFrom, fadeTo, time1)
	obj.wtMenu:FinishFadeEffect()
	local toShow = fadeTo == 1
	obj.wtMenu:Enable( toShow )
	local time2 = 0
	if fadeFrom ~= fadeTo then time2 = math.ceil( math.abs( time1 * (fadeTo - obj.wtMenu:GetFade()) / ( fadeFrom - fadeTo) ) ) end
	if time2 > time1 then time2 = time1 end
	if time2<50 then
		obj.wtMenu:SetFade( fadeTo )
		onEvent.EVENT_EFFECT_FINISHED( { wtOwner = obj.wtMenu } )------ selfs[pars.wtOwner:GetInstanceId()]
	else
		obj.wtMenu:PlayFadeEffect( obj.wtMenu:GetFade(), fadeTo, time2, EA_MONOTONOUS_INCREASE )
	end
	--- ������� ���� ���������� �� ��������
	local parentObj = obj.parentObj
	if parentObj and not obj.childsActive then
		--- ���� ���� �������� � � �������� ������� ��� ����� �� �������� �� ������ ������� ��������
		if toShow then
			PlayFade(parentObj, parentObj.wtMenu:GetFade(), parentObj.fadeVal, parentObj.fadeOff)
		else
			PlayFade(parentObj, parentObj.wtMenu:GetFade(), 1, parentObj.fadeOn)
		end
	end
end

local function FUNC_SelMenu( item )
	--- ��������� ������� � ������� ���� �������� �� ������
	local obj = item.parent
	obj:Show(false)
	obj.parentItem.value = item.name --- ������� ������ � ����-��������
	obj.parentObj:setVal(obj.parentItem, true ) --- update value
	if obj.recurseCount == 1 then
		obj.parentObj.mouse_left_click( obj.parentItem ) --, obj.parentObj )
	end
end

--- �������� �������� �� �������������� ������� ��������
--- ��� ����� ���� �������� - ����� ������ - � ��������� ��������
local function FUNC_onSetList( obj )
	--LogInfo("FUNC_onSetList, recurseCount:", obj.recurseCount )
	--exObj("returnVals", obj.returnVals)
	if obj.recurseCount == 1 then
		--- ��� ��������� ��������� - ������ �������
		obj.parentItem.value = obj.returnVals --- ������� ������ � ����-��������
		if obj.parentObj.mouse_left_click then obj.parentObj.mouse_left_click( obj.parentItem ) end
	else
		--- ��� ��������� �������� ������ ��������
		obj.parentItem.value = obj.returnVals
	end
end

--- ��� ���� ���� ���� �������� �� �������� ��������
local function FUNC_selAddItem( item )
	local objChild = item.parent
	local obj = objChild.parentObj
	local newItem = { name = item.name, label = item.label, type = obj.list.type, value = obj.list.defaultVal, listVals = obj.list.vals }
	table.insert( obj.strucMenu, newItem )
	objChild:Show(false,true)
	obj:repaint()
	obj:Update( { newItem } )
end

local function FUNC_item_del( item ) --, obj )
	local obj = item.parent
	obj.wtMenu:Enable(false)
	obj:removeItem(item.index)
	obj:repaint()
	obj.wtMenu:Enable(true)
	ButtonToggle(obj, obj.wtEdited.del, "[-]")
end

local ItemMoved
local function FUNC_item_move( item ) --, obj )
	local obj = item.parent
	if not ItemMoved then 
		ItemMoved = item
		wtSetVal(obj.wtEdited.move, "=>?")
	else
		obj.wtMenu:Enable(false)
		if item.index > ItemMoved.index then
			table.insert(obj.strucMenu, item.index, ItemMoved)
			table.remove(obj.strucMenu, ItemMoved.index)
		else
			table.remove(obj.strucMenu, ItemMoved.index)
			table.insert(obj.strucMenu, item.index, ItemMoved)
		end
		ItemMoved = nil
		obj:repaint()
		obj.wtMenu:Enable(true)
		ButtonToggle(obj, obj.wtEdited.move, "<=>")
	end
end

-------------------------------------------------------------------------------
-- ADDON
-------------------------------------------------------------------------------
function menu:getVal(item)
	return item.wtVal and wtGetVal( item.wtVal )
end

local function calcValue(obj, item)
	local value, format = item.value

	--if item.name == "AUTOTARGETlist" then exObj("value1", value) end

	--- ������� ��� �������� �����, ����� ��� �� �������� ������ ������
	if type(value) == "function" then value = value(item)
	-- ��� ������ - ������� ��� �������� ��� � �� ��� ��������� elseif type(value) == "table" then value = value[item.name]
	end
	if value == nil then return "-" end

	--if item.name == "AUTOTARGETlist" then exObj("value2", value) end
	

	if item.type == "_txt" or item.type == "_edl" --[[or item.type == "_mnu" --]] then
		if type(value) == "table" then
			--LogToChat(item.name.." is table!")
		else
			--- ���� ��� �������� ���������, �� ��� �� ���������� ��� ������������� 
			--- ������ ��� ��������� �����
			--- ������� �� �������� ����� ������ ��� �������� �������������
			--- �� �������� ��������
			format = obj.valFormats and obj.valFormats[value]
			--LogToChat( item.name.."="..value.." -> "..(format or "NIL") )
			--exObj("obj.valFormats",obj.valFormats)
			--- �������� ������������� ��������
			if obj.valShapes then
				if type(obj.valShapes) == "table" then
					value = obj.valShapes[value] or value
				else
					value = obj.valShapes(item.name,value)
				end
			end
			local len = item.chars or string.len(""..value)
			wtSetPlace( item.wtVal, { sizeX = len*10+10} )
			if item.wtVal.SetMaxSize then item.wtVal:SetMaxSize(len+3) end
		end
	end
	return value, format
end
function menu:setVal(item, toUpdate ) --- update value)
	if not item.wtVal then return end

	local value, format = calcValue(self, item )

	--- ������ ������ ���� ��� - ����� ���� ��� ��������� �������� ������ - � �� ��� ����� ���� ������ ��� �������
	format = format or self.valFormats and self.valFormats[value]
	if format and item.wtVal.SetFormat then
		item.wtVal:SetFormat(ToWS(format))
	end

	--if item.name == "AUTOTARGETlist" then exObj("value", value) end

	if item.menuItems then
		wtSetVal( item.wtVal, "<"..value..">" )
	else
		wtSetVal( item.wtVal, value or "-" )
	end
	if toUpdate then
		--- �������� � ���� ������, ����� ������� ������� ���������
		--- mouse_left_click instead: if item.parent.externalUpdate then item.parent.externalUpdate( item ) end
		if item.externalUpdate then item.externalUpdate( item ) end  --- on change value will call it function
	end

end
function menu:setLabel(w, item )
	wtSetVal( w, item.label )
end
function menu:escEditLine( itemInput )
	local item = itemInput or self.currentEditItem
	if not item then return end

	local w = item.wtVal
	w:Enable(false)
	w:SetFocus(false)
	w:SetGlobalClasses({ "LogColorBlue", "Size14"})
	self:setVal(item)

	self.currentEditItem = nil
end


--- �������� ���� ����� (� ��� ������ � ������ ���� ������) ����� ���������
function menu:enableChilds( on, exclude )
	local onOff
	for _, w in self.wtMenu:GetNamedChildren() do
		onOff = on
		for _, wtExclude in exclude do
			if wtExclude:GetInstanceId() == w:GetInstanceId() then
				onOff = nil
				break
			end
		end
		if onOff ~= nil then w:Enable( onOff ) end
	end
end

-- ������ ������ ��� ��������� ���������/���������
function menu:enableEdited( on, exclude )
	local onOff
	for _, w in self.wtEdited do
		onOff = on
		for _, wtExclude in exclude do
			if wtExclude:GetInstanceId() == w:GetInstanceId() then
				onOff = nil
				break
			end
		end
		if onOff ~= nil then w:Enable( onOff ) end
	end
end

function menu:SetPlace(p)
	wtSetPlace(self.wtMenu, p)
end
function menu:Show(on, instantly)
	if self.showOn == on then return end
	self.showOn = on
	if on == true then
		if self.parentObj then
			-- ���� � ��� ���� �������� �� ������ ��� ��� � ���� �������� �������
			-- ��� ���� ����� � ���� �� ������ ������� ����� ������� ������� ������
			self.parentObj.childsActive = true
			self.parentObj.mouse_overRun = nil
		end
		self:Update()
		self.wtMenu:Show(on)
		if instantly then 
			PlayFade( self, 1.0, 1.0, self.fadeOn )
		else
			PlayFade( self, self.fadeVal, 1.0, self.fadeOn )
		end
	else
		if instantly then
			PlayFade( self, 0.0, 0.0, self.fadeOff )
			menuClose(self)
		else
			PlayFade( self, 1.0, 0.0, self.fadeOff )
		end
	end

end
function menu:IsVisible()
	return self.showOn
end

function menu:ItemFade( item, val )
	val = tonumber(val)
	if val then
		item.fade = val
		for n, w in item.widgets do
			w:SetFade( val )
		end
	end
end

--- ������ ��� ���� �������� ���� ��������� ��� ����� �������
function menu:Update( pars )
	--- ����������� ������
	for i, item in pars or self.strucMenu do
		self:setVal( item )
	end
end

function menu:removeItem(index)
	local item = self.strucMenu[index]
	--- ������ ��� ������� �������� ����
	for k, w in item.widgets do
		w:DestroyWidget()
	end
	--- ������ ������ ��� ������� ����� ��������
	for k, i in self.menuItems do
		if i == index then self.menuItems[k] = nil end
	end
	table.remove(self.strucMenu, index)
end


-------------------------------------------------------------------------------
-- EVENTS
-------------------------------------------------------------------------------
onEvent.EVENT_EFFECT_FINISHED = function( pars )
	local wId = GetInstanceId( pars.wtOwner )
	if not wId then return end

	local obj = selfs[pars.wtOwner:GetInstanceId()]
	if  not obj then return end

	if  not obj.mouse_overRun then return end
	if logOn then LogInfo("EVENT_EFFECT_FINISHED ",obj.name) end

	if obj.showOn then
	else menuClose(obj)
	end
end
--[[object metods not returned ((
local mNew
onEvent.AO_TOOLS_CREATE_MENU = function( pars )
	mNew = menu{}
	exObj("mNew", mNew, true)
	for k, v in pars do
		mNew[k] = v
	end
	userMods.SendEvent( "AO_TOOLS_MENU_CREATED", mNew ) 
end
--]]

-------------------------------------------------------------------------------
-- REACTIONS
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function reactionsOthers( obj, wtReact, react )
--- ��������� ������ ��� ������������ ����
	local wName = wtReact:GetName()
	if wName == "set_btn" then
		local vals = {}
		--exObj("obj.strucMenu", obj.strucMenu )
		for k, v in obj.strucMenu do
			
			if type(v.value) == "table" then
				if v.format then 
					-- ���� ����� - � ������ ���� �������� �������
					vals[v.name] = { value = v.value, format = v.format }
				else
					vals[v.name] = v.value
				end
			elseif v.value then
				local val = v.value ~= "-" and string.lower( v.value )
				val = tonumber(val) or v.listVals and v.listVals[val] --[[ or consts[val] --]] or val
				if v.format then
					--- ���� � ������ ���� ������ �������������
					val = { value = val, format = v.format }
				end
				if obj.list.numberKeys then vals[k] = { [v.name] = val } -- ��� ������ � ������ �� �������� - ���������� �� ������
				else vals[v.name] = val --- ��� ������ �� ������ - ��� ����������
				end
			else
				LogToChat(v.name..L(" has empty value!") )
			end
		end
		--exObj("vals", vals)
		obj.returnVals = vals
		obj:Show(false)
		--- ����� ������� ���������
		--- { name = obj.parentName, value = obj.returnVals )
		if obj.onSet then obj.onSet( obj ) end
	elseif wName == "add_btn" then

		if obj.list.labels then
			--- ��� ���� �������������� �������� - ������� ��
			if obj.addMenu then
				--- ���� ����� ���� ��� �����������
				wtChain( obj.addMenu.wtMenu, wtReact, -10, -30)
				obj.addMenu:Show( true, true )
			else
				---{ list.type = "_txt", list.labels = getAllTypes() }
				local strucMenu = {}
				for k, v in obj.list.labels do
					table.insert( strucMenu, { name = k, label = v, type = "_nil" } )
				end
				local mSel = menu{}
				mSel:init({ 
					name = L("add Item"), strucMenu = strucMenu, priority = obj.priority + 100, alfa = 1, 
					parentObj = obj, --- �������� ��� �������� ����� ������� ���������� �������� - ��� ������ ���� �������������
						recurseCount = obj.recurseCount + 1, --- ������� �������� ��� ������ �������
						mouse_left_click = FUNC_selAddItem, ---- ���� ����������
					})
	
				wtChain( mSel.wtMenu, wtReact, 10, -20)
				obj.addMenu = mSel
				obj.addMenu:Show( true, true )
			end
		else
			--- ��� ��� �������������� �������� - ����� ������� ���� ��� �����
			obj.mouse_overRun_temp = obj.mouse_overRun
			obj.mouse_overRun = false
			obj.addingNewItem = { name = L("{empty}"), label = L("{empty}"), value = obj.list.defaultVal,
				type = obj.list.type, listVals = obj.list.vals }

			table.insert( obj.strucMenu, obj.addingNewItem )
			obj:repaint()
			obj:Update( { obj.addingNewItem } )
			local n = obj.addingNewItem.widgets["mnu_"]
			n:Show(false)
			obj.wtEdited.input:SetPlacementPlain(n:GetPlacementPlain())
			wtSetVal(obj.wtEdited.input, obj.addingNewItem.name )
			obj.wtEdited.input:Show(true)
			obj.wtEdited.input:SetMaxSize( string.len (obj.addingNewItem.name) + 3 )
			obj.wtEdited.input:SetFocus(true)
			obj:enableChilds(false, { obj.wtEdited.input } )
		end
		return --- ����� ����� ����� ����� ��������
	elseif wName == "input_edl" and react == "on_enter" then
		--- ��� ��� ���� ����� - ��������
		local item = obj.addingNewItem
		obj.addingNewItem = nil
		obj.wtEdited.input:Show(false)
		local val = FromWS( obj.wtEdited.input:GetText() )
		item.name, item.label = val, val
		local n = item.widgets["mnu_"]
		obj:setLabel(n, item )
		obj.wtEdited.input:Show(false)
		obj.wtEdited.input:SetFocus(false)
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		n:Show(true)
		obj:enableChilds( true, { obj.wtEdited.input } )
		return --- ����� ����� ����� ����� ��������
	elseif wName == "del_btn" then
		ButtonToggle(obj, wtReact, "[-]", "-?-", FUNC_item_del)
	elseif wName == "move_btn" then
		ButtonToggle(obj, wtReact, "<=>", "?=>", FUNC_item_move)
	end

	if obj.addingNewItem then
		--- ���� ���� �������� ��� ������ ������ ���� ��
		obj.wtEdited.input:Show(false)
		obj.wtEdited.input:SetFocus(false)
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		local index = obj.addingNewItem.index
		obj:removeItem(index)
		obj.addingNewItem = nil
		obj:repaint()
		obj:enableChilds( true, { obj.wtEdited.input } )
	end

end

onReaction.menu_item_over = function( pars )
	local wParent = pars.widget:GetParent()
	local obj = wParent and selfs[wParent:GetInstanceId()]
	if  not obj then return end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = obj.strucMenu[menuItemId]

	if item and item.tip then
		--- � ����� ���� ���� ��������� - �������� ��
		if type( item.tip ) == "function" then
			item.tip( item, tipRun, pars )
		else
			tipRun(pars.widget, item.tip, pars.active, obj.wtMenu:GetPriority() )
		end
	end
end
onReaction.panel_over = function( pars )
	local wParent = pars.widget:GetParent()
	local obj = wParent and selfs[wParent:GetInstanceId()]
	if  not obj then return end

	if "bottomTip_pan" == pars.widget:GetName() then
		tipRun(pars.widget, obj.bottomTip.text, pars.active, obj.wtMenu:GetPriority() )
	end
end

onReaction.menu_over = function( pars )
	local obj = selfs[pars.widget:GetInstanceId()]
	if  not obj or not obj.mouse_overRun then return end

	if logOn then LogInfo("menu_over ",obj.name) end
	obj:Show(pars.active)
end

onReaction.mouse_over = function( pars )
	local wt = pars.widget
	--LogToChat(wt:GetName())
	local obj = selfs[wt:GetInstanceId()]
	if obj then
		onReaction.menu_over( pars )
	else
		local parent = wt:GetParent()
		obj = selfs[parent:GetInstanceId()]
		if obj then
			onReaction.menu_item_over( pars )
		else
			onReaction.panel_over( pars )
		end

	end

end


onReaction.on_esc = function( pars )
	local obj = selfs[pars.widget:GetParent():GetInstanceId()]
	if  not obj then return end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = obj.strucMenu[menuItemId]

	if not item then
		--- ������ ��� ����� ������ � �����-��������
		reactionsOthers( obj, pars.widget, "on_esc" )
		return
	end

	obj:escEditLine(item)

end

onReaction.on_enter = function( pars )
	local obj = selfs[pars.widget:GetParent():GetInstanceId()]
	if  not obj then return end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = obj.strucMenu[menuItemId]

	if not item then
		--- ������ ��� ����� ������ � �����-��������
		reactionsOthers( obj, pars.widget, "on_enter" )
		return
	end

	obj.currentEditItem = nil

	pars.widget:Enable(false)
	pars.widget:SetFocus(false)
	pars.widget:SetGlobalClasses({ "LogColorBlue", "Size14"})

	--- ����� ������� ���������
	--- ��� ���� ���� ������� ��� �� �������� �����������
	item.value = FromWS(pars.widget:GetText())
	obj:setVal(item, true) --- update value

	if obj.on_enter then obj.on_enter( item )
	elseif obj.mouse_left_click then obj.mouse_left_click( item ) --, obj)
	end

end

onReaction.mouse_left_click = function( pars )

	local obj = selfs[pars.widget:GetParent():GetInstanceId()]
	if not obj then return end

	if logOn then LogInfo(obj.name, "mouse_left_click ",pars.widget:GetName() ) end

	if obj.currentEditItem then
		--- ���� ��� ���� - ������� ���
		obj:escEditLine()
	end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = menuItemId and obj.strucMenu[menuItemId]
	if not item then
		--- ������ ��� ����� ������ � �����-��������
		reactionsOthers( obj, pars.widget, "mouse_left_click" )
		return
	end

	if obj.mouse_left_click_instead then
		--- ���� ������� ������� ��� �� ���� � ������ ����� ������ ������� �� ����
		obj.mouse_left_click_instead( item ) --, obj)
		return
	end

	if false then
	elseif item.type == "_edl" then
		item.wtVal:Enable(true)
		item.wtVal:SetGlobalClasses({"LogColorGold", "Size20"})
		obj.currentEditItem = item
		item.wtVal:SetFocus(true)
		local value = item.value
		if type(value) == "function" then value = value(item)
		elseif type(value) == "table" then value = value[item.name]
		end
		if value == nil then value = "-" end
		local len = string.len("  "..value)
		wtSetPlace( item.wtVal, { sizeX = len*11+15} )
		return --- ������ ������� ���������
	elseif item.type == "_txt" and item.listVals then
		--- ��� ����� ������ ��������
		--- ��� ���� ����� ��������� �� ������ ��� ������
		local vals = item.listVals
		local i
		for k, v in vals do
			if v == item.value then i = k + 1 break end
		end
		item.value = vals[i] or vals[1] --- ������� ��������� �������� �� ������ ��� ������ -- ����� �� ��������� �� ���="-"
		obj:setVal( item, true ) --- update value
	elseif item.menuItems or item.type == "_lst" then
		local mV
		--LogInfo(" list in ",item.menuItems)
		if item.menuItems then
			--- ��� ������ ������ ��� ������ �������� �� ������
			local strucMenu = {}
			if item.list and item.list.numberKeys then
				for i, name in item.menuItems do
					strucMenu[i] = { name = name, label = name, type = item.value == name and "_txt" or "_nil", value = item.value == name and "<--" or nil}
				end
			else
				for name in item.menuItems do
					table.insert( strucMenu, { name = name, label = name, type = item.value == name and "_txt" or "_nil", value = item.value == name and "<--" or nil} )
				end
				table.sort( strucMenu, function( A, B ) return A.name < B.name end )
			end
			mV = menu{ strucMenu = strucMenu,
				mouse_left_click = FUNC_SelMenu,
				}
		else
			--- ��� ������� ������ � item.data = ...
			local value = item.value or item.data
			--LogInfo(" list as DATA ", value)
			if type(value) == "function" then value = value(item) end
			mV = menuVals({
					onSet = FUNC_onSetList,
					data = value,
					list = item.list or item.parent.list.list,
					--mouse_left_click = item.list.mouse_left_click,
					})
		end
		--exObj( "mV", mV )
		--exObj( "obj.valShapes", obj.valShapes )
		--exObj( "item.valFormats", item.valFormats )

		mV:init({ priority = obj.wtMenu:GetPriority() + 100, alfa = 1, 
			parentObj = obj, --- �������� ��� �������� ����� ������� ���������� �������� - ��� ������ ���� �������������
			parentItem = item, --- � �������� ��� ������ ��������� ��������� �����
			recurseCount = obj.recurseCount or 0 + 1, --- ������� �������� ��� ������ �������
			name = item.label, 
			mouse_overRun = true,
			valFormats = item.valFormats,
			RowsColsRate = 10,
			fadeOn = 200, fadeOff = 300,
			valShapes = obj.valShapes, --- ��������� ������� ������������� ��� ��������
			})
 		wtChain( mV.wtMenu, item.wtVal or item.widgets["mnu_"], -30, -40)
		mV:Show( true, true )
		return
	end

	--- ����� ������� ���������
	if obj.mouse_left_click then
		obj.mouse_left_click( item, pars )
	end
end

onReaction.mouse_right_click = function( pars )

	local obj = selfs[pars.widget:GetParent():GetInstanceId()]
	if not obj then return end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = menuItemId and obj.strucMenu[menuItemId]
	if not item then
		return
	end

	--- ����� ������� ���������
	if obj.mouse_right_click then
		obj.mouse_right_click( item, pars )
	end
end
onReaction.mouse_double_click = function( pars )

	local obj = selfs[pars.widget:GetParent():GetInstanceId()]
	if not obj then return end

	local menuItemId = obj.menuItems[pars.widget:GetInstanceId()]
	local item = menuItemId and obj.strucMenu[menuItemId]
	if not item then
		return
	end

	--- ����� ������� ���������
	if obj.mouse_double_click then
		obj.mouse_double_click( item, pars )
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
function menu:repaint()
	self:init(nil, true) -- ��� ������ ���� ��� ������� �� ������ ���������� ��� ������� ���� ���
end
function menu:destroy()
	selfs[self.id] = nil --- ������ ����� �� ������
	self.wtMenu:DestroyWidget() --- ��������� ������ �� ��������
end

---function menu:makeWidgets(self)
function menu:init(pars, repaint)

	if pars then
		for k, v in pars do
			self[k] = v
		end
	end
	self.alfa = self.alfa or 0.8 --- transparency
	self.posX = self.posX or 0
	self.posY = self.posY or 0
	self.itemSizeX = self.itemSizeX or 250
	self.itemSizeY = self.itemSizeY or 20
	self.alignX = self.alignX or 0
	self.alignY = self.alignY or 0
	self.name = self.name or ""
	self.rows = self.rows or 20
	self.priority = self.priority or 500
	self.fadeOn = self.fadeOn or 500
	self.fadeOff = self.fadeOff or 1000
	self.fadeVal = self.fadeVal or 0.7 --- ��������� ������ ��� ����������� �������
	if not repaint then self.menuItems = {} end

	---------------------------------------------
	-------- ������������ �������� ����������
	---------------------------------------------
	local w, n, i, v, d, x, y, sz, str, len, tpe, ddx, name, itemNameStore
	--- ��������
	
	name = "menu_"..self.name
	w = repaint and self.wtMenu --- ����� �� ��� ������� ������� mainForm:GetChildUnchecked(name, false )
	if not w then
		w = mainForm:CreateWidgetByDesc( dsc.Menu ) w:SetName( name )
		self.id = w:GetInstanceId()
		--- �������� ������ ��� ������ ��� � ��������
		selfs[self.id] = self
		wtSetPlace( w, { posX = self.posX, posY = self.posY, alignX = self.alignX, alignY = self.alignY } )
		w:SetPriority(self.priority)
		self.wtMenu = w
		self.showOn = false

		--- ������� ������������
		n = w:GetBackgroundColor()
		n.a = self.alfa
		w:SetBackgroundColor(n)
		n = mainForm:CreateWidgetByDesc( dsc.Text ) n:SetName( "Header" )
		n:SetFormat(ToWS("<html alignx='left' fontsize='14'><tip_golden><r name='value'/></tip_golden></html>"))
		wtSetPlace( n, { highPosX=15, posY = -2, alignX = 1, alignY = 0, sizeX = string.len(self.name)*10+10, sizeY=20 } )
		n:SetVal("value", ToWS(self.name) )
		w:AddChild(n) n:Show(true)
	else
		w = self.wtMenu
	end

	--- ��������� ����
	local tLen = table.getn(self.strucMenu)
	self.rows, self.cols = tuneRowsCols(tLen, self.rows, self.cols)
	if self.RowsColsRate and self.rows / self.cols < self.RowsColsRate then
		self.rows = math.ceil( (tLen * self.RowsColsRate)^0.5 ) + 1
		self.rows, self.cols = tuneRowsCols(tLen, self.rows, self.cols)
	end

	ddx = 20
	i = 0
	local offset
	for c = 1, self.cols do
	for r = 1, self.rows do
		i = i + 1
		local item = self.strucMenu[i]
		if not item then break end
		if not item.widgets then item.widgets = {} end
		item.index = i
		item.parent = self
		offset = item.offset or 0
		offset = type(offset) == "function" and offset(item) or offset
		x = (c-1)*self.itemSizeX + ddx + offset
		y = (r-1)*self.itemSizeY + 20
		if item.token then
			--- ���� ��� �����������
			name = item.token.."_txt"
			itemNameStore = "tkn_"
			n = item.widgets[itemNameStore]
			if not n then
				n = mainForm:CreateWidgetByDesc( dsc.Text ) n:SetName( name )
				item.widgets[itemNameStore] = n --- �������� ������� ��� ����� �������� ���� - ���� ����� �� �������������
				if item.format then n:SetFormat(ToWS(item.format))
				else n:SetFormat(ToWS("<html alignx='center' fontsize='14'><tip_golden><r name='value'/></tip_golden></html>"))
				end
				if tonumber(item.fade) then n:SetFade ( tonumber(item.fade) ) end
				wtSetVal(n, item.label )
				sz = self.itemSizeX - 2*ddx - offset ---- string.len(item.label)*9+25
				wtSetPlace( n, { sizeX = sz, sizeY = self.itemSizeY } )
				w:AddChild(n) n:Show(true)
			end
			wtSetPlace( n, { posX = x, posY = y, alignX = 0, alignY = 0 } )
		else
			name = item.name.."_mnu"
			itemNameStore = "mnu_"
			n = item.widgets[itemNameStore]
			if not n then
				n = mainForm:CreateWidgetByDesc( dsc.MenuItemBtn ) n:SetName( name )
				item.widgets[itemNameStore] = n --- �������� ������� ��� ����� �������� ���� - ���� ����� �� �������������
				--- � ������ ��� ����� ������ if item.format then n:SetFormat(ToWS(item.format)) end
				menu:setLabel(n, item )
				sz = self.itemSizeX - 2*ddx - offset ---- string.len(item.label)*9+25
				wtSetPlace( n, { sizeX = sz, sizeY = self.itemSizeY } )
				if tonumber(item.fade) then n:SetFade ( tonumber(item.fade) ) end
				w:AddChild(n) n:Show(true)
				if false and item.icon then
					local wtIcon = WCD( dsc.Panel, "icon", n, { alignX = 0, alignY = 2, sizeX = 20, sizeY = 20}, true )
					wtIcon:SetBackgroundTexture( item.icon )
				end

			end
			self.menuItems[n:GetInstanceId()] = i --- ������ ��� �������� - ������ ����������
			wtSetPlace( n, { posX = x, posY = y, alignX = 0, alignY = 0 } )

			--- ���� � ����� ���� ���� �������� �� �������� ��� ��� ����
			local enableEdit = false
			d = nil
			if item.type == "_chk" then
				d = dsc.Check
			elseif item.type == "_edl" then
				d = dsc.EditLine
				enableEdit = true
			elseif item.type == "_txt" or item.type == "_lst" --[[or item.type == "_mnu" --]] then
				---- ������� ��������� ��������
				d = dsc.Text
			end
			if d then
				name = item.name.."_val"..item.type
				itemNameStore = "val_"
				v = item.widgets[itemNameStore]
				if not v then
					v = mainForm:CreateWidgetByDesc( d ) v:SetName( name )
					item.widgets[itemNameStore] = v --- �������� ������� ��� ����� �������� ���� - ���� ����� �� �������������
					item.wtVal = v --- �������� ������ � ������� ������������ ��������
					wtSetPlace( v, { sizeX = 60, sizeY=self.itemSizeY } )
					if v.SetFormat then v:SetFormat(ToWS("<html alignx='right' fontsize='12'><r name='value'/></html>")) end
					---if v.
					if v.SetGlobalClasses then v:SetGlobalClasses({ "LogColorBlue", "Size14"}) end
					if v.SetMaxSize and item.chars then
						v:SetMaxSize(item.chars)
						wtSetPlace( v, { sizeX = item.chars*10+5 } )
					end
					if tonumber(item.fade) then v:SetFade ( tonumber(item.fade) ) end

					---if v.GetInitialGlobalClass then exObj("cc",v:GetInitialGlobalClass(),true) end
					v:Show(true)  v:Enable( enableEdit )
					v:SetPriority( 100 )
					w:AddChild(v)
				end
				self.menuItems[v:GetInstanceId()] = i --- ������ ��� �������� - ������ ����������
				wtSetPlace( v, { highPosX = (self.cols-c)*self.itemSizeX + 15, posY = y, alignX = 1, alignY = 0 } )
			else
			end
		end
	end
	end

	if self.bottomTip then
		n = mainForm:CreateWidgetByDesc( dsc.PanelReact ) n:SetName("bottomTip_pan")
		str = self.bottomTip.label
		len = string.len(str)
		wtSetPlace( n, { highPosX=15, highPosY = -2, alignX = 1, alignY = 1, sizeX =10*len+10, sizeY=20 } )
		w:AddChild(n)
		n:Show( true )
		v = mainForm:CreateWidgetByDesc( dsc.Text ) v:SetName("bottomTip_txt")
		n:AddChild(v)
		wtSetPlace( v, { alignX = 3, alignY = 3 } )
		v:Show( true )
		v:SetVal("value", ToWS( str ))
	end

	local szX, szY = self.itemSizeX * self.cols, self.itemSizeY * self.rows + 40 + (self.sizeYbottom or 0 )
	self.wtSize = { sizeX = szX, sizeY = szY }
	wtSetPlace( self.wtMenu, self.wtSize )

end

------------------------------ ���������� ������ ------------------------------
------------------------------ ������������� ������ �������� ------------------
Class( "menuVals", {
})
function menuVals:init(pars, repaint)
--[[		mPars = menu{ strucMenu = strucMenu, priority = 8000, fadeOff = 500 }
		local p = wtSetPanel:GetPlacementPlain()
		mPars.mouse_left_click = FUNC_mPars_click
		mPars:init({ alfa = 1, name = LabelType[key], rows = 20, posX = p.posX - 0, posY = p.posY - 0, valFormats = valFormats })
		mPars:Show(true)
--]]

	if not repaint then
		if pars then
			for k, v in pars do
				self[k] = v
			end
		end
		self.itemSizeX = self.itemSizeX or (self.list.edited and 250 or 100) --- ��� ��� ��� ������ �� ������� �����������
		
		local strucMenu, i, len = {}, 0, 0
		for k, v in self.data do
			i = i + 1
			if self.list.numberKeys then
				--- ������������� � ��� ��� �� ������ ����� �������� ������������ - � ��������� �������� ��� ����� �����-�����
				local name, val = next (v)
				strucMenu[i] = { name = name, label = self.list.labels and self.list.labels[name] or name,
					value = val, ---makeItemValue(val), --- ���� ��� - �� ������� � ����������� ��������, 
					type = self.list.type, listVals = self.list.vals }
			else
				--exObj(k,v)
				if type(v) == "table" and v.format then
					--- ����� �������� ��� ������ ����� ���� ��������� ������� ����  � ������ ����� ������
					strucMenu[i] = { name = k,
						label = self.list.labels and self.list.labels[ k ] or v.format.label or k,
						value = v.value, ---makeItemValue(v),
						type = v.format.type or self.list.type, 
						listVals = v.format.listVals or self.list.vals or self.list.listVals,
						defaultVal = v.format.defaultVal or self.list.defaultVal,
						tip = v.format.tip,
						format = v.format
						}

				else
					--- ������
					strucMenu[i] = { name = k,
						label = self.list.labels and self.list.labels[ k ] or k,
						value = v, ---makeItemValue(v),
						type = self.list.type, listVals = self.list.vals }
					end
			end
			local valiTxt = strucMenu[i].value
			valiTxt = type(valiTxt) == "table" and "{table}" or valiTxt
			local ll = string.len ( strucMenu[i].label )
			ll = ll< 6 and 6 or ll
			ll = ll + 10 + string.len ( self.list.vals and self.list.vals[valiTxt] or valiTxt )
			if ll < 13 then ll = 13 end
			if len < ll then len = ll end
		end

		if not self.list.numberKeys then
			table.sort( strucMenu, function( A, B ) return A.name < B.name end )
		end


		local itemSizeX = len*8 + 40
		if itemSizeX > self.itemSizeX then self.itemSizeX = itemSizeX end

		self.classParent = menu{ strucMenu = strucMenu, itemSizeX = self.itemSizeX, sizeYbottom = 20 }
		self.classParent:init(pars, repaint)
		--- ���������� ��� �� �������� ������
		local metaParent = menu
		local metaSelf = menuVals
		for k, v in metaParent do
			if not metaSelf[k] then metaSelf[k] = v end
		end
		--- ������ ��������
		for k, v in self.classParent do
			if not self[k] then self[k] = v end
		end
		--- �������� � ���� �������� �� ���� (�� �������)
		selfs[self.classParent.id] = self
		--- � ��� ���� ������� ���� �������� �������� �� ����
		--- ����� ������ � �������� obj=item.parent ����� �� ���� ������ ���
		for k, v in self.classParent.strucMenu do
			v.parent = self
		end
		

		local w

		if not self.list.sel_on_click then
			w = mainForm:CreateWidgetByDesc( dsc.Button ) w:SetName( "set_btn" )
			wtSetVal(w,"[=]")
			wtSetPlace( w, { posX = 0, highPosX = 20, posY = 0, highPosY = 3, alignX = 1, alignY = 1, sizeX = 30, sizeY=25 } )
			self.classParent.wtMenu:AddChild(w) 	w:Show(true)
		else
		end

		if self.list.edited then
			self.wtEdited = {}
			--- ���� ��������� ��������� ������ ������
			w = mainForm:CreateWidgetByDesc( dsc.Button ) w:SetName( "add_btn" )
			wtSetVal(w,"[+]")
			wtSetPlace( w, { posX = 30, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 30, sizeY=25 } )
			self.classParent.wtMenu:AddChild(w) 	w:Show(true)
			self.wtEdited.add = w

			w = mainForm:CreateWidgetByDesc( dsc.ToggleButton ) w:SetName( "del_btn" )
			wtSetVal(w,"[-]")
			wtSetPlace( w, { posX = 70, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 40, sizeY=25 } )
			self.classParent.wtMenu:AddChild(w) 	w:Show(true)
			self.wtEdited.del = w

			w = mainForm:CreateWidgetByDesc( dsc.ToggleButton ) w:SetName( "move_btn" )
			wtSetVal(w,"[<=>]")
			wtSetPlace( w, { posX = 120, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 40, sizeY=25 } )
			self.classParent.wtMenu:AddChild(w) 	w:Show(true)
			self.wtEdited.move = w

			w = mainForm:CreateWidgetByDesc( dsc.EditLine ) w:SetName( "input_edl" )
			self.classParent.wtMenu:AddChild(w) --- ���� ��� ������� 	w:Show(true)
			w:SetPriority(400)
			self.wtEdited.input = w
		end
		self.mouse_left_click = self.list.mouse_left_click

	else
		for k, v in self do
			self.classParent[k] = v
		end
		self.classParent.classParent = nil
		self.classParent.parentObj = nil
		self.classParent:init( nil, repaint)
		--- ������ �������� �������� ���� �������� �� ����
		for k, v in self.classParent do
			self[k] = v
		end
	end

end

------------------------------------------------------------------------------

-- register events
RegisterEventHandlers( onEvent )
-- register reactions
RegisterReactionHandlers( onReaction )
