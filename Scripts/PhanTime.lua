-- PhanTime
---------------------------------------------------------------------------------

local dsc
local wBtn

-- Панели ----------------------------
local wxMainPanel, wxTimePanel, wxTimerPanel, wtFButtonsPan, wtFButtonsCont, wtFButton
-- Текст ----------------------------
local wtTimeText, wtTimerText
-- Кнопки ---------------------------
local wbTimerButton, wbTimerActiveButton, wbPauseButton, wbPauseActiveButton
-- Other ---------------------------
local Time = {}
local Timer = {}
local GotTime = false 
local TimerRun = false

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function TimeTextSetVal( wtparam, param )

	wtparam:SetVal( "hours", common.FormatInt( param.h , "%02d" ) )
	wtparam:SetVal( "minutes", common.FormatInt( param.m , "%02d" ) )
	wtparam:SetVal( "seconds", common.FormatInt( param.s , "%02d" ) )
	
end
---------------------------------------------------------------------------------
function TimeTextInit( wtparam, param )

	param.h = 0
	param.m = 0
	param.s = 0

	TimeTextSetVal( wtparam, param )

end
---------------------------------------------------------------------------------
function SetCurrentTime( param )
	if not math.mod then math.mod = function ( x, y ) return x % y end end
	Time = param
	Time.h = Time.h + math.floor( tonumber(get_PS("TimeZoneOffset")) or 0 )
	if Time.h > 23 then Time.h = math.mod( Time.h, 24 ) end
	if Time.h < 0 then Time.h = math.mod( Time.h, 24 ) + 24 end
	GotTime = true

end
---------------------------------------------------------------------------------
function TimeCounter()

	-- Синхронизация времени, один раз в минуту.
	if Time.s == 59 and mission.GetWorldTimeHMS then -- AO 1.1.03+
		SetCurrentTime( mission.GetWorldTimeHMS() )
	end
	
	if (Time.s == 59) then
		Time.s = 0
		if (Time.m == 59) then
			Time.m = 0
			if (Time.h == 23) then
				Time.h = 0
			else
				Time.h = Time.h + 1
			end
		else
			Time.m = Time.m + 1
		end
	else
		Time.s = Time.s + 1
	end

	TimeTextSetVal( wtTimeText, Time )
end
---------------------------------------------------------------------------------
function TimerCounter()

	if (Timer.s == 59) then
		Timer.s = 0
		if (Timer.m == 59) then
			Timer.m = 0
			Timer.h = Timer.h + 1
		else
			Timer.m = Timer.m + 1
		end
	else
		Timer.s = Timer.s + 1
	end

	TimeTextSetVal( wtTimerText, Timer )
end
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- EVENT HANDLERS
---------------------------------------------------------------------------------
local valuedText = common.CreateValuedText()
local format = "<html fontname='AllodsWest' fontsize='14' shadow='1'><tip_blue><r name='text'/></tip_blue></html>"
valuedText:SetFormat(ToWS(format))

local cccc = 1
local function pushVT( VT )
	if wtFButtonsCont.PushFrontValuedText then
		wtFButtonsCont:PushFrontValuedText( VT )
	end
end
local function pushBT( BT )
	if false and wtFButtonsCont.Insert then
		LogToChat("Insert")
		wtFButtonsCont:Insert( 1, BT )
	end
	if wtFButtonsCont.PushBack then
		LogToChat("PushBack")
		wtFButtonsCont:PushBack( BT )
	end
end

--[[local function onTimePanelLeft( pars )
	FBmenuShow( true )
end]]

local function onTimePanelDbl( pars )
	if wBtn:GetInstanceId() == pars.widget:GetInstanceId() then
		AddonsMenuShow( wtTimerText, true )
	end
end

-- Включение панели таймера, Запуск таймера
function OnTimerButtonReaction( )

	TimeTextInit( wtTimerText, Timer )

	TimerRun = true

	wxTimerPanel:Show( true )
	wbPauseButton:Show( true )
	wbPauseActiveButton:Show( false )

	wbTimerButton:Show( false )
	wbTimerActiveButton:Show( true )

	--local p = wxMainPanel:GetPlacementPlain()
	--p.sizeY =80
	--wxMainPanel:SetPlacementPlain( p )

end
---------------------------------------------------------------------------------
--Выключение панели таймера, Останов таймера
function OnTimerActiveButtonReaction( )

	TimerRun = false

	wxTimerPanel:Show( false )
	wbTimerButton:Show( true )
	wbTimerActiveButton:Show( false )

	wbPauseButton:Show( false )
	wbPauseActiveButton:Show( false )

	--local p = wxMainPanel:GetPlacementPlain()
	--p.sizeY = 80
	--wxMainPanel:SetPlacementPlain( p )

end
---------------------------------------------------------------------------------
-- Вкл. паузу
function OnPauseButtonReaction( )
	TimerRun = false;
	wbPauseButton:Show( false )
	wbPauseActiveButton:Show( true )
end
-- Выкл. паузу
function OnPauseActiveButtonReaction( )
	TimerRun = true;
	wbPauseButton:Show( true )
	wbPauseActiveButton:Show( false )
end
---------------------------------------------------------------------------------
-- Каждую секунду
function OnEventSecondTimer( )

	if GotTime then TimeCounter() end
	if TimerRun then TimerCounter() end

end


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- INITIALIZATION
---------------------------------------------------------------------------------
function InitPhanTime()

 if not mission.GetWorldTimeHMS then
  mission.GetWorldTimeHMS=function()
   local eva=common.GetLocalDateTime()
   eva.m=eva.min
   return eva
  end
 end
	SetCurrentTime( mission.GetWorldTimeHMS() )
	
	-- Каждую секунду
	common.RegisterEventHandler( OnEventSecondTimer, "EVENT_SECOND_TIMER" )
	-- Регистрируем кнопочные события
	common.RegisterReactionHandler( onTimePanelDbl, "mouse_double_click" )
	--common.RegisterReactionHandler( onTimePanelLeft, "mouse_left_click" )

	common.RegisterReactionHandler( OnTimerButtonReaction, "wbTimerButtonReaction" )
	common.RegisterReactionHandler( OnTimerActiveButtonReaction, "wbTimerActiveButtonReaction" )
	common.RegisterReactionHandler( OnPauseButtonReaction, "wbPauseButtonReaction" )
	common.RegisterReactionHandler( OnPauseActiveButtonReaction, "wbPauseActiveButtonReaction" )
	
	-- Основная панель (контейнер)
	wxMainPanel = mainForm:GetChildChecked( "PhanTime", false )
	
	-- Вложенные панели
	wxTimePanel = wxMainPanel:GetChildChecked( "TimePanel", false )
	wxTimerPanel = wxMainPanel:GetChildChecked( "TimerPanel", false )
	wxTimerPanel:Show( false )

	-- Текст
	wtTimeText = wxTimePanel:GetChildChecked( "TimeText", false )
	wtTimerText = wxTimerPanel:GetChildChecked( "TimerText", false )
	
	-- Кнопки
	wbTimerButton = wxTimePanel:GetChildChecked( "wbTimerButton" , false )
	wbTimerActiveButton = wxTimePanel:GetChildChecked( "wbTimerActiveButton" , false )
	wbTimerActiveButton:Show( false )

	wbPauseButton = wxTimerPanel:GetChildChecked( "wbPauseButton" , false )
	wbPauseActiveButton = wxTimerPanel:GetChildChecked( "wbPauseActiveButton" , false )
	wbPauseActiveButton:Show( false )

	-- Backward compatibility with pre-1.1.04 versions:
	if not social.GetFriendInfo then
		mainForm:SetPriority( 10000 )
	end
	
	dsc = AddonsMenuInit( )
	
	wBtn = WCD( dsc.ButtonHide, "PT_buton",	wxTimePanel, { posX=0, highPosX=0, posY=0, highPosY=0, alignX = 3, alignY = 3 }, true )
	
	FBmenuInit(wxMainPanel, wBtn)
	

end


function get_PTwtMainPanel()
	return wxMainPanel, wBtn
end
