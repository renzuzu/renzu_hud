-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
---------------------------------------------------------https://github.com/renzuzu/renzu_hud------------------------------------------
config = {}
config.gamebuild = 'auto' -- if 2189 pedshot transparent and 1604 or < 2000 = Enter vehicle game event will not work, we will use normal pedshot ( gamebuild is what you set on your server start example: +set sv_enforceGameBuild 2189, available build 1604, 2060, 2189 and more.) this is important if you are using UI Normal with Ped Face.
config.framework = 'ESX' -- ESX | QBCORE | VRP | STANDALONE (VRP not supported yet, but you can use standalone, it will work!)
config.Mysql = 'mysql-async' -- 'ghmattisql' | 'mysql-async' | 'oxmysql'
config.weight_type = false -- ESX item weight or limit type
config.vehicle_table = 'owned_vehicles' -- change this if you use different sql table for player vehicles (note identifier steam is always being used here)
config.Owner_column = 'owner' -- owner column name for identifier eg.steam hex,licensed
config.ESX_Items = { -- important to change job, weight. (job = false means its available to use for everyone) -- do not change the array name ex. ['nitro'], you can change the name = 'nitro'
	['nitro'] = {name = 'nitro', event = 'renzu_hud:addnitro', value = false, weight = 1, label = 'Nitro', job = false},
	['coolant'] = {name = 'coolant', event = 'renzu_hud:coolant', value = false, weight = 1, label = 'Coolant', job = false},
	['engineoil'] = {name = 'engineoil', event = 'renzu_hud:oil', value = false, weight = 1, label = 'Engine Oil', job = 'mechanic'},
	['turbo_street'] = {name = 'turbo_street', event = 'renzu_hud:install_turbo', value = 'street', weight = 1, label = 'Street Turbine', job = 'mechanic'},
	['turbo_sports'] = {name = 'turbo_sports', event = 'renzu_hud:install_turbo', value = 'sports', weight = 1, label = 'Sports Turbine', job = 'mechanic'},
	['turbo_racing'] = {name = 'turbo_racing', event = 'renzu_hud:install_turbo', value = 'racing', weight = 1, label = 'Racing Turbine', job = 'mechanic'},
	['head_brace'] = {name = 'head_brace', event = 'renzu_hud:healbody', value = 'head', weight = 1, label = 'Head Brace', job = false},
	['leg_bandage'] = {name = 'leg_bandage', event = 'renzu_hud:healbody', value = 'leg', weight = 1, label = 'Leg Bandage', job = false},
	['arm_bandage'] = {name = 'arm_bandage', event = 'renzu_hud:healbody', value = 'arm', weight = 1, label = 'Arm Bandage', job = false},
	['body_bandage'] = {name = 'body_bandage', event = 'renzu_hud:healbody', value = 'chest', weight = 1, label = 'Body Bandage', job = false},
	['street_tirekit'] = {name = 'street_tirekit', event = 'renzu_hud:installtire', value = 'default', weight = 1, label = 'Street Tire Kit', job = 'mechanic'},
	['sports_tirekit'] = {name = 'sports_tirekit', event = 'renzu_hud:installtire', value = 'sports', weight = 1, label = 'Sports Tire Kit', job = 'mechanic'},
	['racing_tirekit'] = {name = 'racing_tirekit', event = 'renzu_hud:installtire', value = 'racing', weight = 1, label = 'Racing Tires Kit', job = 'mechanic'},
	['drag_tirekit'] = {name = 'drag_tirekit', event = 'renzu_hud:installtire', value = 'drag', weight = 1, label = 'Drag Tires Kit', job = 'mechanic'},
	['manual_tranny'] = {name = 'manual_tranny', event = 'renzu_hud:manual', value = true, weight = 1, label = 'Manual Trannsmition', job = 'mechanic'},
	['automatic_tranny'] = {name = 'automatic_tranny', event = 'renzu_hud:manual', value = false, weight = 1, label = 'Automatic Tranny', job = 'mechanic'},
}
config.enable_commands_as_item = true -- if you are not using ESX, you can enable this, you can type /useitem nitro (for example) -- standalone purpose without ESX
config.commanditem_permission = { -- item command permission -- standalone purpose!
	'steam:11000013ec77a2e', -- steam hex id, change this to yours, you can add as many as you want
	'steam:11000013ec77a2e',
	'df845523fc29c5159ece179359f22a741ca2ca9a',
	'license:df845523fc29c5159ece179359f22a741ca2ca9a',
}
config.identifier = 'license:' -- standalone purpose, carlock
--MULTI CHARACTER START -- set config.multichar = false if you are not using any multi character ( configuring this is needed to avoid problems saving to database )
config.multichar = false -- KASHACTERS, cd_multicharacter, etc...
--IMPORTANT PART IF USING Multicharacter
-- if multichar_advanced is false == using steam: format or the config.identifier
config.multichar_advanced = true -- Using Permanent Char1,Char2 up to Char5 identifier from database. ( This means the identifier reads by ESX or other framework will have Char1:BLAHBLAHBLAH instead of steam:BLAHBLAHBLAH ( from xPlayer.identifier for example))
config.characterchosenevent = 'kashactersS:CharacterChosen' -- this event contains charid (IMPORTANT and will read only if using advanced)
config.charprefix = 'Char' -- dont change unless you know what you are doing
--loadedasmp will use the charslot from user_lastcharacter, kashacters and other multicharacter have this.
config.loadedasmp = false -- if player model is mp player, pass the loaded event to server ( naturally if player model is PLAYER_ZERO its mean you are on the loading screen or in the character select page of your multicharacter script. )
config.forceplayerload = false -- false playerloaded event (use this only if you experience hud not loading at all, and if you dont use multicharacter or else you will get server error about player nil value)
--MULTI CHAR END
--MAIN UI CONFIG START
config.enablestatus = true -- enable/disable status v1 ( icons,progress status ) -- this will disable all status functions
config.enablecompass = true -- enable/disable compass

-- minimap
config.radarwhiledriving = true
config.useminimapeverytime = false -- FORCE display radarmap all the time? (USE THIS ONLY IF Some of your other script use displayradar(FALSE) , its advisable to disable this config instead remove it on your other script, default GTA show the Minimap everytime)
config.usecircleminimap = true -- display oval minimap instead of box radar map?
config.removemaphealthandarmor = false -- FORCE REMOVE HEALTHBAR AND ARMOR FROM MINIMAP (This will cause more infinite loop just to disable the hp and armor, will cause more Cpu ms at resmon) -- USE THIS ONLY IF minimap.gfx is not working for you, its on the stream folder, it remove health and armor automatically

-- COMPASS STREET LOCATION Customization options
config.border = { r = 255; g = 255; b = 255; a = 0.65; size = 2.5; }; config.current = { r = 9; g = 222; b = 1; a = 0.9; size = 1.0; }; config.crossing = { r = 255; g = 233; b = 233; a = 0.9; size = 1.1; }; config.direction = { r = 255; g = 233; b = 233; a = 0.9; size = 2.5; }; config.position = { offsetX = 17; offsetY = 1.2; };

config.vehicleCheck = true

-- GEAR FUNCTION
nextgearhash = `SET_VEHICLE_NEXT_GEAR`
setcurrentgearhash = `SET_VEHICLE_CURRENT_GEAR`
function SetRpm(veh, val)
    Renzu_Hud(0x2A01A8FC, veh, val)
end
function SetVehicleNextGear(veh, gear)
    Renzu_Hud(nextgearhash & 0xFFFFFFFF, veh, gear)
end
function SetVehicleCurrentGear(veh, gear)
    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, veh, gear)
end

function Renzu_SetGear(vehicle, gear)
    if gear >= 6 then
        gear = 6
    end
	if gear < 0 then
		gear = 1
	end
    Hud:ForceVehicleGear(vehicle, gear)
end

function LockSpeed(veh,speed)
    Renzu_Hud(0x0E46A3FCBDE2A1B1, veh, speed)
end

function VehicleSpeed(veh)
    return Renzu_Hud(0xD5037BA82E12416F, veh, ReturnFloat)
end

function VehicleRpm(veh)
    return Renzu_Hud(0xE7B12B54, veh, ReturnFloat)
end

function WheelSpeed(veh,int)
    return Renzu_Hud(0x149C9DA0, veh, int, ReturnFloat)
end

function RCR(int,pad)
    return Renzu_Hud(0x50F940259D3841E6, int, pad)
end

function RCR2(int,pad)
    return Renzu_Hud(0x648EE3E7F38877DD, int, pad)
end

function RCP(int,pad)
    return Renzu_Hud(0xF3A21BCD95725A4A, int, pad)
end

function GetVehStats(veh,field,stat)
    return Renzu_Hud(0x642FC12F, veh, field, stat, ReturnFloat)
end

function GetCamhead()
    return Renzu_Hud(0x743607648ADD4587, ReturnFloat)
end

function SetVehStats(veh,field,stat,float)
    Renzu_Hud(0x488C86D2, veh, field, stat, float)
end

function SetVehicleBoost(vehicle,val)
	Renzu_Hud(0xB59E4BD37AE292DB, vehicle,val)
end

function GetGear(vehicle)
	return Renzu_Hud(0xB4F4E566, vehicle, ReturnInt)
end
function build()  return GetGameBuildNumber() end
--config.gamebuild = build()
-------------------------------------------https://github.com/renzuzu/renzu_hud----------------------------------------------------------
--------------------------------------------------------------VARIABLES------------------------------------------------------------------
Hud = {
	customcarui = false, isdead = false,reorder = false,esx_status = nil, buclothes = nil,saveclothe = {},identifier=nil,lastveh = nil,newdate = nil,underwatertime=30,healing=nil,manual2 = false,alreadyblackout = false,regdecor=false,busy = false,onlinevehicles = {},nearstancer = {},wheelsettings = {},wheeledit = false,turbosound = 0,oldgear = 0,newgear = 0,rpm2 = 0,propturbo = nil,boost = 1.0,old_diff = nil,togglediff = false,cruising = false,lastdamage = nil,oldlife = 200,windowbones = {[0] = 'window_rf',[1] = 'window_lf',[2] = 'window_rr',[3] = 'window_lr'},carcontrol = false,isbusy = false,oldweapon = nil,weaponui = false,wstatus = {},trail = {},nitromode = false,lightshit = {},light_trail_isfuck = false,purgefuck = {},purgeshit = {},pressed = false,proptire = nil,keyless = true,hasmask=false,hashelmet = false,imbusy = true,carstatus = false,enginelist = {},syncengine = {},syncveh = {},ped = nil,playerNamesDist = 3,key_holding = false,particlesfire = {},particleslight = {},charslot = nil,pedshot = false,lastped = nil,dummyskin = {},show = false,notifycd = {},statuses = {},vitals = {},statusloop = -1,garbage = 0,start = false,breakstart = false,lastplate = nil,notloaded = true,minimap=nil,shooting = false,busyplate = {},busyairsus = false,crosshair = 1,flametable = {},spool = false,shouldUpdateSkin = false,pedSkin = {},oldclothes = nil,clothestate = {},dummyskin1 = {},sounded = false,left = false,right = false,hazard = false,signal_state = false,turbo = config.boost,newstreet = nil,newmic = nil,newhealth = 1111,newarmor = 1111,triggered = false,cansmoke = true,refresh = false,veh_stats_loaded = false,finaldrive = 0,flywheel = 0,speed=0,maxspeed = 0,currentengine={},headshot = nil,enginespec=false,handlings={},vehiclehandling={},boost=1.0,correctgears=1,gear=1,plate=nil,loadedplate=false,maxgear=5,pid=nil,veh_stats=nil,Renzuzu=Citizen,entering=false,mode='NORMAL',ismapopen=false,date="00:00",plate=nil,degrade=1.0,playerloaded=false,manual=false,vehicletopspeed=nil,uimove=false,reverse=false,savegear=0,rpm=0.2,hour=0,vali=false,minute=0,globaltopspeed=nil,segundos=0,month="",dayOfMonth=0,voice=2,voiceDisplay=2,proximity=25.0,belt=false,ExNoCarro=false,sBuffer={},vBuffer={},displayValue=true,gasolina=0,street=nil,vehicle=nil,hp=0,shifter=false,hasNitro=true,k_nitro=70,n_boost=15.0,boost=1.0,nitro_state=100,isBlack="false",invehicle=false,topspeedmodifier=1.0,switch=false,life=100,receive='new',bodystatus={},bonecategory={},parts={},bodyui=false,body=false,arm=false,armbone=0,armbone2=0,leg=false,head=false,shooting=false,manualstatus=false,traction=nil,traction2=nil,alreadyturbo=false,Creation=Citizen.CreateThread,Renzu_Hud=Citizen.InvokeNative,ClientEvent=TriggerEvent,RenzuNetEvent=RegisterNetEvent,RenzuEventHandler=AddEventHandler,RenzuCommand=RegisterCommand,RenzuSendUI=SendNUIMessage,RenzuKeybinds=RegisterKeyMapping,RenzuNuiCallback=RegisterNUICallback,ReturnFloat=Citizen.ResultAsFloat(),ReturnInt=Citizen.ResultAsInteger()
}
identifier=nil;lastveh = nil;newdate = nil;underwatertime=30;healing=nil;manual2 = false;alreadyblackout = false;regdecor=false;busy = false;onlinevehicles = {};nearstancer = {};wheelsettings = {};wheeledit = false;turbosound = 0;oldgear = 0;newgear = 0;rpm2 = 0;propturbo = nil;boost = 1.0;old_diff = nil;togglediff = false;cruising = false;lastdamage = nil;oldlife = 200;windowbones = {[0] = 'window_rf',[1] = 'window_lf',[2] = 'window_rr',[3] = 'window_lr'};carcontrol = false;isbusy = false;oldweapon = nil;weaponui = false;wstatus = {};trail = {};nitromode = false;lightshit = {};light_trail_isfuck = false;purgefuck = {};purgeshit = {};pressed = false;proptire = nil;keyless = false;hasmask=false;hashelmet = false;imbusy = true;carstatus = false;enginelist = {};syncengine = {};syncveh = {};ped = nil;playerNamesDist = 3;key_holding = false;particlesfire = {};particleslight = {};charslot = nil;pedshot = false;lastped = nil;dummyskin = {};show = false;notifycd = {};statuses = {};vitals = {};statusloop = -1;garbage = 0;start = false;breakstart = false;lastplate = nil;notloaded = true;minimap=nil;shooting = false;busyplate = {};busyairsus = false;crosshair = 1;flametable = {};spool = false;shouldUpdateSkin = false;pedSkin = {};oldclothes = nil;clothestate = {};dummyskin1 = {};sounded = false;left = false;right = false;hazard = false;state = false;turbo = config.boost;newstreet = nil;newmic = nil;newhealth = 1111;newarmor = 1111;triggered = false;cansmoke = true;refresh = false;veh_stats_loaded = false;finaldrive = 0;flywheel = 0;maxspeed = 0;currentengine={};headshot = nil;enginespec=false;handlings={};vehiclehandling={};boost=1.0;correctgears=1;gear=1;plate=nil;loadedplate=false;maxgear=5;pid=nil;veh_stats=nil;entering=false;mode='NORMAL';ismapopen=false;date="00:00";plate=nil;degrade=1.0;playerloaded=false;manual=false;vehicletopspeed=nil;uimove=false;reverse=false;savegear=0;rpm=0.2;hour=0;vali=false;minute=0;globaltopspeed=nil;segundos=0;month="";dayOfMonth=0;voice=2;voiceDisplay=2;proximity=25.0;belt=false;ExNoCarro=false;sBuffer={};vBuffer={};displayValue=true;gasolina=0;street=nil;vehicle=nil;hp=0;shifter=false;hasNitro=true;k_nitro=70;n_boost=15.0;boost=1.0;nitro_state=100;isBlack="false";invehicle=false;topspeedmodifier=1.0;switch=false;life=100;receive='new';bodystatus={};bonecategory={};parts={};bodyui=false;body=false;arm=false;armbone=0;armbone2=0;leg=false;head=false;shooting=false;manualstatus=false;traction=nil;traction2=nil;alreadyturbo=false;Creation=Citizen.CreateThread;Renzu_Hud=Citizen.InvokeNative;ClientEvent=TriggerEvent;RenzuNetEvent=RegisterNetEvent;RenzuEventHandler=AddEventHandler;RenzuCommand=RegisterCommand;RenzuSendUI=SendNUIMessage;RenzuKeybinds=RegisterKeyMapping;RenzuNuiCallback=RegisterNUICallback;ReturnFloat=Citizen.ResultAsFloat();ReturnInt=Citizen.ResultAsInteger()
-----------------------------------------------------------------------------------------------------------------------------------------