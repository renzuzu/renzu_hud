-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
ESX = nil
local getdata = false
CreateThread(function()
	LocalPlayer.state:set('playerloaded', false,true)
	if config.framework == 'ESX' then
		ESX = exports['es_extended']:getSharedObject()
		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
	elseif config.framework == 'VRP' then
		local Tunnel = module("vrp","lib/Tunnel")
		local Proxy = module("vrp","lib/Proxy")
		vRP = Proxy.getInterface("vRP")
	elseif config.framework == 'QBCORE' then
		while not QBCore do
		    pcall(function() QBCore =  exports['qb-core']:GetCoreObject() end)
		    if not QBCore then
			pcall(function() QBCore =  exports['qb-core']:GetSharedObject() end)
		    end
		    if not QBCore then
			TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		    end
		    Citizen.Wait(1)
		end
		QBCore.Functions.GetPlayerData(function(PlayerData)
			xPlayer = PlayerData
        end)
		ESX = true
	else
		ESX = true
	end
	DecorRegister("INERTIA", 1);DecorRegister("DRIVEFORCE", 1);DecorRegister("TOPSPEED", 1);DecorRegister("STEERINGLOCK", 1);DecorRegister("MAXGEAR", 1);DecorRegister("TRACTION", 1);DecorRegister("TRACTION2", 1);DecorRegister("TRACTION3", 1);DecorRegister("TRACTION4", 1);DecorRegister("TRACTION5", 1)
	if not DecorIsRegisteredAsType("MANUAL", 1) then DecorRegister("MANUAL", 1) end
	DecorRegister("PLAYERLOADED", 1);DecorRegister("CHARSLOT", 1)
end)

RegisterNetEvent('esx:setJob', function(job)
	xPlayer.job = job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	print('logout')
	SendNUIMessage({
		type = "hideui",
		content = false
	})
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    SendNUIMessage({
		type = "hideui",
		content = false
	})
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VOICE FUNC
-----------------------------------------------------------------------------------------------------------------------------------------

--PMA VOICE LISTENER
RegisterNetEvent("pma-voice:setTalkingMode", function(prox)
	Hud.voiceDisplay = prox
	SendNUIMessage({
		type = "setMic",
		content = prox
	})
end)

--MUMBLE VOIP SetVoice Listener
local current_channel = 0
local cdch = 0
RegisterNetEvent("renzu_hud:SetVoiceData", function(mode,val)
	if mode == 'radio' then
		Wait(0,math.random(500)) -- fix old rpradio ver
	end
	if mode == 'proximity' then
		Hud.voiceDisplay = val
		SendNUIMessage({
			type = "setMic",
			content = val
		})
	elseif mode == 'radio' and cdch < GetGameTimer() then
		cdch = GetGameTimer() + 1000
		if current_channel == val then val = 0 end
		local channel = config.radiochannels[val].text
		if channel ~= nil and channel.job ~= nil and channel.job ~= 'all' and xPlayer ~= nil and xPlayer.job ~= nil and channel.job ~= xPlayer.job.name then
			channel = false
			val = 0
		end
		if val == 0 then
			channel = false
			val = 0
		end
		SendNUIMessage({
			type = "setRadioChannel",
			content = channel
		})
		current_channel = val
	end
end)

-- PMA RADIO CHANNEL LISTENER
RegisterNetEvent("pma-voice:clSetPlayerRadio", function(channel)
	local channel = config.radiochannels[channel].text
	if channel.job ~= 'all' and xPlayer ~= nil and xPlayer.job ~= nil and channel.job ~= xPlayer.job.name then
		channel = false
	end
	SendNUIMessage({
		type = "setRadioChannel",
		content = channel
	})
end)

-- PMA REMOVE PLAYER FROM CHANNEL RADIO
RegisterNetEvent("pma-voice:removePlayerFromRadio", function(channel)
	SendNUIMessage({
		type = "setRadioChannel",
		content = false
	})
end)


CreateThread(function()
	if config.voicecommandandkeybind then
		RegisterCommand(config.commands['voip'], function()
			if Hud.proximity == 3.0 then
				Hud.voiceDisplay = 1
				Hud.proximity = 10.0
			elseif Hud.proximity == 10.0 then
				Hud.voiceDisplay = 2
				Hud.proximity = 25.0
			elseif Hud.proximity == 25.0 then
				Hud.voiceDisplay = 3
				Hud.proximity = 3.0
			end
			if config.enableproximityfunc then
				Hud:setVoice()
			end
			SendNUIMessage({
				type = "setMic",
				content = Hud.voiceDisplay
			})
		end, false)
		RegisterKeyMapping(config.commands['voip'], 'Voice Proximity', 'keyboard', config.keybinds['voip'])
	end
	return
end)

RegisterNetEvent('renzu_hud:charslot', function(charid)
	Hud.charslot = charid
	while not LocalPlayer.state.playerloaded do
		Wait(100)
	end
	Wait(2000)
	if DecorExistOn(PlayerPedId(), "CHARSLOT") then
		DecorRemove(PlayerPedId(), "CHARSLOT")
	end
	DecorSetFloat(PlayerPedId(), "CHARSLOT", Hud.charslot*1.0) -- fuck bug in int type
end)

-- loaded events
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	Wait(1000)
	LocalPlayer.state:set('playerloaded', true,true)
	LocalPlayer.state.playerloaded = true
	Wait(2000)
	Hud.lastped = PlayerPedId()
	DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
	Wait(5000)
	SendNUIMessage({content = true, type = 'pedface'})
	SendNUIMessage({content = true, type = 'playerloaded'})
	SendNUIMessage({
		type = "hideui",
		content = true
	})
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Wait(1000)
	LocalPlayer.state:set('playerloaded', true,true)
	LocalPlayer.state.playerloaded = true
	Wait(2000)
	Hud.lastped = PlayerPedId()
	DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
	Wait(5000)
	SendNUIMessage({content = true, type = 'pedface'})
	SendNUIMessage({content = true, type = 'playerloaded'})
	SendNUIMessage({
		type = "hideui",
		content = true
	})
end)

RegisterNetEvent('playerSpawned', function(spawn)
	if config.framework ~= 'ESX' and config.framework ~= 'QBCORE' then
		Wait(1000)
		LocalPlayer.state:set('playerloaded', true,true)
		LocalPlayer.state.playerloaded = true
		Wait(2000)
		Hud.lastped = PlayerPedId()
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		Wait(5000)
		SendNUIMessage({content = true, type = 'pedface'})
		SendNUIMessage({content = true, type = 'playerloaded'})
	end
end)

CreateThread(function()
	Wait(1000)
	if Hud.charslot == nil and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0.0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= nil then
		Hud.charslot = Hud:round(DecorGetFloat(PlayerPedId(),"CHARSLOT"))
	else
		Citizen.Wait(4000)
	end
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and Hud.charslot ~= nil then
		LocalPlayer.state.playerloaded = true
		SendNUIMessage({content = true, type = 'playerloaded'})
	end
	Wait(500)
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and config.loadedasmp and Hud:isplayer() then
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		LocalPlayer.state.playerloaded = true
		SendNUIMessage({content = true, type = 'pedface'})
		SendNUIMessage({content = true, type = 'playerloaded'})
	elseif Hud:isplayer() and config.forceplayerload then
		Wait(10000)
		LocalPlayer.state.playerloaded = true
		Wait(2000)
		Hud.lastped = PlayerPedId()
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		Wait(5000)
		SendNUIMessage({content = true, type = 'pedface'})	
		SendNUIMessage({content = true, type = 'playerloaded'})
	elseif DecorExistOn(PlayerPedId(), "PLAYERLOADED") then
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		LocalPlayer.state.playerloaded = true
		SendNUIMessage({content = true, type = 'pedface'})
		SendNUIMessage({content = true, type = 'playerloaded'})
	end
	while not LocalPlayer.state.playerloaded do
		Wait(1000)
	end

	while LocalPlayer.state.playerloaded do -- dev purpose when restarting script, either you uncomment this or Hud.left it , it doesnt matter.
		Wait(20000)
		if not DecorExistOn(PlayerPedId(), "PLAYERLOADED") then
			DecorRemove(Hud.lastped,"PLAYERLOADED")
			DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		end
	end
	--return
end)


--- NEW HUD FUNC
RegisterNUICallback('requestface', function(data, cb)
	while not LocalPlayer.state.playerloaded do
		Wait(1000)
	end
	while not Hud:isplayer() do
		Wait(1000)
	end
    cb(Hud:getawsomeface(data.force or false))
	Hud:ClearPedHeadshots()
end)

CreateThread(function()
	while not LocalPlayer.state.playerloaded do Wait(100) end
	Wait(1000)
	for k,v in pairs(config.statusordering) do
		if v.enable then
			Hud.notifycd[v.status] = 0
		end
	end
	if config.enablestatus then
		while not Hud.reorder do Wait(100) end
		local register = {}
		local registered = false
		local vitals = {}
		AddEventHandler("esx_status:onTick", function(vitals) -- use renzu_status
			vitals = vitals
			if vitals[1] ~= nil then -- esx status (if index int is not nil, its a normal esx_status) else its renzu_status
				if Hud.esx_status == nil then
					for k,v in ipairs(config.statusordering) do -- replace int to string name
						config.statusordering[v.status] = v
						config.statusordering[k] = nil
					end
					config.statusordering['health'] = config.statusordering[0]
					config.statusordering[0] = nil
					Hud.esx_status = true
				end
				for k,v in ipairs(vitals) do
					if config.statusordering[v.name] ~= nil then
						vitals[v.name] = v.val -- populate the data from esx_status and convert to renzu_status format
						vitals[k] = nil
					else
						vitals[k] = nil
					end
				end
			else
				Hud.esx_status = false
			end
			if config.framework ~= 'QBCORE' then
				Hud:UpdateStatus(false,vitals)
			end

			for k,v in pairs(vitals) do
				register[k] = true
			end

			if config.registerautostatus and not registered then
				DecorRegister("STATUSR", 1)
				for k,v in pairs(config.statusordering) do -- register all status
					if v.enable and v.custom and register[v.status] == nil and not DecorGetBool(PlayerPedId(), "STATUSR") then
						local remove_value = v.statusremove
						TriggerEvent('esx_status:registerStatus', v.status, tonumber(v.startvalue), '#CFAD0F', function(status)
							return true
							end, function(status)
							status.remove(remove_value)
						end)
					end
				end
				DecorSetBool(PlayerPedId(), "STATUSR", true)
				registered = true
			end
		end)
		if config.framework == 'QBCORE' then
			local hunger = 0
			local thirst = 0
			local stress = 0
			CreateThread(function()
				while true do
					--TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
					Citizen.Wait(250)
					QBCore.Functions.GetPlayerData(function(PlayerData)
						if PlayerData ~= nil and PlayerData.metadata ~= nil then
							hunger, thirst, stress = PlayerData.metadata["hunger"] * 10000, PlayerData.metadata["thirst"] * 10000, PlayerData.metadata["stress"] * 10000
							local statusqb = {
								['hunger'] = hunger,
								['thirst'] = thirst,
								['stress'] = stress -- this should be registered at config
							}
							for k,v in pairs(vitals) do
								if k ~= 'hunger' and k ~= 'thirst' and k ~= 'stress' then
									statusqb[k] = v
								end
							end
							Hud:UpdateStatus(false,statusqb)
						end
					end)
					Wait(2500)
				end
			end)
		end
	else
		for k,v in pairs(config.statusordering) do
			v.enable = false
		end
	end
	return
end)

CreateThread(function()
	while not LocalPlayer.state.playerloaded do Wait(100) end
	Wait(2000)
	SetPlayerUnderwaterTimeRemaining(Hud.pid,9999)
	SetPedMaxTimeUnderwater(Hud.ped,99999)
	for k,v in pairs(config.statusordering) do
		if v.custom and v.enable then
			Hud.statuses[k] = v.status
		end
	end

	if config.statusv2 then
		SendNUIMessage({
			type = "setShowstatusv2",
			content = config.statusv2
		})
	end

	SendNUIMessage({
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
	if nuiloop then
		CreateThread(function()
			while true do
				if se and not Hud.invehicle then
					Citizen.CreateThreadNow(function()
						Wait(1000)
						Hud:setStatusEffect()
						return
					end)
				end
				if wui and not Hud.invehicle then
					Hud:WeaponStatus()
				end
				if ec then
					Hud:Compass()
				end
				Wait(2500)
			end
		end)
	end
	if config.enablestatus or not config.enablestatus and config.statusui == 'normal' then
		while not LocalPlayer.state.playerloaded do Wait(100) end
		Hud:updateplayer(true)
	end
end)

RegisterCommand(config.commands['showstatus'], function()
	Hud.show = not Hud.show
    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0 )
	SendNUIMessage({
		type = "setShowstatus",
		content = {['bool'] = Hud.show, ['enable'] = config.enablestatus}
	})
	Hud:Myinfo(true)
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['showstatus'], 'HUD Status UI', 'keyboard', config.keybinds['showstatus'])
	return
end)

RegisterNUICallback('pushtostart', function(data, cb)
	Hud.start = true
	Hud.breakstart = false
	cb(true)
end)

RegisterNUICallback('getoutvehicle', function(data, cb)
	Hud.start = false
	Hud.breakstart = false
	SetNuiFocus(false,false)
	TaskLeaveVehicle(Hud.ped,Hud.vehicle,0)
	cb(true)
end)

CreateThread(function()
	while not LocalPlayer.state.playerloaded do Wait(100) end
	local enable_status = config.enablestatus
	local ordering = config.statusordering
	local placing = config.statusplace
	local status_type = config.status_type
	local status_ui = config.statusui
	local uiconf = config.uiconfig
	while config.userconfig == nil do Wait(100) end
	SendNUIMessage({type = "reimportsetting",content = config.userconfig})
	Wait(500)
	SendNUIMessage({type = "setStatusUI",content = {['type'] = status_type, ['ver'] = status_ui, ['enable'] = enable_status}})
	Wait(1000)
	SendNUIMessage({map = true, type = 'sarado'})
	--SendNUIMessage({type = "uiconfig", content = uiconf})
	SendNUIMessage({type = "setStatusType",content = status_type})
	Wait(500)
	SendNUIMessage({type = "SetStatusOrder",content = {['data'] = ordering, ['float'] = placing}})
	Wait(1000)
	Hud.reorder = true
	while not LocalPlayer.state.playerloaded do Citizen.Wait(100) print("loading") end
	Wait(100)
	local tbl = {['data'] = ordering, ['float'] = placing}
	if config.enable_carui then
		SendNUIMessage({type = 'setCarui', content = config.carui})
	end
	Wait(500)
	SendNUIMessage({type = "setCompass",content = config.enablecompass})
	Wait(500)
	SendNUIMessage({type = "changeallclass",content = config.uidesign})
	Wait(100)
	--SendNUIMessage({type = 'setCarui', content = config.carui})
	Wait(100)
	Hud:statusplace()
	--WHEN RESTARTED IN CAR
	if not Hud.uimove and config.enable_carui then
		local content = {
			['bool'] = false,
			['type'] = config.carui
		}
		SendNUIMessage({
			type = "setShow",
			content = content
		})
	end
	Hud.uimove = true
	SendNUIMessage({map = true, type = 'sarado'})
	if config.enable_carui and GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
		Wait(100)
		Hud.start = true
		SendNUIMessage({
			type = "setStart",
			content = Hud.start
		})
		Hud.vehicle = GetVehiclePedIsIn(PlayerPedId())
		Hud:EnterVehicleEvent(true,Hud.vehicle)
	end
	--WHEN RESTARTED IN CAR
	local l = 0
	Hud.notloaded = false
	while true do
		Hud.ped = PlayerPedId()
		Hud.vehicle = GetVehiclePedIsIn(Hud.ped)
		if config.enablestatus or not config.enablestatus and config.statusui == 'normal' then
			Hud:updateplayer()
		end
		if Hud.invehicle and Hud.vehicle == 0 then
			Hud:EnterVehicleEvent(false)
		end
		if config.enable_carui and build() < 2000 and not Hud.invehicle and Hud.vehicle ~= 0 or config.gamebuild ~= 'auto' and build() > 2000 then
			Hud:EnterVehicleEvent(true,Hud.vehicle)
		end
		SendNUIMessage({ type = 'Talking', content = NetworkIsPlayerTalking(PlayerId()) })
		if Hud.vehicle == 0 and Hud.mode ~= 'Normal' then 
			Hud.mode = 'NORMAL'
			SendNUIMessage({
				type = "setMode",
				content = Hud.mode
			})
			local veh = Entity(Hud.vehicle).state
			veh:set('hudemode', Hud.mode, true)
		end
		local radarEnabled = config.radarwhiledriving and IsRadarEnabled()
		if config.radarwhiledriving and not IsPedInAnyVehicle(PlayerPedId()) and radarEnabled then
			DisplayRadar(false)
		elseif config.radarwhiledriving and IsPedInAnyVehicle(PlayerPedId()) and not radarEnabled then
			DisplayRadar(true)
		end
		Wait(config.car_mainloop_sleep)
	end
end)

CreateThread(function() -- lets use space as a signal to handbrake NUI more effective and optimize. disable it if you are using it on other scripts.
	Wait(100)
	SendNUIMessage({
		type = "setBrake",
		content = false
	})
	RegisterKeyMapping(config.commands['car_handbrake'], 'Car Emergency Brake', 'keyboard', config.keybinds['car_handbrake'])
	return
end)

RegisterCommand(config.commands['car_handbrake'], function()
	Hud:NuiVehicleHandbrake()
end)

local inshock = false
local shockcount = 50 -- 5 seconds shock
AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkEntityDamage' then
		local victim = args[1]
		if victim == Hud.ped and config.enablestatus or victim == Hud.ped and not config.enablestatus and config.statusui == 'normal' then
			Hud:updateplayer(true)
			if not inshock then
				inshock = true
				shockcount = 4
				CreateThread(function()
					while inshock and shockcount > 1 do
						Hud:updateplayer(true)
						shockcount = shockcount - 1
						Wait(500)
					end
					return
				end)
			end
			inshock = false
		end
	end
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		if args[1] == PlayerId() and config.enable_carui or args[2] == GetVehiclePedIsIn(PlayerPedId()) and config.enable_carui then
			Hud.vehicle = args[2]
			Hud:EnterVehicleEvent(true,args[2])
		end
	end
end)

-- SEATBELT
CreateThread(function()
	RegisterKeyMapping(config.commands['car_seatbelt'], 'Car Seatbelt', 'keyboard', config.keybinds['car_seatbelt'])
	return
end)

RegisterCommand(config.commands['car_seatbelt'], function()
	if Hud.vehicle ~= 0 then
		if Hud:haveseatbelt() then
			if Hud.belt then
				SetTimeout(1000,function()
					Hud.belt = false
					if newbelt ~= Hud.belt or newbelt == nil then
						newbelt = Hud.belt
						SendNUIMessage({
						type = "setBelt",
						content = Hud.belt
						})
					end
					Hud:Notify('warning','Seatbelt',"Seatbelt has been Detached")
					SetFlyThroughWindscreenParams(35.0, 45.0, 17.0, 2000.0)
					SetPedConfigFlag(PlayerPedId(), 32, true)
				end)
			else
				SetTimeout(1000,function()
					Hud.belt = true
					if newbelt ~= Hud.belt or newbelt == nil then
						newbelt = Hud.belt
						SendNUIMessage({
						type = "setBelt",
						content = Hud.belt
						})
						SetFlyThroughWindscreenParams(35.0, 45.0, 17.0, 99999999.0)
						--SetPedConfigFlag(PlayerPedId(), 32, false)
						Hud:Notify('success','Seatbelt',"Seatbelt has been attached")
					end
					while Hud.belt and Hud.invehicle and config.seatbelt_2 do
						DisableControlAction(1, 75, true)  -- Disable exit vehicle when stop
						DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
						Wait(4)
					end
					if config.seatbelt_2 then
						Hud.belt = false
					end
					Hud:SendNuiSeatBelt()
				end)
			end
		end
	end
end, false)

RegisterCommand(config.commands['signal_left'], function()
	if Hud.vehicle ~= 0 then
		Hud.right = false
		Wait(100)
		Hud.left = true
		if GetVehicleIndicatorLights(Hud.vehicle) == 0 then
			SetVehicleIndicatorLights(Hud.vehicle,1, true)
		elseif GetVehicleIndicatorLights(Hud.vehicle) == 2 then
			SetVehicleIndicatorLights(Hud.vehicle,0, false)
			SetVehicleIndicatorLights(Hud.vehicle,1, true)
		end

		state = false
		if not state and Hud.right then
			state = 'right'
		end
		if not state and Hud.left then
			state = 'left'
		end
		if Hud.hazard then
			state = 'hazard'
		end
		Hud.signal_state = state
		Hud:sendsignaltoNUI()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['signal_left'], 'Signal Left', 'keyboard', config.keybinds['signal_left'])
end)

RegisterCommand(config.commands['signal_right'], function()
	if Hud.vehicle ~= 0 then
		Hud.left = false
		Wait(100)
		Hud.right = true
		if GetVehicleIndicatorLights(Hud.vehicle) == 0 then
			SetVehicleIndicatorLights(Hud.vehicle,0, true)
		elseif GetVehicleIndicatorLights(Hud.vehicle) == 1 then
			SetVehicleIndicatorLights(Hud.vehicle,1, false)
			SetVehicleIndicatorLights(Hud.vehicle,0, true)
		end

		state = false
		if not state and Hud.right then
			state = 'right'
		end
		if not state and Hud.left then
			state = 'left'
		end
		if Hud.hazard then
			state = 'hazard'
		end
		Hud.signal_state = state
		Hud:sendsignaltoNUI()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['signal_right'], 'Signal Right', 'keyboard', config.keybinds['signal_right'])
	return
end)

RegisterCommand(config.commands['entering'], function()
	Hud:entervehicle()
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['entering'], 'Enter Vehicle', 'keyboard', config.keybinds['entering'])
	return
end)

RegisterCommand(config.commands['signal_hazard'], function()
	if Hud.vehicle ~= 0 then
		if GetVehicleIndicatorLights(Hud.vehicle) == 0 then
			Hud.hazard = true
			SetVehicleIndicatorLights(Hud.vehicle,0, true)
			SetVehicleIndicatorLights(Hud.vehicle,1, true)
		else
			Hud.hazard = false
			Hud.left = false
			Hud.right = false
			SetVehicleIndicatorLights(Hud.vehicle,0, false)
			SetVehicleIndicatorLights(Hud.vehicle,1, false)
		end

		state = false
		if not state and Hud.right then
			state = 'right'
		end
		if not state and Hud.left then
			state = 'left'
		end
		if Hud.hazard then
			state = 'hazard'
		end
		Hud.signal_state = state
		Hud:sendsignaltoNUI()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['signal_hazard'], 'Signal Hazard', 'keyboard', config.keybinds['signal_hazard'])
	return
end)

--ETC
CreateThread(function()
	local count = 0
	while not LocalPlayer.state.playerloaded or count < 5 do -- REAL WAY TO REMOVE HEALTHBAR AND ARMOR WITHOUT USING THE LOOP ( LOAP minimap.gfx first ) then on spawn load the circlemap
		count = count + 1
		Wait(1000)
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

	 	Hud.minimap = RequestScaleformMovie("minimap")

		SetRadarBigmapEnabled(true, false)
		Wait(100)
		SetRadarBigmapEnabled(false, false)
	end
	return
end)

CreateThread(function()
	ClearPedTasks(PlayerPedId())
	if config.removemaphealthandarmor or config.useminimapeverytime then
		while true do
			Wait(0)
			if config.removemaphealthandarmor then -- FALSE ONLY - ACTIVATE only if you still see health and armor, it should be already removed from the minimap.gfx else check all your script!
				BeginScaleformMovieMethod(Hud.minimap, "SETUP_HEALTH_ARMOUR")
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

RegisterCommand(config.commands['cruisecontrol'], function()
	if Hud.vehicle ~= 0 then
		Hud:Cruisecontrol()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['cruisecontrol'], 'Vehicle Cruise Control', 'keyboard', config.keybinds['cruisecontrol'])
	return
end)

CreateThread(function()
	while not LocalPlayer.state.playerloaded do Wait(100) end
	Wait(1000)
	local enable_w = false
	if config.enablestatus then
		enable_w = true
	elseif config.bodystatus then
		enable_w = true
	end
	if config.firing_affect_status and enable_w then
		while Hud.ped == nil or Hud.ped == 0 do
			Citizen.Wait(100)
		end
		SendNUIMessage({
			type = "setShooting",
			content = 2000
		})
	end
	return
end)

CreateThread(function()
	Citizen.Wait(1500)
	if config.weaponsui then
		if config.crosshairenable then
			SendNUIMessage({
				type = "setCrosshair",
				content = config.crosshair
			})
		end
	end
	return
end)

RegisterCommand(config.commands['weaponui'], function()
	config.weaponsui = not config.weaponsui
	SendNUIMessage({
		type = "setWeaponUi",
		content = config.weaponsui
	})
	Hud.weaponui = config.weaponsui
end, false)

RegisterCommand(config.commands['crosshair'], function(source, args, raw)
	if args[1] == nil then
		Hud.crosshair = 1
	else
		Hud.crosshair = args[1]
	end
	SendNUIMessage({
		type = "setCrosshair",
		content = Hud.crosshair
	})
	Hud:Notify('success','Crosshair System',"Crosshair has been changed")
end, false)

CreateThread(function()
	Wait(500)
	if config.carstatus then
		RegisterCommand(config.commands['vehicle_status'], function()
			Hud:CarStatus()
		end, false)
		RegisterKeyMapping(config.commands['vehicle_status'], 'Toggle Vehicle Status', 'keyboard', config.keybinds['vehicle_status'])
	end
	return
end)

RegisterCommand(config.commands['carui'], function(source, args, raw)
	Hud:DefineCarUI(args[1])
end)

RegisterCommand(config.commands['dragui'], function(source, args, raw)
	bool = not bool
	SendNUIMessage({
		type = "Drag",
		content = bool
	})
	SetNuiFocus(bool,bool)
end)

RegisterCommand(config.commands['dragcarui'], function(source, args, raw)
	bool = not bool
	SendNUIMessage({
		type = "DragCar",
		content = bool
	})
	SetNuiFocus(bool,bool)
end)

pause = false
RegisterKeyMapping('ESCAPE', 'Pause Menu', 'keyboard', 'ESCAPE')
RegisterCommand('ESCAPE', function(source, args, raw)
	if not IsPauseMenuActive() and not pause then
		pause = not pause
		Wait(500)
		SendNUIMessage({
			type = "hideui",
			content = false
		})
		CreateThread(function()
			while IsPauseMenuActive() == 1 do
				Wait(10)
			end
			pause = not pause
			SendNUIMessage({
				type = "hideui",
				content = true
			})
			return
		end)
	end
end)

RegisterKeyMapping(config.commands['carheadlight'], 'Vehicle Headlight', 'keyboard', config.keybinds['carheadlight'])
RegisterCommand(config.commands['carheadlight'], function(source, args, raw)
	Wait(500)
	local off,low,high = GetVehicleLightsState(Hud.vehicle)
	local light = 0
	if low == 1 and high == 0 then
		light = 1
	elseif high == 1 then
		light = 2
	elseif off == 1 then
		light = 0
	end
	newlight = light
	SendNUIMessage({
	type = "setHeadlights",
	content = light
	})
end)

RegisterCommand(config.commands['uiconfig'], function(source, args, raw)
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
	config.uiconfig = {acceleration = config.acceleration, animation_ms = config.animation_ms, transition = config.transition, accelerationcar = config.accelerationcar, animation_mscar = config.animation_mscar, transitioncar = config.transitioncar}
	SendNUIMessage({
		type = "uiconfig",
		content = config.uiconfig
	})
end)

RegisterCommand(config.settingcommand, function(source, args, raw)
	settingbool = not settingbool
	SendNUIMessage({
		type = "SettingHud",
		content = {config = config.userconfig, bool = settingbool}
	})
	SetNuiFocus(settingbool,settingbool)
	SendNUIMessage({
		type = "DragCar",
		content = settingbool
	})
	SendNUIMessage({
		type = "Drag",
		content = settingbool
	})
end)

CreateThread(function()
	RegisterKeyMapping(config.settingcommand, 'HUD Settings', 'keyboard', config.keybinds['hudsetting'])
	return
end)

RegisterNUICallback('setrefreshrate', function(data)
	if tonumber(data.val) then
		config.Rpm_sleep = data.val
	end
end)

RegisterNUICallback('setcarui', function(data)
	if config.carui ~= data.val or config.enable_carui_perclass then
		Hud.customcarui = true
		config.carui = data.val
	else
		Hud.customcarui = false
	end
end)

settingbool = false
RegisterNUICallback('hidecarlock', function(data, cb)
    SetNuiFocus(false,false)
	SendNUIMessage({
		type = "SettingHud",
		content = {config = config.userconfig, bool = false}
	})
	settingbool = false
	cb(true)
end)