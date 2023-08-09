--------------------------------------------------------------------------------
-- GLOBALS для загрузки из config.txt
Global( "_", nil )
Global( "ON", "ON" )
Global( "OFF", "OFF" )

Global( "ADDONname", common.GetAddonName() )
Global( "ERROR", false )

Global("PS", { 
	TimeZoneOffset = 0,
	dndIDstart = 357,
	MY_texture = "FrameBBlue2",
	MY_color = {a=0.7,r=1,g=1,b=0.7},
	MY_item_texture = "ButtonB",
	MY_item_color = {a=0.7,r=0.5,g=0.7,b=1},
	--FB_texture = "RacePlateSelected",
	--FB_color = {a=0.7,r=1,g=0.4,b=0.6},
	FB_item_texture = "ButtonRegular1-Disabled",
	FB_item_color = {a=1,r=1.0,g=1,b=1},
	FB_icon = "Will",
} )