Global("skin", {} )

--- author icreator
--- UPDATED: 2011.09.27

--[[

	menu.close_button = true or Place
	menu.close_button_desc

	item.icon_clr or obj.icon_clr
	.headerText = str
	self.list.DnD = { fUseCfg, fLockedToScreenArea, Padding }
	DnD:Init( mV.wtMenu, mV.wtMenu, pars.DnD.fUseCfg, pars.DnD.fLockedToScreenArea, pars.DnD.Padding )

	self.border_dX = self.border_dX or self.itemSizeY/2
	self.border_dY = self.border_dY or self.itemSizeY*1.5

	menu.onShow, item.list.onShow
	if self.onShow then self:onShow( on, instantly ) end

-->> tipRun(wBase, tip, active, prior)
	item.tip = { values = { va1=VAL1, val2=Val2}, format=<html> .. <r name='val1'/> .. <r name='itemName'/>
		"<br /><html alignx='right' aligny='middle' fontsize='14' shadow='1' ><r name='val2'/></html>"
	item.tip = { VT=ValuedText }

	menu.itemSizeX, itemSizeY, ddx
	item.cmd = 1 === item.type = "_cmd"

	menu.mouse_overRun = true - окно будет закрываться если мышка с него ушла
	menu.notSkinned = true --- НЕ будет менять оформление по командам из АТ
	menu.place
.type =
"_cmd" -command. value not used

"_txt" -text value
"_edl" -edit line
"_edn" -edit number
"_lst" -list of values
	.menu = {} -- all val recopy to new menu

	--- то что в таблице list - передается в создающееся меню

	(menu or list).edited -- меню с кнопками редактирования
	(menu or list).set_button --  показаь кнопку равно -  оно само включается при создании лист
	(menu or list).hide_set_button  - не показывать "="
	list = { fadeVal = 0, },

"_clr" -color set = {a=,b=,g=,r=}
"_icn" -icon.  = texture or string (will find in local textures)
"_fnt" -FONT set - для создания фонта из массива юзайте:
	local frmt = makeFontFormatFromTab( item.value )
	item.wtVal:SetFormat(ToWS(frmt))

"_plc" - set GetPlacementPlain tab
	.item.list.wtPlaced =

	valGet = nil or function or table --->To get Texture by name in value. for example:
	valGet = TexturesStoreTable --- = table { [name1] - texture1,...}
	or
	valGet = GetTextureByName --- = function(name) return ... end
	default:
	valGet = nil  ---> texture = common.GetAddonRelatedTexture(item.value)


заначение поля хранится в:
	.value
	.valueScale = SetTextScale( self, scale )
получить данные - при начальном создании меню или когда делается показ меню - Update():
	.valGet = function(item) or table[item.name]
	- результат будет записан в .value
при изменении данных пользователем:
	.valOnSet = function(item)

функция вызываемая после изменения данных в меню ( после нажатия на пункт меню )
тоесть когда создается дополнительное окно и в нем кнопка с "="
нет - она не пашет потому что вместо нее FUNC_onSetList вызывается всегда
для передачи значения в родительский пункт меню
	.list = {.valOnSet} надо использовать в пункте меню в описании list {}
тогда кроме стандартных действий обновления значения еще и будет запускать функцию
например перирисовать окошко

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
	.labelScale = SetTextScale( self, scale )
прямо в имя кнопки можно писать <html> например так:
label = "<html fontname='AllodsSystem' fontsize='24' alignx='right' shadow='2'><tip_green>HGJH</tip_green></html>"
		--- формат действует только на ТОКЕНЫ - кнопкам нельзя формат присвоить (
	.labelFormat  - <html format> = "<html fontname='AllodsWest' fontsize='14' shadow='1'><tip_blue><r name='text'/></tip_blue></html>"
	.labelShapes = function(label) or table[label]
	- меняет ярлык - обычно для локализации

	.menu.toClose --- если это родитель и он при закрывании ребенка будет открываться, то чтобы этого не было - задать тут ТРУЕ

каждая кнопка стектурой
	= 0 - not change
	item.item_texture = common.GetAddonRelatedTexture("FrameRed") 104x104
	item.item_color = common.GetAddonRelatedTexture("FrameRed")
	item.item_color_add - чуток меняет уже существующий цвет
	item.item_desc = widget:GetWidgetDesc() --- описатель кнопки
	item.widget = --- готовый виджет вместо кнопки или токена - w = WCD( dsc.ColorPanel, i.."_rcp", nil, {alignX=3, alignY=3}, true )
	item.widget_react = Тогда нужно задать так же этот параметр ля слежки за реакциями

	item.button_texture = common.GetAddonRelatedTexture("FrameRed") 104x104
	item.button_color = common.GetAddonRelatedTexture("FrameRed")
	item.button_desc = widget:GetWidgetDesc() --- описатель кнопки

	menu.border_desc -- если указан то стандартный бордер окна будет прозрачным. Например чтобы можно было гасить бордер отдельно или непоказываь его а 
		бордер у подсказки был бы стандартный от skin
	menu.texture
	menu.color
	menu.desc - описатель панели меню? Например чобы фрейм из 200х200 текстур делать
	menu.head_desc - описатель заголовка меню

.texture =
{string} == GetAddonRelatedTexture()
"=name" == GetAddonRelatedTexture( item.name )
{table} == table[ item.name or obj.name ]

self.wtMenu - панель самого меню можно его тоже перерисовать как угодно - текстуры подставить

если у поля нет своей функции то она берется общая из самого меню:
	if item.valGet then
	elseif item.parent.valGet then
	end
	if item.labelShapes then
	elseif item.parent.labelShapes then
	end

на правую мышку реакция тут:
	item.mouse_right_click or obj.mouse_right_click
	item.onRClick or obj.onRClick

если это пункт команды (без значений) или текст "_txt" без списков - как оманда то функция по клику хранится в:
	.onClick = function( obj, item, pars )

	--- порядок вызова внешних функций при нажатии на пункт меню / изменении данных 
	local onClick = item.onClick or item.valOnSet or obj.valOnSet or obj.onClick
	if onClick then onClick( item, pars ) end

other reactions:
	misc.on_mouse_over, item.on_mouse_over, obj.on_mouse_over


FUNCTIONS

menuEnableTips
menuTipIsVisible
setBGtexture

	
METODS

menu:getItemByIDS( ids ) --> [GetInstanceId(wt)] = item

menu:getItemByName( name )
menu:setVal(item)

menu:setIcon( item, wt )
menu:setLabel( item, wt )

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

menu:removeItem(index) -------- 	obj:removeItem(item.index)
menu:insertItem( item, pos )

menu:repaint()
menu:destroy()

menu:init(pars)


	item.wtItemPan - контейнер для иконки, кнопки и значения пункта меню (ну и токен тудаже)
	menu.strucMenu[i] = item

]]

--- тут дети-меню сами показываю/гасят своих родителей
--- через параметр  parentObj
--- параметры item.value item.offset -  могут быть функциями для автоматического обновления при menu:Update()

---- класс для всех менюшек - тут не должно быть вызовов к внешним данным чтобы она была независимая
--- value = "-" - это nil - эго надо во вне правильно присвоить: setPS(name, nil)
local o
local logOn = nil --- включает вывод в лог 

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
	{ name ="itemName", label = L("Item Label"), type = "_txt", listVals =onoff, chars = 10, offset = 20, valFormats, defaultVal=},
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
local tipFormat = ToWS("<html alignx='left' aligny='middle' fontname='AllodsWest' fontsize='14' shadow='1'>"
	--.."<log_dark_white>"
	.."<r name='value'/>"
	--.."</log_dark_white>"
	.."</html>")
--"<html alignx='right' fontsize='12' outline='2'><r name='value'/></html>"
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
	--- вызов внешней процедуры
local function onClick( item, pars )
	if false then
		LogToChat("menu3 onClick: "..item.name.." value:"..(item.value and " HAS" or "NIL"))
		local parentItem = item.parent and item.parent.parentItem
		if parentItem then LogToChat("menu3 onClick: .parent.patentItem: "..parentItem.name) end
	end
	local f
	if item.value == nil then
		--- тут пункт меню
		f = item.onClick or item.parent.onClick
	else
		--- тут было какое-то значение изменено
		f = item.valOnSet or item.parent.valOnSet
	end
	if f then f( item, pars ) end
end
-- если сложную форму закончили править-заполнять и нажали готов-выход-запомнить
-- ут соберем все значения по форме и отдадим на верх родителю
local function collectValsFromChild( child )
	local vals = {}
	for k, v in pairs(child.strucMenu) do
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
			if child.numberKeys then vals[k] = { [v.name] = val } -- тут список в списке но индексам - сортировка по номеру
			else vals[v.name] = val --- тут список по именам - без сотрировки
			end
		else
			--LogToChat((v.name or v.label or v.token)..L(" has empty value!") )
		end
	end
	return vals
end
local function reactionsOthers_SetButton( objIn, reactName )
	local obj
	if objIn.strucMenu then
		obj = objIn
	else
		--- это итем
		obj = objIn.parent
	end
	--LogToChat("set_btn -- " .. obj.name)

	obj.returnVals = collectValsFromChild( obj )
	obj:Show(false)
	--- вызов внешней процедуры
	--- { name = obj.parentName, value = obj.returnVals )
	if obj.onSet then obj.onSet( obj ) end
	--- тут будет вызов ПРОС для меню-листа - её надо задаваь в параметре .list = {}
	if obj.valOnSet then obj.valOnSet( obj ) end
end

local function FUNC_SelMenu( item )
	--- обработка нажатия в обычном меню вызваном из списка с присвоением значения и гашением текущего окна
	--LogToChat( "FUNC_SelMenu: "..item.name )
	local obj = item.parent
	--LogInfo("FUNC_SelMenu   obj."..obj.name.." .recurseCount=",obj.recurseCount)
	obj:Show(false)
	obj.parentItem.value = item.name --- обновим данные в меню-родителе
	obj.parentObj:setVal(obj.parentItem )
	-- тут нет уровней if obj.recurseCount == 1 then
		--obj.parentObj.mouse_left_click( obj.parentItem ) --, obj.parentObj )
		onClick( obj.parentItem )
	--end
end
--- обработка возврата из редактирования списков значений
--- там может быть рекурсия - самый первый - в параметры закатать
local function FUNC_onSetList( obj )
	--LogInfo("FUNC_onSetList   obj."..obj.name.." .recurseCount=",obj.recurseCount)
	obj.parentItem.value = obj.returnVals --- обновим данные в меню-родителе
	if obj.recurseCount == 1 then
		--- тут присвоить параметру - высший уровень
		onClick( obj.parentItem )

	else
		--- тут присвоить элементу списка текущего
	end
	--- тут значения бурется уже из сохраненых PS[key} по valGet
	--- поэтому нужно сначала выполнить процедуры сохранения - onClic onSet
	obj.parentObj:Update( { obj.parentItem } )
end

local repainted
function repaint_all_menus()
	--- тут много записей на одо меню поэтому надо дубляжи пропускать
	repainted = {}
	local idsObj
	for ids, rec in pairs(selfs) do
		if rec.obj and not rec.obj.notSkinned then
			--- переоформим только те что разрешены в одежке
			idsObj = GetInstanceId(rec.obj.wtMenu)
			if repainted[idsObj] then
			else
				rec.obj:repaint()
				repainted[idsObj] = 1 --- запомним что это меню уже перерисовали
			end
		end
	end
end

-------------------------------------------
--------- PLACE PANEL ----------------------
-------------------------------------------
local menuPlc

local wtPlaceProbe
local function PlcSetAlignVal( item, obj )
	local xy, v = string.sub( item.name, -1 )
	if item.value == 0 then
		v = obj:getItemByName( "pos"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "size"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "highPos"..xy )
		v.wtItemPan:Enable ( false )
		v.wtItemPan:SetFade ( 0.1 )
	elseif item.value == 1 then
		v = obj:getItemByName( "highPos"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "size"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "pos"..xy )
		v.wtItemPan:Enable ( false )
		v.wtItemPan:SetFade ( 0.1 )
	elseif item.value == 2 then
		v = obj:getItemByName( "pos"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "size"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "highPos"..xy )
		v.wtItemPan:Enable ( false )
		v.wtItemPan:SetFade ( 0.1 )
	elseif item.value == 3 then
		v = obj:getItemByName( "pos"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "highPos"..xy )
		v.wtItemPan:Enable ( true )
		v.wtItemPan:SetFade ( 1 )
		v = obj:getItemByName( "size"..xy )
		v.wtItemPan:Enable ( false )
		v.wtItemPan:SetFade ( 0.1 )
	end
end

local function valOnSetPlace()
	-- сюда приходт до нажатий - когда инициализируется меню поэтому тут
	-- нельзя сотреть итем текущий
	-- exObj2("item", item )

	local obj, item = menuPlc

	--- соберем для пробного окна положеение
	local plc = collectValsFromChild( obj ) 
	if menuPlc.wtPlaced then
	else
		local p = menuPlc.wtMenu:GetPlacementPlain()
		plc.posX = (tonumber(plc.posX) or 0 )/3 if plc.posX + 20 > p.sizeX then plc.posX = p.sizeX - 20 end
		plc.posY = (tonumber(plc.posY) or 0 )/3 if plc.posY + 20 > p.sizeY then plc.posY = p.sizeY - 20 end

		plc.highPosX = (tonumber(plc.highPosX) or 0 )/3 if plc.highPosX + 20 > p.sizeX then plc.highPosX = p.sizeX - 20 end
		plc.highPosY = (tonumber(plc.highPosY) or 0 )/3 if plc.highPosY + 20 > p.sizeY then plc.highPosY = p.sizeY - 20 end

		plc.sizeX = (tonumber(plc.sizeX) or 100 )/3 if plc.sizeX > p.sizeX then plc.sizeX = p.sizeX end
		plc.sizeY = (tonumber(plc.sizeY) or 100 )/3 if plc.sizeY > p.sizeY then plc.sizeY = p.sizeY end

		if plc.sizeX < 30 then plc.sizeX = 30 end
		if plc.sizeY < 30 then plc.sizeY = 30 end
	end

	wtSetPlace ( (menuPlc.wtPlaced or wtPlaceProbe), plc )
	

	item = obj:getItemByName( "alignX" )
	PlcSetAlignVal( item, obj )
	item = obj:getItemByName( "alignY" )
	PlcSetAlignVal( item, obj )

end
local function takePlace(item)
	menuPlc.PlaceTaken = true
	local obj = item.parent
	obj.returnVals = collectValsFromChild( obj )
	obj:Show(false)
	--- вызов внешней процедуры для запис значения
	FUNC_onSetList( obj )

	--- тут значения бурется уже из сохраненых PS[key} по valGet
	--- поэтому нужно сначала выполнить процедуры сохранения - onClic onSet
	obj.parentObj:Update( { obj.parentItem } )
end
local function dropPlace(item)
	item.parent:Show( false, true )
end

local plcAlignx, plcAligny = { [0]="left", [1]="right", [2]="center", [3]="both"}, {[0]="top",[1]="bottom",[2]="meddle",[3]="both"}
local plcAlign = { 0, 1, 2, 3}

local function PlacePanelInit()
	if menuPlc then return end

	--local wt = WCD(dsc.Frame,nil,nil, { alignX=3, alignY=3 }, true )

	menuPlc = menu{ strucMenu = 	{
		{ name = "alignX", label = "Align X", type = "_txt", listVals = plcAlign, valShapes = plcAlignx, valOnSet=valOnSetPlace},
		{ name = "alignY", label = "Align Y", type = "_txt", listVals = plcAlign, valShapes = plcAligny, valOnSet=valOnSetPlace},
		{ name = "sizeX", label = "Size X", type = "_edn", chars=4, valOnSet=valOnSetPlace },
		{ name = "sizeY", label = "Size Y", type = "_edn", chars=4, valOnSet=valOnSetPlace },
		{ name = "posX", label = "Pos X", type = "_edn", chars=4, valOnSet=valOnSetPlace },
		{ name = "posY", label = "Pos Y", type = "_edn", chars=4, valOnSet=valOnSetPlace },
		{ name = "highPosX", label = "High Pos X", type = "_edn", chars=4, valOnSet=valOnSetPlace },
		{ name = "highPosY", label = "High Pos Y", type = "_edn", chars=4, valOnSet=valOnSetPlace },

	--	{ widdet = wt },
		{ name = "takeIt", label = "Take or Drop It", cmd=1, item_desc=dsc.Button, onClick=takePlace, mouse_right_click=dropPlace,
			tip = "Right mouse - drop"},
		},
		---onSet = FUNC_onSetList, --- после закрытия по "=" присвоит значение родителю
		mouse_overRun = false,
	}
	menuPlc:init({})
	--- так как это окно одно то можно его таскать
	DnD:Init( menuPlc.wtMenu, menuPlc.wtMenu, false)
	wtPlaceProbe = WCD(dsc.Border, nil, menuPlc.wtMenu, { alignX=0, alignY=0, sizeZ=40, sizeY=40 }, true )
	wtPlaceProbe:SetFade( 0.7 )
	wtPlaceProbe:SetPriority( menuPlc.wtMenu:GetPriority() + 10 )
	wtPlaceProbe:SetBackgroundTexture( getWorldTextutes()["BorderLight"].texture ) -- ItemMallBannerHighlight SlotBlink MarkHighlight

	menuPlc._Show = menuPlc.Show
	menuPlc.Show = function( self, on, inst )
		if on then
			if menuPlc.wtPlaced then
				menuPlc.PlaceTaken = false
				menuPlc.PlaceOld = menuPlc.wtPlaced:GetPlacementPlain()
				menuPlc.wtPlaced:AddChild(wtPlaceProbe)
			end
			wtSetPlace(wtPlaceProbe, { alignX=3, alignY=3, posX=0, posY=0, highPosX=0, highPosY=0})
			--LogToChat("wtPlaceProbe:PlayFadeEffect")
			wtPlaceProbe:PlayFadeEffect( 1, 0.2, 800, EA_SYMMETRIC_FLASH )
			self.PlayFade = true
		else
			self.PlayFade = false
			if menuPlc.wtPlaced then
				menuPlc.wtMenu:AddChild(wtPlaceProbe)
				if not menuPlc.PlaceTaken then menuPlc.wtPlaced:SetPlacementPlain(menuPlc.PlaceOld) end
			end
		end
		self:_Show( on, inst )
	end

end

-------------------------------------------
--------- FONT PANEL ----------------------
-------------------------------------------
local menuFnt

local function makeParamFont( obj, vN, name )
	local v = obj:getItemByName( vN )
	return v and ( v.value and (name or vN).."='"..v.value.."' ") or ""
end
local function makeParamClrFont( obj, vN, name )
	local clr = obj:getItemByName( vN )
	clr = clr and clr.value
	return clr and( (name or vN).."='0x"
			..string.format("%02X",(clr.a or 1)*255) --- color="0xFFFF771F"
			..string.format("%02X",(clr.r or 1)*255)
			..string.format("%02X",(clr.g or 1)*255)
			..string.format("%02X",(clr.b or 1)*255))
			.."' "
		or ""
end

local function FontMakeFormat( parent )
	local str, v, vN = "<html "

	str = str .. makeParamFont( parent, "fontname")
	str = str .. makeParamFont( parent, "fontsize")
	str = str .. makeParamFont( parent, "outline")
	str = str .. makeParamFont( parent, "shadow")
	str = str .. makeParamFont( parent, "alignx")
	str = str .. makeParamFont( parent, "aligny")

	str = str .. makeParamClrFont( parent, "color")
	str = str .. makeParamClrFont( parent, "shadowcolor")
	str = str .. makeParamClrFont( parent, "outlinecolor")

	return str.." ><r name='value'/></html>"
end

local function valOnSetFont( item )
	local parent = item and item.parent or menuFnt

	local str = FontMakeFormat( parent )

	for i, v in pairs(parent.strucMenu) do
		if v.token then
			v.labelFormat = str
			--parent:setLabel( item )
			--parent:SetVal( v )
			parent:repaint()
			break
		end
	end
end
local function takeFont(item)
	local obj = item.parent
	--LogInfo("takeFont")
	obj.returnVals = collectValsFromChild( obj )
	--LogInfo("obj.parentItem:", obj.parentItem.name )
	--obj.parentItem.value = collectValsFromChild( obj )
	--exObj2("obj.parentItem.value", obj.parentItem.value )
	obj:Show(false)
	--- вызов внешней процедуры для запис значения
	FUNC_onSetList( obj )

	--- тут значения бурется уже из сохраненых PS[key} по valGet
	--- поэтому нужно сначала выполнить процедуры сохранения - onClic onSet
	obj.parentObj:Update( { obj.parentItem } )
	--LogInfo("takeFont after Update")
end
local function dropFont(item)
	item.parent:Show( false, true )
end
--[[
local function FontPanelOpen( obj, item, wtBase )
	--externatWidgetRun = true --- показывает что мы запустили внешний виджет так что с него отлавливать будем реакцию
	obj:Enable( false )
	obj.mouse_overRun_temp = obj.mouse_overRun
	obj.mouse_overRun = false
	CURRENT_ITEM = item
--	selfs[wtColorPanel:GetInstanceId()] = { obj = obj, misc = w } --- запомним объект для вызова его в событиях

	--LogInfo("open CURRENT_ITEM",CURRENT_ITEM)

	setFontVals(item.value)

	wtChain( menuFnt.wtMenu, wtBase, 10, -50)

	menuFnt.wtMenu:SetPriority( obj.wtMenu:GetPriority() + 10 )
	menuFnt.wtMenu:Show( true )
end
]]

local fontNames, fntAlignx, fntAligny = { AllodWest = 1, AllodsSystem = 1 }, { "left", "center", "right"}, {"top","meddle","bottom"}
local function FontPanelInit()
	if menuFnt then return end
	menuFnt = menu{ strucMenu = 	{
		{ name = "fontname", label = "Name", type = "_txt", menuItems = fontNames, valOnSet=valOnSetFont},
		{ name = "fontsize", label = "Size", type = "_edn", chars=3, valOnSet=valOnSetFont },
		{ name = "color", label = "Color", type = "_clr", valOnSet=valOnSetFont },
		{ name = "alignx", label = "Align X", type = "_txt", listVals = fntAlignx, valOnSet=valOnSetFont},
		{ name = "aligny", label = "Align Y", type = "_txt", listVals = fntAligny, valOnSet=valOnSetFont},
		{ name = "shadow", label = "Shadow", type = "_edn", chars=1, valOnSet=valOnSetFont, tip="Set Shadow wight" },
		{ name = "shadowcolor", label = "Shadow Color", type = "_clr", valOnSet=valOnSetFont },
		{ name = "outline", label = "Outline", type = "_edn", chars=1, valOnSet=valOnSetFont, tip="Set Outline wight" },
		{ name = "outlinecolor", label = "Outline Color", type = "_clr", valOnSet=valOnSetFont },
		{ token = "_", label = "TEST text Format", type = "_clr", valOnSet=valOnSetFont },
		{ name = "takeIt", label = "Take or Drop It", cmd=1, item_desc=dsc.Button, onClick=takeFont, mouse_right_click=dropFont,
			tip = "Right mouse - drop"},
		},
		---onSet = FUNC_onSetList, --- после закрытия по "=" присвоит значение родителю
		mouse_overRun = false,
	}
	menuFnt:init({})
	--- так как это окно одно то можно его таскать
	DnD:Init( menuFnt.wtMenu, menuFnt.wtMenu, false)
	
end
--------------------------------------------------------------------------------
----------- COLOR_PANEL -------------------------
-------------------------------------------------
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
	return item
end

local function extendedMenuReactions( pars, react )
	local name, obj, item = pars.widget:GetName()
	externatWidgetRun = nil --- прекратим отслеживание реакций
	if name == "ColorPanel_btn" then
		if react == "mouse_left_click" then
			item = ColorPanelClose()
		elseif react == "mouse_right_click" then
			ColorPanelClose( true ) -- без сохранения значения
		end
	else
		--- еще мы не закончили работу с внешним виджетом
		externatWidgetRun = true
	end

	return item --- нужно для вызова внешней процедуры valOnSet
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
	for _, w in pairs(wAddonsTools:GetNamedChildren()) do
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
	wTip =WCD( dsc.Border, "tip_pan", nil, nil, nil, true )
	wTipTxt = WCD( dsc.Text, "tip_txt", wTip, nil, true )
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
local function setEditLineFormat( w, id )
	local alignX1 = "EditLineMoneyCount" -- "EditLineMoneyCount" -- "EditLineMoneyCountSelection"
	local alignX2 = "EditLineMoneyCountSelection"
	if id == 1 then w:SetGlobalClasses({ "Relic", "Size14", alignX1, }) --CommonCursed
	elseif id == 2 then w:SetGlobalClasses({ "RelicCursed", "Size20", alignX2, })
	elseif id == 3 then w:SetGlobalClasses({ alignX1, "CommonCursed", "Size16",}) -- "LogColorGreen"
	end
end


local function setBGtexture (w, txtre, name )
	if txtre then
		local val, valType
		valType = type(txtre)
		if valType == "number" then
		elseif valType == "string" then
			if txtre == "=name" then
				val = common.GetAddonRelatedTexture( name )
			else
				val = common.GetAddonRelatedTexture( txtre )
			end
		elseif valType == "function" then val = txtre( name )
		elseif valType == "table" then val = txtre[ name ]
		else val = txtre
		end
		if val then w:SetBackgroundTexture( val ) end
	end
end


local function getValsFromSelfs( wt )
	local ids = GetInstanceId(wt)
	local val = selfs[ids]
	if not val then return end
	return ids, val.obj, val.item, val.misc
end

--- либо функция либо массив
local function callFuncTab_0(item, func, pars)
	--LogInfo("callFuncTab_0 ", item.name, " value=",item.value," func:", func, " pars:", pars)
	local noPars = pars == nil and item == nil
	if type(func) == "function" then return func(pars == nil and item or pars)
	elseif type(func) == "table" then return noPars and func or func[pars == nil and item.name or pars]
	end
end
--- либо берет функцию у пункта меню либо общую от всего меню
local function callFuncTab(obj, item, funcName, pars )
	--LogInfo("callFuncTab: item:",item.name," func:", funcName, " pars:",pars)
	if item[funcName] then
		return callFuncTab_0( item, item[funcName], pars )
	elseif obj[funcName] then
		return callFuncTab_0( item, obj[funcName], pars )
	end
end
-- вычислим значение для отображения в поле пункта меню
local function calcValue(obj, item)

	local value, format = item.value
	--LogInfo("calcValue item:",item.name, " value:",value )

	if type(value) == "table" then return "{table}" end
	--- получим новое значение - если заданы метки для значений
	value = callFuncTab(obj, item, "valLabels", value ) or value

	--- на выходе может быть false
	if value == nil then value = item.defaultVal or obj.defaultVal end
	if value == nil then return "-" end

	if item.type == "_txt" or item.type == "_edl" or item.type == "_edn" --[[or item.type == "_mnu" --]] then
		--- итак тут значение вычислено, но еще не обработано как представление 
		--- поэтому тут поробуем взять формат для будущего представления
		--- по текущему значению
		format = callFuncTab( obj, item, "valFormats", value )
		--- создадим представление значения
		value = callFuncTab( obj, item, "valShapes", value ) or value
	end
	return value, format
end

--[[
local function makeItemValue( v )
--	return names[v] or v or "-"
	return v or "-"
end
]]

local enableTipsVal = true
function menuEnableTips(on)
	if on == nil then
		enableTipsVal = not enableTipsVal
	else
		enableTipsVal = on
	end
end
function tipRun(wBase, tip, active, prior)
	if active == true then
		
		wTipTxt:ClearValues()
		local tipTxt
		local len, lenX, lenY
		if type(tip) == "table" then
			--exObj2("tip", tip)
			if tip.VT then
				wTipTxt:SetValuedText( tip.VT )
				local len1 = string.len( FromWS( common.ExtractWStringFromValuedText(tip.VT) ) )
				len = (tip.len or 4) + len1
			else
				tipTxt = tip.values
				len = tip.len or 0 --- Добавочная длина в формате могут быть символы
				for _, v in pairs(tipTxt or {}) do
					len = len + string.len(v)
				end
				--- тут много парметров с форматом
				if tip.format then wTipTxt:SetFormat(ToWS(tip.format)) end
				for r, v in pairs(tipTxt or {}) do
					wTipTxt:SetVal(r,ToWS(L(v)))
				end
			end
		else
			wTipTxt:SetFormat( tipFormat )
			tipTxt = tip
			len = string.len(tipTxt)
			--- одиночная строка без формата
			wTipTxt:SetVal("value",ToWS(L(tipTxt)))
		end
		lenX = math.ceil(len^0.5 *TipShink)
		if lenX < 40 then lenX = 40 end
		lenY = math.ceil(len/lenX)
		wtSetPlace( wTip, { sizeX = lenX*9+60, sizeY=lenY*16 + 60 } )
		
		if wBase then
			wtChain( wTip, wBase, 10, 30)
			wTip:SetPriority( (prior or wBase:GetPriority()) + 100 ) ---or .wtMenu:GetPriority())+100)
			wtSetPlace( wTip, NormalizePlacement( wTip ) )
		end
		wTip:Show( true )
	else
		wTip:Show( false )
	end
end
function menuTipIsVisible() -- setBGtexture
	return wTip:IsVisible()
end
function menuTipSkin(obj)
	setBGtexture( wTip, obj.texture )
	if obj.color and type(obj.color) ~= "number" then wTip:SetBackgroundColor( obj.color ) end
end



local mouse_over_widget, mouse_over_widget_timer, mouse_over_tip_showed

local function showTip( wt, on )

	if not enableTipsVal then return end

	local ids, obj, item, misc = getValsFromSelfs( wt )
	if obj then
		setBGtexture( wTip, obj.texture )
		if obj.color and type(obj.color) ~= "number" then wTip:SetBackgroundColor( obj.color ) end
	end

	if item then
		if item.tip then
			mouse_over_tip_showed = on and wt
			--- у итема меню есть подсказка - запустим ее
			if type( item.tip ) == "function" then
				item.tip( item, tipRun, on )
			else
				tipRun( item.wtItemPan, item.tip, on, obj.wtMenu:GetPriority() )
			end
		end
	elseif misc then
		mouse_over_tip_showed = on and wt
		--tipRun( wt, obj.bottomTip.text, on, obj.wtMenu:GetPriority() )
		tipRun( wt, misc.tip, on, obj.wtMenu:GetPriority() )
	end
end
local function closeTip()
	if mouse_over_tip_showed then
		--LogToChat("closeTip  "..mouse_over_tip_showed:GetName())
		showTip( mouse_over_tip_showed, false )
		mouse_over_tip_showed = nil
	end
	mouse_over_widget_timer = 1 -- любое движение сброс запуска подсказки
	mouse_over_widget = nil
end

---ButtonToggle(obj, obj.wtEdited.del, "[-]")
local function ButtonToggle(obj, wtReact, LabelNormal, LabelPusshed, PROC)
	local vart = wtReact:GetVariant()
	wtReact:SetVariant( vart == 1 and 0 or 1)
	--LogInfo("mouse_overRun_temp ","buttonToggle =", vart)
	if vart == 0 then
		--- запретис гашение по выходу
		--LogToChat("del_btn in ButtToggle for "..obj.wtMenu:GetName())

		obj.mouse_overRun_temp = obj.mouse_overRun
		obj.mouse_overRun = false
		--- запретим прочие действия тут
		obj:enableEdited(false, { wtReact } )
		obj.mouse_left_click_instead = PROC
		wtSetVal(wtReact, LabelPusshed )
	else
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_left_click_instead = nil
		obj:enableEdited(true, { wtReact } )
		wtSetVal(wtReact, LabelNormal )
	end
end

local function tuneRowsCols(Len,Rin,Cin, sizeX, sizeY)
	local x,y = getScreenSizeCenter()
	local sX, sY = sizeX, sizeY
	local rate = x/y / (sX/sY)
	local R, C
	if Cin then
		C = Cin
		R = math.ceil( Len / C )
	elseif Rin then
		R = Rin
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


--- тут надо этот итем дабавить в структуру текущего
local function FUNC_selAddItem( item )
	local objChild = item.parent
	local obj = objChild.parentObj
	local newItem = { name = item.name, label = item.label, type = obj.type, 
		value = obj.defaultVal, valLabels = obj.valLabels, listVals = obj.vals }
	table.insert( obj.strucMenu, newItem )
	objChild:Show(false,true)
	obj:repaint()
	obj:Update( { newItem } )
end

local function FUNC_item_del( item, misc )
	local obj = item.parent
	obj.wtMenu:Enable(false)
	obj:removeItem(item.index)
	obj:repaint()
	obj.wtMenu:Enable(true)
	ButtonToggle(obj, obj.wtEdited.del, "[-]")
end

local ItemMoved
local function FUNC_item_move( item, misc )
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

function menu:getItemByName( name )
	local iName
	for i, v in pairs(self.strucMenu) do
		iName = v.name or (v.token and v.label)
		if iName == name then
			return v
		end
	end
end

function menu:setVal(item) --, toUpdate ) --- update value)
	if not item.wtVal then return end

	if item.type == "_fnt" then
		--LogInfo("menu:setVal(item) _fnt", item.name, "item.value:", item.value)
		if item.value and type(item.value) == "table" then
			local frmt = makeFontFormatFromTab( item.value )
			item.wtVal:SetFormat(ToWS(frmt))
		end
		return
	elseif item.type == "_plc" then
		return
	elseif item.type == "_clr" then
		if item.value and type(item.value) == "table" then
			item.wtVal:SetBackgroundColor(item.value)
		end
		return
	elseif item.type == "_icn" then
		local valGet, texture = item.valGet ---, getWorldTextutes()["Empty_Tiled"] --common.GetAddonRelatedTexture("Empty_Tiled")
		if item.value then
			if valGet then
				if type(valGet) == "function" then
					texture = valGet(item.value)
				elseif type(valGet) == "table" then
					texture = valGet[item.value]
				end
			else
				texture = item.value
			end
			if type(texture) == "string" then texture = common.GetAddonRelatedTexture(texture) end
		end
		if texture then item.wtVal:SetBackgroundTexture(texture) end
		return
	end

	--LogInfo("setVal "..item.name.."item.value:", item.value )
	local value, format = calcValue(self, item )
	--LogInfo("setVal:", value )
	local len = item.chars or 10
	--wtSetPlace( item.wtVal, { sizeX = len*10+10} )
	--if item.wtVal.SetMaxSize then item.wtVal:SetMaxSize(len+3) end

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

function menu:setIcon( item, wtIn )
	if not item.icon then return end
	local wt = wtIn or item.widgets["icn_"]
	if not wt then return end
	if type(item.icon) == "string" then item.icon = common.GetAddonRelatedTexture( item.icon ) end
	wt:SetBackgroundTexture( item.icon  )
	if item.icon_clr or item.parent.icon_clr then wt:SetBackgroundColor( item.icon_clr or item.parent.icon_clr ) end
end

function menu:setLabel( item, w )
	local lbl = callFuncTab(self, item, "labelShapes", item.label) or item.label
	--if item.icon then lbl = "      "..lbl end
--[[	if not w or item.widgets["mnu_"] or item.widgets["tkn_"] then
		exObj2("item", item)
	end]]
	if lbl == nil then
		LogError(" item:",item.name," in menu:", item.parent.name," .label is NIL")
		lbl = ".NIL."
	end
	wtSetVal( w or item.widgets["mnu_"] or item.widgets["tkn_"], lbl )
end
function menu:escEditLine( itemInput )
	local item = itemInput or self.currentEditItem
	if not item then return end

	local w = item.wtVal
	w:Enable(false)
	w:SetFocus(false)
	setEditLineFormat(w, 1 )
	self:setVal(item)

	self.currentEditItem = nil
end


--- погасить всех детей (в том читсле и пункты меню самого) кроме указанных
function menu:enableChilds( on, exclude )
	local onOff
	for _, w in pairs(self.wtMenu:GetNamedChildren()) do
		onOff = on
		for _, wtExclude in pairs(exclude) do
			if GetInstanceId(wtExclude) == GetInstanceId(w) then
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
	for _, w in pairs(self.wtEdited) do
		onOff = on
		for _, wtExclude in pairs(exclude) do
			if GetInstanceId(wtExclude) == GetInstanceId(w) then
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

local function menuClose( obj )
	
	obj.showOn = false
	obj.wtMenu:Show( false )
	if obj.parentObj then
		--- скажем родителю что ребенка закрыли
		obj.parentObj.childsActive = nil
		--LogInfo(obj.name,":  <- mouse_overRun_temp ","menuClose")
		obj.parentObj.mouse_overRun = obj.parentObj.mouse_overRun_temp
		obj.parentObj:Enable( true )
		if obj.parentObj.toClose then
			obj.parentObj:Show( false, true )
		else
			--obj.parentObj:Show( true, true )
		end
	end

end

local function PlayFade(obj, fadeFrom, fadeTo, time1)
	obj.wtMenu:FinishFadeEffect()
	--obj.wtMenu:Enable( obj.showOn and true or false ) --- погасим сразу тут окно но включать будем не тут
	local time2 = 0
	if fadeFrom ~= fadeTo then time2 = math.ceil( math.abs( time1 * (fadeTo - obj.wtMenu:GetFade()) / ( fadeFrom - fadeTo) ) ) end
	if time2 > time1 then time2 = time1 end
	if time2<50 then
		obj.wtMenu:SetFade( fadeTo )
		onEvent.EVENT_EFFECT_FINISHED( { wtOwner = obj.wtMenu } )
	else
		obj.wtMenu:PlayFadeEffect( obj.wtMenu:GetFade(), fadeTo, time2, EA_MONOTONOUS_INCREASE )
	end
end

local function activateAfterChild( obj, instantly )
	if instantly then
		obj.wtMenu:Show( true )
		obj.wtMenu:Enable( true )
		obj.wtMenu:SetFade( 1 )
	else
		obj.wtMenu:Show( true ) --- его могли выключить
		PlayFade( obj, obj.fadeVal, 1.0, obj.fadeOff )
	end
end

function menu:Show(on, instantly)
	if self.showOn == on then return end
	self.showOn = on --- сначала сменим указание
	self.wtMenu:FinishFadeEffect() --- сбросить

	if self.onShow then self:onShow( on, instantly ) end
	--LogInfo(" self:Show:", self.name,"  parent:",self.parentObj," on:", on )  
	local parentObj = self.parentObj
	if on == true then
		if parentObj then
			--LogInfo(" parentObj.childsActive:", parentObj.childsActive )  
			-- если у нас есть родитель то скажем ему что у него появился ребенок
			-- для того чтобы у него не менять гашение когда ребенок ребенка гаснет
			if not parentObj.childsActive then
				--- если еще не было детей то сохраним втемп 
				--- иначе не будем сохранять так возможно окно гасло уже но поновой открылось
				--- и ТЕМП уже перезаписался
				--LogInfo(self.name,":  -> mouse_overRun_temp ","Show")
				parentObj.mouse_overRun_temp = parentObj.mouse_overRun
				parentObj.mouse_overRun = false
			end
			parentObj.childsActive = true
			parentObj.wtMenu:Enable( false )
			PlayFade( parentObj, 1.0, parentObj.fadeVal, parentObj.fadeOff )
		end
		self:Update()
		self.wtMenu:Show(on)
		if instantly then 
			self.wtMenu:SetFade(1)
		else
			PlayFade( self, self.fadeVal, 1.0, self.fadeOn )
		end
	else
		if wTip then wTip:Show( false ) end
		if instantly then
			menuClose(self)
		else
			PlayFade( self, 1.0, 0.0, self.fadeOff )
		end
		if parentObj then
			activateAfterChild( parentObj, instantly )
		end
	end

end
function menu:IsVisible()
	return self.showOn
end

function menu:ItemFade( item, val )
	val = tonumber(val) or item.fade
	if val then
		item.fade = val
		item.wtItemPan:SetFade( val )
	end
end


--- поидее тут надо вставить свою обработку для каждй менюшки
function menu:Update( pars )
	local v
	--- перезапишем данные
	for i, item in pairs(pars or self.strucMenu) do
		if item.widget then --- их пропустим там сами должны
		elseif item.name and item.type ~= "_cmd" and not item.cmd then
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
		if item.label then self:setLabel(item) end
		if item.icon then self:setIcon(item) end
		menu:ItemFade( item )
	end
end

local function getStoreKey( item )
		return item.name or item.token
end

function menu:removeItem(index)
	local item = self.strucMenu[index]
	if not item then return end
	if not item.wtItemPan then exObj2("item", item) end
	
	if item.childObj then item.childObj:destroy() end

	local itemKey = getStoreKey( item )
	self.storeWT[itemKey] = nil
	for k, wt in pairs(item.widgets) do
		--- удалим ссылки для реакций
		self.menuItems[GetInstanceId(wt)] = nil
		selfs[GetInstanceId(wt)] = nil
	end
	--- удалим все виджеты элемента меню
	item.wtItemPan:DestroyWidget()
	--- удалим память что виджеты созданы в меню
	table.remove(self.strucMenu, index)
	return true
end


-------------------------------------------------------------------------------
-- EVENTS
-------------------------------------------------------------------------------
onEvent.EVENT_SECOND_TIMER = function ( pars )
	if mouse_over_widget then
		if mouse_over_widget_timer == 0 then
			showTip( mouse_over_widget, true )
			mouse_over_widget = nil
		else
			mouse_over_widget_timer = mouse_over_widget_timer - 1
		end
	end
end

onEvent.EVENT_EFFECT_FINISHED = function( pars )


	local wt = pars.wtOwner
	local wId = GetInstanceId( wt )
	if not wId then return end

	if wtPlaceProbe and GetInstanceId(wtPlaceProbe) == wId and menuPlc.PlayFade then
		wtPlaceProbe:PlayFadeEffect( 1, 0.2, 800, EA_SYMMETRIC_FLASH )
		return
	end

	local ids, obj, item, misc = getValsFromSelfs( pars.wtOwner )

	if not obj then return end
	if item or misc then return end -- это пункт меню

	--if obj.mouse_overRun_temp ~= nil then
	--	obj.mouse_overRun = obj.mouse_overRun_temp
	--end

	local fade = wt:GetFade()
	if fade == 1 then wt:Enable( true ) end
	if fade == 0 then
		--- это меню полностью погашено но даже если у него Enable - fasle
		--- оно все равно перехватывает мышку - а если хочется за окном пощелкать?
		wt:Show( false )
	end

	if logOn then LogInfo("EVENT_EFFECT_FINISHED",obj.name) end

	if obj.showOn then
		--- влючим тут только после полного гашения ребенка
		--obj.wtMenu:Enable( true )
	else
		--LogInfo(obj.name)
		menuClose(obj)
	end
end

-------------------------------------------------------------------------------
-- REACTIONS
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function reactionsOthers( obj, wtReact, reactName )
--- обработка кнопок для расширенного меню
	local wName = wtReact:GetName()
	if wName == "set_btn" then
		if reactName == "mouse_left_click" then
			reactionsOthers_SetButton( obj, reactName )
		else
			obj:Show( false, true )
		end
	elseif wName == "cls_btn" then
		obj:Show( false, true )
	elseif wName == "add_btn" then

		if obj.labels then
			--- тут есть подстановочные значения - выведем их
			if obj.addMenu then
				--- если такое меню уже создавалось
				wtChain( obj.addMenu.wtMenu, wtReact, -10, -30)
				obj.addMenu:Show( true, true )
			else
				---{ list.type = "_txt", list.labels = getAllTypes() }
				local strucMenu = {}
				for k, v in pairs(obj.labels) do
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
				--LogInfo(obj.name,":  -> mouse_overRun_temp ","reactionsOthers")
			obj.mouse_overRun_temp = obj.mouse_overRun
			obj.mouse_overRun = false
			obj.addingNewItem = { name = L("{empty}"), label = L("{empty}"), value = obj.defaultVal,
				type = obj.type, listVals = obj.vals }

			--menu:insertItem( item )
			table.insert( obj.strucMenu, obj.addingNewItem )
			obj.place = obj.wtMenu:GetPlacementPlain()
			obj:repaint()
			obj:Update( { obj.addingNewItem } )
			local n = obj.addingNewItem.widgets["mnu_"]
			n:Show(false) --- погасим пока саму кнопку у пункта меню
			obj.wtEdited.input:SetPlacementPlain(n:GetPlacementPlain())
			obj.addingNewItem.wtItemPan:AddChild( obj.wtEdited.input )
			wtSetVal(obj.wtEdited.input, obj.addingNewItem.name )
			obj.wtEdited.input:Show(true)
			obj.wtEdited.input:SetMaxSize( string.len (obj.addingNewItem.name) + 3 )
			obj.wtEdited.input:SetFocus(true)
			obj:enableChilds(false, { obj.wtEdited.input:GetParent() } ) -- отавим панель в котрой поле ввода
		end
		return --- выход иначе внизу пункт удалится
	elseif wName == "input_edl" and reactName == "on_enter" then
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
			--LogInfo(obj.name,":  <- mouse_overRun_temp ","reactionsOthers")
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		n:Show(true)
		obj:enableChilds( true, { obj.wtEdited.input:GetParent() } ) -- отавим панель в котрой поле ввода
		obj:repaint()
		obj:Update( { item } )
		return --- выход иначе внизу пункт удалится
	elseif wName == "del_btn" then
		ButtonToggle(obj, wtReact, "[-]", "-?-", FUNC_item_del)
	elseif wName == "move_btn" then
		ButtonToggle(obj, wtReact, "<=>", "?=>", FUNC_item_move)
	end

	if obj.addingNewItem then
		--- если было прервано вод нового пункта меню то
		obj.wtEdited.input:Show(false)
		obj.wtEdited.input:SetFocus(false)
			--LogInfo(obj.name,":  <- mouse_overRun_temp ","reactionsOthers")
		obj.mouse_overRun = obj.mouse_overRun_temp
		obj.mouse_overRun_temp = nil
		local index = obj.addingNewItem.index
		obj:removeItem(index)
		obj.addingNewItem = nil
		obj:repaint()
		obj:enableChilds( true, { obj.wtEdited.input:GetParent() } ) -- отавим панель в котрой поле ввода
	end

end
onReaction.mouse_over = function( pars )

	if DnD:IsDragging() then return end
	-- сюда может прийти от самого меню, от кнопки меню и от ТИПнижнего

	closeTip()

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )

	if false then
	elseif not obj or not obj.wtMenu:IsEnabled() then return --- если окно не разрешено то не откликаться на мышку
	elseif item then
		if item.fade and item.fade < 1 then
		else
			--exObj2("item", item, nil, excludeList )
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
			mouse_over_widget = pars.active and wt
		end
		if item.on_mouse_over then item.on_mouse_over( item, pars ) end
	elseif misc then
		local name = wt:GetName()
		if "bTip_pan" == name then
			mouse_over_widget = pars.active and wt
		elseif name == "ColorPanel" then
			if not pars.active then ColorPanelClose( true ) end --- закроем без перезаписи значения
		elseif type(misc) == "table" and misc.tip then
			mouse_over_widget = pars.active and wt
			
		end
		if misc.on_mouse_over then misc.on_mouse_over( misc, pars ) end
	else
		--LogInfo("mouse_over:", obj.name, " mouse_overRun:", obj.mouse_overRun)
		if obj.mouse_overRun then --- это само окно
			if logOn then LogInfo("menu_over ",obj.name, "active:", pars.active) end
			obj:Show( pars.active )
		end
		if obj.on_mouse_over then obj.on_mouse_over( obj, pars ) end
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
	setEditLineFormat( pars.widget, 3 )

	--- вызов внешней процедуры
	--- тут если была функция она на значение перепишется
	item.value = FromWS(pars.widget:GetText())
	obj:setVal(item)

	--[[if obj.on_enter then obj.on_enter( item )
	elseif obj.mouse_left_click then obj.mouse_left_click( item ) --, obj)
	end
	]]
	onClick( item, pars )

end

onReaction.mouse_left_click = function( pars )

	if DnD:IsDragging() then return end

	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	--LogInfo( ids,":", obj,":", item,":", misc)

	local reactName = "mouse_left_click"
	if not obj then
		if externatWidgetRun then
			--- это реакция от внешних виджетов, которые это меню запустило - например выбор цвета
			item = extendedMenuReactions( pars, reactName )
			--- запустим внешнию процедуру после обновления
			onClick( item, pars )
		end
		return
	end

	if logOn then LogInfo(obj.name, reactName ,pars.widget:GetName() ) end

	wTip:Show( false )
	if obj.currentEditItem then
		--- если был ввод - отменим его
		obj:escEditLine()
	end

	if misc then
		--- значит был нажат кнопка в спике-занчений
		reactionsOthers( obj, pars.widget, reactName)
		return
	end

	-- сюда придет только если есть ИТЕМ

	if obj.mouse_left_click_instead then
		--- если никаких действи тут не надо а вместо этого другое сделать на клик
		obj.mouse_left_click_instead( item, misc )
		return
	end

	--LogToChat("mouse_left_click")
	--exObj2("item", item, nil, excludeList)

	if false then
	elseif item.type == "_clr" then
		ColorPanelOpen( obj, item, pars.widget )
		return --- дальше не идем - иначе там onClick сработает
	elseif item.type == "_edl" or item.type == "_edn" then
		item.wtVal:Enable(true)
		setEditLineFormat( item.wtVal, 2 )
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
	elseif item.menuItems or item.type == "_lst" or item.type == "_fnt" or item.type == "_plc" then
		local mV
		--[[ это в :Show ребенка делается obj.mouse_overRun_temp = obj.mouse_overRun
		obj.mouse_overRun = false]]
		--LogInfo("make new menu, parentObj",obj.name,": temp:",obj.mouse_overRun_temp, " obj.mouse_overRun:", obj.mouse_overRun )
		local pars = {
			notSkinned = obj.notSkinned,
			--onSet = FUNC_onSetList,
			--mouse_left_click = FUNC_SelMenu,
			--onClick = FUNC_SelMenu,
			priority = obj.wtMenu:GetPriority() + 10,
			parentObj = obj, --- запомним кто родитель чтобы обратно управление передать - для показа меню родительского
			parentItem = item, --- и запомним для какого параметра изменения будут
			recurseCount = (obj.recurseCount or 0) + 1, --- подсчет рекурсии для разных выходов
			name = item.label,
			mouse_overRun = true,
			--- если это есть в ЛИСТ то далее перезапишется
			labelShapes = item.labelShapes or obj.labelShapes,
			labelFormat = item.labelFormat or obj.labelFormat,
			valShapes = item.valShapes or obj.valShapes,
			valFormats = item.valFormats or obj.valFormats,
			fadeOff = 300,
			texture = item.texture or obj.texture,
			color = item.color or obj.color,
			item_texture = item.item_texture or obj.item_texture,
			item_color = item.item_color or obj.item_color,
			}
			
		if not item.list then item.list = {} end
		local strucMenu = {}
		if item.type == "_fnt" then
			mV = menuFnt
			local mV_item --- через него както значения передаются! не помню уже как
			-- передадим значения
			--[[for k, v in pairs(item.value or {}) do
				mV_item = mV:getItemByName( k ) --- так вот тут берется итем из меню и ему присваивается
				mV_item.value = v
			end]]
			--- надо обнулить все пункты меню иначе онип римут значение отп редыдущей установки
			for k, mV_item in pairs(mV.strucMenu) do
				mV_item.value = item.value and item.value[mV_item.name]
			end
			pars.mouse_overRun = false
			pars.itemSizeY = 30
		elseif item.type == "_plc" then
			mV = menuPlc
			--exObj2("mVplc.place", mV.place)

			local mV_item --- через него както значения передаются! не помню уже как
			-- передадим значения
			--- надо обнулить все пункты меню иначе онип римут значение отп редыдущей установки
			for k, mV_item in pairs(mV.strucMenu) do
				mV_item.value = item.value and item.value[mV_item.name]
			end
			pars.mouse_overRun = false
			pars.itemSizeY = 30
		elseif item.strucMenu then
				mV = menu{ strucMenu = item.strucMenu,
					set_button = not (item.list and item.list.hide_set_button),
					onSet = FUNC_onSetList, --- выход только по нажатию на "=" или уходу мышки - чтобы взять все значения в полях
					}
			local mV_item --- через него както значения передаются! не помню уже как
			for k, v in pairs(item.value or {}) do
				mV_item = mV:getItemByName( k )
				if mV_item then mV_item.value = v end
			end
		elseif item.menuItems then
			--- тут просто список для выбора значения из списка
			if item.list.numberKeys then
				for i, menuItem in pairs(item.menuItems) do
					if type(menuItem) == "table" then
						strucMenu[i] = Clone( menuItem )
						strucMenu[i].value = item.value == menuItem.name and "<--" or nil
					else
						strucMenu[i] = { name = menuItem, label = menuItem, type = item.value == menuItem and "_txt" or "_nil",
							value = item.value == menuItem and "<--" or nil}
					end
				end
			else
				for name, menuItem in pairs(item.menuItems) do
					if type(menuItem) == "table" then
						if item.value == menuItem.value then
							item.highlight = true
						end
						table.insert( strucMenu, menuItem )
					elseif item.type == "_icn" then
						table.insert( strucMenu, { name = name, label = name, type = "_icn",
							value = name,
							--value = item.value == name and "<---" or nil,
							--highlight = item.value == name,
							} )
					else
						table.insert( strucMenu, { name = name, label = name, type = item.value == name and "_txt" or "_nil",
							value = item.value == name and "<---" or nil,
							highlight = item.value == name } )
					end
				end
				table.sort( strucMenu, function( A, B ) return A.name < B.name end )
			end
			mV = menu{ strucMenu = strucMenu,
				mouse_left_click = FUNC_SelMenu, --- тут обычнаый выбор по клику
				onClick = FUNC_SelMenu, --- тут обычнаый выбор по клику
				valOnSet = FUNC_SelMenu,
				}
		elseif item.list then
			local i = 0
			--- тут сложный список с item.data = ...
			for k, v in pairs(item.value) do
				i = i + 1
				local name, val = k, v
				if item.list.numberKeys then
					--- сигнализирует о том как из списка потом значения запаоквывать - с индексами номерами или сразу имена-ключи
					name, val = next(v)
				end
				strucMenu[i] = { name = name, label = item.list.labels and item.list.labels[name] or name,
					value = val, type = item.list.type, listVals = item.list.vals, valLabels = item.list.valLabels }
			end
			if not item.list.numberKeys then
				table.sort( strucMenu, function( A, B ) return A.name < B.name end )
			end

			mV = menu{ strucMenu = strucMenu,
				set_button = not item.list.hide_set_button,
				onSet = FUNC_onSetList, --- выход только по нажатию на "=" или уходу мышки - чтобы взять все значения в полях
				}
		end
		--exObj2("item.list", item.list)
		if item.list then
			for k, v in pairs(item.list) do
				pars[k] = v
			end
		end
		--exObj2("pars", pars, nil, excludeList)
		
		--exObj2("mV.place", mV.place)
		mV:init(pars, (item.type == "_fnt" or item.type == "_plc") )

		wtChain( mV.wtMenu, item.wtVal or item.widgets["mnu_"], -30, -40)
		if pars.DnD then
			--fUseCfg, fLockedToScreenArea, Padding,
			--kbFlag, --[[ KBF_ANY, KBF_SHIFT, KBF_ALT, KBF_CTRL, KBF_NONE or nil -]]
			--notCursor -- для слайдеров
			DnD:Init( mV.wtMenu, mV.wtMenu, pars.DnD.fUseCfg, pars.DnD.fLockedToScreenArea, pars.DnD.Padding )
		end

		local plc = mV.wtMenu:GetPlacementPlain()
		mV.place = { posX = plc.posX, posY = plc.posY, alignX=0, alignY=0 }
		mV:Show( true, true )

		if item.type == "_fnt" then valOnSetFont() end --- фонт нарисеум по загрузке
		if item.type == "_plc" then valOnSetPlace() end --- окошко нарисуем
		
		--item.menuObj = mV
		--LogInfo("mVparentObj:",mV.parentObj.name,": temp:",mV.parentObj.mouse_overRun_temp, " obj.mouse_overRun:", mV.parentObj.mouse_overRun )
		return --- без вызова внешних обработчков на клик
	elseif item.type == "_txt" then
		if (item.listVals or obj.listVals) then
			--- тут поиде список констант
			--- нам надо взять следующую по списку или первую
			local vals = item.listVals or obj.listVals
			--exObj("vals", vals )
			--LogInfo( item.value )
			local i
			for k, v in pairs(vals) do
				if v == item.value then i = k + 1 break end
			end
			--- возьмем следующее значение из списка или первое -- оноже по умолчанию на НИЛ="-"
			if i == nil or vals[i] == nil then item.value = vals[1]
			else item.value = vals[i]
			end
			--LogInfo( "i=",i, " val:", item.value)
			obj:setVal( item )
		else
		end
	elseif item.type == "_icn" then
		--onClick( item, pars )
		---return --- дальше не идем - иначе там onClick сработает
	else
		--LogToChat(item.name.." "..(item.type or ""))
	end

	--- вызов внешней процедуры
	if item.onClick then 
		item.onClick( item, pars )
	else
		onClick( item, pars )
	end

end

local function onRClick( item, pars )
		--- вызов внешней процедуры
	local func = item.mouse_right_click or item.onRClick or item.parent.mouse_right_click or item.parent.onRClick
	if func then func( item, pars ) end
end

onReaction.mouse_right_click = function( pars )

	if DnD:IsDragging() then return end
	local wt = pars.widget
	local ids, obj, item, misc = getValsFromSelfs( wt )
	local reactName = "mouse_right_click"

	--LogToChat("mouse_right_click")
	if not obj then
		if externatWidgetRun then
			--- это реакция от внешних виджетов, которые это меню запустило - например выбор цвета
			item = extendedMenuReactions( pars, reactName )
			--- запустим внешнию процедуру после обновления
			if item then onRClick( item, pars ) end
		end
		return
	end

	if logOn then LogInfo(obj.name, reactName ,pars.widget:GetName() ) end

	wTip:Show( false )
	if obj.currentEditItem then
		--- если был ввод - отменим его
		obj:escEditLine()
	end

	if misc then
		--- значит был нажат кнопка в спике-занчений
		reactionsOthers( obj, pars.widget, reactName)
		return
	end

	-- сюда придет только если есть ИТЕМ

	if obj.mouse_right_click_instead then
		--- если никаких действи тут не надо а вместо этого другое сделать на клик
		obj.mouse_right_click_instead( item, misc )
		return
	end

	if item then onRClick( item, pars ) end

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

function menu:getItemByIDS( ids )
	return selfs[ ids ].item
end

function menu:insertItem( item, pos )
	if pos then table.insert( self.strucMenu, pos, item )
	else table.insert( self.strucMenu, item )
	end
	if not pos then table.sort( self.strucMenu, function( A, B ) return (A.name or A.label) < (B.name or B.label) end ) end
	self:repaint()
	self:Update( { item } )
	return item
end

function menu:repaint()
	self:init(nil, true) -- тут елисли есть уже виджеты то просто перерисует или добавит чего нет
end
function menu:destroy()
	for i, item in pairs(self.strucMenu) do
		if item.childObj then item.childObj:destroy() end
	end
	selfs[self.id] = nil --- удалим сылку на объект
	self.wtMenu:DestroyWidget() --- освободим память от виджетов
end

---function menu:makeWidgets(self)
function menu:init(pars, repaint)

	if pars then
		for k, v in pairs(pars) do
			self[k] = v
		end
	end

	if self.notSkinned then
	else
		--exObj2("self.item_color", self.item_color)
		--exObj2("skin.item_color", skin.item_color)
		--- если параметр - число то одежку не применять тут
		self.texture = type(self.texture) == "number" and self.texture or skin.texture
		self.color = type(self.color) == "number" and self.color or skin.color
		self.item_texture = type(self.item_texture) == "number" and  self.item_texture or skin.item_texture
		self.item_color = type(self.item_color) == "number" and  self.item_color or skin.item_color
		--exObj2("self.item_color ->", self.item_color)
	end
	

	---------------------------------------------
	-------- динамическое создание интерфейса
	---------------------------------------------
	local w, n, i, v, d, x, y, sz, str, len, tpe, ddx, name, itemNameStore, wtPan, wtItem, itemKey, txtre, clr
	--- описания
	
	name = "menu_".. ( self.name or "" )
	w = self.wtMenu --- иначе не тот находит какойто mainForm:GetChildUnchecked(name, false )
	if not w then
		--- парметры по умолчанию только в первый раз иницализации установить
		self.storeWT = self.storeWT or {} -- тут все виджеты будем хранить
		--self.alfa = self.alfa -- or 0.8 --- transparency

		self.itemSizeX = self.itemSizeX or 250
		self.itemSizeY = self.itemSizeY or 25
		self.border_dX = self.border_dX or self.itemSizeY/2
		self.border_dY = self.border_dY or self.itemSizeY*1.5
		self.name = self.name or ""
		self.priority = self.priority or 500
		self.fadeOn = self.fadeOn or 500
		self.fadeOff = self.fadeOff or 1000
		self.fadeVal = self.fadeVal or 0.5 --- насколько тушить при откурывании ребенка

		w = mainForm:CreateWidgetByDesc( self.desc or dsc.Menu ) w:SetName( name )
		self.id = GetInstanceId(w)
		--- запомним объект для вызова его в событиях
		selfs[self.id] = { obj = self }

		n = WCD( self.border_desc or dsc.Border, "border", w, { alignX=3, alignY=3}, true )
		self.wtBorder = n

		self.wtMenu = w
		self.showOn = false

		n = WCD( dsc.Text, "Header", w, { highPosX=15, posY = -2, alignX = 3, alignY = 0, sizeY=self.itemSizeY }, true )
		repaint = nil
	else
		repaint = true
		--- погасим пока все итемы
		for k, wts in pairs(self.storeWT) do
			for kk, wt in pairs(wts) do
				wt:Show( false )
			end
		end
		self.place = w:GetPlacementPlain() --- еслие го таскали чтобы при перерисовке не улетело из под мышки ине закрылось
	end
	if not repaint then self.menuItems = {}
	else
	end
	local wtBorder
	if self.wtBorder then
		wtBorder = self.wtBorder
		self.wtMenu:SetBackgroundTexture( getWorldTextutes()["Empty_Tiled"].texture ) ---common.GetAddonRelatedTexture( "Empty_Tiled") )
	else 
		wtBorder = self.wtMenu
	end 
--- изменим прозрачность
	if self.alfa then 
		clr = wtBorder:GetBackgroundColor()
		clr.a = self.alfa
		wtBorder:SetBackgroundColor(clr)
	end
	
	if not self.place then
		if self.parentItem then
			n = self.parentItem.wtItemPan
		elseif self.parentObj then
			n = self.parentObj.wtMenu
		end
		wtChain( self.wtMenu, n, -30, -40)
		local plc = self.wtMenu:GetPlacementPlain()
		self.place = { posX = plc.posX, posY = plc.posY, alignX=0, alignY=0 }
	end
	wtSetPlace( w, self.place )

	setBGtexture( wtBorder, self.texture, self.name)
	if self.color and type(self.color) ~= "number" then wtBorder:SetBackgroundColor( self.color ) end
	w:SetPriority(self.priority)

	n = W("Header", w )
	n:SetFormat(ToWS("<html alignx='right' fontsize='14'><tip_golden><r name='value'/></tip_golden></html>"))
	n:SetVal("value", ToWS(self.headerText or self.name) )


	--- структура меню
	ddx = self.ddx or self.itemSizeY / 2
	local tLen = table.getn(self.strucMenu)

	self.rows1, self.cols1 = tuneRowsCols(tLen, self.rows, self.cols, self.itemSizeX+ddx, self.itemSizeY)
	if self.RowsColsRate and self.rows1 / self.cols1 < self.RowsColsRate then
		self.rows1 = math.ceil( (tLen * self.RowsColsRate)^0.5 ) + 1
		self.rows1, self.cols1 = tuneRowsCols(tLen, self.rows, self.cols, self.itemSizeX+ddx, self.itemSizeY)
	end

	--LogInfo("self.rows, self.cols",self.rows, ":", self.cols)

	i = 0
	local offset, valSize
	--local dPos = self.itemSizeY / 2
	for c = 1, self.cols1 do
	for r = 1, self.rows1 do
		i = i + 1
		local item = self.strucMenu[i]
		if not item then break end

		item.token = item.token and "_token"..i or nil --- переименуем все токены - иначе с одинаковыми названиями стирают друг друга
		itemKey = getStoreKey( item )
		if not itemKey then
			LogInfo("menuCls3.lua: menu:init() - .name and .token = nil! index="..i)
			ErrToChat("menuCls3.lua: menu:init() - .name and .token = nil! index="..i)
			break
		end


		-- теперь нам надо найти может уже такой пункт меню был создан и все его виджеты гдето созданы
		-- но на гругом номере - это возможно при изменени списка пунктов меню на лету
		item.widgets = self.storeWT[getStoreKey(item)]
		if not item.widgets then item.widgets = {} end

		item.index = i
		item.parent = self
		offset = item.offset or 0
		offset = type(offset) == "function" and offset(item) or offset
		x = (c-1)*self.itemSizeX + ddx + offset + self.border_dX
		y = (r-1)*self.itemSizeY + self.border_dY

		--- создадим контейнер - панель длял пункта меню куда закатем иконку, кнопку и виджет о знчениями
		name = itemKey.."_pan"
		itemNameStore = "pan_"
		n = item.widgets[itemNameStore]
		if not n then
			n = WCD( item.item_desc or self.item_desc or dsc.MenuItem, name, w, nil, true )
			item.widgets[itemNameStore] = n
			selfs[GetInstanceId(n)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
		else
			n:Show( true )
		end
		self.menuItems[GetInstanceId(n)] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
		wtPan = n
		item.wtItemPan = wtPan

		--- теперь настроим нуект меню
		sz = self.itemSizeX - 2*ddx - offset ---- string.len(item.label)*9+25
		if tonumber(item.fade) then wtPan:SetFade ( tonumber(item.fade) ) end
		wtSetPlace( wtPan, { sizeX = sz, sizeY = self.itemSizeY, posX = x, posY = y, alignX = 0, alignY = 0 } )

		if item.widget then
			--- если это готовый виджет
			name = item.name.."_txt"
			itemNameStore = "wdt_"
			n = item.widgets[itemNameStore]
			if not n then
				wtPan:AddChild( item.widget )
				item.widgets[itemNameStore] = item.widget --- запомним виджет - чтобы с нм чтонибудь потом делать
				if item.widget_react then
					selfs[GetInstanceId(item.widget_react)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
				end
			else
				n:Show( true )
			end
		elseif item.token then
			--- если это разделитель
			name = item.token.."_txt"
			itemNameStore = "tkn_"
			n = item.widgets[itemNameStore]
			if not n then
				n = WCD( dsc.Text, name, wtPan, { alignX = 3, alignY = 3 }, true )
				item.widgets[itemNameStore] = n --- запомним виджет - чтобы с нм чтонибудь потом делать
				selfs[GetInstanceId(n)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
			else
				n:Show( true )
			end
			self.menuItems[GetInstanceId(n)] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			if item.labelFormat then 
				n:SetAlignY( string.find(item.labelFormat,	"aligny='top'") and 0
					or string.find(item.labelFormat,	"aligny='bottom'") and 1
					or 2 )
			end
			if item.labelScale and n.SetTextScale then n:SetTextScale( item.labelScale ) end
			
			n:SetFormat(ToWS(item.labelFormat or "<html alignx='center' fontsize='16'><tip_golden><r name='value'/></tip_golden></html>"))
			item.label = item.label or item.token
			self:setLabel( item, n )
		else
			setBGtexture( wtPan, item.item_texture or self.item_texture, item.name)
			local item_color = item.item_color or self.item_color
			--LogInfo("type(item_color)=",type(item_color))
			if item_color and type(item_color) ~= "number" then
				wtPan:SetBackgroundColor( item_color )
				--exObj2("item_color", item_color)
			end
			if item.item_color_add then
				local clr = wtPan:GetBackgroundColor()
				for k,_ in pairs(clr) do
					clr[k] = clr[k] + (item.item_color_add[k] or 0)
				end
				wtPan:SetBackgroundColor( clr )
			end

			name = item.name.."_mnu"
			itemNameStore = "mnu_"
			n = item.widgets[itemNameStore]
			if not n then
				n = WCD( item.button_desc or self.button_desc or dsc.MenuItemBtn, name, wtPan, { alignX=3,alignY=3, posX=0,posY=0,highPosX=0,highPosY=0}, true )
				--- размер пункта меню потом зазадим по присутсвию иконки и размеру значения
				item.widgets[itemNameStore] = n --- запомним виджет - чтобы с нм чтонибудь потом делать
				selfs[GetInstanceId(n)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
			else
				n:Show( true )
			end
			self.menuItems[GetInstanceId(n)] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			self:setLabel( item, n )
			wtItem = n
			if item.labelScale and n.SetTextScale then n:SetTextScale( item.labelScale ) end

			setBGtexture(n, item.button_texture or self.button_texture, item.name)
			local button_color = item.button_color or self.button_color
			if button_color and type(button_color) ~= "number" then
				wtItem:SetBackgroundColor( button_color )
			end

			if item.highlight then
				--wtItem:SetBackgroundTexture(  )
				--LogToChat("highlight : ".. item.name)
				--LogInfo("highlight : ".. item.name)
				--wtItem:SetBackgroundColor( )
				--n:SetVariant( 1 ) --- ВАЛИТ КЛИЕНТА ЕСЛИ чтото не так с итемом в описатете виджета ((((((((((((
			end

			--- если у итема меню есть значения то создадим для них поле
			local enableEdit, itemType = false, item.type or self.type
			d = nil
			if itemType == "_chk" then
				d = dsc.Check
			elseif itemType == "_edl" then
				d = dsc.EditLine
				enableEdit = true
			elseif itemType == "_edn" then
				d = dsc.EditLineNum
				enableEdit = true
			elseif itemType == "_txt" or itemType == "_lst" --[[or itemType == "_mnu" --]] then
				---- обычное текстовое значение
				d = dsc.Text
			elseif itemType == "_clr" then
				---- панель для выбора цвета с движками
				d = dsc.Bar
				ColorPanelInit()
			elseif itemType == "_fnt" then
				---- панель для настройки фонта
				d = dsc.Text
				FontPanelInit()
			elseif itemType == "_plc" then
				---- панель для настройки фонта
				d = dsc.Text
				PlacePanelInit()
			elseif itemType == "_icn" then
				--- иконка
				d = dsc.Bar
			end
			if d then
				name = item.name.."_val"..itemType
				itemNameStore = "val_"
				v = item.widgets[itemNameStore]
				if not v then
					v = WCD( d, name, wtPan, nil, true )
					selfs[GetInstanceId(v)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
					item.widgets[itemNameStore] = v --- запомним виджеты для этого элемента меню - чобы потом их редактировать
				else
					v:Show( true )
				end
				item.wtVal = v --- запомним виджет в котором отображается значение
				if v.SetFormat then v:SetFormat(ToWS("<html alignx='right' aligny='bottom' fontsize='12' outline='1'><r name='value'/></html>")) end
				if v.SetGlobalClasses then
					setEditLineFormat( v, 1 )
				end
				if item.valueScale and v.SetTextScale then v:SetTextScale( item.valueScale ) end

				if itemType == "_fnt" then v:SetVal("value",ToWS("Ab")) end
				if itemType == "_plc" then v:SetVal("value",ToWS("{place}")) end

				valSize = self.itemSizeY


				if v.SetMaxSize and item.chars then
					--item.chars = item.chars or 5
					v:SetMaxSize(item.chars)
				end
				valSize = (itemType == "_clr" or itemType == "_icn" or itemType == "_chk") and self.itemSizeY*1.2
					or itemType == "_fnt" and self.itemSizeY*3
					or itemType == "_plc" and self.itemSizeY*5
					or item.chars and item.chars*self.itemSizeY/2
					--or self.itemSizeX/5
					or self.itemSizeY*4
				--valSize = valSize > self.itemSizeY*2 and valSize or self.itemSizeY
				--LogInfo(item.name, "  item.chars:", item.chars, "self.itemSizeY:", self.itemSizeY )
				wtSetPlace( v, { sizeX = valSize, highPosX = self.itemSizeY/2, alignX = 1,
					alignY = itemType == "_clr" and 2 or 3, sizeY = self.itemSizeY*1 } )

				---if v.GetInitialGlobalClass then exObj("cc",v:GetInitialGlobalClass(),true) end
				--v:Enable( enableEdit )
				v:SetPriority( 100 )
				self.menuItems[GetInstanceId(v)] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			else
			end

			if item.icon then
				name = item.name.."_icn"
				itemNameStore = "icn_"
				v = item.widgets[itemNameStore]
				if not v then
					v = WCD( dsc.PanelEmpty, name, wtPan, { alignX = 0, alignY = 2 }, true )
					item.widgets[itemNameStore] = v --- запомним виджеты для этого элемента меню - чобы потом их редактировать
					selfs[GetInstanceId(v)] = { obj = self, item = item } --- запомним объект для вызова его в событиях
				else
					v:Show( true )
				end
				wtSetPlace(	v, { sizeX = self.itemSizeY, sizeY = self.itemSizeY } )
				self:setIcon( item, v )
				self.menuItems[GetInstanceId(v)] = i --- запоним ИД чтобы на реакцию узнать ИТЕМ - список мог поменяьт - номера сдвинуться
			end

			wtSetPlace( wtItem, { posX = self.itemSizeY/2 + (item.icon and self.itemSizeY/2 or 0),
				highPosX = self.itemSizeY/2, alignX = 3, alignY = 3 } )

		end
		self.storeWT[getStoreKey(item)] = item.widgets --- запоним все виджеты что тут создали может потом их переиспользуем при пересборе меню
	end
	end


	if self.bottomTip then
		str = self.bottomTip.label
		len = string.len(str)
		name = "bTip_pan"
		itemNameStore = "bTip_pan"
		n = Wun0(name, w ) 
		if not n then
			n = WCD( dsc.PanelReact, name, w, { highPosX=15, highPosY = -2, alignX = 1, alignY = 1 }, true )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = self.bottomTip.text } }
			v = WCD( dsc.Text, "bTip_txt", n, { alignX = 3, alignY = 3 }, true)
		end
		wtSetPlace( n, { sizeX = self.itemSizeY*len+10, sizeY=self.itemSizeY } )
		v:SetVal("value", ToWS( str ))
	end

	if (self.set_button or self.edited) and not self.hide_set_button then
		name = "set_btn"
		n = Wun0(name, w ) 
		if not n then
			n = WCD( dsc.Button, name, w,{ posX = 0, highPosX = 20, posY = 0, highPosY = 3, alignX = 1, alignY = 1, sizeX = 35, sizeY=25 }, true )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = L("Click for TAKE result or Right Click for Drop") } } --- запомним объект для вызова его в событиях
			wtSetVal(n,"[=]")
		end
	end

	if self.close_button then
		name = "cls_btn"
		n = Wun0(name, w ) 
		if not n then
			n = WCD( self.close_button_desc or dsc.ButtonCornerCross, name, w,
				type(self.close_button) == "table" and self.close_button or { alignX = 1, alignY = 0 }, true )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, } }
			--wtSetVal(n,"[=]")
		end
	end

	if self.edited then
		name = "add_btn"
		n = Wun0(name, w ) 
		if not n then
			self.wtEdited = {}
			--- если разрешено изменение самого списка
			n = WCD( dsc.Button, name, w, { posX = 30, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 35, sizeY=25 }, true)
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = L("Click me than input name for item") } } --- запомним объект для вызова его в событиях
			wtSetVal(n,"[+]")
			self.wtEdited.add = n
	
			n = WCD( dsc.ToggleButton, "del_btn", w, { posX = 70, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 45, sizeY=25 }, true )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = L("For delete item - click on me than click on item") } } --- запомним объект для вызова его в событиях
			wtSetVal(n,"[-]")
			self.wtEdited.del = n
	
			n = WCD( dsc.ToggleButton, "move_btn", w, { posX = 120, highPosX = 0, posY = 0, highPosY = 3, alignX = 0, alignY = 1, sizeX = 45, sizeY=25 }, true )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = L("For move items - click on me and select 1st item than select 2nd item") } } --- запомним объект для вызова его в событиях
			wtSetVal(n,"[<=>]")
			self.wtEdited.move = n
	
			n = WCD( dsc.EditLine, "input_edl", w, { alignX=3, alignY =3 }, false )
			selfs[GetInstanceId(n)] = { obj = self, misc = { wt = n, tip = L("Press 'Enter' for TAKE result or 'ESC' for Drop") } } --- запомним объект для вызова его в событиях
			n:SetPriority(400)
			self.wtEdited.input = n
		end
	end

	local szX, szY = self.itemSizeX * self.cols1 + self.border_dX*2, 
			self.itemSizeY * self.rows1 + (self.sizeYbottom or 0 ) + ((self.set_button or self.edited) and 20 or 0 ) + self.border_dY*2
	self.wtSize = { sizeX = szX, sizeY = szY }
	wtSetPlace( self.wtMenu, self.wtSize )

end

------------------------------------------------------------------------------

-- register events
RegisterEventHandlers( onEvent )
-- register reactions
RegisterReactionHandlers( onReaction )
