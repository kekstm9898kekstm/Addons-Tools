

local _PS  --- параметры

function get_PS( name )
	--if name == "MY_texture" then LogInfo(_PS[name]) LogToChat(_PS[name]) end
	return name == nil and _PS or _PS[name]
end
function set_PS( key, val )
	if key then _PS[key] = val
	else _PS = val
	end
end

function reset_PS()
	_PS = {} --- обнулим текущие параметры
	for k, v in pairs(PS) do
		_PS[k] = v
	end
end

----------- WATCH seconds -----------------
local suspendedToDo = {}
local startedWatch

local function onEvent_EVENT_SECOND_TIMER()
	local pos, notEmpty
	--- уменьшим время ожидания у всех у кого оно есть
	for k, v in pairs(suspendedToDo) do
		notEmpty = true
		if v.time then
			if v.time > 0 then v.time = v.time - 1 ---LogToChat("["..k.."].time:"..v.time)
			else v.time = nil
			end
		else
			pos = k
		end
	end
	if notEmpty and not pos then return end --- ничего еще не готово
	local ToDo = notEmpty and table.remove( suspendedToDo, pos )
	if not ToDo then
		common.UnRegisterEventHandler( onEvent_EVENT_SECOND_TIMER, "EVENT_SECOND_TIMER" )
		startedWatch = false
	else
		---exObj("ToDo", ToDo)
		ToDo.proc(ToDo.pars)
	end
end

local function startWatch()
	if startedWatch then return end
	startedWatch = true
	common.RegisterEventHandler( onEvent_EVENT_SECOND_TIMER, "EVENT_SECOND_TIMER" )
end

--- положить в очередь вызов функции
function StartToDo( func, pars, time )
	table.insert(suspendedToDo, { proc = func, pars = pars, time = time } )
	startWatch()
end
-----------------------------
-- EMOTES
-----------------------------
----------- for test emote and reseive Text params:
--- { name = Name, tets=1 }
----------- for run emote:
--- { name = Name }
local onEvent = {}
local onEventAL = {} --- when Avatar Loaded
local onTest = {}
local stack = {}
local tested = {}
local emotesDB = {}
local Me, emoteRuned, emoteText

------------------------------------------------------------
function RunEmote( emote )
	---LogToChat("RunEmote:"..emote.name)
	if emote.name == "ClearMood" then
		--- сбросить настроение
		avatar.ClearMood()
		continueEmoTests()
		return
	end

	if not emotesDB[emote.name] then
		tested[emote.name] = { text = ToWS("unknown" ) }
		--- unknown emote
		if emote.test then userMods.SendEvent( "EVENT_EMOTE_TESTED", emote ) end
		return
	end
	local id = emotesDB[emote.name]
	emoteRuned = avatar.GetEmoteInfo( id )
	emoteRuned.test = emote.test
	--LogToChat(emote.name.." EMOTE runned")
	avatar.RunEmote( id )
end

-----------------------------------------------------------
--- "EVENT_CUSTOM_EMOTE" --- запускается по команде в чат /emote ...
-----------------------------------------------------------
---onTest.EVENT_CUSTOM_EMOTE = function ( pars )

onTest.EVENT_EMOTE_TEXT = function ( pars )
--id: ObjectId (not nil) - от кого пришло сообщение
--targetId: ObjectId - цель сообщения или nil
--text: WString - текстовое сообщение из базы (форматированный текст), в зависимости от наличия/отсутствия цели приходит соответствующий вариант (т.е. подразумевающий цель или нет)
--isAlive: boolean - жив игрок (может действовать) или нет (мертв или в числилище)
--image: TextureId - идентификатор изображения эмоции (иконки)
--image2: TextureId - идентификатор второго изображения эмоции (иконки)
	if pars.id ~= Me or not emoteRuned.test then return end
	userMods.SendEvent( "EVENT_EMOTE_TESTED", { name = emoteRuned.sysName, id = emoteRuned.id, text = pars.text } )
	--- запомним что уже тестировали
	tested[emoteRuned.sysName] = { id = emoteRuned.id, text = pars.text }
end

-----------------------------------------------------------
--- тут событие приходит 2 раза на одну эмоцию - вначале и в конце
--- поэтому надо проверить окончание нашей текущей эмоции
---------------------------------------------
function continueEmoTests()
	--- дальше из стека
	local i, nextEmote = next(stack)
	if nextEmote then
		table.remove( stack, i )
		onEventAL.EVENT_EMOTE_RUN( nextEmote )
	else
		--- стек пуст - мы свободны
	end
end

onEventAL.EVENT_EMOTES_CHANGED = function ( pars )
	if not emoteRuned then return end
	local emoteInfo = avatar.GetEmoteInfo( emoteRuned.id )
	if emoteInfo.canRun then
		--- эмоция закончилась - можно начинать следующую
		if emoteRuned.test then UnRegisterEventHandlers( onTest ) end
		emoteRuned = nil
		continueEmoTests()
	else
		--- эмоция началась
	end
end

onEventAL.EVENT_EMOTE_RUN = function ( pars )
	if pars.test and tested[pars.name] then
		---LogToChat(pars.name.." alredy exist")
		userMods.SendEvent( "EVENT_EMOTE_TESTED", { name = pars.name, id = tested[pars.name].id, text = tested[pars.name].text } )
	elseif not emoteRuned and avatar.IsExist() then
		---LogToChat(pars.name.." try test")
		if pars.test then RegisterEventHandlers( onTest ) avatar.TargetSelf() end
		RunEmote( pars )
	else
		---LogToChat(pars.name.." wait in stack")
		table.insert( stack, pars )
	end
end

--[[
--------------------------------------------------------------------------------
--- DND uniques
--------------------------------------------------------------------------------
local configVals = {} ---userMods.GetGlobalConfigSection( common.GetAddonName() ) or {}
local ids = {} -- список занятых
local ID
--ID = tonumber(_PS.dndIDstart)
local function makeKeyDnD( pars )
	return "DnD:"..pars.addon.."."..pars.index
end

onEvent.EVENT_GET_UNIQUE_DND_NUMBER = function ( pars )
	local key = makeKeyDnD(pars)
	--common.LogInfo( "common", "EVENT_GET_UNIQUE_DND_NUMBER:"..key )
	local id = configVals[key]
	if not id then
		--- сначала найдем овобожденные
		for i = tonumber(_PS.dndIDstart),1,1000 do
			if ids[ i ] == 0 then
				id = i
				break
			end
		end
		if not id then
			--- create new
			ID = ID + 1
			id = ID
		end
		configVals[key] = id
		ids[ id ] = 1
	end
	---common.LogInfo( "common", "EVENT_UNIQUE_DND_NUMBER_RECEIVED:"..key.."="..id )
	userMods.SendEvent( "EVENT_UNIQUE_DND_NUMBER_RECEIVED", { addon = pars.addon, index=pars.index, id = id } )
end

onEvent.EVENT_DND_NUMBER_RELEASED = function ( pars )
	local key = makeKeyDnD(pars)
	local id = configVals[key]
	if id then
		ids[ id ] = 0
		configVals[key] = nil
	end
end
]]
---- bulletinBoard ---------------------------------------------------------------------------
local messages = {}
local currMess
local registeredBB

--- сюда приходят системные сообщения для персонада в центре экрана - например что нельзя добавить еще одно сообщение
onEvent_EVENT_CLIENT_MESSAGE = function( pars )
	common.UnRegisterEventHandler( onEvent_EVENT_CLIENT_MESSAGE, "EVENT_CLIENT_MESSAGE" )
	--exObj("EVENT_CLIENT_MESSAGE", pars)
	--LogToChat("EVENT_CLIENT_MESSAGE",nil,true)
--[[
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE{
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.sysId="ENUM_WARNING_MESSAGE"
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.text="<html><LogColorRed>Доска объявлений: необходимо подождать <r name="timeToWait"/> секунд, чтобы написать новое сообщение в раздел "<r name="postType"/>".</LogColorRed></html>{WString}
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values{
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.1{
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.1.name="timeToWait"
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.1.int=423
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.1}
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.0{
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.0.name="postType"
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.0.resourceObject=userdata: 1A7073A0{userdata}
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values.0}
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE.values}
Info: addon AddonsTools: EVENT_CLIENT_MESSAGE}
]]
	for _, val in pairs(pars.values) do
		if val.name == "timeToWait" then
			--- найдено сообщение про ожидание по доске объявлений
			if currMess and val.int then
				---currMess.wait = val.int 
				--- пока нельзя добавлять -- положим его в стек отложенных действий
				---LogToChat("suspend on ".. val.int .."sec")
				table.insert(suspendedToDo, { proc = onEvent_EVENT_BULLETIN_BOARD_CHANGED, time = val.int , pars = Clone(currMess) } )
				startWatch()
			end
			break
		end
	end
end

onEvent_EVENT_BULLETIN_BOARD_CHANGED = function( pars )

	--- если вызов пришелся на занятое состояние то выход - подождем прихода сюда события освобождения доски
	if bulletinBoard.IsOperationInProgress() then 
		table.insert(suspendedToDo, { proc = onEvent_EVENT_BULLETIN_BOARD_CHANGED, time = 10, pars = pars } )
		return
	end

	--- возмем первоо сообщение
	local mess = pars or table.remove( messages, 1 )
	currMess = mess

	if not mess then
		common.UnRegisterEventHandler( onEvent_EVENT_BULLETIN_BOARD_CHANGED, "EVENT_BULLETIN_BOARD_CHANGED" )
		registeredBB = false
		return
	end

	common.RegisterEventHandler( onEvent_EVENT_CLIENT_MESSAGE, "EVENT_CLIENT_MESSAGE" )

	if mess.cmd == "add" then
		local result = bulletinBoard.CanAddText( mess.typeId )
		---exObj("add bull", result)
		---if result.isMsgLimitReached then return end
		if result.isCanAdd then
			---common.LogInfo( "common", "added:", mess.txt, mess.isPremium and " +isPremium" or "" )
			---LogToChat("add:"..FromWS(mess.txt))
			--exObj("bulletinBoard", _G ) --bulletinBoard)
			bulletinBoard.AddText( mess.typeId, mess.txt, mess.isPremium )
		else
			mess.suspend = result
			--- пока нельзя добавлять -- положим его в стек отложенных действий
			table.insert(suspendedToDo, { proc = onEvent_EVENT_BULLETIN_BOARD_CHANGED, pars = mess, time = 10 } )
			startWatch()
			--- и все же продолжим другие команды
			onEvent_EVENT_BULLETIN_BOARD_CHANGED()
			return
		end
	elseif mess.cmd == "edit" then
		---common.LogInfo( "common", "edited:"..mess.id, "=", mess.txt )
		---LogToChat("edited:"..FromWS(mess.txt))
		bulletinBoard.EditText( mess.id,  mess.txt ) 
		--- так как при редавтировании не будет изменений а 1 лимит объявлений потратится
	elseif mess.cmd == "del" then
		---common.LogInfo( "common", "deleted:"..mess.id )
		bulletinBoard.DeleteText( mess.id )
	end

	--- для продолжения других объявлений - параметры = ПУСТО
	StartToDo( onEvent_EVENT_BULLETIN_BOARD_CHANGED, nil, 10 )

end


--[[ пока отключим так как с доской облом небольшой
onEventAL.AT_BULLETIN_BOARD_COMMAND = function ( pars )
	--- { typeId, id=ID mess=WSstring, cmd=txtConnamd, isPremium }
	---common.LogInfo( "common", "run:", pars.txt )
	table.insert( messages, pars )
	if not registeredBB then common.RegisterEventHandler( onEvent_EVENT_BULLETIN_BOARD_CHANGED, "EVENT_BULLETIN_BOARD_CHANGED" ) end
	registeredBB = true
	--- вызов принудительно - так как может быть никаких изменения ранее не делалось
	onEvent_EVENT_BULLETIN_BOARD_CHANGED()
end
]]

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local templateCFG = {"unloaded",  }
function toConfig()
	local cfg = {}
	cfg.PS = {}
	for name, pars in pairs(_PS or {}) do
		if type(pars) ~= "table" and not PS[name] or PS[name] ~= pars then
			--- запаковать только то чего нет в config.txt или изменено
			--- чтобы не раздувать файл user.cfg
			cfg.PS[name] = pars
		end
	end

	cfg.am, cfg.fb, cfg.ams = addons_toConfig()

	userMods.SetAvatarConfigSection( ADDONname, cfg )

	sendSKIN()

	LogToChat(L("saved"), nil, true)
end
function fromConfig()
	--- если секция не найдена то инициализируем как таблицу
	local cfg = userMods.GetAvatarConfigSection( ADDONname ) or {}
	---_PS = {}
	for name, pars in pairs(cfg.PS or {}) do
		_PS[name] = pars
	end
	--exObj2("->_PS",_PS)
	
	SetGameLocalization(_PS.Localize)

	addons_fromConfig( cfg.am, cfg.fb, cfg.ams )

	sendSKIN()

	LogToChat(L("loaded"), nil, true)
end

function toConfigGlobal()
	--- тут нельзя весь конфиг браьт так так там еще ДнД и прочее
	local cfg = userMods.GetGlobalConfigSection( ADDONname ) or {}
	if not cfg.PS then cfg.PS = {} end
	for name, pars in pairs(_PS or {}) do
		if type(pars) == "table" or cfg.PS[name] == nil or cfg.PS[name] ~= pars then
			--- запаковать только то чего нет в config.txt или изменено
			--- чтобы не раздувать файл user.cfg
			cfg.PS[name] = pars
		end
	end
	cfg.am, cfg.fb, cfg.ams = addons_toConfig()
	userMods.SetGlobalConfigSection( ADDONname, cfg )

	LogToChat(L("saved").." "..L("global"), nil, true)
end
function fromConfigGlobal()
	--- если секция не найдена то инициализируем как таблицу
	--- тут нельзя весь конфиг брать так так там еще ДнД и прочее
	local cfg = userMods.GetGlobalConfigSection( ADDONname ) or {}

	---_PS = {}
	for name, pars in pairs(cfg.PS or {}) do
		_PS[name] = pars
	end
	SetGameLocalization(_PS.Localize)

	addons_fromConfig( cfg.am, cfg.fb, cfg.ams )

	LogToChat(L("loaded").." "..L("global"), nil, true)
end

EVENT_DND_PICK_ATTEMPT = function()
		mission.DNDCancelDrag()
end
function DnDWorldLock()
	if _PS.DnDWorldLock == "ON" then
		LogToChat("DnDWorldLock ON")
		common.RegisterEventHandler( EVENT_DND_PICK_ATTEMPT, "EVENT_DND_PICK_ATTEMPT" )
	else
		common.UnRegisterEventHandler( EVENT_DND_PICK_ATTEMPT, "EVENT_DND_PICK_ATTEMPT" )
	end
end

local function onAvatarCreated( pars )
	
	DnDWorldLock()
	common.UnRegisterEventHandler( onAvatarCreated, "EVENT_AVATAR_CREATED" )
	local emo
	for _, id in pairs(avatar.GetEmotes()) do
		emo = avatar.GetEmoteInfo( id )
		emotesDB[emo.sysName] = id
	end
	Me = avatar.GetId()
	RegisterEventHandlers( onEventAL )
	continueEmoTests() --- тогда можно эмоци посылать сюда не ожиждая загрузки аватара
	
	InitPhanTime()
	
	userMods.SendEvent( "EVENT_ADDONS_TOOLS_AVATAR_CREATED", { } )

end


reset_PS()
reset_addons()
fromConfigGlobal()
--exObj("_PS glb", _PS)
fromConfig()
--exObj("_PS", _PS)

RegisterEventHandlers( onEvent )
userMods.SendEvent( "EVENT_ADDONS_TOOLS_STARTED", { } )
--sendSKIN()

if avatar.IsExist() then onAvatarCreated() --- для инициализации при загрузке/выгрузке
else common.RegisterEventHandler( onAvatarCreated, "EVENT_AVATAR_CREATED" ) end

--InitPhanTime() --- тут другие аддоны что ниже по списку имен не успевают загрузиться вообще
