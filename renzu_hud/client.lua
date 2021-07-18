-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
ESX = nil
Creation(function()
	if config.framework == 'ESX' then
		while ESX == nil do ClientEvent('esx:getSharedObject', function(obj) ESX = obj end) Renzuzu.Wait(0) end
		while ESX.GetPlayerData().job == nil do Renzuzu.Wait(0) end
		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
		RenzuSendUI({type = "isAmbulance",content = xPlayer.job.name == config.checkbodycommandjob})
		Renzuzu.Wait(5000)
	elseif config.framework == 'VRP' then
		local Tunnel = module("vrp","lib/Tunnel")
		local Proxy = module("vrp","lib/Proxy")
		vRP = Proxy.getInterface("vRP")
	else
		ESX = true
	end
	DecorRegister("INERTIA", 1);DecorRegister("DRIVEFORCE", 1);DecorRegister("TOPSPEED", 1);DecorRegister("STEERINGLOCK", 1);DecorRegister("MAXGEAR", 1);DecorRegister("TRACTION", 1);DecorRegister("TRACTION2", 1);DecorRegister("TRACTION3", 1);DecorRegister("TRACTION4", 1);DecorRegister("TRACTION5", 1)
	if not DecorIsRegisteredAsType("MANUAL", 1) then DecorRegister("MANUAL", 1) end
	DecorRegister("PLAYERLOADED", 1);DecorRegister("CHARSLOT", 1)
	while not playerloaded do Wait(1000) end
	while not receive do Wait(1000) end
	for type,val in pairs(config.buto) do if bodystatus then  bonecategory[type] = bodystatus[type] else bonecategory[type] = 0.0 or 0.0 end if not other then parts[type] = {} for bone,val in pairs(val) do parts[type][bone] = 0.0 end end end
	RenzuSendUI({type = "setUpdateBodyStatus",content = bonecategory})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	xPlayer.job = job
	RenzuSendUI({type = "isAmbulance",content = xPlayer.job.name == config.checkbodycommandjob})
	for type,val in pairs(config.buto) do if bodystatus then  bonecategory[type] = bodystatus[type] else bonecategory[type] = 0.0 or 0.0 end if not other then parts[type] = {} for bone,val in pairs(val) do parts[type][bone] = 0.0 end end end
	RenzuSendUI({type = "setUpdateBodyStatus",content = bonecategory})
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VOICE FUNC
-----------------------------------------------------------------------------------------------------------------------------------------

--PMA VOICE LISTENER
RenzuNetEvent("pma-voice:setTalkingMode")
RenzuEventHandler("pma-voice:setTalkingMode", function(prox)
	voiceDisplay = prox
	RenzuSendUI({
		type = "setMic",
		content = prox
	})
end)

--MUMBLE VOIP SetVoice Listener
local current_channel = 0
RenzuNetEvent("renzu_hud:SetVoiceData")
RenzuEventHandler("renzu_hud:SetVoiceData", function(mode,val)
	if mode == 'proximity' then
		voiceDisplay = val
		RenzuSendUI({
			type = "setMic",
			content = val
		})
	elseif mode == 'radio' and val > 0 and val ~= current_channel then
		RenzuSendUI({
			type = "setRadioChannel",
			content = config.radiochannels[val]
		})
		current_channel = val
	elseif mode == 'radio' and val <= 0 or val == current_channel then
		RenzuSendUI({
			type = "setRadioChannel",
			content = false
		})
		current_channel = 0
	end
end)

-- PMA RADIO CHANNEL LISTENER
RenzuNetEvent("pma-voice:clSetPlayerRadio")
RenzuEventHandler("pma-voice:clSetPlayerRadio", function(channel)
	RenzuSendUI({
		type = "setRadioChannel",
		content = config.radiochannels[channel]
	})
end)

-- PMA REMOVE PLAYER FROM CHANNEL RADIO
RenzuNetEvent("pma-voice:removePlayerFromRadio")
RenzuEventHandler("pma-voice:removePlayerFromRadio", function(channel)
	RenzuSendUI({
		type = "setRadioChannel",
		content = false
	})
end)

Creation(function()
	if config.voicecommandandkeybind then
		RenzuCommand(config.commands['voip'], function()
			if proximity == 3.0 then
				voiceDisplay = 1
				proximity = 10.0
			elseif proximity == 10.0 then
				voiceDisplay = 2
				proximity = 25.0
			elseif proximity == 25.0 then
				voiceDisplay = 3
				proximity = 3.0
			end
			if config.enableproximityfunc then
				setVoice()
			end
			RenzuSendUI({
				type = "setMic",
				content = voiceDisplay
			})
		end, false)
		RenzuKeybinds(config.commands['voip'], 'Voice Proximity', 'keyboard', config.keybinds['voip'])
	end
	return
end)

RenzuNetEvent('renzu_hud:charslot')
RenzuEventHandler('renzu_hud:charslot', function(charid)
	charslot = charid
	while not playerloaded do
		Wait(100)
	end
	Wait(2000)
	if DecorExistOn(PlayerPedId(), "CHARSLOT") then
		DecorRemove(PlayerPedId(), "CHARSLOT")
	end
	DecorSetFloat(PlayerPedId(), "CHARSLOT", charslot*1.0) -- fuck bug in int type
end)

Creation(function()
	Wait(10)
	if config.framework == 'ESX' then
		RenzuNetEvent('esx:playerLoaded')
		RenzuEventHandler('esx:playerLoaded', function(xPlayer)
			playerloaded = true
			Renzuzu.Wait(2000)
			----print("ESX")
			lastped = PlayerPedId()
			TriggerServerEvent("renzu_hud:getdata",charslot)
			DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
			Wait(5000)
			RenzuSendUI({content = true, type = 'pedface'})
		end)
	else
		RenzuNetEvent('playerSpawned')
		RenzuEventHandler('playerSpawned', function(spawn)
			playerloaded = true
			Renzuzu.Wait(2000)
			lastped = PlayerPedId()
			DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
			TriggerServerEvent("renzu_hud:getdata",charslot)
			Wait(5000)
			RenzuSendUI({content = true, type = 'pedface'})	
		end)
	end
	Wait(1000)
	if charslot == nil and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0.0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= nil then
		charslot = round(DecorGetFloat(PlayerPedId(),"CHARSLOT"))
		----print("CHARSLOT")
	else
		Citizen.Wait(4000)
	end
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and charslot ~= nil then
		----print("PLAYERLOADED")
		TriggerServerEvent("renzu_hud:getdata",charslot)
		playerloaded = true
	end
	--print('ismp?', playerloaded, isplayer())
	Wait(500)
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and config.loadedasmp and isplayer() then
		--print("ISMP")
		TriggerServerEvent("renzu_hud:getdata",0, true)
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		playerloaded = true
		RenzuSendUI({content = true, type = 'pedface'})
	end
	while not playerloaded do
		Wait(1000)
	end
	while playerloaded do -- dev purpose when restarting script, either you uncomment this or left it , it doesnt matter.
		Wait(20000)
		if not DecorExistOn(PlayerPedId(), "PLAYERLOADED") then
			DecorRemove(lastped,"PLAYERLOADED")
			DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
			if config.multichar_advanced then
				DecorRemove(lastped,"CHARSLOT")
				DecorSetInt(PlayerPedId(), "CHARSLOT", charslot)
			end
		end
	end
	--return
end)


--- NEW HUD FUNC
RenzuNuiCallback('requestface', function(data, cb)
	while not playerloaded do
		Renzuzu.Wait(1000)
		--print("Playerloadedface")
	end
	Renzuzu.Wait(5000)
	TriggerEvent('skinchanger:getSkin', function(current) dummyskin = current end)
	while tablelength(dummyskin) <= 2 do
		--print(tablelength(dummyskin))
		TriggerEvent('skinchanger:getSkin', function(current) dummyskin = current end)
		Wait(1000)
	end
	while not isplayer() do
		Wait(1000)
	end
    cb(getawsomeface())
	ClearPedHeadshots()
end)

Creation(function()
	Wait(1000)
	for k,v in pairs(config.statusordering) do
		if v.enable then
			notifycd[v.status] = 0
		end
	end
	if config.enablestatus then
		RegisterNetEvent("esx_status:onTick")
		AddEventHandler("esx_status:onTick", function(vitals)
			UpdateStatus(false,vitals)
		end)
	else
		for k,v in pairs(config.statusordering) do
			v.enable = false
		end
	end
	return
end)

Creation(function()
	Renzuzu.Wait(2000)
	SetPlayerUnderwaterTimeRemaining(pid,9999)
	SetPedMaxTimeUnderwater(ped,99999)
	for k,v in pairs(config.statusordering) do
		if v.custom and v.enable then
			statuses[k] = v.status
		end
	end

	if config.statusv2 then
		RenzuSendUI({
			type = "setShowstatusv2",
			content = config.statusv2
		})
	end

	RenzuSendUI({
		type = "NuiLoop",
		content = 1000
	})
	local se = config.enablestatus and config.running_affect_status or config.melee_combat_affect_status or config.parachute_affect_status or config.playing_animation_affect_status
	local wui = config.weaponsui
	local ec = config.enablecompass
	local bs = config.bodystatus
	local va = config.enable_carui and config.customengine
	local wa = config.wheelstancer
	local nuiloop = false
	if se then
		nuiloop = true
	elseif wui then
		nuiloop = true
	elseif ec then
		nuiloop = true
	elseif bs then
		nuiloop = true
	elseif va then
		nuiloop = true
	elseif wa then
		nuiloop = true
	end
	while veh_stats == nil do
		Wait(100)
	end
	if nuiloop then
		RenzuNuiCallback('NuiLoop', function(data, cb)
			--updateplayer()
			if se and not invehicle then
				Creation(function()
					Wait(1000)
					setStatusEffect()
					return
				end)
			end
			if wui and not invehicle then
				Creation(function()
					Wait(1500)
					WeaponStatus()
					return
				end)
			end

			if ec then
				Creation(function()
					Wait(2000)
					Compass()
					return
				end)
			end

			-- if bs and not invehicle then
			-- 	Creation(function()
			-- 		BodyLoop()
			-- 		return
			-- 	end)
			-- end

			if va or wa then
				SyncWheelAndSound(va,wa)
			end
			-- if wa then
			-- 	SyncWheelSetting()
			-- end
			if garbage > 200 then
				collectgarbage()
				garbage = 0
			end
			garbage = garbage + 1
			--print(garbage,"Garbage")
			cb(true)
		end)
	end
	if config.enablestatus or not config.enablestatus and config.statusui == 'normal' then
		updateplayer(true)
	end
end)

RenzuCommand(config.commands['showstatus'], function()
	show = not show
	Myinfo(true)
    PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	RenzuSendUI({
		type = "setShowstatus",
		content = {['bool'] = show, ['enable'] = config.enablestatus}
	})
end, false)

Creation(function()
	RenzuKeybinds(config.commands['showstatus'], 'HUD Status UI', 'keyboard', config.keybinds['showstatus'])
	return
end)

RenzuNuiCallback('pushtostart', function(data, cb)
	start = true
	breakstart = false
	cb(true)
end)

RenzuNuiCallback('getoutvehicle', function(data, cb)
	start = false
	breakstart = false
	SetNuiFocus(false,false)
	TaskLeaveVehicle(ped,vehicle,0)
	cb(true)
end)

Creation(function()
	Wait(1000)
	RenzuSendUI({map = true, type = 'sarado'})
	RenzuSendUI({type = "uiconfig", content = config.uiconfig})
	while not playerloaded do Citizen.Wait(100) end
	Wait(100)
	RenzuSendUI({type = "setStatusType",content = config.status_type})
	local tbl = {['table'] = config.statusordering, ['float'] = config.statusplace}
	if config.enable_carui then
		RenzuSendUI({type = 'setCarui', content = config.carui})
	end
	Wait(500)
	RenzuSendUI({type = "setCompass",content = config.enablecompass})
	Wait(500)
	RenzuSendUI({type = "SetStatusOrder",content = tbl})
	Wait(500)
	RenzuSendUI({type = "setStatusUI",content = {['type'] = config.status_type, ['ver'] = config.statusui, ['enable'] = config.enablestatus}})
	Wait(500)
	RenzuSendUI({type = "changeallclass",content = config.uidesign})
	Wait(100)
	--RenzuSendUI({type = 'setCarui', content = config.carui})
	Wait(100)
	statusplace()
	--WHEN RESTARTED IN CAR
	if not uimove and config.enable_carui then
		local content = {
			['bool'] = false,
			['type'] = config.carui
		}
		RenzuSendUI({
			type = "setShow",
			content = content
		})
	end
	uimove = true
	RenzuSendUI({map = true, type = 'sarado'})
	if config.enable_carui and GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
		Renzuzu.Wait(100)
		start = true
		RenzuSendUI({
			type = "setStart",
			content = start
		})
		vehicle = GetVehiclePedIsIn(PlayerPedId())
		EnterVehicleEvent(true,vehicle)
	end
	--WHEN RESTARTED IN CAR
	while veh_stats == nil do
		--print("vehstats")
		Wait(100)
	end
	local l = 0
	--print("starting thread")
	notloaded = false
	while true do
		ped = PlayerPedId()
		vehicle = GetVehiclePedIsIn(ped)
		if not invehicle and config.enablestatus or not invehicle and not config.enablestatus and config.statusui == 'normal' then
			updateplayer()
		end
		if invehicle and vehicle == 0 then
			local EV1 <const> = Renzu_Function(EnterVehicleEvent(false))
		end
		if config.enable_carui and build() < 2000 and not invehicle and vehicle ~= 0 then
			local EV2 <const> = Renzu_Function(EnterVehicleEvent(true,vehicle))
		end
		Renzuzu.Wait(config.car_mainloop_sleep)
	end
end)

RegisterNetEvent("renzu_hud:receivedata")
AddEventHandler("renzu_hud:receivedata", function(data,i)
	veh_stats = data
	if i ~= nil then
		identifier = i
	end
	veh_stats_loaded = true
	for k,v in pairs(data) do
		if v.entity ~= nil then
			if onlinevehicles[k] == nil then
				onlinevehicles[k] = {}
			end
			onlinevehicles[k].entity = v.entity
			onlinevehicles[k].plate = k
			if v.height ~= nil then
				onlinevehicles[k].height = v.height
			end
			if v.engine ~= nil then
				onlinevehicles[k].engine = v.engine
			end
		end
	end
end)

Creation(function() -- lets use space as a signal to handbrake NUI more effective and optimize. disable it if you are using it on other scripts.
	Wait(100)
	RenzuSendUI({
		type = "setBrake",
		content = false
	})
	RenzuKeybinds(config.commands['car_handbrake'], 'Car Emergency Brake', 'keyboard', config.keybinds['car_handbrake'])
	return
end)

RenzuCommand(config.commands['car_handbrake'], function()
	NuiVehicleHandbrake()
end)

RenzuNetEvent('start:smoke')
RenzuEventHandler('start:smoke', function(ent,coord)
	local mycoord = GetEntityCoords(ped,false)
	local dis = #(mycoord - coord)
	local ent = NetToVeh(ent)
	if dis < 100 then --SILLY WAY TO AVOID ONE SYNC INFINITY ISSUE
		StartSmoke(ent)
	end
end)

RenzuCommand('testsmoke', function(source, args, raw)
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) + config.addheat)
	Renzuzu.Wait(100)
	StartSmoke(getveh())
end)

local inshock = false
local shockcount = 50 -- 5 seconds shock
AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkEntityDamage' then
		local victim = args[1];
		if victim == ped and config.enablestatus or victim == ped and not config.enablestatus and config.statusui == 'normal' then
			updateplayer(true)
			Wait(300)
			BodyMain()
			if not inshock then
				inshock = true
				shockcount = 50
				while inshock and shockcount > 1 do
					updateplayer(true)
					shockcount = shockcount - 1
					Wait(100)
				end
				Wait(100)
				if config.bodystatus then
					BodyLoop()
				end
			end
			inshock = false
		end
	end
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		print("ENTER VEHICLE",args[1],pid,args[2])
		if args[1] == pid and config.enable_carui then
			vehicle = args[2]
			local enterEvent <const> = Renzu_Function(EnterVehicleEvent(true,args[2]))
		end
	end
	--print(name)
end)

-- SEATBELT
Creation(function()
	RenzuKeybinds(config.commands['car_seatbelt'], 'Car Seatbelt', 'keyboard', config.keybinds['car_seatbelt'])
	return
end)

RenzuCommand(config.commands['car_seatbelt'], function()
	if vehicle ~= 0 then
		if haveseatbelt() then
			if belt then
				SetTimeout(1000,function()
					belt = false
					if newbelt ~= belt or newbelt == nil then
						newbelt = belt
						RenzuSendUI({
						type = "setBelt",
						content = belt
						})
					end
					Notify('warning','Seatbelt',"Seatbelt has been Detached")
					SetFlyThroughWindscreenParams(config.seatbeltminspeed, 2.2352, 0.0, 0.0)
					SetPedConfigFlag(PlayerPedId(), 32, true)
					--SendNuiSeatBelt()
				end)
			else
				SetTimeout(1000,function()
					belt = true
					if newbelt ~= belt or newbelt == nil then
						newbelt = belt
						RenzuSendUI({
						type = "setBelt",
						content = belt
						})
						SetFlyThroughWindscreenParams(config.seatbeltmaxspeed, 2.2352, 0.0, 0.0)
						--SetPedConfigFlag(PlayerPedId(), 32, false)
						Notify('success','Seatbelt',"Seatbelt has been attached")
					end
					--SendNuiSeatBelt()
				end)
			end
		end
	end
end, false)

RenzuCommand(config.commands['signal_left'], function()
	local ped = ped
	local vehicle = vehicle
	if vehicle ~= 0 then
		right = false
		Renzuzu.Wait(100)
		left = true
		if GetVehicleIndicatorLights(vehicle) == 0 then
			SetVehicleIndicatorLights(vehicle,1, true)
		elseif GetVehicleIndicatorLights(vehicle) == 2 then
			SetVehicleIndicatorLights(vehicle,0, false)
			SetVehicleIndicatorLights(vehicle,1, true)
		end

		state = false
		if not state and right then
			state = 'right'
		end
		if not state and left then
			state = 'left'
		end
		if hazard then
			state = 'hazard'
		end
		sendsignaltoNUI()
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['signal_left'], 'Signal Left', 'keyboard', config.keybinds['signal_left'])
end)

RenzuCommand(config.commands['signal_right'], function()
	local ped = ped
	local vehicle = vehicle
	if vehicle ~= 0 then
		left = false
		Renzuzu.Wait(100)
		right = true
		if GetVehicleIndicatorLights(vehicle) == 0 then
			SetVehicleIndicatorLights(vehicle,0, true)
		elseif GetVehicleIndicatorLights(vehicle) == 1 then
			SetVehicleIndicatorLights(vehicle,1, false)
			SetVehicleIndicatorLights(vehicle,0, true)
		end

		state = false
		if not state and right then
			state = 'right'
		end
		if not state and left then
			state = 'left'
		end
		if hazard then
			state = 'hazard'
		end
		sendsignaltoNUI()
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['signal_right'], 'Signal Right', 'keyboard', config.keybinds['signal_right'])
	return
end)

RenzuCommand(config.commands['entering'], function()
	entervehicle()
end, false)

Creation(function()
	RenzuKeybinds(config.commands['entering'], 'Enter Vehicle', 'keyboard', config.keybinds['entering'])
	return
end)

RenzuCommand(config.commands['signal_hazard'], function()
	local ped = ped
	local vehicle = vehicle
	if vehicle ~= 0 then
		if GetVehicleIndicatorLights(vehicle) == 0 then
			hazard = true
			SetVehicleIndicatorLights(vehicle,0, true)
			SetVehicleIndicatorLights(vehicle,1, true)
		else
			hazard = false
			left = false
			right = false
			SetVehicleIndicatorLights(vehicle,0, false)
			SetVehicleIndicatorLights(vehicle,1, false)
		end

		state = false
		if not state and right then
			state = 'right'
		end
		if not state and left then
			state = 'left'
		end
		if hazard then
			state = 'hazard'
		end
		sendsignaltoNUI()
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['signal_hazard'], 'Signal Hazard', 'keyboard', config.keybinds['signal_hazard'])
	return
end)

RenzuNetEvent('renzu_hud:hasturbo')
RenzuEventHandler('renzu_hud:hasturbo', function(type)
	if invehicle then
		alreadyturbo = true
		Wait(1000)
		--print("TURBO ACTIVATE")
		if invehicle and config.turbogauge then
			RenzuSendUI({
				type = "setShowTurboBoost",
				content = true
			})
		end
		plate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
		plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
		Creation(function()
			turboanimation(type)
			Boost(true)
			return
		end)
	end
end)

RenzuNetEvent('renzu_hud:install_turbo')
RenzuEventHandler('renzu_hud:install_turbo', function(type)
	local type = type
	local veh = getveh()
	turboanimation(type)
	local plate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
	if veh_stats[plate] == nil then
		get_veh_stats(veh, plate)
	end
	Citizen.Wait(2000)
	playanimation('creatures@rottweiler@tricks@','petting_franklin')
	--ExecuteCommand("e petting")
	Renzuzu.Wait(2500)
	ClearPedTasks(ped)
	playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	--ExecuteCommand("e gangsign")
	Renzuzu.Wait(200)
	SetVehicleDoorOpen(veh,4,false,false)
	Renzuzu.Wait(400)
	ClearPedTasks(ped)
	SetVehicleDoorOpen(veh,4,false,false)
	playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Citizen.Wait(10000)
	veh_stats[plate].turbo = type
	veh_stats[plate].turbo_health = config.turbo_health
	TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
	Notify('success','Turbo Install',""..veh_stats[plate].turbo.." turbine has been install")
	playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Renzuzu.Wait(2000)
	SetVehicleDoorShut(veh,4,false)
	Renzuzu.Wait(300)
	ClearPedTasks(ped)
	ClearPedTasks(ped)
end)

RenzuCommand(config.commands['mode'], function()
	if vehicle ~= 0 then
		vehiclemode()
	end
end, false)

Creation(function()
	mode = 'NORMAL'
	RenzuKeybinds(config.commands['mode'], 'Vehicle Mode', 'keyboard', config.keybinds['mode'])
	return
end)

RenzuCommand(config.commands['differential'], function()
	if vehicle ~= 0 then
		differential()
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['differential'], '4WD Mode', 'keyboard', config.keybinds['differential'])
	return
end)

--ETC
Creation(function()
	local count = 0
	while not playerloaded or count < 5 do -- REAL WAY TO REMOVE HEALTHBAR AND ARMOR WITHOUT USING THE LOOP ( LOAP minimap.gfx first ) then on spawn load the circlemap
		count = count + 1
		Renzuzu.Wait(1000)
	end
	if config.usecircleminimap then -- FIVEM Client needs to be restarted if you want to reverse the config, change from circle to default mode.
		RequestStreamedTextureDict("circlemap", false)
		while not HasStreamedTextureDictLoaded("circlemap") do
			Wait(100)
		end
		AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

		SetMinimapClipType(1)
		SetMinimapComponentPosition("minimap", "L", "B", 0.025, -0.03, 0.153, 0.21)
		SetMinimapComponentPosition("minimap_mask", "L", "B", 0.135, 0.12, 0.093, 0.164)
		SetMinimapComponentPosition("minimap_blur", "L", "B", 0.012, 0.022, 0.256, 0.337)

	 	minimap = RequestScaleformMovie("minimap")

		SetRadarBigmapEnabled(true, false)
		Renzuzu.Wait(100)
		SetRadarBigmapEnabled(false, false)
	end
	return
end)

Creation(function()
	ClearPedTasks(PlayerPedId())
	if config.removemaphealthandarmor or config.useminimapeverytime then
		while true do
			Renzuzu.Wait(0)
			if config.removemaphealthandarmor then -- FALSE ONLY - ACTIVATE only if you still see health and armor, it should be already removed from the minimap.gfx else check all your script!
				BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
				ScaleformMovieMethodAddParamInt(3)
				EndScaleformMovieMethod()
			end
			if config.useminimapeverytime then
				DisplayRadar(true)
			end
		end
	end
	return
end)

RegisterNetEvent('renzu_hud:coolant')
AddEventHandler('renzu_hud:coolant', function()
	local ped = PlayerPedId()
	local bone = GetEntityBoneIndexByName(getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(getveh(),bone)
	local vehrotation = GetEntityRotation(getveh(),2)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(getveh())
	local veh_coord = GetEntityCoords(getveh(),false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	requestmodel('bkr_prop_meth_sacid')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_long_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(getveh()) * 0.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.1, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Renzuzu.Wait(2500)
	ClearPedTasks(ped)
	playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	Renzuzu.Wait(200)
	SetVehicleDoorOpen(getveh(),4,false,false)
	Renzuzu.Wait(400)
	ClearPedTasks(ped)
	SetVehicleDoorOpen(getveh(),4,false,false)
	--SetEntityCoords(ped,realx,realy,realz)
	water = CreateObject(GetHashKey('bkr_prop_meth_sacid'), x, y, z, 1, 0, 1)
	SetEntityCollision(water, false, true)
	NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "chemical_pour_long_cooker", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(water, netScene, animDict, "chemical_pour_long_sacid", 4.0, -8.0, 1)
	Renzuzu.Wait(150)
	SetEntityHeading(ped, GetEntityHeading(getveh()) - 180)
	Renzuzu.Wait(20)
	NetworkStartSynchronisedScene(netScene)
	Renzuzu.Wait(40000)
	ClearPedTasks(ped)
	DeleteEntity(water)
	playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Renzuzu.Wait(2000)
	SetVehicleDoorShut(getveh(),4,false)
	Renzuzu.Wait(300)
	ClearPedTasks(ped)
	veh_stats[plate].coolant = 100
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) - config.reducetemp_onwateradd)
	RenzuSendUI({
		type = "setCoolant",
		content = 100
	})
	Notify('success','Vehicle System',"Coolant has been restore")
	Renzuzu.Wait(100)
end)

RegisterNetEvent('renzu_hud:oil')
AddEventHandler('renzu_hud:oil', function()
	local ped = PlayerPedId()
	local bone = GetEntityBoneIndexByName(getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(getveh(),bone)
	local vehrotation = GetEntityRotation(getveh(),2)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(getveh())
	local veh_coord = GetEntityCoords(getveh(),false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	requestmodel('prop_oilcan_01a')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_short_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(getveh()) * 0.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.2, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Renzuzu.Wait(2500)
	ClearPedTasks(ped)
	playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	Renzuzu.Wait(200)
	SetVehicleDoorOpen(getveh(),4,false,false)
	Renzuzu.Wait(400)
	ClearPedTasks(ped)
	SetVehicleDoorOpen(getveh(),4,false,false)
	oil = CreateObject(GetHashKey('prop_oilcan_01a'), x, y, z+0.5	, 1, 0, 1)
	SetEntityCollision(water, false, true)
	NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "chemical_pour_short_cooker", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(oil, netScene, animDict, "chemical_pour_short_sacid", 4.0, -8.0, 1)
	Renzuzu.Wait(150)
	SetEntityHeading(ped, GetEntityHeading(getveh()) - 180)
	Renzuzu.Wait(20)
	NetworkStartSynchronisedScene(netScene)
	Renzuzu.Wait(30000)
	ClearPedTasks(ped)
	DeleteEntity(oil)
	playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Renzuzu.Wait(2000)
	SetVehicleDoorShut(getveh(),4,false)
	Renzuzu.Wait(300)
	ClearPedTasks(ped)
	veh_stats[plate].oil = 100
	veh_stats[plate].mileage = 0
	degrade = 1.0
	RenzuSendUI({
		type = "setMileage",
		content = 0
	})
	Notify('success','Vehicle System',"Oil has been changed")
	Renzuzu.Wait(100)
end)

RenzuCommand('putwater', function(source, args, raw)
	TriggerEvent("renzu_hud:coolant")
end)

RenzuCommand('changeoil', function(source, args, raw)
	TriggerEvent("renzu_hud:oil")
end)

RenzuCommand(config.commands['cruisecontrol'], function()
	if vehicle ~= 0 then
		Cruisecontrol()
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['cruisecontrol'], 'Vehicle Cruise Control', 'keyboard', config.keybinds['cruisecontrol'])
	return
end)

Creation(function()
	Wait(1000)
	local enable_w = false
	if config.enablestatus then
		enable_w = true
	elseif config.bodystatus then
		enable_w = true
	end
	if config.firing_affect_status and enable_w then
		while ped == nil or ped == 0 do
			Citizen.Wait(100)
		end
		RenzuSendUI({
			type = "setShooting",
			content = 2000
		})
		--Citizen.Wait(2000) -- 2 seconds wait to check if player is aiming, more optimized 100x than to loop wait(0) just to check if player is firing or not
		RenzuNuiCallback('setShooting', function(data, cb)
			--print("ishooting",shooting)
			-- if not shooting then
			-- 	--print("not shooting")
			-- 	Creation(function()
			-- 		local count = 0
			-- 		local killed = {}
			-- 		local lastent = nil
			-- 		local pid = pid
			-- 		while IsPlayerFreeAiming(pid) do
			-- 			if IsPedShooting(ped) then
			-- 				--print("shooting")
			-- 				shooting = true
			-- 				if config.enablestatus and config.killing_affect_status then
			-- 					val, ent = GetEntityPlayerIsFreeAimingAt(pid)
			-- 					----print("shooting")
			-- 					if lastent ~= nil and lastent ~= 0 then
			-- 						if not killed[lastent] and IsEntityDead(lastent) and GetPedSourceOfDeath(lastent) == ped then
			-- 							killed[lastent] = true
			-- 							--print("LAST ENTITY IS DEAD "..lastent.."")
			-- 							lastent = nil
			-- 							TriggerEvent('esx_status:'..config.killing_status_mode..'', config.killing_affected_status, config.killing_status_val)
			-- 							Citizen.Wait(100)
			-- 						end
			-- 					end
			-- 					if ent ~= lastent then
			-- 						lastent = nil
			-- 					end
			-- 				end
			-- 				if config.enablestatus and count > config.firing_bullets then
			-- 					count = 0
			-- 					TriggerEvent('esx_status:'..config.firing_status_mode..'', config.firing_affected_status, config.firing_statusaddval)
			-- 					----print("STATUS ADDED")
			-- 				end
			-- 				count = count + 1
			-- 				----print(count)
			-- 				lastent = ent
			-- 				shooting = true
			-- 				if config.bodystatus then
			-- 					if armbone > armbone2 then
			-- 						recoil(armbone / 5.0)
			-- 					else
			-- 						recoil(armbone2 / 5.0)
			-- 					end
			-- 				end
			-- 			end
			-- 			----print("aiming")
			-- 			Citizen.Wait(5)
			-- 		end
			-- 		shooting = false
			-- 		return
			-- 	end)
			-- end
			cb(true)
		end)
	end
	return
end)

RenzuCommand(config.commands['bodystatus'], function()
	BodyUi()
end, false)

RenzuCommand(config.commands['bodystatus_other'], function()
	CheckPatient()
end, false)

Creation(function()
	RenzuKeybinds(config.commands['bodystatus'], 'Open Body Status', 'keyboard', config.keybinds['bodystatus'])
	return
end)

RegisterNetEvent('renzu_hud:bodystatus')
AddEventHandler('renzu_hud:bodystatus', function(status,other)
	checkingpatient = other
	while not playerloaded do Wait(100) end
	RenzuSendUI({type = "setBodyParts",content = config.healtype})
	local status = status
	receive = true
	bodystatus = {}
	bodystatus = status
	damage = 0
	for type,val in pairs(config.buto) do
		if bodystatus then 
			bonecategory[type] = bodystatus[type] or 0.0
		else 
			bonecategory[type] = 0
		end
		damage = damage + bonecategory[type]
		if not other then
			parts[type] = {}
			for bone,val in pairs(val) do
				parts[type][bone] = 0
			end
		end
	end
	print(damage)
	if not other and damage > 35 then
		ApplyPedDamagePack(GetPlayerPed(-1), "Fall", damage, damage)
	end
	if other then
		RenzuSendUI({
			type = "setShowBodyUi",
			content = bodyui
		})
		Wait(100)
		SetNuiFocusKeepInput(bodyui)
		SetNuiFocus(bodyui,bodyui)
	end
	Wait(100)
	RenzuSendUI({
		type = "setUpdateBodyStatus",
		content = bonecategory
	})
	Creation(function()
		while bodyui do
			whileinput()
			Wait(5)
		end
		SetNuiFocusKeepInput(false)
		SetNuiFocus(false,false)
		return
	end)
end)

Creation(function()
	while not playerloaded do
		Wait(100)
	end
	if config.bodystatus then
		Citizen.Wait(1000)
		while DecorGetBool(PlayerPedId(), "PLAYERLOADED") ~= 1 do
			Citizen.Wait(500)
			if playerloaded then
				DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
				break
			end
		end
		TriggerServerEvent('renzu_hud:checkbody')
	end
	return
end)

local busyheal = false
RenzuNuiCallback('healpart', function(data, cb)
	Wait(math.random(300,1000))
	if not busyheal then
		TriggerServerEvent('renzu_hud:checkitem',data.part)
	end
	cb(true)
end)

RegisterNetEvent('renzu_hud:healpart')
AddEventHandler('renzu_hud:healpart', function(part)
	busyheal = true
	TaskTurnPedToFaceEntity(ped,GetPlayerPed(GetPlayerFromServerId(healing)))
	Wait(300)
	if healing == nil then
		healing = GetPlayerServerId(PlayerId())
	end	
	TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', -1, true)
	TriggerServerEvent('renzu_hud:healbody',healing,part)
	Makeloading('Applying Item',12000)
	Wait(12000)
	Notify('success','Body System',"Healing Successful")
	Wait(100)
	if healing ~= nil and GetPlayerServerId(PlayerId()) ~= healing then
		TriggerServerEvent('renzu_hud:checkbody', tonumber(healing))
	end
	ClearPedTasks(ped)
	busyheal = false
	BodyLoop()
end)

RegisterNetEvent('renzu_hud:healbody')
AddEventHandler('renzu_hud:healbody', function(bodypart, patient)
	-- Preparing
	if not patient then
		TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', -1, true)
	end
	Makeloading('Applying Item',10000)
    Wait(10000)
    ClearPedTasks(ped)
	-- Start Healing Injuries
	local canheal
	for k,v in pairs(config.healtype[bodypart]) do
		canheal = bonecategory[v]
		bonecategory[v] = 0
	end
	if canheal then
		TriggerServerEvent('renzu_hud:savebody', bonecategory)
		Citizen.Wait(1000)
	end
	RenzuSendUI({
		type = "setUpdateBodyStatus",
		content = bonecategory
	})
	--lastdamage = nil
	Notify('success','Body System',"You have been healed")
	damage = 0
	for type,val in pairs(config.buto) do
		damage = damage + bonecategory[type]
	end
	ApplyPedDamagePack(GetPlayerPed(-1), "Fall", damage, damage)
	if damage <= 0 then
		ClearPedBloodDamage(ped)
	end
	Wait(500)
	BodyLoop()
end)

Creation(function()
	if config.enablehealcommand then
		RenzuCommand(config.commands['bodyheal'], function(source,args)
			if args[1] ~= nil then
				TriggerEvent("renzu_hud:healbody", args[1])
			end
		end, false)
	end
	return
end)

RenzuCommand(config.commands['carcontrol'], function()
	if config.enablecarcontrol then
		if config.allowoutsideofvehicle then
			CarControl()
		elseif invehicle then
			CarControl()
		end
	end
end, false)

Creation(function()
	if config.enablecarcontrol then
		RenzuKeybinds(config.commands['carcontrol'], 'Open Car Control', 'keyboard', config.keybinds['carcontrol'])
	end
	return
end)

RenzuNuiCallback('closecarcontrol', function(data, cb)
	carcontrol = false
	RenzuSendUI({
		type = "setShowCarcontrol",
		content = carcontrol
	})
	SetNuiFocus(false,false)
	cb(true)
end)

RenzuNuiCallback('setVehicleDoor', function(data, cb)
	vehicle = getveh()
    if data.bool then
		SetVehicleDoorOpen(vehicle,tonumber(data.index),false,false)
    else     
        SetVehicleDoorShut(vehicle,tonumber(data.index),false,false)
    end
	cb(true)
end)

RenzuNuiCallback('setVehicleSeat1', function(data, cb)
	vehicle = getveh()
    if IsVehicleSeatFree(vehicle,-1) then
		shuffleseat(-1)
	elseif IsVehicleSeatFree(vehicle,0) then
		shuffleseat(0)
    end
	cb(true)
end)

RenzuNuiCallback('setVehicleSeat2', function(data, cb)
	vehicle = getveh()
    if IsVehicleSeatFree(vehicle,1) then
		shuffleseat(1)
	elseif IsVehicleSeatFree(vehicle,2) then
		shuffleseat(2)
    end
	cb(true)
end)

RenzuNuiCallback('setVehicleEnginestate', function(data, cb)
	vehicle = getveh()
    if GetIsVehicleEngineRunning(vehicle) then
        SetVehicleEngineOn(vehicle, false, false, true)
		start = false
		RenzuSendUI({
			type = "setStart",
			content = start
		})
		carcontrol = false
		RenzuSendUI({
			type = "setShowCarcontrol",
			content = carcontrol
		})
    else
        SetVehicleEngineOn(vehicle, true, true, true)
		start = true
		RenzuSendUI({
			type = "setStart",
			content = start
		})
		carcontrol = false
		RenzuSendUI({
			type = "setShowCarcontrol",
			content = carcontrol
		})
    end
	SetNuiFocus(false,false)
	cb(true)
end)

RegisterNetEvent("renzu_hud:airsuspension")
AddEventHandler("renzu_hud:airsuspension", function(vehicle,val,coords)
	local v = NetToVeh(vehicle)
	Creation(function()
		Wait(math.random(1,500))
		if vehicle ~= 0 and #(coords - GetEntityCoords(ped)) < 50 and not busyplate[GetPlate(v)] then
			busyplate[GetPlate(v)] = true
			if nearstancer[GetPlate(v)] ~= nil then
				nearstancer[GetPlate(v)].wheeledit = true
			end
			playsound(GetEntityCoords(v),20,'suspension',1.0)
			local max = 0
			local data = {}
			local min = GetVehicleSuspensionHeight(v)
			local count = 0
			data.val = val
			if (data.val * 100) < 15 then
				val = min
				data.val = data.val - 0.1
				local good = false
				count = 0
				while min > data.val and busyplate[GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min < data.val and busyplate[GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) + (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
				end
				SetVehicleSuspensionHeight(v,data.val)
			else
				val = min
				local good = false
				count = 0
				while min < data.val and busyplate[GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) + (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min > data.val and busyplate[GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					count = count + 1
					min = GetVehicleSuspensionHeight(v)
					Citizen.Wait(100)
				end
				SetVehicleSuspensionHeight(v,data.val)
			end
			--TriggerServerEvent("renzu_hud:airsuspension_state",VehToNet(vehicle), true)
			busyplate[GetPlate(v)] = false
			busyairsus = false
		end
		return
	end)
end)

RenzuNuiCallback('setvehicleheight', function(data, cb)
	vehicle = getveh()
    if vehicle ~= nil and vehicle ~= 0 and not busyairsus then
		busyairsus = true
		TriggerServerEvent("renzu_hud:airsuspension",VehToNet(vehicle), data.val, GetEntityCoords(vehicle))
    end
	cb(true)
end)

RenzuNuiCallback('setvehiclewheeloffsetfront', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		print(val)
		print("-0."..val.."")
		SetVehicleWheelXOffset(vehicle,0,tonumber("-0."..val..""))
		SetVehicleWheelXOffset(vehicle,1,tonumber("0."..val..""))
		if wheelsettings[plate]['wheeloffsetfront'] == nil then wheelsettings[plate]['wheeloffsetfront'] = {} end
		wheelsettings[plate]['wheeloffsetfront'].wheel0 = tonumber("-0."..val.."")
		wheelsettings[plate]['wheeloffsetfront'].wheel1 = tonumber("0."..val.."")
		wheeledit = true
		if nearstancer[plate] ~= nil then
			nearstancer[plate].wheeledit = true
		end
		RenzuSendUI({type = "unsetradio",content = false})
    end
	cb(true)
end)

RenzuNuiCallback('setvehiclewheeloffsetrear', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		print(val)
		print("-0."..val.."")
		SetVehicleWheelXOffset(vehicle,2,tonumber("-0."..val..""))
		SetVehicleWheelXOffset(vehicle,3,tonumber("0."..val..""))
		if wheelsettings[plate]['wheeloffsetrear'] == nil then wheelsettings[plate]['wheeloffsetrear'] = {} end
		wheelsettings[plate]['wheeloffsetrear'].wheel2 = tonumber("-0."..val.."")
		wheelsettings[plate]['wheeloffsetrear'].wheel3 = tonumber("0."..val.."")
		wheeledit = true
		if nearstancer[plate] ~= nil then
			nearstancer[plate].wheeledit = true
		end
		RenzuSendUI({type = "unsetradio",content = false})
    end
	cb(true)
end)

RenzuNuiCallback('setvehiclewheelrotationfront', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		print(val)
		print("-0."..val.."")
		SetVehicleWheelYRotation(vehicle,0,tonumber("-0."..val..""))
		SetVehicleWheelYRotation(vehicle,1,tonumber("0."..val..""))
		if wheelsettings[plate]['wheelrotationfront'] == nil then wheelsettings[plate]['wheelrotationfront'] = {} end
		wheelsettings[plate]['wheelrotationfront'].wheel0 = tonumber("-0."..val.."")
		wheelsettings[plate]['wheelrotationfront'].wheel1 = tonumber("0."..val.."")
		wheeledit = true
		if nearstancer[plate] ~= nil then
			nearstancer[plate].wheeledit = true
		end
		RenzuSendUI({type = "unsetradio",content = false})
    end
	cb(true)
end)

RenzuNuiCallback('setvehiclewheelrotationrear', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		print(val)
		print("-0."..val.."")
		SetVehicleWheelYRotation(vehicle,2,tonumber("-0."..val..""))
		SetVehicleWheelYRotation(vehicle,3,tonumber("0."..val..""))
		if wheelsettings[plate]['wheelrotationrear'] == nil then wheelsettings[plate]['wheelrotationrear'] = {} end
		wheelsettings[plate]['wheelrotationrear'].wheel2 = tonumber("-0."..val.."")
		wheelsettings[plate]['wheelrotationrear'].wheel3 = tonumber("0."..val.."")
		wheeledit = true
		if nearstancer[plate] ~= nil then
			nearstancer[plate].wheeledit = true
		end
		RenzuSendUI({type = "unsetradio",content = false})
    end
	cb(true)
end)

Creation(function()
	Wait(1000)
	if config.wheelstancer then
		while veh_stats == nil do
			Wait(100)
		end
		while true do
			local sleep = 2000
			for k,v in pairs(nearstancer) do
				if v.speed > 1 and not v.wheeledit and v.dist < 100 and veh_stats[v.plate] ~= nil and veh_stats[v.plate]['wheelsetting'] ~= nil then
					sleep = 50
					SetVehicleWheelWidth(v.entity,0.7) -- trick to avoid stance bug
					SetVehicleWheelXOffset(v.entity,0,tonumber(veh_stats[v.plate]['wheelsetting']['wheeloffsetfront'].wheel0))
					SetVehicleWheelXOffset(v.entity,1,tonumber(veh_stats[v.plate]['wheelsetting']['wheeloffsetfront'].wheel1))
					SetVehicleWheelXOffset(v.entity,2,tonumber(veh_stats[v.plate]['wheelsetting']['wheeloffsetrear'].wheel2))
					SetVehicleWheelXOffset(v.entity,3,tonumber(veh_stats[v.plate]['wheelsetting']['wheeloffsetrear'].wheel3))
					SetVehicleWheelSize(v.entity,GetVehicleWheelSize(v.entity)) -- trick to avoid stance bug tricking the system or game that this is all visual only not physics maybe?
					SetVehicleWheelYRotation(v.entity,0,tonumber(veh_stats[v.plate]['wheelsetting']['wheelrotationfront'].wheel0))
					SetVehicleWheelYRotation(v.entity,1,tonumber(veh_stats[v.plate]['wheelsetting']['wheelrotationfront'].wheel1))
					SetVehicleWheelYRotation(v.entity,2,tonumber(veh_stats[v.plate]['wheelsetting']['wheelrotationrear'].wheel2))
					SetVehicleWheelYRotation(v.entity,3,tonumber(veh_stats[v.plate]['wheelsetting']['wheelrotationrear'].wheel3))
					-- SetVehicleWheelTireColliderWidth(v.entity,0,0.4)
					-- SetVehicleWheelTireColliderWidth(v.entity,1,0.4)
					-- SetVehicleWheelTireColliderWidth(v.entity,2,0.1)
					-- SetVehicleWheelTireColliderWidth(v.entity,3,0.1)
				end
			end
			Wait(sleep)
		end
	end
	return
end)

RenzuNuiCallback('wheelsetting', function(data, cb)
	vehicle = getveh()
	wheeledit = false
	print("UNSET")
	print("UNSET")
	print("UNSET")
	print("UNSET")
	print("UNSET")
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
	get_veh_stats(getveh(), plate)
	if veh_stats[plate]['wheelsetting'] == nil then
		veh_stats[plate]['wheelsetting'] = {}
	end
	local vehicle_height = GetVehicleSuspensionHeight(vehicle)
	--for i = 0, numwheel - 1 do
	--will rewrite later for shorter code
	if wheelsettings[plate]['wheeloffsetfront'].wheel0 == nil then
		wheelsettings[plate]['wheeloffsetfront'].wheel0 = GetVehicleWheelXOffset(vehicle,0)
	end
	if wheelsettings[plate]['wheeloffsetfront'].wheel1 == nil then
		wheelsettings[plate]['wheeloffsetfront'].wheel1 = GetVehicleWheelXOffset(vehicle,1)
	end
	if wheelsettings[plate]['wheeloffsetrear'].wheel2 == nil then
		wheelsettings[plate]['wheeloffsetrear'].wheel2 = GetVehicleWheelXOffset(vehicle,2)
	end
	if wheelsettings[plate]['wheeloffsetrear'].wheel3 == nil then
		wheelsettings[plate]['wheeloffsetrear'].wheel3 = GetVehicleWheelXOffset(vehicle,3)
	end

	if wheelsettings[plate]['wheelrotationfront'].wheel0 == nil then
		wheelsettings[plate]['wheelrotationfront'].wheel0 = GetVehicleWheelYRotation(vehicle,0)
	end
	if wheelsettings[plate]['wheelrotationfront'].wheel1 == nil then
		wheelsettings[plate]['wheelrotationfront'].wheel1 = GetVehicleWheelYRotation(vehicle,1)
	end
	if wheelsettings[plate]['wheelrotationrear'].wheel2 == nil then
		wheelsettings[plate]['wheelrotationrear'].wheel2 = GetVehicleWheelYRotation(vehicle,2)
	end
	if wheelsettings[plate]['wheelrotationrear'].wheel3 == nil then
		wheelsettings[plate]['wheelrotationrear'].wheel3 = GetVehicleWheelYRotation(vehicle,3)
	end
	veh_stats[plate]['wheelsetting'] = wheelsettings[plate]
	--end
	veh_stats[plate].height = vehicle_height
    if vehicle ~= nil and vehicle ~= 0 and not data.bool then
		TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
	end
	Wait(1000)
	nearstancer[plate].wheeledit = false
	cb(true)
end)

RenzuNuiCallback('setvehicleneon', function(data, cb)
	vehicle = getveh()
	r,g,b = GetVehicleNeonLightsColour(vehicle)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(getveh(), i, data.bool)
			Citizen.Wait(500)
		end
	end
	cb(true)
end)

local neoneffect1 = false
local oldneon = nil
local r,g,b = nil,nil,nil
local o_r,og,ob = nil,nil,nil
RenzuNuiCallback('setneoneffect1', function(data, cb)
	vehicle = getveh()
	local mycar = vehicle
	r,g,b = GetVehicleNeonLightsColour(mycar)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		requestcontrol(mycar)
		neoneffect1 = not neoneffect1
		Wait(100)
		Creation(function()
			if neoneffect1 then
				o_r,og,ob = GetVehicleNeonLightsColour(mycar)
			end
			while neoneffect1 do
				requestcontrol(mycar)
				SetVehicleNeonLightsColour(mycar,getColor(0,0,0,255,255,255))
				for i = 0, 3 do
					--print("set")
					SetVehicleNeonLightEnabled(mycar, i, true)
				end
				Citizen.Wait(222)
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(mycar, i, false)
				end
				Citizen.Wait(222)
			end
			SetVehicleNeonLightsColour(mycar,o_r,og,ob)
			return
		end)
	end
	cb(true)
end)

local neoneffect2 = false
RenzuNuiCallback('setneoneffect2', function(data, cb)
	vehicle = getveh()
	local mycar = vehicle
	r,g,b = GetVehicleNeonLightsColour(mycar)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		neoneffect2 = not neoneffect2
		requestcontrol(mycar)
		Wait(100)
		Creation(function()
			while neoneffect2 do
				requestcontrol(mycar)
				rand = math.random(1,4) - 1
				math.randomseed(GetGameTimer())
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(mycar, i, data.bool)
				end
				for i = rand, rand do
					SetVehicleNeonLightEnabled(mycar, i, data.bool)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(mycar, i, not data.bool)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(mycar, i, data.bool)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(mycar, i, not data.bool)
				end
				Citizen.Wait(155)
			end
			return
		end)
	end
	cb(true)
end)

RenzuNuiCallback('setVehicleWindow1', function(data, cb)
	vehicle = getveh()
    if IsVehicleWindowIntact(vehicle,0) == 1 or IsVehicleWindowIntact(vehicle,0) then
        RollDownWindow(vehicle,1)
		RollDownWindow(vehicle,0)
    else     
        RollUpWindow(vehicle,1)
		RollUpWindow(vehicle,0)
    end
	cb(true)
end)

RenzuNuiCallback('setVehicleWindow2', function(data, cb)
	vehicle = getveh()
    if IsVehicleWindowIntact(vehicle,2) == 1 or IsVehicleWindowIntact(vehicle,2) then
        RollDownWindow(vehicle,2)
		RollDownWindow(vehicle,3)
    else     
        RollUpWindow(vehicle,3)
		RollUpWindow(vehicle,2)
    end
	cb(true)
end)

Creation(function()
	Citizen.Wait(1500)
	if config.weaponsui then
		if config.crosshairenable then
			RenzuSendUI({
				type = "setCrosshair",
				content = config.crosshair
			})
		end
	end
	return
end)

RenzuCommand(config.commands['weaponui'], function()
	config.weaponsui = not config.weaponsui
	RenzuSendUI({
		type = "setWeaponUi",
		content = config.weaponsui
	})
	weaponui = config.weaponsui
end, false)

RenzuCommand(config.commands['crosshair'], function(source, args, raw)
	if args[1] == nil then
		crosshair = 1
	else
		crosshair = args[1]
	end
	RenzuSendUI({
		type = "setCrosshair",
		content = crosshair
	})
	Notify('success','Crosshair System',"Crosshair has been changed")
end, false)

RegisterNetEvent("renzu_hud:addnitro")
AddEventHandler("renzu_hud:addnitro", function(amount)
		local lib, anim = 'mini@repair', 'fixing_a_car'
        local playerPed = PlayerPedId()
		playanimation('mini@repair','fixing_a_car')
		ClearPedTasks(playerPed)
		Wait(5000)
		Notify('success','Nitro System',"Nitro is Max")
		veh_stats[GetPlate(getveh())].nitro = 100
end)

RegisterNetEvent("renzu_hud:nitro_flame_stop")
AddEventHandler("renzu_hud:nitro_flame_stop", function(c_veh,coords)
		if purgefuck[c_veh] ~= nil then
			purgefuck[c_veh] = false
		end
		for k,v in pairs(purgeshit) do
			if k == c_veh then
				for k2,v2 in pairs(v) do
					StopParticleFxLooped(k2, 1)
					RemoveParticleFx(k2, true)
					k2 = nil
					print('remove2')
				end
				k = nil
			end
		end
		for k,v in pairs(lightshit) do
			if k == c_veh then
				for k2,v2 in pairs(v) do
					StopParticleFxLooped(k2, 1)
					RemoveParticleFx(k2, true)
					k2 = nil
					print('remove2')
				end
				k = nil
			end
		end
		RemoveParticleFxFromEntity(NetToVeh(c_veh))
end)

RegisterNetEvent("renzu_hud:nitro_flame")
AddEventHandler("renzu_hud:nitro_flame", function(c_veh,coords)
	print(coords - GetEntityCoords(ped))
	if #(coords - GetEntityCoords(ped)) < 50 then
		if not HasNamedPtfxAssetLoaded(config.nitroasset) then
			RequestNamedPtfxAsset(config.nitroasset)
			while not HasNamedPtfxAssetLoaded(config.nitroasset) do
				Wait(1)
			end
		end
		if GetEntitySpeed(NetToVeh(c_veh)) * 3.6 > 5 then
			local vehicle = NetToVeh(c_veh)
			for _,bones in pairs(config.tailights_bone) do
				UseParticleFxAssetNextCall(config.nitroasset)
				lightrailparticle = StartParticleFxLoopedOnEntityBone(config.trail_particle_name, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(vehicle, bones), config.trail_size, false, false, false)
				SetParticleFxLoopedEvolution(lightrailparticle, "speed", 1.00, false)
				if lightshit[c_veh] == nil then
					lightshit[c_veh] = {}
				end
				table.insert(lightshit[c_veh], lightrailparticle)
			end
			for _,bones in pairs(config.exhaust_bones) do
				UseParticleFxAssetNextCall(config.nitroasset)
				local index = GetEntityBoneIndexByName(vehicle, bones)
				if index ~= config.bannedindex then
					local boneposition = GetWorldPositionOfEntityBone(vehicle, index)
					local mufflerpos = GetOffsetFromEntityGivenWorldCoords(vehicle, boneposition.x, boneposition.y, boneposition.z)
					flames = StartParticleFxLoopedOnEntity('ent_amb_candle_flame',vehicle,mufflerpos.x,mufflerpos.y+0.9,mufflerpos.z-0.2,0.0,0.0,0.0,config.exhaust_flame_size * 6,false,false,false)
					SetParticleFxLoopedEvolution(flames, "speed", 0.00, false)
					SetParticleFxLoopedFarClipDist(flames,0.5)
					table.insert(flametable, flames)
					Wait(100)
				end
			end
			while GetVehicleThrottleOffset(vehicle) > 0.1 do
				Wait(100)
			end
			for k,v in pairs(flametable) do
				StopParticleFxLooped(k, 1)
				RemoveParticleFx(k, true)
				k = nil
			end

		else
			if not purgefuck[c_veh] then
				local vehicle = NetToVeh(c_veh)
				purgefuck[c_veh] = true
				print("purge")
				local index = GetEntityBoneIndexByName(vehicle, config.purge_left_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge1 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x + 0.03, particle_location.y + 0.1, particle_location.z+0.2, 20.0, 0.0, 0.5,config.purge_size,false,false,false)
																																												---20.0, 0.0, 0.5,config.purge_size,false,false,false)
				SetVehicleBoostActive(vehicle, 1, 0)
				SetVehicleBoostActive(vehicle, 0, 0)
				if purgeshit[c_veh] == nil then
					purgeshit[c_veh] = {}
				end
				table.insert(purgeshit[c_veh], purge1)
				local index = GetEntityBoneIndexByName(vehicle, config.purge_right_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge2 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x - 0.03, particle_location.y + 0.1, particle_location.z+0.2, 20.0, 0.0, 0.5,config.purge_size,false,false,false)
				table.insert(purgeshit[c_veh], purge2)
				while purgefuck[c_veh] do
					Wait(55)
					SetVehicleBoostActive(vehicle, 1, 0)
					SetVehicleBoostActive(vehicle, 0, 0)
				end
			end
		end
	end
end)

RenzuCommand(config.commands['enablenitro'], function()
	if vehicle ~= 0 then
		if config.enablenitro then
			if not nitromode then
				nitromode = not nitromode
				spool = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
				Notify('success','Nitro System',"Nitro has been activated")
				EnableNitro()
			else
				nitromode = not nitromode
				StopSound(spool)
				ReleaseSoundId(spool)
				Notify('warning','Nitro System',"Nitro has been off")
			end
		end
	end
end, false)

Creation(function()
	if config.enablenitro then
		RenzuKeybinds(config.commands['enablenitro'], 'Enable Nitro Control', 'keyboard', config.keybinds['enablenitro'])
	end
	return
end)

local installcount = 0
RegisterNetEvent("renzu_hud:installtire")
AddEventHandler("renzu_hud:installtire", function(type)
	local bones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local index = {["wheel_lf"] = 0, ["wheel_rf"] = 1, ["wheel_lm1"] = 2, ["wheel_rm1"] = 3, ["wheel_lm2"] = 45,["wheel_rm2"] = 47, ["wheel_lm3"] = 46, ["wheel_rm3"] = 48, ["wheel_lr"] = 4, ["wheel_rr"] = 5,}
	local coords = GetEntityCoords(ped, false)
	local vehicle = getveh()
	if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, -1) and IsPedOnFoot(ped) then
		for i = 1, #bones do
			local tirepos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, bones[i]))
			local distance = #(coords - tirepos)
			local currentindex = bones[bones[i]]
			local plate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
			plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
			if veh_stats == nil then
				veh_stats = {}
			end
			if plate ~= nil and veh_stats[plate] == nil then
				veh_stats[plate] = {}
				veh_stats[plate].plate = plate
				veh_stats[plate].mileage = 0
				veh_stats[plate].oil = 100
				veh_stats[plate].coolant = 100
				veh_stats[plate].nitro = 100
				local numwheel = GetVehicleNumberOfWheels(vehicle)
				for i = 0, numwheel - 1 do
					if veh_stats[plate][tostring(i)] == nil then
						veh_stats[plate][tostring(i)] = {}
					end
					veh_stats[plate][tostring(i)].tirehealth = config.tirebrandnewhealth
				end
			end
			if distance < 3 and veh_stats ~= nil and veh_stats[plate] ~= nil then
				tireanimation()
				Wait(1000)
				if config.repairalltires then
					playanimation('anim@amb@clubhouse@tutorial@bkr_tut_ig3@','machinic_loop_mechandplayer')
					Makeloading('Installing New Tires',10000)
					Citizen.Wait(10000)
					local numwheel = GetVehicleNumberOfWheels(vehicle)
					for tire = 0, numwheel - 1 do
						SetVehicleTyreFixed(vehicle, tire)
						SetVehicleWheelHealth(vehicle, tire, 1000.0)
						veh_stats[plate][tostring(tire)].tirehealth = 999.0
						local wheeltable = {
							['index'] = tire,
							['tirehealth'] = veh_stats[plate][tostring(tire)].tirehealth
						}
						RenzuSendUI({
							type = "setWheelHealth",
							content = wheeltable
						})
					end
					Notify('success','Tire System',"New Tires has been Successfully Install")
					ClearPedTasks(ped)
					if type ~= nil and type ~= 'default' then
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult) -- start burnout less = traction
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult)  -- asphalt mud less = traction
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin) -- accelaration grip
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax) -- cornering grip
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral) -- curve lateral grip
						veh_stats[plate].tirespec = {}
						veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult
						veh_stats[plate].tirespec['fTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult
						veh_stats[plate].tirespec['fTractionCurveMin'] = DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin
						veh_stats[plate].tirespec['fTractionCurveMax'] = DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax
						veh_stats[plate].tirespec['fTractionCurveLateral'] = DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral
					end
					if type ~= nil then
						veh_stats[plate].tires = type
					end
					TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
					ReqAndDelete(proptire,true)
					break
				else
					playanimation('anim@amb@clubhouse@tutorial@bkr_tut_ig3@','machinic_loop_mechandplayer')
					Makeloading('Installing New Tire #'..i..'',10000)
					Citizen.Wait(10000)
					SetVehicleTyreFixed(vehicle, i)
					SetVehicleWheelHealth(vehicle, i, 1000.0)
					veh_stats[plate][tostring(i)].tirehealth = 999.0
					ClearPedTasks(ped)
					local wheeltable = {
						['index'] = i,
						['tirehealth'] = veh_stats[plate][tostring(i)].tirehealth
					}
					RenzuSendUI({
						type = "setWheelHealth",
						content = wheeltable
					})
					installcount = installcount + 1
					if type ~= nil and type ~= 'default' and installcount >= (numwheel + 1) then
						installcount = 0
						if type ~= nil and type ~= 'default' then
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult) -- start burnout less = traction
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult)  -- asphalt mud less = traction
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin) -- accelaration grip
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax) -- cornering grip
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral) -- curve lateral grip
							veh_stats[plate].tirespec = {}
							veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult
							veh_stats[plate].tirespec['fTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult
							veh_stats[plate].tirespec['fTractionCurveMin'] = DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin
							veh_stats[plate].tirespec['fTractionCurveMax'] = DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax
							veh_stats[plate].tirespec['fTractionCurveLateral'] = DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral
						end
						if type ~= nil then
							veh_stats[plate].tires = type
						end
					end
					TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
					Notify('success','Tire System',"New Tire #"..i.." has been Successfully Install")
					ReqAndDelete(proptire,true)
					break
				end
				ClearPedTasks(ped)
			end
		end
	end
end)

Creation(function()
	if config.repaircommand then
		RenzuCommand('repairtire', function()
			TriggerEvent("renzu_hud:installtire")
		end, false)
	end
	return
end)

Creation(function()
	if config.carlock then
		RenzuCommand(config.commands['carlock'], function()
			Carlock()
		end, false)
		RenzuKeybinds(config.commands['carlock'], 'Toggle Carlock System', 'keyboard', config.keybinds['carlock'])
	end
	return
end)

RegisterNetEvent("renzu_hud:synclock")
AddEventHandler("renzu_hud:synclock", function(v, type, coords)
	local v = NetToVeh(v)
	if #(coords - GetEntityCoords(ped)) < 50 then
		SetVehicleLights(v, 2);Citizen.Wait(100);SetVehicleLights(v, 0);Citizen.Wait(200);SetVehicleLights(v, 2)
		Citizen.Wait(100)
		SetVehicleLights(v, 0)	
		if type == 'lock' then
			--print("locking shit")
			playsound(coords,20,'lock',1.0)
			SetVehicleDoorsLocked(v,2)
			Wait(500)
			ClearPedTasks(ped)
		end
		if type == 'force' then
			SetVehicleDoorsLocked(v,7)
		end
		if type == 'carjack' then
			SetVehicleDoorsLocked(v,1)
		end
		if type == 'unlock' then
			--print("unlocking shit")
			playsound(coords,20,'unlock',1.0)
			SetVehicleDoorsLocked(v,1)
			Wait(500)
			ClearPedTasks(ped)
		end
	end
end)

RenzuNuiCallback('hidecarlock', function(data, cb)
    SetNuiFocus(false,false)
	RenzuSendUI({
		type = "setShowKeyless",
		content = false
	})
	keyless = true
	cb(true)
end)

RenzuNuiCallback('setvehiclelock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Notify('success','Vehicle Lock System','Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", VehToNet(data.vehicle), 'lock', GetEntityCoords(ped))
    end
	cb(true)
end)

RenzuNuiCallback('setvehicleunlock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Notify('success','Vehicle Lock System','Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", VehToNet(data.vehicle), 'unlock', GetEntityCoords(ped))
    end
	cb(true)
end)

RenzuNuiCallback('setvehicleopendoors', function(data, cb)
	--print("openall")
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Opening All Doors # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		playsound(GetEntityCoords(data.vehicle),20,'openall',1.0)
		for i = 0, 3 do
			if data.bool then
				--print(i)
				SetVehicleDoorOpen(data.vehicle,i,false,false)
			else     
				SetVehicleDoorShut(data.vehicle,i,false,false)
			end
		end
		if data.bool then
			Notify('success','Lock System',"All Doors is Open")
		else
			Notify('warning','Lock System',"All Doors has been closed")
		end
		Wait(500)
		ClearPedTasks(ped)
    end
	cb(true)
end)

RenzuNuiCallback('setvehiclealarm', function(data, cb)
	--print("vehicle alarm")
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		Makeloading('Vehicle Alarm Mode # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		if data.bool then
			SetVehicleAlarm(data.vehicle, 1)
			StartVehicleAlarm(data.vehicle)
			SetVehicleAlarmTimeLeft(data.vehicle, 180000)
			alarmStatus = true
		else
			SetVehicleAlarm(data.vehicle, 0)
			alarmStatus = false
		end
		Wait(500)
		ClearPedTasks(ped)
    end
	cb(true)
end)

--clothes
Creation(function()
	Wait(500)
	--print("CLOTHING")
	if config.clothing then
		while DecorGetBool(PlayerPedId(), "PLAYERLOADED") ~= 1 do
			Citizen.Wait(100)
			--print(DecorGetBool(PlayerPedId(), "PLAYERLOADED"))
			if playerloaded then
				DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
				break
			end
			--print("Playerloaded")
		end
		Wait(4000) -- wait 4 sec after the playerloaded event to get ped skin
		TriggerEvent('skinchanger:getSkin', function(current)
			dummyskin1 = current
		end)
		while tablelength(dummyskin1) <= 2 do
			TriggerEvent('skinchanger:getSkin', function(current) dummyskin1 = current end)
			Wait(1000)
			print("dummy")
		end
		SaveCurrentClothes(true)
		skinsave = false
		RenzuCommand(config.commands['clothing'], function()
			SaveCurrentClothes(false)
			if not skinsave then
				--SaveCurrentClothes(false)
				skinsave = true
			end
			Clothing()
		end, false)
		RenzuKeybinds(config.commands['clothing'], 'Toggle Clothing UI', 'keyboard', config.keybinds['clothing'])
	end
	return
end)

local clothebusy = false
RegisterNUICallback('ChangeClothes', function(data)
	local skin = oldclothes
	if not clothebusy then
		clothebusy = true
		if clothestate[tostring(data.variant)] then
			TaskAnimation(config.clothing[data.variant]['taskplay'])
			Notify("success","Clothe System",""..data.variant.." is put off")
			local st = nil
			TriggerEvent('skinchanger:getSkin', function(current)
				TriggerEvent('skinchanger:loadClothes', current, config.clothing[data.variant].skin)
			end)
			PlaySoundFrontend(PlayerId(), 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
			clothestate[tostring(data.variant)] = false
			print(clothestate[tostring(data.variant)])
			if data.variant == 'mask_1' or data.variant == 'helmet_1' then
				RenzuSendUI({content = true, type = 'pedface'})
			end
			local table = {
				['bool'] = clothestate[data.variant],
				['variant'] = data.variant
			}
			RenzuSendUI({
				type = "setClotheState",
				content = table
			})
		else
			if oldclothes[tostring(data.variant)] == config.clothing[tostring(data.variant)]['default'] then
				Notify("warning","Clothe System","No Variant for this type")
			else 
				TaskAnimation(config.clothing[data.variant]['taskplay'])
				Notify("success","Clothe System",""..data.variant.." is put on")
				local Changes = {}
				if data.variant == 'mask_1' or data.variant == 'helmet_1' then
					RenzuSendUI({content = true, type = 'pedface'})
				end
				Changes[tostring(data.variant)], Changes[tostring(data.variant2)] = skin[tostring(data.variant)], skin[tostring(data.variant2)]
				if data.variant == 'torso_1' then
					Changes['arms'], Changes['arms_2'] = skin['arms'], skin['arms_2']
				end
				TriggerEvent('skinchanger:getSkin', function(current)
					TriggerEvent('skinchanger:loadClothes', current, Changes)
				end)
				clothestate[tostring(data.variant)] = true
				print(clothestate[tostring(data.variant)])
				PlaySoundFrontend(PlayerId(), 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
				local table = {
					['bool'] = clothestate[data.variant],
					['variant'] = data.variant
				}
				RenzuSendUI({
					type = "setClotheState",
					content = table
				})
			end
		end
		Wait(500)
		clothebusy = false
	end
end)

RegisterNUICallback('hideclothing', function(data)
	clothing = false
	local table = {
		['bool'] = clothing,
		['equipped'] = clothestate
	}
	RenzuSendUI({
		type = "setShowClothing",
		content = table
	})
	SetNuiFocusKeepInput(clothing)
	SetNuiFocus(clothing,clothing)
end)

RegisterNUICallback('resetclothing', function()
	TaskAnimation(config.clothing['reset']['taskplay'])
	TriggerEvent('skinchanger:loadClothes', oldclothes, oldclothes)
	Citizen.Wait(100)
	SaveCurrentClothes(true)
	Citizen.Wait(100)
	ClotheState()
	RenzuSendUI({type = 'ResetClotheState', content = clothestate})
end)

Creation(function()
	Wait(500)
	if config.carstatus then
		RenzuCommand(config.commands['vehicle_status'], function()
			CarStatus()
		end, false)
		RenzuKeybinds(config.commands['vehicle_status'], 'Toggle Vehicle Status', 'keyboard', config.keybinds['vehicle_status'])
	end
	return
end)

--ENGINE SYSTEM

local busy_install = false
RegisterNetEvent('renzu_hud:change_engine')
AddEventHandler('renzu_hud:change_engine', function(engine)
	if not busy_install then
		local oldengine = engine
		local handling = GetHandlingfromModel(GetHashKey(engine))
		local getcurrentvehicleweight = GetVehStats(getveh(), "CHandlingData","fMass")
		print(getcurrentvehicleweight,handling['fMass'])
		if getcurrentvehicleweight <= config.motorcycle_weight_check and handling['fMass'] > 600 then
			Notify('warning','Engine System',"this engine is not fit to this vehicle")
		else
			local bone = GetEntityBoneIndexByName(getveh(),'engine')
			local x,y,z = table.unpack(GetWorldPositionOfEntityBone(getveh(), bone))
			if getveh() ~= 0 and #(GetEntityCoords(ped) - vector3(x,y,z)) <= config.engine_dis then
				busy_install = true
				SetVehicleFixed(getveh())
				plate = tostring(GetVehicleNumberPlateText(getveh()))
				plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
				get_veh_stats(getveh(), plate)
				veh_stats[plate].engine = engine
				--print("loop item")
				Citizen.Wait(2000)
				playanimation('creatures@rottweiler@tricks@','petting_franklin')
				--ExecuteCommand("e petting")
				Renzuzu.Wait(2500)
				ClearPedTasks(ped)
				playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
				--ExecuteCommand("e gangsign")
				Renzuzu.Wait(200)
				SetVehicleDoorOpen(getveh(),4,false,false)
				Renzuzu.Wait(400)
				ClearPedTasks(ped)
				SetVehicleDoorOpen(getveh(),4,false,false)
				Wait(1000)
				SetVehicleDoorBroken(getveh(),4,true)
				Wait(1000)
				if config.enable_engine_prop then
					installing = true
					for k,v in pairs(config.blacklistvehicle) do
						print(GetVehicleClass(getveh()))
						if tonumber(GetVehicleClass(getveh())) == tonumber(v) then
							installing = false
							busy_install = false
						end
					end
					if installing then
						repairengine(plate)
					end
				end
				engine_c = GetOffsetFromEntityInWorldCoords(enginemodel)
				local count = 25
				DetachEntity(enginemodel)
				while installing do
					if RCR(1, 173) then
						SetEntityCoords(enginemodel,engine_c.x,engine_c.y,engine_c.z - 0.05)
						engine_c = GetOffsetFromEntityInWorldCoords(enginemodel)
						count = count - 1
					end
					if RCR(1, 172) then
						SetEntityCoords(enginemodel,engine_c.x,engine_c.y,engine_c.z + 0.05)
						engine_c = GetOffsetFromEntityInWorldCoords(enginemodel)
						count = count + 1
					end
					if count <= 0 then
						installing = false
						busy_install = false
						break
					end
					Wait(7)
				end

				playanimation('creatures@rottweiler@tricks@','petting_franklin')
				Wait(10000)
				busy_install = false
				installing = false
				ReqAndDelete(enginemodel,true)
				ReqAndDelete(standmodel,true)
				ClearPedTasks(ped)
				SetVehicleFixed(getveh())
				TriggerServerEvent('renzu_hud:change_engine', plate, veh_stats[plate])
			else
				Notify('warning','Engine System',"You must be infront of the vehicle engine - Walk to the engine position now")
				while engine == oldengine do
					--print(#(vector3(x,y,z) - GetEntityCoords(ped)), oldengine)
					if #(vector3(x,y,z) - GetEntityCoords(ped)) <= 2.2 then
						busy_install = false
						TriggerEvent('renzu_hud:change_engine',oldengine)
						break
					end
					Wait(100)
				end
			end
		end
	else
		Notify('warning','Engine System',"You have ongoing installation, go to the vehicle")
	end
end)

RegisterNetEvent('renzu_hud:syncengine')
AddEventHandler('renzu_hud:syncengine', function(plate, table)
    veh_stats[tostring(plate)] = table
end)

RenzuCommand(config.commands['carui'], function(source, args, raw)
	DefineCarUI(args[1])
end)

RenzuCommand(config.commands['dragui'], function(source, args, raw)
	bool = not bool
	RenzuSendUI({
		type = "Drag",
		content = bool
	})
	SetNuiFocus(bool,bool)
end)

RenzuCommand(config.commands['dragcarui'], function(source, args, raw)
	bool = not bool
	RenzuSendUI({
		type = "DragCar",
		content = bool
	})
	SetNuiFocus(bool,bool)
end)

pause = false
RenzuKeybinds('ESCAPE', 'Pause Menu', 'keyboard', 'ESCAPE')
RenzuCommand('ESCAPE', function(source, args, raw)
	if not IsPauseMenuActive() and not pause then
		pause = not pause
		Wait(500)
		RenzuSendUI({
			type = "hideui",
			content = false
		})
		Creation(function()
			while IsPauseMenuActive() == 1 do
				Wait(10)
			end
			pause = not pause
			RenzuSendUI({
				type = "hideui",
				content = true
			})
			return
		end)
	end
end)

RenzuKeybinds(config.commands['carheadlight'], 'Vehicle Headlight', 'keyboard', config.keybinds['carheadlight'])
RenzuCommand(config.commands['carheadlight'], function(source, args, raw)
	Wait(500)
	local off,low,high = GetVehicleLightsState(vehicle)
	local light = 0
	if low == 1 and high == 0 then
		light = 1
	elseif high == 1 then
		light = 2
	elseif off == 1 then
		light = 0
	end
	print(off,low,high)
	newlight = light
	RenzuSendUI({
	type = "setHeadlights",
	content = light
	})
end)

RenzuCommand(config.commands['uiconfig'], function(source, args, raw)
	local set = nil
	if args[1] == 'transition' then
		set = args[2] or 'ease'
		config.transition = args[2] or 'unset'
	end
	if args[1] == 'ms' then
		set = args[2] or '0ms'
		config.animation_ms = args[2] or '0ms'
	end
	if args[1] == 'acceleration' then
		set = args[2] or 'none'
		config.acceleration = args[2] or 'unset'
	end
	config.uiconfig = {acceleration = config.acceleration, animation_ms = config.animation_ms, transition = config.transition}
	RenzuSendUI({
		type = "uiconfig",
		content = config.uiconfig
	})
end)

CreateThread(function()
	Wait(10000)
	collectgarbage() -- collect all destroyed threads from memory
end)