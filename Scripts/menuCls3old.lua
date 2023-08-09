
--- author icreator
--- UPDATED: 2011.09.27

--[[
	menu.place

.type =
"_cmd" -command. value not used

"_txt" -text value
"_edl" -edit line
"_lst" -list of values
	.menu = {} -- all val recopy to new menu
	list.sel_on_click

"_clr" -color set = {a=,b=,g=,r=}
"_icn" -icon. 
	valGet = nil or function or table --->To get Texture by name in value. for example:
	valGet = TexturesStoreTable --- = table { [name1] - texture1,...}
	or
	valGet = GetTextureByName --- = function(name) return ... end
	default:
	valGet = nil  ---> texture = common.GetAddonRelatedTexture(item.value)


заначение поля хранится в:
	.value
получить данные - при начальном создании меню или когда делается показ меню - Update():
	.valGet = function(item) or table[item.name]
	- результат будет записан в .value
при изменении данных пользователем:
	.valOnSet = function(item)
функция вызываемая после изменения данных в меню ( после нажатия на пункт меню)
	.onSet = function(item)

для показа значения в поле меню:
1. изменение значениея до форматирования - наклейки для значений
	.valLabels = function(item) or table[item.name]
	- результат запишется в локальную
	VAL = 
2. выбираем формат для показа данных по VAL для SetFormat():
	.valFormats = table[VAL]
3. изменяем занчениие еще раз (Обычно это для локализации нужно):
	.valShapes = function(VAL) or table[VAL]
	- результат выводится в поле по :SetVal()

для ярлыков пунктов меню:
	.label - тектовое значение
прямо в имя кнопки можно писать <html> например так:
label = "<html fontname='AllodsSystem' fontsize='24' alignx='right' shadow='2'><tip_green>HGJH</tip_green></html>"
		--- формат действует только на ТОКЕНЫ - кнопкам нельзя формат присвоить (
	.labelFormat  - <html format> = "<html fontname='AllodsWest' fontsize='14' shadow='1'><tip_blue><r name='text'/></tip_blue></html>"
	.labelShapes = function(label) or table[label]
	- меняет ярлык - обычно для локализации

каждая кнопка стектурой
	item.item_texture = common.GetAddonRelatedTexture("FrameRed") 104x104
	item.item_color = common.GetAddonRelatedTexture("FrameRed")
	item.item_desc = widget:GetWidgetDesc() --- описатель кнопки

	item.button_texture = common.GetAddonRelatedTexture("FrameRed") 104x104
	item.button_color = common.GetAddonRelatedTexture("FrameRed")
	item.button_desc = widget:GetWidgetDesc() --- описатель кнопки

	menu.texture
	menu.color
	menu.desc - описатель панели меню
	menu.head_desc - описатель заголовка меню

self.wtMenu - панель самого меню можно его тоже перерисовать как угодно - текстуры подставить

если у поля нет своей функции то она берется общая из самого меню:
	if item.valGet then
	elseif item.parent.valGet then
	end
	if item.labelShapes then
	elseif item.parent.labelShapes then
	end

если это пункт без значений - как оманда то функция по клику хранится в:
	.onClick = function( item )

	--- порядок вызова внешних функций при нажатии на пункт меню / изменении данных 
	local onClick = item.onClick or item.valOnSet or obj.valOnSet or obj.onClick
	if onClick then onClick( item, pars ) end

METODS

menu:setVal(item)

menu:setLabel( item, w )

menu:escEditLine( itemInput )

--- погасить всех детей (в том читсле и пункты меню самого) кроме указанных
menu:enableChilds( on, exclude )

-- только кнопки для изменения запрещает/разрешает
menu:enableEdited( on, exclude )

menu:SetPlace(p)
menu:Enable(on)
menu:Show(on, instantly)
menu:IsVisible()
menu:ItemFade( item, val )

menu:Update( pars ) --- pars = list of items or nil 

menu:removeItem(index)
menu:insertItem( item, pos )

menu:repaint()
menu:destroy()

menu:init(pars)


	item.wtItemPan - контейнер для иконки, кнопки и значения пункта меню (ну и токен тудаже)

]]

--- тут дети-меню сами показываю/гасят своих родителей
--- через параметр  parentObj
--- параметры item.value item.offset -  могут быть функциями для автоматического обновления при menu:Update()

---- класс для всех менюшек - тут не должно быть вызовов к внешним данным чтобы она была независимая
--- value = "-" - это nil - эго надо во вне правильно присвоить: setPS(name, nil)
local o, logOn --- включает вывод в лог 

 --- хранит ссылки на объекты, для обработки их в реакциях виджетов на мышку и клавиатуру
local selfs = { } -- [ids] = { obj=.., item=.., misc=.. }
Class( "menu", {} )
--[[
nemu = {
---wtMenu,
---menuItems,
---showOn,
	strucMenu = { menuItems ...},
	valFormats = formats for :SetFormat()
	valShapes = function( item.name, item, value ) or table [item,value] - for make shape for SetVal() (( таблица или функция для представлений значений ))
}
]]


--[[ SCHEME:
strucMenu = {
	{ token ="_0", label = L("*** MAIN SETTINGS ***") },
	{ name ="itemName", label = L("Item Label"), type = "_txt", listVals =onoff, chars = 10, offset = 20, valFormats},
	{ name ="itemName", label = L("Item Label"), type ="_lst", 
			list = { type = "_txt", labels = getAllTypes(), vals = sortVals,
				edited = true, --- можно редактировать список
				numberKeys = true, --- список состоит из нумерованных списков - очередность элементов влияет на результаты и их можно менять местами
				},
			offset = 15 },
	{ name ="myTargMarkName", label = L("MTM Name"), type ="_edl", offset = 15 },
}
--]]


--- обработчики прерываний - одно на весь класс
local onEvent = {}
local onReaction = {}

local excludeList = { parentObj = true, parentItem = true, parent = true } --- cancel recursion for indexes
function menu.GetExludeList()
	return excludeList
end

local dsc = {}
local wTip, wTipTxt
local tipFormat = ToWS("<html alignx='left' aligny='middle' fontname='AllodsWest' fontsize='14' shadow='1'><log_dark_white><r name='value'/></log_dark_white></html>")

-----------------------------------------------------------------

----------------- COLOR PANEL ------------------------------
local externatWidgetRun
local wtColorPanel
local ColorSliders
local CusCol
local CURRENT_ITEM
-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------
local function colorToSlidePos( v )
	local r = math.floor((1 - v) * 256)
	if r > 256 then r = 256 end
	if r < 0 then r = 0 end
	return r
end
local function setColorSliders( v )
	local p = v and type( v ) == "table" and v or { r=1;g=1;b=1;a=1 }
	ColorSliders[0]:SetPos( colorToSlidePos( p.r ) )
	ColorSliders[1]:SetPos( colorToSlidePos( p.g ) )
	ColorSliders[2]:SetPos( colorToSlidePos( p.b ) )
	ColorSliders[3]:SetPos( colorToSlidePos( p.a ) )
	CusCol = p
	wtColorPanel:SetBackgroundColor(p)
end

onReaction["CS_Changed"] = function ( r )
	local red = ColorSliders[0]:GetPos()
	local green = ColorSliders[1]:GetPos()
	local blue = ColorSliders[2]:GetPos()
	local alpha = ColorSliders[3]:GetPos()
	CusCol = wtColorPanel:GetBackgroundColor()
	CusCol.r = 1 - red / 256
	CusCol.b = 1 - blue / 256
	CusCol.g = 1 - green / 256
	CusCol.a = 1 - alpha / 256
	wtColorPanel:SetBackgroundColor(CusCol)
	local cw = CusCol.r + CusCol.g + CusCol.b
	if cw > 1.5 then
		ColorSliders[3]:SetBackgroundColor({r=0.2;g=0.2;b=0.2;a=1})
	else
		ColorSliders[3]:SetBackgroundColor({r=0.8;g=0.8;b=0.8;a=1})
	end

end

local function ColorPanelClose( escape )
	wtColorPanel:Show( false )
	local item = CURRENT_ITEM
	local obj = item.parent
	if not escape then
		item.value = CusCol
		obj:setVal(item)
	end
	obj:Enable( true )
	obj.mouse_overRun = obj.mouse_overRun_temp
	return obj, item
end

local function extendedMenuReactions( pars )
	local name, obj, item = pars.widget:GetName()
	externatWidgetRun = nil --- прекратим отслеживание реакций
	if name == "ColorPanel_btn" then
		obj, item = ColorPanelClose()
	else
		--- еще мы не закончили работу с внешним виджетом
		externatWidgetRun = true
	end

	return obj, item --- нужно для вызова внешней процедуры valOnSet
end

local function ColorPanelOpen( obj, item, wtBase )
	externatWidgetRun = true --- показывает что мы запустили внешний виджет так что с него отлавливать будем реакцию
	obj:Enable( false )
	obj.mouse_overRun_temp = obj.mouse_overRun
	obj.mouse_overRun = false
	CURRENT_ITEM = item
--	selfs[wtColorPanel:GetInstanceId()] = { obj = obj, misc = w } --- запомним объект для вызова его в событиях

	--LogInfo("open CURRENT_ITEM",CURRENT_ITEM)

	setColorSliders(item.value)

	wtChain( wtColorPanel, wtBase, 10, -50)

	wtColorPanel:SetPriority( obj.wtMenu:GetPriority() + 10 )
	wtColorPanel:Show( true )
end

local function ColorPanelInit()
	if wtColorPanel then return end
	--- если еше не было иницализации панели для цвета - создадим

	wtColorPanel = WCD(dsc.ColorPanel,"ColorPanel",nil, nil, false)
	ColorSliders = {}
	CusCol = {r=1;g=1;b=1;a=1}

	local wt
	for i = 0, 3 do
		wt = WCD( dsc.ColorSliderPanel, nil, wtColorPanel, { posX = 32 * i }, true )
		ColorSliders[i] = wt:GetChildChecked("ColorSlider", false)
	end
	ColorSliders[0]:SetBackgroundColor({r=1;g=0;b=0;a=0.7})
	ColorSliders[1]:SetBackgroundColor({r=0;g=1;b=0;a=0.7})
	ColorSliders[2]:SetBackgroundColor({r=0;g=0;b=1;a=0.7})
	ColorSliders[3]:SetBackgroundColor({r=0.6;g=0.6;b=0.6;a=1})
	wtSetPlace(wtColorPanel, { sizeY = 300 } )
	wt = WCD(dsc.Button, "ColorPanel_btn", wtColorPanel, { alignY = 1, alignX = 2, sizeX = 120 }, true )
	wtSetVal(wt, L("Select") )
	
end

function menuDscInit( wAddonsTools )
	--- сздадим описания из виджетов
	local name = {}
	for _, w in wAddonsTools:GetNamedChildren() do
		name = w:GetName()
		if string.sub(name,1,3) == "dsc" then
			dsc[string.sub(name,4)] = w:GetWidgetDesc()
			if name == "dscTextContainer" or name == "dscContainer" then
				--- dscTextContainer - он сразу видимый ибо иначе он будет не рабочим
				--- поэтому тут его надо выключить
				w:Show( false )
			end
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


local function getValsFromSelfs( wt )
	local ids = wt:GetInstanceId()
	local val = selfs[ids]
	if not val then return end
	return ids, val.obj, val.item, val.misc
end

--- либо функция либо массив
local function callFuncTab_0(item, func, pars)
	--LogInfo("callFuncTab_0 ", item.name, " func:", func, " pars:", pars)
	local noPars = pars == nil and item == nil
	if type(func) == "function" then return func(pars == nil and item or pars)
	elseif type(func) == "table" then return noPars and func or func[pars == nil and item.name or pars]
	end
end
--- либо берет функцию у пункта меню либо общую от всего меню
local function callFuncTab(obj, item, funcName, pars )
	if item[funcName] then
		return callFuncTab_0( item, item[funcName], pars )
	elseif obj[funcName] then
		return callFuncTab_0( item, obj[funcName], pars )
	end
end
	--- вызов внешней процедуры
local function onClick( obj, item, pars )
	
	local f
	if item.value == nil then
		--- тут пункт меню
		f = item.onClick or obj.onClick
	else
		--- тут было какое-то значение изменено
		f = item.valOnSet or obj.valOnSet
	end
	if f then f( item, pars ) end
end

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
			len = tip.len or 0 --- Добавочная длина в формате могут быть символы
			for _, v in tipTxt do
				len = len + string.len(v)
			end
			--- тут много парметров с форматом
			wTipTxt:SetFormat(ToWS(tip.format))
			for r, v in tipTxt do
				wTipTxt:SetVal(r,ToWS(v))
			end
		else
			wTipTxt:SetFormat( tipFormat )
			tipTxt = tip
			len = string.len(tipTxt)
			--- одиночная строка без формата
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
		--- запретис гашение по выходу
		LogToChat("del_btn in ButtToggle for "..obj.wtMenu:GetName())

		obj.mouse_overRun_temp = obj.mouse_overRun
		obj.mouse_overRun = false
		--- запретим прочие действия тут
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

local function tuneRowsCols(Len,R,C, sizeX, sizeY)
	local x,y = getScreenSizeCenter()
	local sX, sY = sizeX, sizeY
	local rate = x/y / (sX/sY)
	if C then 
		R = math.ceil( Len / C )
	elseif R then
		C = math.ceil ( Len / R )
	else
		R = math.ceil( math.sqrt( Len / rate ) )
		C = math.ceil( math.sqrt( Len * rate ) )
	end
	if C <= 0 then C = 1 end
	R = math.ceil ( Len / C )
	if R <= 0 then R = 1 end
	return R, C
	
end

local function menuClose( obj )
	obj.showOn = false
	obj.wtMenu:Show( false )
	if obj.parentObj then
		--- скажем родителю что ребенка закрыли
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
		onEvent.EVENT_EFFECT_FINISHED( { wtOwner = obj.wtMenu } )
	else
		obj.wtMenu:PlayFadeEffect( obj.wtMenu:GetFade(), fadeTo, time2, EA_MONOTONOUS_INCREASE )
	end
	--- отразим наше затемнение на родителе
	local parentObj = obj.parentObj
	if parentObj and not obj.childsActive then
		--- если есть родитель и у текущего объекта нет детей не закрытых то меняем гашение родителя
		if toShow then
			PlayFade(parentObj, parentObj.wtMenu:GetFade(), parentObj.fadeVal, parentObj.fadeOff)
		else
			PlayFade(parentObj, parentObj.wtMenu:GetFade(), 1, parentObj.fadeOn)
		end
	end
end

local function FUNC_SelMenu( item )
	--- обработка нажатия в обычном меню вызваном из списка
	local obj = item.parent
	obj:Show(false)
	obj.parentItem.value = item.name --- обновим данные в меню-родителе
	obj.parentObj:setVal(obj.parentItem )
	if obj.recurseCount == 1 then
		---obj.parentObj.mouse_left_click( obj.parentItem ) --, obj.parentObj )
		onClick( obj.parentObj, obj.parentItem )
	end
end

--- обработка возврата из редактирования списков значений
--- там может быть рекурсия - самый первый - в параметры закатать
local function FUNC_onSetList( obj )
	if obj.recurseCount == 1 then
		--- тут присвоить параметру - высший уровень
		obj.parentItem.value = obj.returnVals --- обновим данные в меню-родителе
		--obj.parentObj.mouse_left_click( obj.parentItem ) --, obj.parentObj )
		onClick( obj.parentObj, obj.parentItem )

	else
		--- тут присвоить элементу списка текущего
		obj.parentItem.value = obj.returnVals
	end
end

--- тут надо этот итем дабавить в структуру текущего
local function FUNC_selAddItem( item )
	local objChild = item.parent
	local obj = objChild.parentObj
	local newItem = { name = item.name, label = item.label, type = obj.list.type, 
		value = obj.list.defaultVal, valLabels = obj.list.valLabels, listVals = obj.list.vals }
	table.insert( obj.strucMenu, newItem )
	objChild:Show(false,true)
	obj:repaint()
	obj:Update( { newItem } )
end

local function FUNC_item_del( item ) --, obj )
	LogToChat("FUNC_item_del: ".. item.name)
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
--[[function menu:getVal(item)
	return item.wtVal and wtGetVal( item.wtVal )
end
]]

-- вычислим значение для отображения в поле пункта меню
local function calcValue(obj, item)

	local value, format = item.value

	if type(value) == "table" then return "{table}" end
	--- получим новое значение - если заданы метки для значений
	value = callFuncTab(obj, item, "valLabels", value ) or value

	--- на выходе может быть false
	if value == nil then value = item.defaultVal or obj.defaultVal end
	if value == nil then return "-" end

	if item.type == "_txt" or item.type == "_edl" --[[or item.type == "_mnu" --]] then
		--- итак тут значение вычислено, но еще не обработано как представление 
		--- поэтому тут поробуем взять формат для будущего представления
		--- по текущему значению
		format = callFuncTab( obj, item, "valFormats", value )
		--- создадим представление значения
		value = callFuncTab( obj, item, "valShapes", value ) or value
	end
	return value, format
end
function menu:setVal(item) --, toUpdate ) --- update value)
	if not item.wtVal then return end

	if item.type == "_clr" then
		if item.value and type(item.value) == "table" then
			item.wtVal:SetBackgroundColor(item.value)
		end
		return
	elseif item.type == "_icn" then
		local valGet, texture = item.valGet, common.GetAddonRelatedTexture("Empty_Tiled")
		if item.value then
			if valGet then
				if type(valGet) == "function" then
					texture = valGet(item.value)
				elseif type(valGet) == "table" then
					texture = valGet[item.value]
				end
			else
				texture = common.GetAddonRelatedTexture(item.value)
			end
		end
		item.wtVal:SetBackgroundTexture(texture)
		return
	end

	--LogInfo("setVal item.value:", item.value )
	local value, format = calcValue(self, item )
	--LogInfo("setVal:", value )
	local len = item.chars or 10
	wtSetPlace( item.wtVal, { sizeX = len*10+10} )
	if item.wtVal.SetMaxSize then item.wtVal:SetMaxSize(len+3) end

	--- формат показа ищем тут - после того как вычислили значение пункта - а то там может быть массив или функция
	format = format or self.valFormats and self.valFormats[value]
	if format and item.wtVal.SetFormat then
		item.wtVal:SetFormat(ToWS(format))
	end

	if item.menuItems then
		wtSetVal( item.wtVal, "<"..value..">" )
	else
		wtSetVal( item.wtVal, value == nil and "-" or value )
		--LogInfo(value)
		--item.wtVal:Show( true )
		--wtSetPlace(item.wtVal, { alignY=3, alignX = 1} )
		--item.wtVal:SetPriority( 1000 )
	end
end

function menu:setLabel( item, w )
	local lbl = callFuncTab(self, item, "labelShapes", item.label) or item.label
	--if item.icon then lbl = "      "..lbl end
--[[	if not w or item.widgets["mnu_"] or item.widgets["tkn_"] then
		exObj2("item", item)
	end]]
	wtSetVal( w or item.widgets["mnu_"] or item.widgets["tkn_"], lbl )
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


--- погасить всех детей (в том читсле и пункты меню самого) кроме указанных
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

-- только кнопки для изменения запрещает/разрешает
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
function menu:Enable(on)
	self.wtMenu:Enable( on )
end
function menu:Show(on, instantly)
	if self.showOn == on then return end
	self.showOn = on --- сначала сменим указание
	self.wtMenu:FinishFadeEffect() --- сбросить

	if on == true then
		if instantly then 
			PlayFade( self, 1.0, 1.0, self.fadeOn )
		else
			PlayFade( self, self.fadeVal, 1.0, self.fadeOn )
		end
		if self.parentObj then
			-- если у нас есть родитель то скажем ему что у него появился ребенок
			-- для того чтобы у него не менять гашение когда ребенок ребенка гаснет
			self.parentObj.childsActive = true
			self.parentObj.mouse_overRun = nil
		end
		self:Update()
		self.wtMenu:Show(on)
	else
		if wTip then wTip:Show( false ) end
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
		item.wtItemPan:SetFade( val )
	end
end


--- поидее тут надо вставить свою обработку для каждй менюшки
function menu:Update( pars )
	local v
	--- перезапишем данные
	for i, item in pars or self.strucMenu do
		if item.name then
			v = callFuncTab( self, item, "valGet" )
			--- из функции может вернуться false - тогда это тоже результат
			if v == nil then
				if item.value == nil then
					--- в default тоже может быть false
					if item.defaultVal == nil then item.value = item.parent.defaultVal
					else item.value = item.defaultVal
					end
				else
					--item.value = item.value
				end
			else item.value = v
			end
			self:setVal( item )
		---elseif item.token then
		end
		self:setLabel(item)
	end
end

function menu:removeItem(index)
	local item = self.strucMenu[index]
	local itemKey = item.name or item.token
	self.storeWT[itemKey] = nil
	for k, wt in item.widgets do
		--- удалим ссылки для реакций
		self.menuItems[wt:GetInstanceId()] = nil
		selfs[wt:GetInstanceId()] = nil
	end
	--- удалим все виджеты элемента меню
	item.wtItemPan:DestroyWidget()
	--- удалим память что виджеты созданы в меню
	table.remove(self.strucMenu, index)
end


-------------------------------------------------------------------------------
-- EVENTS
-------------------------------------------------------------------------------
onEvent.EVENT_EFFECT_FINISHED = function( pars )
	local ids, obj, item, misc = getValsFromSelfs( pars.wtOwner )

	if not obj then return end
	if not obj.mouse_overRun then return end
	if item or misc then return end -- это пункт меню

	if logOn then LogInfo("EVENT_EFFECT_FINISHED",obj.name) end

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
--- обработка кнопок для расширенного меню
	local wName = wtReact:GetName()
	if wName == "set_btn" then
		LogToChat("set_btn")
		local vals = {}
		for k, v in obj.strucMenu do
			if v.value then
				local val = v.value
				if val == "-" then
					val = nil
				elseif tonumber(val) then
					val = tonumber(val)
				elseif type(v.listVals) == "table" and v.listVals[val] then -- or consts[val] or val
					val = v.listVals[val]
				elseif type(v.listVals) == "function" then -- or consts[val] or val
					val = v.listVals(val)
				else
				end
				if obj.list.numberKeys then vals[k] = { [v.name] = val } -- тут список в списке но индексам - сортировка по номеру
				else vals[v.name] = val --- тут список по именам - без сотрировки
				end
			else
				LogToChat(v.name..L(" has empty value!") )
			end
		end
		obj.returnVals = vals
		obj:Show(false)
		--- вызов внешней процедуры
		--- { name = obj.parentName, value = obj.returnVals )
		if obj.onSet then obj.onSet( obj ) end
	elseif wName == "add_btn" then

		if obj.list.labels then
			--- тут есть подстановочные значения - выведем их
			if obj.addMenu then
				--- если такое меню уже создавалось
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
					parentObj = obj, --- запомним кто родитель чтобы обратно управление передать - для показа меню родительского
						recurseCount = obj.recurseCount + 1, --- подсчет рекурсии для разных выходов
						---mouse_left_click = FUNC_selAddItem, ---- свой обработчик
						onClick = FUNC_selAddItem,
					})
	
				wtChain( mSel.wtMenu, wtReact, 10, -20)
				obj.addMenu = mSel
				obj.addMenu:Show( true, true )
			end
		else
			--- тут нет подстановочных значение - нужно вывести поле для ввода
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
			obj.addingNewItem.wtItemPan:AddChild( obj.wtEdited.input )
			wtSetVal(obj.wtEdited.input, obj.addingNewItem.name )
			obj.wtEdited.input:Show(true)
			obj.wtEdited.input:SetMaxSize( string.len (obj.addingNewItem.name) + 3 )
			obj.wtEdited.input:SetFocus(true)
			obj:enableChilds(false, { obj.wtEdited.input:GetParent() } )
		end
		return --- выход иначе внизу пункт удалится
	elseif wName == "input_edl" and react == "on_enter" then
		--- тут был ввод нажат - запомним
		local item = obj.addingNewItem
		obj.addingNewItem = nil
		obj.wtEdited.input:Show(false)
		obj.wtMenu:AddChild( obj.wtEdited.input )

		local val = FromWS( obj.wtEdited.input:GetText() )
		item.name, item.label = val, val
		local n = item.widgets["mnu_"]
		obj:setLabel( item, n )
		obj.wtEdited.input:Show(false)
		obj.wtEdited.input:SetFocus(false)
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		n:Show(true)
		obj:enableChilds( true, { obj.wtEdited.input:GetParent() } )
		return --- выход иначе внизу пункт удалится
	elseif wName == "del_btn" then
		LogToChat("del_btn for "..obj.wtMenu:GetName())
		ButtonToggle(obj, wtReact, "[-]", "-?-", FUNC_item_del)
	elseif wName == "move_btn" then
		ButtonToggle(obj, wtReact, "<=>", "?=>", FUNC_item_move)
	end

	if obj.addingNewItem then
		--- если было прервано вод нового пункта меню то
		obj.wtEdited.input:Show(false)
		obj.wtEdited.input:SetFocus(false)
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		local index = obj.addingNewItem.index
		obj:removeItem(index)
		obj.addingNewItem = nil
		obj:repaint()
		obj:enableChilds( true, { obj.wtEdited.input:GetParent() } )
	end

end

onReaction.mouse_over = function( pars )

	if DnD:IsDragging() then return end
	--LogToChat( pars.widget:GetName() )
	-- сюда может прийти от самого меню, от кнопки меню и от ТИПнижнего

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	--LogInfo(ids,":", obj,":", item,":", misc, " active:",pars.active)

	if false then
	elseif not obj or not obj.wtMenu:IsEnabled() then return --- если окно не разрешено то не откликаться на мышку
	elseif item then
		--obj:Show( true )
		if item.icon then
			local w = item.wtItemPan--- возьмем саму панель пункта а не кнопку
			local p = w:GetPlacementPlain()
			p.sizeY = obj.itemSizeY
			w:SetPlacementPlain(p) -- надо восстановиь иначе растягивается потихоньку

			local pp = Clone( p )
			local dS = 8
			pp.sizeY = obj.itemSizeY + (pars.active and 1 or -0.5 )*dS
			--- тут только размер увеличивается
			w:PlayResizeEffect( p, pp, 300, EA_SYMMETRIC_FLASH )
		end
		if item.tip then
			--- у итема меню есть подсказка - запустим ее
			if type( item.tip ) == "function" then
				item.tip( item, tipRun, pars )
			else
				tipRun(pars.widget, item.tip, pars.active, obj.wtMenu:GetPriority() )
			end
		end
	elseif misc then
		--obj:Show( true )
		--- возможно от подсказки внизу?
		local name = wt:GetName()
		if "bTip_pan" == name then
			tipRun(pars.widget, obj.bottomTip.text, pars.active, obj.wtMenu:GetPriority() )
		elseif name == "ColorPanel" then
			if not pars.active then ColorPanelClose( true ) end --- закроем без перезаписи значения
		else
			--LogToChat( "mouse_over:".. wt:GetName() )
		end
		return
	else --- это само окно
		--LogToChat("menu_over "..obj.name.."active:"..(pars.active and "ON" or "OFF")) 
		--LogInfo("menu_over ",obj.name, "active:", pars.active) 
		if logOn then LogInfo("menu_over ",obj.name, "active:", pars.active) end
		--ToDoShow[ ids ] = { obj = obj.Show, pars = pars.active }
		LogToChat( obj.wtMenu:GetName() .. (obj.wtMenu:IsFocused() and " IsFocused" or " NOT IsFocused"))
		obj:Show( pars.active )
	end

end



onReaction.on_esc = function( pars )

	if DnD:IsDragging() then return end

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	if not obj then return end

	if misc then
		--- значит был нажат кнопка в спике-занчений
		reactionsOthers( obj, pars.widget, "on_esc" )
	elseif item then
		obj:escEditLine(item)
	end


end

onReaction.on_enter = function( pars )
	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	if not obj then return end

	if misc then
		--- значит был нажат кнопка в спике-занчений
		reactionsOthers( obj, pars.widget, "on_enter" )
		return
	end

	obj.currentEditItem = nil

	pars.widget:Enable(false)
	pars.widget:SetFocus(false)
	pars.widget:SetGlobalClasses({ "LogColorBlue", "Size14"})

	--- вызов внешней процедуры
	--- тут если была функция она на значение перепишется
	item.value = FromWS(pars.widget:GetText())
	obj:setVal(item)

	--[[if obj.on_enter then obj.on_enter( item )
	elseif obj.mouse_left_click then obj.mouse_left_click( item ) --, obj)
	end
	]]
	onClick( obj, item, pars )

end

onReaction.mouse_left_click = function( pars )

	if DnD:IsDragging() then return end

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )

	if not obj then
		if externatWidgetRun then
			--- это реакция от внешних виджетов, которые это меню запустило - например выбор цвета
			obj, item = extendedMenuReactions( pars )
			--- запустим внешнию процедуру после обновления
			onClick( obj, item, pars )
		end
		return
	end

	if logOn then LogInfo(obj.name, "mouse_left_click ",pars.widget:GetName() ) end

	wTip:Show( false )
	if obj.currentEditItem then
		--- если был ввод - отменим его
		obj:escEditLine()
	end

	if misc then
		--- значит был нажат кнопка в спике-занчений
		reactionsOthers( obj, pars.widget, "mouse_left_click" )
		return
	end

	-- сюда придет только если есть ИТЕМ

	if obj.mouse_left_click_instead then
		--- если никаких действи тут не надо а вместо этого другое сделать на клик
		obj.mouse_left_click_instead( item ) --, obj)
		return
	end

	--LogToChat("mouse_left_click")
	--exObj2("item", item)

	if false then
	elseif item.type == "_clr" then
		ColorPanelOpen( obj, item, pars.widget )
		return --- дальше не идем - иначе там onClick сработает
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
		return --- дальше событие продолжит
	elseif item.menuItems or item.type == "_lst" then
		local mV, onClick
		if not item.list then item.list = {} end
		if item.menuItems then
			--- тут просто список для выбора значения из списка
			local strucMenu = {}
			if item.list.numberKeys then
				for i, menuItem in item.menuItems do
					if type(menuItem) == "table" then
						strucMenu[i] = Clone( menuItem )
						strucMenu[i].value = item.value == menuItem.name and "<--" or nil
					else
						strucMenu[i] = { name = menuItem, label = menuItem, type = item.value == menuItem and "_txt" or "_nil",
							value = item.value == menuItem and "<--" or nil}
					end
				end
			else
				for name, menuItem in item.menuItems do
					if type(menuItem) == "table" then
						table.insert( strucMenu, menuItem )
					else
						table.insert( strucMenu, { name = name, label = name, type = item.value == name and "_txt" or "_nil",
							value = item.value == name and "<--" or nil} )
					end
				end
				--exObj2("strucMenu", strucMenu)
				table.sort( strucMenu, function( A, B ) return A.name < B.name end )
				--exObj("strucMenu - sort", strucMenu)
			end
			mV = menu{ strucMenu = strucMenu,
				mouse_left_click = FUNC_SelMenu, --- тут обычнаый выбор по клику
				onClick = FUNC_SelMenu, --- тут обычнаый выбор по клику
				}
		else
			--- тут сложный список с item.data = ...
			
			local value = item.value or item.data
			if type(value) == "function" then value = value(item) end
			--[[ -- сортировка только в таблице с индексами работает (
			LogToChat("sort")
			table.sort( value, function( A, B ) return A.name < B.name end )
			]]
			mV = menuVals({
					onSet = FUNC_onSetList,
					data = value,
					--mouse_left_click = FUNC_SelMenu,
					--onClick = FUNC_SelMenu,
					list = item.list or obj.list,
					})
		end
		local pars = { 
			priority = obj.wtMenu:GetPriority() + 100, alfa = 1,
			parentObj = obj, --- запомним кто родитель чтобы обратно управление передать - для показа меню родительского
			parentItem = item, --- и запомним для какого параметра изменения будут
			recurseCount = obj.recurseCount or 0 + 1, --- подсчет рекурсии для разных выходов
			name = item.label, 
			mouse_overRun = true,
			listVals = item.list.listVals,
			valGet = item.list.valGet,
			valLabels = item.list.valLabels,
			labelShapes = item.valShapes or obj.valShapes or item.list.labelShapes or item.labelShapes or obj.labelShapes, --- просто локализация
			labelFormat = item.list.labelFormat or item.labelFormat or obj.labelFormat, --- просто локализация
			valFormats = item.list.valFormats or item.valFormats or obj.valFormats,
			valShapes = item.list.valShapes or item.valShapes or obj.valShapes, --- скопируем таблицу представлений для значений

			valOnSet = item.list.valOnSet,
			mouse_right_click = item.list.mouse_right_click,
			mouse_double_click = item.list.mouse_double_click,

			--RowsColsRate = 10,
			fadeOn = 200, fadeOff = 300,
			--place = self.list.place
			bottomTip = item.list.bottomTip,

			--list = item.list.list,
			}
		if item.menu then
			for k, v in item.menu do
				pars[k] = v
			end
		end
		mV:init(pars)
 		if not item.list.place then wtChain( mV.wtMenu, item.wtVal or item.widgets["mnu_"], -30, -40) end
		mV:Show( true, true )
		return
	elseif item.type == "_txt" and (item.listVals or obj.listVals) then
		--- тут поиде список констант
		--- нам надо взять следующую по списку или первую
		local vals = item.listVals or obj.listVals
		--exObj("vals", vals )
		--LogInfo( item.value )
		local i
		for k, v in vals do
			if v == item.value then i = k + 1 break end
		end
		--- возьмем следующее значение из списка или первое -- оноже по умолчанию на НИЛ="-"
		if i == nil or vals[i] == nil then item.value = vals[1]
		else item.value = vals[i]
		end
		--LogInfo( "i=",i, " val:", item.value)
		obj:setVal( item )
	elseif item.type == "_icn" then
		---return --- дальше не идем - иначе там onClick сработает
	end

	--- вызов внешней процедуры
	onClick( obj, item, pars )

end

onReaction.mouse_right_click = function( pars )

	if DnD:IsDragging() then return end
	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	if not obj then return end

	wTip:Show( false )
	if item then
		--- вызов внешней процедуры
		if obj.mouse_right_click then
			obj.mouse_right_click( item, pars )
		end
	end

end
onReaction.mouse_double_click = function( pars )

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	if not obj then return end

	wTip:Show( false )
	if item then
		--- вызов внешней процедуры
		if obj.mouse_double_click then
			obj.mouse_double_click( item, pars )
		end
	end

end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
function menu:insertItem( item, pos )
	table.insert( self.strucMenu, self.addingNewItem, pos )
	self:repaint()
end

function menu:repaint()
	self:init(nil, true) -- тут елисли есть уже виджеты то просто перерисует или добавит чего нет
end
function menu:destroy()
	selfs[self.id] = nil --- удалим сылку на объект
	self.wtMenu:DestroyWidget() --- освободим память от виджетов
end

---function menu:makeWidgets(self)
function menu:init(pars, repaint)

	if pars then
		for k, v in pars do
			self[k] = v
		end
	end

	self.storeWT = self.storeWT or {} -- тут все виджеты будем хранить
	self.alfa = self.alfa or 0.8 --- transparency
	self.posX = self.posX or 0
	self.posY = self.posY or 0
	self.itemSizeX = self.itemSizeX or 250
	self.itemSizeY = self.itemSizeY or 20
	self.alignX = self.alignX or 0
	self.alignY = self.alignY or 0
	self.name = self.name or ""
	--self.rows = self.rows
	--self.cols = self.cols
	self.priority = self.priority or 500
	self.fadeOn = self.fadeOn or 500
	self.fadeOff = self.fadeOff or 1000
	self.fadeVal = self.fadeVal or 0.7 --- насколько тушить при откурывании ребенка
	
	if not repaint then self.menuItems = {}
	else
	end

	---------------------------------------------
	-------- динамическое создание интерфейса
	---------------------------------------------
	local w, n, i, v, d, x, y, sz, str, len, tpe, ddx, name, itemNameStore, wtPan, wtItem, itemKey
	--- описания
	
	name = "menu_"..self.name
	w = repaint and self.wtMenu --- иначе не тот находит какойто mainForm:GetChildUnchecked(name, false )
	if not w then
		w = mainForm:CreateWidgetByDesc( self.desc or dsc.Menu ) w:SetName( name )
		self.id = w:GetInstanceId()
		--- запомним объект для вызова его в событиях
		selfs[self.id] = { obj = self }
		wtSetPlace( w, { posX = self.posX, posY = self.posY, alignX = self.alignX, alignY = self.alignY } )
		w:SetPriority(self.priority)
		if self.texture then w:SetBackgroundTexture( self.texture ) end
		if self.color then w:SetBackgroundColor( self.color ) end
		self.wtMenu = w
		self.showOn = false

		--- изменим прозрачность
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

	--- структура меню
	ddx = 20
	local tLen = table.getn(self.strucMenu)

	self.rows, self.cols = tuneRowsCols(tLen, self.rows, self.cols, self.itemSizeX+ddx, self.itemSizeY)
	if self.RowsColsRate and self.rows / self.cols < self.RowsColsRate then
		self.rows = math.ceil( (tLen * self.RowsColsRate)^0.5 ) + 1
		self.rows, self.cols = tuneRowsCols(tLen, self.rows, self.cols, self.itemSizeX+ddx, self.itemSizeY)
	end

	--LogInfo("self.rows, self.cols",self.rows, ":", self.cols)

	i = 0
	local offset
	for c = 1, self.cols do
	for r = 1, self.rows do
		i = i + 1
		local item = self.strucMenu[i]
		if not item then break end
		itemKey = item.name or item.token

		-- теперь нам надо найти может уже такой пункт меню был создан и все его виджеты гдето созданы
		-- но на гругом номере - это возможно при изменени списка пунктов меню на лету
		item.widgets = self.storeWT[itemKey]
		if not item.widgets then item.widgets = {} end

		item.index = i
		item.parent = self
		offset = item.offset or 0
		offset = type(offset) == "function" and offset(item) or offset
		x = (c-1)*self.itemSizeX + ddx + offset
		y = (r-1)*self.itemSizeY + 20

		--- создадим контейнер - панель длял пункта меню куда закатем иконку, кнопку и виджет о знчениями
		name = itemKey.."_pan"
		itemNameStore = "pan_"
		n = item.widgets[itemNameStore]
		if not n then
			n = WCD( item.item_desc or self.item_desc or dsc.MenuItem, name, w, nil, true ) --- dsc.PanelER
			item.widgets[itemNameStore] = n
			selfs[n:GetInstanceId()] = { obj = self, item = item } --- запомним объект для вызова его в событиях
		end
		local item_texture = item.item_texture or self.item_texture
		if item_texture then
			--LogToChat("item_texture --> SetBackgroundTexture")
			n:SetBackgroundTexture( item_texture )
		end
		local item_color = item.item_color or self.item_color
		if item_color then
			n:SetBackgroundColor( item_color )
		end
		self.menuItems[n:GetInstanceId()] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
		wtPan = n
		item.wtItemPan = wtPan

		--- теперь настроим нуект меню
		sz = self.itemSizeX - 2*ddx - offset ---- string.len(item.label)*9+25
		if tonumber(item.fade) then wtPan:SetFade ( tonumber(item.fade) ) end
		wtSetPlace( wtPan, { sizeX = sz, sizeY = self.itemSizeY, posX = x, posY = y, alignX = 0, alignY = 0 } )

		if item.token then
			--- если это разделитель
			name = item.token.."_txt"
			itemNameStore = "tkn_"
			n = item.widgets[itemNameStore]
			if not n then
				n = WCD( dsc.Text, name, wtPan, { alignX = 3, alignY = 3}, true )
				item.widgets[itemNameStore] = n --- запомним виджет - чтобы с нм чтонибудь потом делать
				selfs[n:GetInstanceId()] = { obj = self, item = item } --- запомним объект для вызова его в событиях
			end
			self.menuItems[n:GetInstanceId()] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			n:SetFormat(ToWS(item.labelFormat or "<html alignx='center' fontsize='16'><tip_golden><r name='value'/></tip_golden></html>"))
			self:setLabel( item, n )
		else
			name = item.name.."_mnu"
			itemNameStore = "mnu_"
			n = item.widgets[itemNameStore]
			if not n then
				n = WCD( item.button_desc or self.button_desc or dsc.MenuItemBtn, name, wtPan, nil, true )
				--- размер пункта меню потом зазадим по присутсвию иконки и размеру значения
				item.widgets[itemNameStore] = n --- запомним виджет - чтобы с нм чтонибудь потом делать
				selfs[n:GetInstanceId()] = { obj = self, item = item } --- запомним объект для вызова его в событиях
			end
			self.menuItems[n:GetInstanceId()] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			self:setLabel( item, n )
			wtItem = n

			local button_texture = item.button_texture or self.button_texture
			if button_texture then
				wtItem:SetBackgroundTexture( button_texture )
			end
			local button_color = item.button_color or self.button_color
			if button_color then
				wtItem:SetBackgroundColor( button_color )
			end

			--- если у итема меню есть значения то создадим для них поле
			local enableEdit = false
			d = nil
			if item.type == "_chk" then
				d = dsc.Check
			elseif item.type == "_edl" then
				d = dsc.EditLine
				enableEdit = true
			elseif item.type == "_txt" or item.type == "_lst" --[[or item.type == "_mnu" --]] then
				---- обычное текстовое значение
				d = dsc.Text
			elseif item.type == "_clr" then
				---- панель для выбора цвета с движками
				d = dsc.Bar
				ColorPanelInit()
			elseif item.type == "_icn" then
				--- иконка
				d = dsc.Bar
			end
			if d then
				name = item.name.."_val"..item.type
				itemNameStore = "val_"
				v = item.widgets[itemNameStore]
				if not v then
					v = WCD( d, name, wtPan, {
						sizeX = (item.type == "_clr" or item.type == "_icn" or item.type == "_chk") and self.itemSizeY or self.itemSizeY*3,
						alignX=1, alignY=3 }, true )
					selfs[v:GetInstanceId()] = { obj = self, item = item } --- запомним объект для вызова его в событиях
					item.widgets[itemNameStore] = v --- запомним виджеты для этого элемента меню - чобы потом их редактировать
				end
				item.wtVal = v --- запомним виджет в котором отображается значение
				if v.SetFormat then v:SetFormat(ToWS("<html alignx='right' fontsize='12'><r name='value'/></html>")) end
				if v.SetGlobalClasses then v:SetGlobalClasses({ "LogColorBlue", "Size14"}) end
				if v.SetMaxSize and item.chars then
					v:SetMaxSize(item.chars)
					wtSetPlace( v, { sizeX = item.chars*self.itemSizeY/2+5 } )
				end

				---if v.GetInitialGlobalClass then exObj("cc",v:GetInitialGlobalClass(),true) end
				--v:Enable( enableEdit )
				v:SetPriority( 100 )
				self.menuItems[v:GetInstanceId()] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			else
			end

			if item.icon then
				name = item.name.."_icn"
				itemNameStore = "icn_"
				v = item.widgets[itemNameStore]
				if not v then
					v = WCD( dsc.PanelEmpty, name, wtPan, { alignX = 0, alignY = 3, sizeX = self.itemSizeY }, true )
					item.widgets[itemNameStore] = v --- запомним виджеты для этого элемента меню - чобы потом их редактировать
					selfs[v:GetInstanceId()] = { obj = self, item = item } --- запомним объект для вызова его в событиях
				end
				v:SetBackgroundTexture( item.icon )
				self.menuItems[v:GetInstanceId()] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			end

			--- у кнопок нет этого метода if item.labelFormat then wtItem:SetFormat(ToWS(item.labelFormat)) end
			sz = self.itemSizeX - 2*ddx - offset ---- string.len(item.label)*9+25
			local dX_icon = item.icon and (self.itemSizeY + 3) or 0
			wtSetPlace( wtItem, { sizeX = sz - dX_icon, posX = dX_icon, posY = 0, alignX = 0, alignY = 3 } )

		end
		self.storeWT[item.name or item.token] = item.widgets --- запоним все виджеты что тут создали может потом их переиспользуем при пересборе меню
	end
	end


	if self.bottomTip then
		str = self.bottomTip.label
		len = string.len(str)

		name = "bTip_pan"
		itemNameStore = "bTip_pan"
		n = Wun0(name, w ) 
		if not n then
			n = WCD( dsc.PanelReact, name, w, { highPosX=15, highPosY = -2, alignX = 1, alignY = 1,
				sizeX = self.itemSizeY*len+10, sizeY=self.itemSizeY }, true )
			v = WCD( dsc.Text, "bTip_txt", n, { alignX = 3, alignY = 3 }, true)
		end
		v:SetVal("value", ToWS( str ))
	end

	local szX, szY = self.itemSizeX * self.cols, self.itemSizeY * self.rows + 40 + (self.sizeYbottom or 0 )
	self.wtSize = { sizeX = szX, sizeY = szY }
	wtSetPlace( self.wtMenu, self.wtSize )

end

------------------------------ Расширение класса ------------------------------
------------------------------ редактируемый список значений ------------------
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
		self.itemSizeX = self.list.itemSizeX or (self.list.edited and 250 or 100) --- так как тут кнопки то зададим минимальный
		
		local strucMenu, i, len = {}, 0, 0
		local item
		for k, v in self.data do
			i = i + 1
			local name, val = k, v
			if self.list.numberKeys then
				--- сигнализирует о том как из списка потом значения запаоквывать - с индексами номерами или сразу имена-ключи
				name, val = next(v)
			end
			item = { name = name, label = self.list.labels and self.list.labels[name] or name,
				value = val, ---makeItemValue(val), --- если нил - то берется с глабального значения, 
				type = self.list.type, listVals = self.list.vals, valLabels = self.list.valLabels }
			local ll --= string.len ( strucMenu[i].label ) + string.len ( self.list.vals and self.list.vals[strucMenu[i].value] or strucMenu[i].value ) + 3
			ll = string.len ( callFuncTab(self, item, "labelShapes", item.label) or item.label )
			ll = ll + string.len ( calcValue(self, item ) )
			if len < ll then len = ll end
			strucMenu[i] = item
		end
		if not self.list.numberKeys then
			-- сортировка только в таблице с индексами работает
			-- поэтому можно только тут внутри это сделать
			--LogToChat("sort")
			table.sort( strucMenu, function( A, B ) return A.name < B.name end )
		end

		local itemSizeX = len*8 + 40
		if itemSizeX > self.itemSizeX then self.itemSizeX = itemSizeX end
		--LogToChat(itemSizeX..":"..self.itemSizeX)

		self.classParent = menu{ strucMenu = strucMenu, itemSizeX = self.itemSizeX, sizeYbottom = 20 }
		self.classParent:init(pars, repaint)
		--- унаследуем все от родителя методы
		local metaParent = menu
		local metaSelf = menuVals
		for k, v in metaParent do
			if not metaSelf[k] then metaSelf[k] = v end
		end
		--- теперь значения
		for k, v in self.classParent do
			if not self[k] then self[k] = v end
		end

		--- и для всех пунктов меню подменим родителя на себя
		--- чтобы вызовы в функциях obj=item.parent имено на этот объект шли
		for k, v in self.classParent.strucMenu do
			v.parent = self
		end
		
		--self.

		local w

		if not self.list.sel_on_click then
			w = WCD( dsc.Button, "set_btn", self.classParent.wtMenu,{ posX = 0, highPosX = 20, posY = 0, highPosY = 3, alignX = 1, alignY = 1, sizeX = 30, sizeY=25 }, true )
			selfs[w:GetInstanceId()] = { obj = self.classParent, misc = w } --- запомним объект для вызова его в событиях
			wtSetVal(w,"[=]")
		else
		end

		if self.list.edited then
			self.wtEdited = {}
			--- если разрешено изменение самого списка
			w = WCD( dsc.Button, "add_btn", self.classParent.wtMenu, { posX = 30, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 30, sizeY=25 }, true)
			selfs[w:GetInstanceId()] = { obj = self.classParent, misc = w } --- запомним объект для вызова его в событиях
			wtSetVal(w,"[+]")
			self.wtEdited.add = w

			w = WCD( dsc.ToggleButton, "del_btn", self.classParent.wtMenu, { posX = 70, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 40, sizeY=25 }, true )
			selfs[w:GetInstanceId()] = { obj = self.classParent, misc = w } --- запомним объект для вызова его в событиях
			wtSetVal(w,"[-]")
			self.wtEdited.del = w

			w = WCD( dsc.ToggleButton, "move_btn", self.classParent.wtMenu, { posX = 120, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 40, sizeY=25 }, true )
			selfs[w:GetInstanceId()] = { obj = self.classParent, misc = w } --- запомним объект для вызова его в событиях
			wtSetVal(w,"[<=>]")
			self.wtEdited.move = w

			w = WCD( dsc.EditLine, "input_edl", self.classParent.wtMenu, { alignX=3, alignY =3 }, false )
			selfs[w:GetInstanceId()] = { obj = self.classParent, misc = w } --- запомним объект для вызова его в событиях
			w:SetPriority(400)
			self.wtEdited.input = w
		end
		if self.list.place then
			wtSetPlace( self.classParent.wtMenu, self.list.place )
		end


		--- подменим в базе объектов на себя (на потомка)
		--- дело в том что там все кнопки буду при реакции выдавать клас родитель а не этот!
		--selfs[self.classParent.id] = { obj=self }
		--self.classParent = self
		
	else
		for k, v in self do
			self.classParent[k] = v
		end
		self.classParent.classParent = nil
		self.classParent.parentObj = nil
		self.classParent:init( nil, repaint)
		--- теперь значения наоборот сюда закатаем от туда
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
