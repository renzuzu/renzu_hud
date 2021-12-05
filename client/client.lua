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
		while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(100) end
		while ESX.GetPlayerData().job == nil do Wait(100) end
		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
		Wait(1000)
		SendNUIMessage({type = "isAmbulance",content = xPlayer.job.name == config.checkbodycommandjob})
		Wait(5000)
	elseif config.framework == 'VRP' then
		local Tunnel = module("vrp","lib/Tunnel")
		local Proxy = module("vrp","lib/Proxy")
		vRP = Proxy.getInterface("vRP")
	elseif config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetSharedObject()
		while QBCore == nil do Wait(0) end
		QBCore.Functions.GetPlayerData(function(PlayerData)
			xPlayer = PlayerData
            if PlayerData ~= nil and PlayerData.job ~= nil then
				SendNUIMessage({type = "isAmbulance",content = PlayerData.job.name == config.checkbodycommandjob})
            end
        end)
		Wait(5000)
		ESX = true
	else
		ESX = true
	end
	DecorRegister("INERTIA", 1);DecorRegister("DRIVEFORCE", 1);DecorRegister("TOPSPEED", 1);DecorRegister("STEERINGLOCK", 1);DecorRegister("MAXGEAR", 1);DecorRegister("TRACTION", 1);DecorRegister("TRACTION2", 1);DecorRegister("TRACTION3", 1);DecorRegister("TRACTION4", 1);DecorRegister("TRACTION5", 1)
	if not DecorIsRegisteredAsType("MANUAL", 1) then DecorRegister("MANUAL", 1) end
	DecorRegister("PLAYERLOADED", 1);DecorRegister("CHARSLOT", 1)
	while not LocalPlayer.state.playerloaded do Wait(1000) end
	while not Hud.receive do Wait(1000) end
	for type,val in pairs(config.buto) do if Hud.bodystatus then  Hud.bonecategory[type] = Hud.bodystatus[type] else Hud.bonecategory[type] = 0.0 or 0.0 end if not other then Hud.parts[type] = {} for bone,val in pairs(val) do Hud.parts[type][bone] = 0.0 end end end
	SendNUIMessage({type = "setUpdateBodyStatus",content = Hud.bonecategory})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	xPlayer.job = job
	SendNUIMessage({type = "isAmbulance",content = xPlayer.job.name == config.checkbodycommandjob})
	for type,val in pairs(config.buto) do if Hud.bodystatus then  Hud.bonecategory[type] = Hud.bodystatus[type] else Hud.bonecategory[type] = 0.0 or 0.0 end if not other then Hud.parts[type] = {} for bone,val in pairs(val) do Hud.parts[type][bone] = 0.0 end end end
	SendNUIMessage({type = "setUpdateBodyStatus",content = Hud.bonecategory})
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    SendNUIMessage({type = "isAmbulance",content = PlayerJob.job.name == config.checkbodycommandjob})
	for type,val in pairs(config.buto) do if Hud.bodystatus then  Hud.bonecategory[type] = Hud.bodystatus[type] else Hud.bonecategory[type] = 0.0 or 0.0 end if not other then Hud.parts[type] = {} for bone,val in pairs(val) do Hud.parts[type][bone] = 0.0 end end end
	SendNUIMessage({type = "setUpdateBodyStatus",content = Hud.bonecategory})
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VOICE FUNC
-----------------------------------------------------------------------------------------------------------------------------------------

--PMA VOICE LISTENER
RegisterNetEvent("pma-voice:setTalkingMode")
AddEventHandler("pma-voice:setTalkingMode", function(prox)
	Hud.voiceDisplay = prox
	SendNUIMessage({
		type = "setMic",
		content = prox
	})
end)

--MUMBLE VOIP SetVoice Listener
local current_channel = 0
local cdch = 0
RegisterNetEvent("renzu_hud:SetVoiceData")
AddEventHandler("renzu_hud:SetVoiceData", function(mode,val)
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
RegisterNetEvent("pma-voice:clSetPlayerRadio")
AddEventHandler("pma-voice:clSetPlayerRadio", function(channel)
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
RegisterNetEvent("pma-voice:removePlayerFromRadio")
AddEventHandler("pma-voice:removePlayerFromRadio", function(channel)
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

RegisterNetEvent('renzu_hud:charslot')
AddEventHandler('renzu_hud:charslot', function(charid)
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
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	Wait(1000)
	LocalPlayer.state:set('playerloaded', true,true)
	LocalPlayer.state.playerloaded = true
	Wait(2000)
	print("ESX")
	Hud.lastped = PlayerPedId()
	if not getdata then
		TriggerServerEvent("renzu_hud:getdata",Hud.charslot)
		getdata = true
	end
	DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
	Wait(5000)
	SendNUIMessage({content = true, type = 'pedface'})
	SendNUIMessage({content = true, type = 'playerloaded'})
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	Wait(1000)
	LocalPlayer.state:set('playerloaded', true,true)
	LocalPlayer.state.playerloaded = true
	Wait(2000)
	print("QB")
	Hud.lastped = PlayerPedId()
	if not getdata then
		TriggerServerEvent("renzu_hud:getdata",Hud.charslot)
		getdata = true
	end
	DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
	Wait(5000)
	SendNUIMessage({content = true, type = 'pedface'})
	SendNUIMessage({content = true, type = 'playerloaded'})
end)

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function(spawn)
	if config.framework ~= 'ESX' and config.framework ~= 'QBCORE' then
		Wait(1000)
		LocalPlayer.state:set('playerloaded', true,true)
		LocalPlayer.state.playerloaded = true
		print("PLAYERLOADED")
		Wait(2000)
		Hud.lastped = PlayerPedId()
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		if not getdata then
			TriggerServerEvent("renzu_hud:getdata",Hud.charslot)
			getdata = true
		end
		Wait(5000)
		SendNUIMessage({content = true, type = 'pedface'})
		SendNUIMessage({content = true, type = 'playerloaded'})
	end
end)

CreateThread(function()
	Wait(1000)
	if Hud.charslot == nil and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= 0.0 and DecorGetFloat(PlayerPedId(),"CHARSLOT") ~= nil then
		Hud.charslot = Hud:round(DecorGetFloat(PlayerPedId(),"CHARSLOT"))
		----print("CHARSLOT")
	else
		Citizen.Wait(4000)
	end
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and Hud.charslot ~= nil then
		print("PLAYERLOADED")
		if not getdata then
			TriggerServerEvent("renzu_hud:getdata",Hud.charslot)
			getdata = true
		end
		LocalPlayer.state.playerloaded = true
		SendNUIMessage({content = true, type = 'playerloaded'})
	end
	Wait(500)
	if DecorExistOn(PlayerPedId(), "PLAYERLOADED") and config.loadedasmp and Hud:isplayer() then
		print("ISMP")
		if not getdata then
			TriggerServerEvent("renzu_hud:getdata",0, config.multichar)
			getdata = true
		end
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		LocalPlayer.state.playerloaded = true
		SendNUIMessage({content = true, type = 'pedface'})
		SendNUIMessage({content = true, type = 'playerloaded'})
	elseif Hud:isplayer() and config.forceplayerload then
		Wait(10000)
		LocalPlayer.state.playerloaded = true
		print("isplayer f")
		Wait(2000)
		Hud.lastped = PlayerPedId()
		DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
		if not getdata then
			TriggerServerEvent("renzu_hud:getdata",Hud.charslot)
			getdata = true
		end
		Wait(5000)
		SendNUIMessage({content = true, type = 'pedface'})	
		SendNUIMessage({content = true, type = 'playerloaded'})
	elseif DecorExistOn(PlayerPedId(), "PLAYERLOADED") then
		print("already loaded")
		if not getdata then
			TriggerServerEvent("renzu_hud:getdata",0, config.multichar)
			getdata = true
		end
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
			if config.multichar_advanced then
				DecorRemove(Hud.lastped,"CHARSLOT")
				DecorSetInt(PlayerPedId(), "CHARSLOT", Hud.charslot)
			end
		end
	end
	--return
end)


--- NEW HUD FUNC
RegisterNUICallback('requestface', function(data, cb)
	while not LocalPlayer.state.playerloaded do
		Wait(1000)
	end
	Wait(5000)
	TriggerEvent('skinchanger:getSkin', function(current) Hud.dummyskin = current end)
	while Hud:tablelength(Hud.dummyskin) <= 2 do
		TriggerEvent('skinchanger:getSkin', function(current) Hud.dummyskin = current end)
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
		if not config.QbcoreStatusDefault and config.framework == 'QBCORE' or config.framework == 'STANDALONE' or config.framework == 'ESX' then
			--RegisterNetEvent("esx_status:onTick")
			local register = {}
			local registered = false
			AddEventHandler("esx_status:onTick", function(vitals) -- use renzu_status
				local vitals = vitals
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
				Hud:UpdateStatus(false,vitals)

				for k,v in pairs(vitals) do
					register[k] = true
				end

				if config.registerautostatus and not registered then
					DecorRegister("STATUSR", 1)
					print("REGISTER START")
					for k,v in pairs(config.statusordering) do -- register all status
						if v.enable and v.custom and register[v.status] == nil and not DecorGetBool(PlayerPedId(), "STATUSR") then
							local remove_value = v.statusremove
							print("Auto Status Register: ",v.status,v.startvalue,v.statusremove)
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
		end
		if config.framework == 'QBCORE' then
			local hunger = 0
			local thirst = 0
			local stress = 0
			if config.QbcoreStatusDefault then -- use qbcore builtin meta data status
				CreateThread(function()
					while true do
						TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
						Citizen.Wait(250)
						QBCore.Functions.GetPlayerData(function(PlayerData)
							if PlayerData ~= nil and PlayerData.metadata ~= nil then
								hunger, thirst, stress = PlayerData.metadata["hunger"] * 10000, PlayerData.metadata["thirst"] * 10000, PlayerData.metadata["stress"] * 10000
								local statusqb = {
									['hunger'] = hunger,
									['thirst'] = thirst,
									['stress'] = stress -- this should be registered at config
								}
								--print("BUILD IN",statusqb,statusqb.hunger,statusqb.thirst,statusqb.stress)
								Hud:UpdateStatus(false,statusqb)
							end
						end)
						Wait(2500)
					end
				end)
			end
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
	while Hud.veh_stats == nil do
		Hud.veh_stats = LocalPlayer.state.adv_stat
		Wait(100)
	end
	if nuiloop then
		CreateThread(function()
			while true do
				if se and not Hud.invehicle then
					CreateThread(function()
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
				if va or wa then
					Hud:SyncWheelAndSound(va,wa)
				end
				if Hud.garbage > 200 then
					collectgarbage()
					Hud.garbage = 0
				end
				Hud.garbage = Hud.garbage + 1
				--print("TEST")
				--Hud:updateplayer()
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
	Wait(3000)
	while config.userconfig == nil do Wait(100) end
	SendNUIMessage({type = "reimportsetting",content = config.userconfig})
	Wait(500)
	SendNUIMessage({type = "setStatusUI",content = {['type'] = status_type, ['ver'] = status_ui, ['enable'] = enable_status}})
	Wait(1000)
	SendNUIMessage({map = true, type = 'sarado'})
	--SendNUIMessage({type = "uiconfig", content = uiconf})
	SendNUIMessage({type = "setStatusType",content = status_type})
	Wait(500)
	print(placing,ordering)
	SendNUIMessage({type = "SetStatusOrder",content = {['data'] = ordering, ['float'] = placing}})
	Wait(1000)
	Hud.reorder = true
	while not LocalPlayer.state.playerloaded do Citizen.Wait(100) print("loading") end
	Wait(100)
	local tbl = {['data'] = ordering, ['float'] = placing}
	if config.enable_carui then
		SendNUIMessage({type = 'setCarui', content = config.carui})
	end
	print("Player Loaded SUCCESS")
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
	while not LocalPlayer.state.loaded do
		--print("vehstats")
		Wait(100)
	end
	local l = 0
	--print("starting thread")
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

RegisterNetEvent("renzu_hud:receivedata")
AddEventHandler("renzu_hud:receivedata", function(data,i)
	Hud.veh_stats = data
	if i ~= nil then
		Hud.identifier = i
	end
	Hud.veh_stats_loaded = true
	for k,v in pairs(data) do
		if v.entity ~= nil then
			if Hud.onlinevehicles[k] == nil then
				Hud.onlinevehicles[k] = {}
			end
			Hud.onlinevehicles[k].entity = v.entity
			Hud.onlinevehicles[k].plate = k
			if v.height ~= nil then
				Hud.onlinevehicles[k].height = v.height
			end
			if v.engine ~= nil then
				Hud.onlinevehicles[k].engine = v.engine
			end
		end
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

RegisterNetEvent('start:smoke')
AddEventHandler('start:smoke', function(ent,coord)
	local mycoord = GetEntityCoords(Hud.ped,false)
	local dis = #(mycoord - coord)
	local ent = NetToVeh(ent)
	if dis < 100 then --SILLY WAY TO AVOID ONE SYNC INFINITY ISSUE
		Hud:StartSmoke(ent)
	end
end)

RegisterCommand('testsmoke', function(source, args, raw)
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) + config.addheat)
	Wait(100)
	Hud:StartSmoke(Hud:getveh())
end)

local inshock = false
local shockcount = 50 -- 5 seconds shock
AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkEntityDamage' then
		local victim = args[1]
		if victim == Hud.ped and config.enablestatus or victim == Hud.ped and not config.enablestatus and config.statusui == 'normal' then
			Hud:updateplayer(true)
			Wait(300)
			Hud:BodyMain()
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
				Wait(100)
				if config.bodystatus then
					Hud:BodyLoop()
				end
			end
			inshock = false
		end
	end
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		print("ENTER VEHICLE",args[1],Hud.pid,args[2])
		print(args[2], GetVehiclePedIsIn(PlayerPedId()))
		if args[1] == PlayerId() and config.enable_carui or args[2] == GetVehiclePedIsIn(PlayerPedId()) and config.enable_carui then
			Hud.vehicle = args[2]
			Hud:EnterVehicleEvent(true,args[2])
		end
	end
	--print(name)
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
					SetFlyThroughWindscreenParams(config.seatbeltminspeed, 10.2352, 0.0, 0.0)
					SetPedConfigFlag(PlayerPedId(), 32, true)
					--SendNuiSeatBelt()
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
						SetFlyThroughWindscreenParams(config.seatbeltmaxspeed, 2.2352, 0.0, 0.0)
						--SetPedConfigFlag(PlayerPedId(), 32, false)
						Hud:Notify('success','Seatbelt',"Seatbelt has been attached")
					end
					while Hud.belt and Hud.invehicle and config.seatbelt_2 do
						DisableControlAction(1, 75, true)  -- Disable exit vehicle when stop
						DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
						Wait(4)
					end
					Hud.belt = false
					--SendNuiSeatBelt()
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

RegisterNetEvent('renzu_hud:hasturbo')
AddEventHandler('renzu_hud:hasturbo', function(type)
	if Hud.invehicle then
		Hud.alreadyturbo = true
		Wait(1000)
		--print("TURBO ACTIVATE")
		if Hud.invehicle and config.turbogauge then
			SendNUIMessage({
				type = "setShowTurboBoost",
				content = true
			})
		end
		plate = GetVehicleNumberPlateText(Hud.vehicle)
		--plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
		CreateThread(function()
			Hud:turboanimation(type)
			Hud:Boost(true)
			return
		end)
	end
end)

RegisterNetEvent('renzu_hud:install_turbo')
AddEventHandler('renzu_hud:install_turbo', function(type)
	local type = type
	local veh = Hud:getveh()
	Hud:turboanimation(type)
	while veh == 0 do veh = Hud:getveh() Wait(100) end
	local plate = GetVehicleNumberPlateText(veh)
	--plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
	if Hud.veh_stats[plate] == nil then
		Hud:get_veh_stats(veh, plate)
	end
	Citizen.Wait(2000)
	Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
	--ExecuteCommand("e petting")
	Wait(2500)
	ClearPedTasks(Hud.ped)
	Hud:playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	--ExecuteCommand("e gangsign")
	Wait(200)
	SetVehicleDoorOpen(veh,4,false,false)
	Wait(400)
	ClearPedTasks(Hud.ped)
	SetVehicleDoorOpen(veh,4,false,false)
	Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Citizen.Wait(10000)
	Hud.veh_stats[plate].turbo = type
	Hud.veh_stats[plate].turbo_health = config.turbo_health
	TriggerServerEvent('renzu_hud:savedata', plate, Hud.veh_stats[tostring(plate)])
	LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] Hud.veh_stats, --[[replicate to server]] true)
	Hud:Notify('success','Turbo Install',""..Hud.veh_stats[plate].turbo.." turbine has been install")
	Hud:playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Wait(2000)
	SetVehicleDoorShut(veh,4,false)
	Wait(300)
	ClearPedTasks(Hud.ped)
	ClearPedTasks(Hud.ped)
end)

RegisterCommand(config.commands['mode'], function()
	if Hud.vehicle ~= 0 then
		Hud:vehiclemode()
	end
end, false)

CreateThread(function()
	Hud.mode = 'NORMAL'
	RegisterKeyMapping(config.commands['mode'], 'Vehicle Mode', 'keyboard', config.keybinds['mode'])
	return
end)

RegisterCommand(config.commands['differential'], function()
	if Hud.vehicle ~= 0 then
		Hud:differential()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['differential'], '4WD Mode', 'keyboard', config.keybinds['differential'])
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

RegisterNetEvent('renzu_hud:coolant')
AddEventHandler('renzu_hud:coolant', function()
	local bone = GetEntityBoneIndexByName(Hud:getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(Hud:getveh(),bone)
	local vehrotation = GetEntityRotation(Hud:getveh(),2)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(Hud:getveh())
	local veh_coord = GetEntityCoords(Hud:getveh(),false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(Hud:getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	Hud:requestmodel('bkr_prop_meth_sacid')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_long_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(Hud:getveh()) * 0.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.1, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Wait(2500)
	ClearPedTasks(Hud.ped)
	Hud:playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	Wait(200)
	SetVehicleDoorOpen(Hud:getveh(),4,false,false)
	Wait(400)
	ClearPedTasks(Hud.ped)
	SetVehicleDoorOpen(Hud:getveh(),4,false,false)
	--SetEntityCoords(Hud.ped,realx,realy,realz)
	water = CreateObject(GetHashKey('bkr_prop_meth_sacid'), x, y, z, 1, 0, 1)
	SetEntityCollision(water, false, true)
	NetworkAddPedToSynchronisedScene(Hud.ped, netScene, animDict, "chemical_pour_long_cooker", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(water, netScene, animDict, "chemical_pour_long_sacid", 4.0, -8.0, 1)
	Wait(150)
	SetEntityHeading(Hud.ped, GetEntityHeading(Hud:getveh()) - 180)
	Wait(20)
	NetworkStartSynchronisedScene(netScene)
	Wait(40000)
	ClearPedTasks(Hud.ped)
	DeleteEntity(water)
	Hud:playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Wait(2000)
	SetVehicleDoorShut(Hud:getveh(),4,false)
	Wait(300)
	ClearPedTasks(Hud.ped)
	Hud.veh_stats[plate].coolant = 100
	SetVehicleEngineTemperature(Hud:getveh(), GetVehicleEngineTemperature(Hud:getveh()) - config.reducetemp_onwateradd)
	SendNUIMessage({
		type = "setCoolant",
		content = 100
	})
	Hud:Notify('success','Vehicle System',"Coolant has been restore")
	Wait(100)
end)

RegisterNetEvent('renzu_hud:oil')
AddEventHandler('renzu_hud:oil', function()
	local bone = GetEntityBoneIndexByName(Hud:getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(Hud:getveh(),bone)
	local vehrotation = GetEntityRotation(Hud:getveh(),2)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(Hud:getveh())
	local veh_coord = GetEntityCoords(Hud:getveh(),false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(Hud:getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	Hud:requestmodel('prop_oilcan_01a')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_short_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(Hud:getveh()) * 0.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.2, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
	Wait(2500)
	ClearPedTasks(Hud.ped)
	Hud:playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
	Wait(200)
	SetVehicleDoorOpen(Hud:getveh(),4,false,false)
	Wait(400)
	ClearPedTasks(Hud.ped)
	SetVehicleDoorOpen(Hud:getveh(),4,false,false)
	oil = CreateObject(GetHashKey('prop_oilcan_01a'), x, y, z+0.5	, 1, 0, 1)
	SetEntityCollision(water, false, true)
	NetworkAddPedToSynchronisedScene(Hud.ped, netScene, animDict, "chemical_pour_short_cooker", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(oil, netScene, animDict, "chemical_pour_short_sacid", 4.0, -8.0, 1)
	Wait(150)
	SetEntityHeading(Hud.ped, GetEntityHeading(Hud:getveh()) - 180)
	Wait(20)
	NetworkStartSynchronisedScene(netScene)
	Wait(30000)
	ClearPedTasks(Hud.ped)
	DeleteEntity(oil)
	Hud:playanimation('rcmepsilonism8','bag_handler_close_trunk_walk_left')
	Wait(2000)
	SetVehicleDoorShut(Hud:getveh(),4,false)
	Wait(300)
	ClearPedTasks(Hud.ped)
	Hud.veh_stats[Hud:GetPlate(Hud:getveh())].oil = 100
	Hud.veh_stats[Hud:GetPlate(Hud:getveh())].mileage = 0
	Hud.degrade = 1.0
	SendNUIMessage({
		type = "setMileage",
		content = 0
	})
	Hud:Notify('success','Vehicle System',"Oil has been changed")
	Wait(100)
end)

RegisterCommand('putwater', function(source, args, raw)
	TriggerEvent("renzu_hud:coolant")
end)

RegisterCommand('changeoil', function(source, args, raw)
	TriggerEvent("renzu_hud:oil")
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

RegisterCommand(config.commands['bodystatus'], function()
	if config.bodystatus then
		Hud:BodyUi()
		SendNUIMessage({type = "setUpdateBodyStatus",content = Hud.bonecategory})
	end
end, false)

RegisterCommand(config.commands['bodystatus_other'], function()
	if config.bodystatus then
		Hud:CheckPatient()
	end
end, false)

CreateThread(function()
	RegisterKeyMapping(config.commands['bodystatus'], 'Open Body Status', 'keyboard', config.keybinds['bodystatus'])
	return
end)

RegisterNetEvent('renzu_hud:bodystatus')
AddEventHandler('renzu_hud:bodystatus', function(status,other)
	checkingpatient = other
	local status = status
	while not LocalPlayer.state.playerloaded do Wait(100) end
	SendNUIMessage({type = "setBodyParts",content = config.healtype})
	local status = status
	Hud.receive = true
	Hud.bodystatus = {}
	Hud.bodystatus = status
	damage = 0
	for type,val in pairs(config.buto) do
		if Hud.bodystatus then 
			Hud.bonecategory[type] = Hud.bodystatus[type] or 0.0
		else 
			Hud.bonecategory[type] = 0
		end
		damage = damage + Hud.bonecategory[type]
		if not other then
			Hud.parts[type] = {}
			for bone,val in pairs(val) do
				Hud.parts[type][bone] = 0
			end
		end
	end
	if not other and damage > 35 then
		ApplyPedDamagePack(GetPlayerPed(-1), "Fall", damage, damage)
	end
	if other then
		SendNUIMessage({
			type = "setShowBodyUi",
			content = Hud.bodyui
		})
		Wait(100)
		SetNuiFocusKeepInput(Hud.bodyui)
		SetNuiFocus(Hud.bodyui,Hud.bodyui)
	end
	Wait(100)
	SendNUIMessage({
		type = "setUpdateBodyStatus",
		content = Hud.bonecategory
	})
	CreateThread(function()
		while Hud.bodyui do
			Hud:whileinput()
			Wait(5)
		end
		SetNuiFocusKeepInput(false)
		SetNuiFocus(false,false)
		return
	end)
	Hud:BodyLoop()
end)

CreateThread(function()
	while not LocalPlayer.state.playerloaded do
		Wait(100)
	end
	if config.bodystatus then
		Citizen.Wait(1000)
		while DecorGetBool(PlayerPedId(), "PLAYERLOADED") ~= 1 do
			Citizen.Wait(500)
			if LocalPlayer.state.playerloaded then
				DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
				break
			end
		end
		TriggerServerEvent('renzu_hud:checkbody')
	end
	return
end)

local busyheal = false
RegisterNUICallback('healpart', function(data, cb)
	Wait(math.random(300,1000))
	if not busyheal then
		TriggerServerEvent('renzu_hud:checkitem',data.part)
	end
	cb(true)
end)

RegisterNetEvent('renzu_hud:healpart')
AddEventHandler('renzu_hud:healpart', function(part)
	busyheal = true
	TaskTurnPedToFaceEntity(Hud.ped,GetPlayerPed(GetPlayerFromServerId(Hud.healing)))
	Wait(300)
	if Hud.healing == nil then
		Hud.healing = GetPlayerServerId(PlayerId())
	end	
	TaskStartScenarioInPlace(Hud.ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', -1, true)
	TriggerServerEvent('renzu_hud:healbody',Hud.healing,part)
	Hud:Makeloading('Applying Item',12000)
	Wait(12000)
	Hud:Notify('success','Body System',"Healing Successful")
	Wait(100)
	if Hud.healing ~= nil and GetPlayerServerId(PlayerId()) ~= Hud.healing then
		TriggerServerEvent('renzu_hud:checkbody', tonumber(Hud.healing))
	end
	ClearPedTasks(Hud.ped)
	busyheal = false
	Hud:BodyLoop()
end)

RegisterNetEvent('renzu_hud:healbody')
AddEventHandler('renzu_hud:healbody', function(bodypart, patient)
	-- Preparing
	if not patient then
		TaskStartScenarioInPlace(Hud.ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', -1, true)
	end
	Hud:Makeloading('Applying Item',10000)
    Wait(10000)
    ClearPedTasks(Hud.ped)
	-- Start Healing Injuries
	local canheal
	for k,v in pairs(config.healtype[bodypart]) do
		canheal = Hud.bonecategory[v]
		Hud.bonecategory[v] = 0
	end
	if canheal then
		TriggerServerEvent('renzu_hud:savebody', Hud.bonecategory)
		Citizen.Wait(1000)
	end
	SendNUIMessage({
		type = "setUpdateBodyStatus",
		content = Hud.bonecategory
	})
	--lastdamage = nil
	Hud:Notify('success','Body System',"You have been healed")
	damage = 0
	for type,val in pairs(config.buto) do
		damage = damage + Hud.bonecategory[type]
	end
	ApplyPedDamagePack(GetPlayerPed(-1), "Fall", damage, damage)
	if damage <= 0 then
		ClearPedBloodDamage(Hud.ped)
	end
	Wait(500)
	Hud:BodyLoop()
end)

CreateThread(function()
	if config.enablehealcommand then
		RegisterCommand(config.commands['bodyheal'], function(source,args)
			if args[1] ~= nil then
				TriggerEvent("renzu_hud:healbody", args[1])
			end
		end, false)
	end
	return
end)

RegisterCommand(config.commands['carcontrol'], function()
	if config.enablecarcontrol then
		if config.allowoutsideofvehicle then
			Hud:CarControl()
		elseif Hud.invehicle then
			Hud:CarControl()
		end
	end
end, false)

CreateThread(function()
	if config.enablecarcontrol then
		RegisterKeyMapping(config.commands['carcontrol'], 'Open Car Control', 'keyboard', config.keybinds['carcontrol'])
	end
	return
end)

RegisterNUICallback('closecarcontrol', function(data, cb)
	Hud.carcontrol = false
	SendNUIMessage({
		type = "setShowCarcontrol",
		content = Hud.carcontrol
	})
	SetNuiFocus(false,false)
	cb(true)
end)

RegisterNUICallback('setVehicleDoor', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if data.bool then
		SetVehicleDoorOpen(Hud.vehicle,tonumber(data.index),false,false)
    else     
        SetVehicleDoorShut(Hud.vehicle,tonumber(data.index),false,false)
    end
	cb(true)
end)

RegisterNUICallback('setVehicleSeat1', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if IsVehicleSeatFree(Hud.vehicle,-1) then
		Hud:shuffleseat(-1)
	elseif IsVehicleSeatFree(Hud.vehicle,0) then
		Hud:shuffleseat(0)
    end
	cb(true)
end)

RegisterNUICallback('setVehicleSeat2', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if IsVehicleSeatFree(Hud.vehicle,1) then
		Hud:shuffleseat(1)
	elseif IsVehicleSeatFree(Hud.vehicle,2) then
		Hud:shuffleseat(2)
    end
	cb(true)
end)

RegisterNUICallback('setVehicleEnginestate', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if GetIsVehicleEngineRunning(Hud.vehicle) then
        SetVehicleEngineOn(Hud.vehicle, false, false, true)
		start = false
		SendNUIMessage({
			type = "setStart",
			content = start
		})
		Hud.carcontrol = false
		SendNUIMessage({
			type = "setShowCarcontrol",
			content = Hud.carcontrol
		})
    else
        SetVehicleEngineOn(Hud.vehicle, true, true, true)
		start = true
		SendNUIMessage({
			type = "setStart",
			content = start
		})
		Hud.carcontrol = false
		SendNUIMessage({
			type = "setShowCarcontrol",
			content = Hud.carcontrol
		})
    end
	SetNuiFocus(false,false)
	cb(true)
end)

RegisterNetEvent("renzu_hud:airsuspension")
AddEventHandler("renzu_hud:airsuspension", function(vehicle,val,coords)
	local v = NetToVeh(vehicle)
	CreateThread(function()
		Wait(math.random(1,500))
		if vehicle ~= 0 and #(coords - GetEntityCoords(Hud.ped)) < 50 and not Hud.busyplate[Hud:GetPlate(v)] then
			Hud.busyplate[Hud:GetPlate(v)] = true
			if Hud.nearstancer[Hud:GetPlate(v)] ~= nil then
				Hud.nearstancer[Hud:GetPlate(v)].wheeledit = true
			end
			Hud:playsound(GetEntityCoords(v),20,'suspension',1.0)
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
				while min > data.val and Hud.busyplate[Hud:GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min < data.val and Hud.busyplate[Hud:GetPlate(v)] and count < 50 do
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
				while min < data.val and Hud.busyplate[Hud:GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) + (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min > data.val and Hud.busyplate[Hud:GetPlate(v)] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					count = count + 1
					min = GetVehicleSuspensionHeight(v)
					Citizen.Wait(100)
				end
				SetVehicleSuspensionHeight(v,data.val)
			end
			--TriggerServerEvent("renzu_hud:airsuspension_state",VehToNet(vehicle), true)
			Hud.busyplate[Hud:GetPlate(v)] = false
			Hud.busyairsus = false
		end
		return
	end)
end)

RegisterNUICallback('setvehicleheight', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 and not Hud.busyairsus then
		Hud.busyairsus = true
		TriggerServerEvent("renzu_hud:airsuspension",VehToNet(Hud.vehicle), data.val, GetEntityCoords(Hud.vehicle))
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheeloffsetfront', function(data, cb)
	Hud.vehicle = Hud:getveh()
	plate = tostring(GetVehicleNumberPlateText(Hud.vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 then
		if Hud.wheelsettings[plate] == nil then Hud.wheelsettings[plate] = {} end
		local val = Hud:round(data.val * 100)
		SetVehicleWheelXOffset(Hud.vehicle,0,tonumber("-0."..val..""))
		SetVehicleWheelXOffset(Hud.vehicle,1,tonumber("0."..val..""))
		if Hud.wheelsettings[plate]['wheeloffsetfront'] == nil then Hud.wheelsettings[plate]['wheeloffsetfront'] = {} end
		Hud.wheelsettings[plate]['wheeloffsetfront'].wheel0 = tonumber("-0."..val.."")
		Hud.wheelsettings[plate]['wheeloffsetfront'].wheel1 = tonumber("0."..val.."")
		Hud.wheeledit = true
		if Hud.nearstancer[plate] ~= nil then
			Hud.nearstancer[plate].wheeledit = true
		end
		SendNUIMessage({type = "unsetradio",content = false})
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheeloffsetrear', function(data, cb)
	Hud.vehicle = Hud:getveh()
	plate = tostring(GetVehicleNumberPlateText(Hud.vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 then
		if Hud.wheelsettings[plate] == nil then Hud.wheelsettings[plate] = {} end
		local val = Hud:round(data.val * 100)
		SetVehicleWheelXOffset(Hud.vehicle,2,tonumber("-0."..val..""))
		SetVehicleWheelXOffset(Hud.vehicle,3,tonumber("0."..val..""))
		if Hud.wheelsettings[plate]['wheeloffsetrear'] == nil then Hud.wheelsettings[plate]['wheeloffsetrear'] = {} end
		Hud.wheelsettings[plate]['wheeloffsetrear'].wheel2 = tonumber("-0."..val.."")
		Hud.wheelsettings[plate]['wheeloffsetrear'].wheel3 = tonumber("0."..val.."")
		Hud.wheeledit = true
		if Hud.nearstancer[plate] ~= nil then
			Hud.nearstancer[plate].wheeledit = true
		end
		SendNUIMessage({type = "unsetradio",content = false})
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheelrotationfront', function(data, cb)
	Hud.vehicle = Hud:getveh()
	plate = tostring(GetVehicleNumberPlateText(Hud.vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 then
		if Hud.wheelsettings[plate] == nil then Hud.wheelsettings[plate] = {} end
		local val = Hud:round(data.val * 100)
		SetVehicleWheelYRotation(Hud.vehicle,0,tonumber("-0."..val..""))
		SetVehicleWheelYRotation(Hud.vehicle,1,tonumber("0."..val..""))
		if Hud.wheelsettings[plate]['wheelrotationfront'] == nil then Hud.wheelsettings[plate]['wheelrotationfront'] = {} end
		Hud.wheelsettings[plate]['wheelrotationfront'].wheel0 = tonumber("-0."..val.."")
		Hud.wheelsettings[plate]['wheelrotationfront'].wheel1 = tonumber("0."..val.."")
		Hud.wheeledit = true
		if Hud.nearstancer[plate] ~= nil then
			Hud.nearstancer[plate].wheeledit = true
		end
		SendNUIMessage({type = "unsetradio",content = false})
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheelrotationrear', function(data, cb)
	Hud.vehicle = Hud:getveh()
	plate = tostring(GetVehicleNumberPlateText(Hud.vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 then
		if Hud.wheelsettings[plate] == nil then Hud.wheelsettings[plate] = {} end
		local val = Hud:round(data.val * 100)
		SetVehicleWheelYRotation(Hud.vehicle,2,tonumber("-0."..val..""))
		SetVehicleWheelYRotation(Hud.vehicle,3,tonumber("0."..val..""))
		if Hud.wheelsettings[plate]['wheelrotationrear'] == nil then Hud.wheelsettings[plate]['wheelrotationrear'] = {} end
		Hud.wheelsettings[plate]['wheelrotationrear'].wheel2 = tonumber("-0."..val.."")
		Hud.wheelsettings[plate]['wheelrotationrear'].wheel3 = tonumber("0."..val.."")
		Hud.wheeledit = true
		if Hud.nearstancer[plate] ~= nil then
			Hud.nearstancer[plate].wheeledit = true
		end
		SendNUIMessage({type = "unsetradio",content = false})
    end
	cb(true)
end)

temp_advstat = {}
CreateThread(function()
	Wait(1000)
	while not LocalPlayer.state.playerloaded do Wait(100) end
	if config.wheelstancer then
		while Hud.veh_stats == nil do
			Wait(100)
			Hud.veh_stats = LocalPlayer.state.adv_stat
		end
		CreateThread(function()
			while true do
				temp_advstat = LocalPlayer.state.adv_stat
				Wait(2000)
			end
		end)
		while true do
			local sleep = 2000
			advstat = temp_advstat
			for k,v in pairs(Hud.nearstancer) do
				v.plate = string.gsub(v.plate, "^%s*(.-)%s*$", "%1")
				if v.speed > 1 and not v.wheeledit and v.dist < 100 and advstat[v.plate] ~= nil and advstat[v.plate]['wheelsetting'] ~= nil then
					sleep = 11
					SetVehicleWheelWidth(v.entity,0.7) -- trick to avoid stance bug
					SetVehicleWheelXOffset(v.entity,0,tonumber(advstat[v.plate]['wheelsetting']['wheeloffsetfront'].wheel0))
					SetVehicleWheelXOffset(v.entity,1,tonumber(advstat[v.plate]['wheelsetting']['wheeloffsetfront'].wheel1))
					SetVehicleWheelXOffset(v.entity,2,tonumber(advstat[v.plate]['wheelsetting']['wheeloffsetrear'].wheel2))
					SetVehicleWheelXOffset(v.entity,3,tonumber(advstat[v.plate]['wheelsetting']['wheeloffsetrear'].wheel3))
					SetVehicleWheelSize(v.entity,GetVehicleWheelSize(v.entity)) -- trick to avoid stance bug tricking the system or game that this is all visual only not physics maybe?
					SetVehicleWheelYRotation(v.entity,0,tonumber(advstat[v.plate]['wheelsetting']['wheelrotationfront'].wheel0))
					SetVehicleWheelYRotation(v.entity,1,tonumber(advstat[v.plate]['wheelsetting']['wheelrotationfront'].wheel1))
					SetVehicleWheelYRotation(v.entity,2,tonumber(advstat[v.plate]['wheelsetting']['wheelrotationrear'].wheel2))
					SetVehicleWheelYRotation(v.entity,3,tonumber(advstat[v.plate]['wheelsetting']['wheelrotationrear'].wheel3))
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

RegisterNUICallback('wheelsetting', function(data, cb)
	Hud.vehicle = Hud:getveh()
	Hud.wheeledit = false
	plate = tostring(GetVehicleNumberPlateText(Hud.vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
	Hud:get_veh_stats(Hud:getveh(), plate)
	if Hud.veh_stats[plate]['wheelsetting'] == nil then
		Hud.veh_stats[plate]['wheelsetting'] = {}
	end
	local vehicle_height = GetVehicleSuspensionHeight(Hud.vehicle)
	--for i = 0, numwheel - 1 do
	--will rewrite later for shorter code
	if Hud.wheelsettings[plate]['wheeloffsetfront'].wheel0 == nil then
		Hud.wheelsettings[plate]['wheeloffsetfront'].wheel0 = GetVehicleWheelXOffset(Hud.vehicle,0)
	end
	if Hud.wheelsettings[plate]['wheeloffsetfront'].wheel1 == nil then
		Hud.wheelsettings[plate]['wheeloffsetfront'].wheel1 = GetVehicleWheelXOffset(Hud.vehicle,1)
	end
	if Hud.wheelsettings[plate]['wheeloffsetrear'].wheel2 == nil then
		Hud.wheelsettings[plate]['wheeloffsetrear'].wheel2 = GetVehicleWheelXOffset(Hud.vehicle,2)
	end
	if Hud.wheelsettings[plate]['wheeloffsetrear'].wheel3 == nil then
		Hud.wheelsettings[plate]['wheeloffsetrear'].wheel3 = GetVehicleWheelXOffset(Hud.vehicle,3)
	end

	if Hud.wheelsettings[plate]['wheelrotationfront'].wheel0 == nil then
		Hud.wheelsettings[plate]['wheelrotationfront'].wheel0 = GetVehicleWheelYRotation(Hud.vehicle,0)
	end
	if Hud.wheelsettings[plate]['wheelrotationfront'].wheel1 == nil then
		Hud.wheelsettings[plate]['wheelrotationfront'].wheel1 = GetVehicleWheelYRotation(Hud.vehicle,1)
	end
	if Hud.wheelsettings[plate]['wheelrotationrear'].wheel2 == nil then
		Hud.wheelsettings[plate]['wheelrotationrear'].wheel2 = GetVehicleWheelYRotation(Hud.vehicle,2)
	end
	if Hud.wheelsettings[plate]['wheelrotationrear'].wheel3 == nil then
		Hud.wheelsettings[plate]['wheelrotationrear'].wheel3 = GetVehicleWheelYRotation(Hud.vehicle,3)
	end
	Hud.veh_stats[plate]['wheelsetting'] = Hud.wheelsettings[plate]
	--end
	Hud.veh_stats[plate].height = vehicle_height
    if Hud.vehicle ~= nil and Hud.vehicle ~= 0 and not data.bool then
		TriggerServerEvent('renzu_hud:savedata', plate, Hud.veh_stats[tostring(plate)])
		LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] Hud.veh_stats, --[[replicate to server]] true)
	end
	Wait(1000)
	Hud.nearstancer[plate].wheeledit = false
	cb(true)
end)

RegisterNUICallback('setvehicleneon', function(data, cb)
	Hud.vehicle = Hud:getveh()
	r,g,b = GetVehicleNeonLightsColour(Hud.vehicle)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(Hud:getveh(), i, data.bool)
			Citizen.Wait(500)
		end
	end
	cb(true)
end)

local neoneffect1 = false
local oldneon = nil
local r,g,b = nil,nil,nil
local o_r,og,ob = nil,nil,nil
RegisterNUICallback('setneoneffect1', function(data, cb)
	Hud.vehicle = Hud:getveh()
	local mycar = Hud.vehicle
	r,g,b = GetVehicleNeonLightsColour(mycar)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		Hud:requestcontrol(mycar)
		neoneffect1 = not neoneffect1
		Wait(100)
		CreateThread(function()
			if neoneffect1 then
				o_r,og,ob = GetVehicleNeonLightsColour(mycar)
			end
			while neoneffect1 do
				Hud:requestcontrol(mycar)
				SetVehicleNeonLightsColour(mycar,getColor(0,0,0,255,255,255))
				for i = 0, 3 do
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
RegisterNUICallback('setneoneffect2', function(data, cb)
	Hud.vehicle = Hud:getveh()
	local mycar = Hud.vehicle
	r,g,b = GetVehicleNeonLightsColour(mycar)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		neoneffect2 = not neoneffect2
		Hud:requestcontrol(mycar)
		Wait(100)
		CreateThread(function()
			while neoneffect2 do
				Hud:requestcontrol(mycar)
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

RegisterNUICallback('setVehicleWindow1', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if IsVehicleWindowIntact(Hud.vehicle,0) == 1 or IsVehicleWindowIntact(Hud.vehicle,0) then
        RollDownWindow(Hud.vehicle,1)
		RollDownWindow(Hud.vehicle,0)
    else     
        RollUpWindow(Hud.vehicle,1)
		RollUpWindow(Hud.vehicle,0)
    end
	cb(true)
end)

RegisterNUICallback('setVehicleWindow2', function(data, cb)
	Hud.vehicle = Hud:getveh()
    if IsVehicleWindowIntact(Hud.vehicle,2) == 1 or IsVehicleWindowIntact(Hud.vehicle,2) then
        RollDownWindow(Hud.vehicle,2)
		RollDownWindow(Hud.vehicle,3)
    else     
        RollUpWindow(Hud.vehicle,3)
		RollUpWindow(Hud.vehicle,2)
    end
	cb(true)
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

RegisterNetEvent("renzu_hud:addnitro")
AddEventHandler("renzu_hud:addnitro", function(amount)
		local lib, anim = 'mini@repair', 'fixing_a_car'
        local playerPed = PlayerPedId()
		Hud:playanimation('mini@repair','fixing_a_car')
		ClearPedTasks(playerPed)
		Wait(5000)
		Hud:Notify('success','Nitro System',"Nitro is Max")
		Hud.veh_stats[Hud:GetPlate(Hud:getveh())].nitro = 100
end)

RegisterNetEvent("renzu_hud:nitro_flame_stop")
AddEventHandler("renzu_hud:nitro_flame_stop", function(c_veh,coords)
		if Hud.purgefuck[c_veh] ~= nil then
			Hud.purgefuck[c_veh] = false
		end
		for k,v in pairs(Hud.purgeshit) do
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
		for k,v in pairs(Hud.lightshit) do
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
	if #(coords - GetEntityCoords(Hud.ped)) < 50 then
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
				if Hud.lightshit[c_veh] == nil then
					Hud.lightshit[c_veh] = {}
				end
				table.insert(Hud.lightshit[c_veh], lightrailparticle)
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
					table.insert(Hud.flametable, flames)
					Wait(100)
				end
			end
			while GetVehicleThrottleOffset(vehicle) > 0.1 do
				Wait(100)
			end
			for k,v in pairs(Hud.flametable) do
				StopParticleFxLooped(k, 1)
				RemoveParticleFx(k, true)
				k = nil
			end

		else
			if not Hud.purgefuck[c_veh] then
				local vehicle = NetToVeh(c_veh)
				Hud.purgefuck[c_veh] = true
				print("purge")
				local index = GetEntityBoneIndexByName(vehicle, config.purge_left_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge1 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x + 0.03, particle_location.y + 0.1, particle_location.z+0.2, 20.0, 0.0, 0.5,config.purge_size,false,false,false)
																																												---20.0, 0.0, 0.5,config.purge_size,false,false,false)
				SetVehicleBoostActive(vehicle, 1, 0)
				SetVehicleBoostActive(vehicle, 0, 0)
				if Hud.purgeshit[c_veh] == nil then
					Hud.purgeshit[c_veh] = {}
				end
				table.insert(Hud.purgeshit[c_veh], purge1)
				local index = GetEntityBoneIndexByName(vehicle, config.purge_right_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge2 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x - 0.03, particle_location.y + 0.1, particle_location.z+0.2, 20.0, 0.0, 0.5,config.purge_size,false,false,false)
				table.insert(Hud.purgeshit[c_veh], purge2)
				while Hud.purgefuck[c_veh] do
					Wait(55)
					SetVehicleBoostActive(vehicle, 1, 0)
					SetVehicleBoostActive(vehicle, 0, 0)
				end
			end
		end
	end
end)

RegisterCommand(config.commands['enablenitro'], function()
	if Hud.vehicle ~= 0 then
		if config.enablenitro then
			if not Hud.nitromode then
				Hud.nitromode = not Hud.nitromode
				Hud.spool = PlaySoundFromEntity(GetSoundId(), "Flare", Hud.vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
				Hud:Notify('success','Nitro System',"Nitro has been activated")
				Hud:EnableNitro()
			else
				Hud.nitromode = not Hud.nitromode
				StopSound(Hud.spool)
				ReleaseSoundId(Hud.spool)
				Hud:Notify('warning','Nitro System',"Nitro has been off")
			end
		end
	end
end, false)

CreateThread(function()
	if config.enablenitro then
		RegisterKeyMapping(config.commands['enablenitro'], 'Enable Nitro Control', 'keyboard', config.keybinds['enablenitro'])
	end
	return
end)

local installcount = 0
RegisterNetEvent("renzu_hud:installtire")
AddEventHandler("renzu_hud:installtire", function(type)
	local bones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local index = {["wheel_lf"] = 0, ["wheel_rf"] = 1, ["wheel_lm1"] = 2, ["wheel_rm1"] = 3, ["wheel_lm2"] = 45,["wheel_rm2"] = 47, ["wheel_lm3"] = 46, ["wheel_rm3"] = 48, ["wheel_lr"] = 4, ["wheel_rr"] = 5,}
	local coords = GetEntityCoords(Hud.ped, false)
	local vehicle = Hud:getveh()
	if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, -1) and IsPedOnFoot(Hud.ped) then
		for i = 1, #bones do
			local tirepos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, bones[i]))
			local distance = #(coords - tirepos)
			local currentindex = bones[bones[i]]
			local plate = GetVehicleNumberPlateText(vehicle)
			--plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
			if Hud.veh_stats == nil then
				Hud.veh_stats = {}
			end
			if plate ~= nil and Hud.veh_stats[plate] == nil then
				Hud.veh_stats[plate] = {}
				Hud.veh_stats[plate].plate = plate
				Hud.veh_stats[plate].mileage = 0
				Hud.veh_stats[plate].oil = 100
				Hud.veh_stats[plate].coolant = 100
				Hud.veh_stats[plate].nitro = 100
				local numwheel = GetVehicleNumberOfWheels(vehicle)
				for i = 0, numwheel - 1 do
					if Hud.veh_stats[plate][tostring(i)] == nil then
						Hud.veh_stats[plate][tostring(i)] = {}
					end
					Hud.veh_stats[plate][tostring(i)].tirehealth = config.tirebrandnewhealth
				end
			end
			if distance < 3 and Hud.veh_stats ~= nil and Hud.veh_stats[plate] ~= nil then
				Hud:tireanimation()
				Wait(1000)
				if config.repairalltires then
					Hud:playanimation('anim@amb@clubhouse@tutorial@bkr_tut_ig3@','machinic_loop_mechandplayer')
					Hud:Makeloading('Installing New Tires',10000)
					Citizen.Wait(10000)
					local numwheel = GetVehicleNumberOfWheels(vehicle)
					for tire = 0, numwheel - 1 do
						SetVehicleTyreFixed(vehicle, tire)
						SetVehicleWheelHealth(vehicle, tire, 1000.0)
						Hud.veh_stats[plate][tostring(tire)].tirehealth = 999.0
						local wheeltable = {
							['index'] = tire,
							['tirehealth'] = Hud.veh_stats[plate][tostring(tire)].tirehealth
						}
						SendNUIMessage({
							type = "setWheelHealth",
							content = wheeltable
						})
					end
					Hud:Notify('success','Tire System',"New Tires has been Successfully Install")
					ClearPedTasks(Hud.ped)
					if type ~= nil and type ~= 'default' then
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult) -- start burnout less = traction
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult)  -- asphalt mud less = traction
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin) -- accelaration grip
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax) -- cornering grip
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral) -- curve lateral grip
						Hud.veh_stats[plate].tirespec = {}
						Hud.veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult
						Hud.veh_stats[plate].tirespec['fTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult
						Hud.veh_stats[plate].tirespec['fTractionCurveMin'] = DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin
						Hud.veh_stats[plate].tirespec['fTractionCurveMax'] = DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax
						Hud.veh_stats[plate].tirespec['fTractionCurveLateral'] = DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral
					end
					if type ~= nil then
						Hud.veh_stats[plate].tires = type
					end
					TriggerServerEvent('renzu_hud:savedata', plate, Hud.veh_stats[tostring(plate)])
					LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] Hud.veh_stats, --[[replicate to server]] true)
					Hud:ReqAndDelete(Hud.proptire,true)
					break
				else
					Hud:playanimation('anim@amb@clubhouse@tutorial@bkr_tut_ig3@','machinic_loop_mechandplayer')
					Hud:Makeloading('Installing New Tire #'..i..'',10000)
					Citizen.Wait(10000)
					SetVehicleTyreFixed(vehicle, i)
					SetVehicleWheelHealth(vehicle, i, 1000.0)
					Hud.veh_stats[plate][tostring(i)].tirehealth = 999.0
					ClearPedTasks(Hud.ped)
					local wheeltable = {
						['index'] = i,
						['tirehealth'] = Hud.veh_stats[plate][tostring(i)].tirehealth
					}
					SendNUIMessage({
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
							Hud.veh_stats[plate].tirespec = {}
							Hud.veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult
							Hud.veh_stats[plate].tirespec['fTractionLossMult'] = DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult
							Hud.veh_stats[plate].tirespec['fTractionCurveMin'] = DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin
							Hud.veh_stats[plate].tirespec['fTractionCurveMax'] = DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax
							Hud.veh_stats[plate].tirespec['fTractionCurveLateral'] = DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral
						end
						if type ~= nil then
							Hud.veh_stats[plate].tires = type
						end
					end
					TriggerServerEvent('renzu_hud:savedata', plate, Hud.veh_stats[tostring(plate)])
					LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] Hud.veh_stats, --[[replicate to server]] true)
					Hud:Notify('success','Tire System',"New Tire #"..i.." has been Successfully Install")
					Hud:ReqAndDelete(Hud.proptire,true)
					break
				end
				ClearPedTasks(Hud.ped)
			end
		end
	end
end)

CreateThread(function()
	if config.repaircommand then
		RegisterCommand('repairtire', function()
			TriggerEvent("renzu_hud:installtire")
		end, false)
	end
	return
end)

CreateThread(function()
	if config.carlock then
		RegisterCommand(config.commands['carlock'], function()
			Hud:Carlock()
		end, false)
		RegisterKeyMapping(config.commands['carlock'], 'Toggle Carlock System', 'keyboard', config.keybinds['carlock'])
	end
	return
end)

RegisterNetEvent("renzu_hud:synclock")
AddEventHandler("renzu_hud:synclock", function(v, type, coords)
	local v = NetToVeh(v)
	if #(coords - GetEntityCoords(Hud.ped)) < 50 then
		SetVehicleLights(v, 2);Citizen.Wait(100);SetVehicleLights(v, 0);Citizen.Wait(200);SetVehicleLights(v, 2)
		Citizen.Wait(100)
		SetVehicleLights(v, 0)	
		if type == 'lock' then
			--print("locking shit")
			Hud:playsound(coords,20,'lock',1.0)
			SetVehicleDoorsLocked(v,2)
			Wait(500)
			ClearPedTasks(Hud.ped)
		end
		if type == 'force' then
			SetVehicleDoorsLocked(v,7)
		end
		if type == 'carjack' then
			SetVehicleDoorsLocked(v,1)
		end
		if type == 'unlock' then
			--print("unlocking shit")
			Hud:playsound(coords,20,'unlock',1.0)
			SetVehicleDoorsLocked(v,1)
			Wait(500)
			ClearPedTasks(Hud.ped)
		end
	end
end)

settingbool = false
RegisterNUICallback('hidecarlock', function(data, cb)
    SetNuiFocus(false,false)
	SendNUIMessage({
		type = "setShowKeyless",
		content = false
	})
	Hud.keyless = true
	SendNUIMessage({
		type = "SettingHud",
		content = {config = config.userconfig, bool = false}
	})
	settingbool = false
	cb(true)
end)

RegisterNUICallback('setvehiclelock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		Hud:playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Hud:Notify('success','Vehicle Lock System','Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", VehToNet(data.vehicle), 'lock', GetEntityCoords(Hud.ped))
    end
	cb(true)
end)

RegisterNUICallback('setvehicleunlock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		Hud:playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Hud:Notify('success','Vehicle Lock System','Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", VehToNet(data.vehicle), 'unlock', GetEntityCoords(Hud.ped))
    end
	cb(true)
end)

RegisterNUICallback('setvehicleopendoors', function(data, cb)
	--print("openall")
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		Hud:playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Opening All Doors # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Hud:playsound(GetEntityCoords(data.vehicle),20,'openall',1.0)
		for i = 0, 3 do
			if data.bool then
				--print(i)
				SetVehicleDoorOpen(data.vehicle,i,false,false)
			else     
				SetVehicleDoorShut(data.vehicle,i,false,false)
			end
		end
		if data.bool then
			Hud:Notify('success','Lock System',"All Doors is Open")
		else
			Hud:Notify('warning','Lock System',"All Doors has been closed")
		end
		Wait(500)
		ClearPedTasks(Hud.ped)
    end
	cb(true)
end)

RegisterNUICallback('setvehiclealarm', function(data, cb)
	--print("vehicle alarm")
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		Hud:playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		Hud:Makeloading('Vehicle Alarm Mode # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
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
		ClearPedTasks(Hud.ped)
    end
	cb(true)
end)

--clothes
CreateThread(function()
	while not LocalPlayer.state.playerloaded do Wait(100) end
	Wait(500)
	--print("CLOTHING")
	if config.clothing then
		while DecorGetBool(PlayerPedId(), "PLAYERLOADED") ~= 1 do
			Citizen.Wait(100)
			--print(DecorGetBool(PlayerPedId(), "PLAYERLOADED"))
			if LocalPlayer.state.playerloaded then
				DecorSetBool(PlayerPedId(), "PLAYERLOADED", true)
				break
			end
			--print("Playerloaded")
		end
		Wait(4000) -- wait 4 sec after the playerloaded event to get Hud.ped skin
		TriggerEvent('skinchanger:getSkin', function(current)
			Hud.dummyskin1 = current
		end)
		while Hud:tablelength(Hud.dummyskin1) <= 2 do
			TriggerEvent('skinchanger:getSkin', function(current) Hud.dummyskin1 = current end)
			Wait(1000)
		end
		Hud:SaveCurrentClothes(true)
		skinsave = false
		RegisterCommand(config.commands['clothing'], function()
			Hud:SaveCurrentClothes(false)
			if not skinsave then
				--SaveCurrentClothes(false)
				skinsave = true
			end
			Hud:Clothing()
		end, false)
		RegisterKeyMapping(config.commands['clothing'], 'Toggle Clothing UI', 'keyboard', config.keybinds['clothing'])
	end
	return
end)

local clothebusy = false
RegisterNUICallback('ChangeClothes', function(data)
	local skin = Hud.oldclothes
	if not clothebusy then
		clothebusy = true
		if Hud.clothestate[tostring(data.variant)] then
			Hud:TaskAnimation(config.clothing[data.variant]['taskplay'])
			Hud:Notify("success","Clothe System",""..data.variant.." is put off")
			local st = nil
			TriggerEvent('skinchanger:getSkin', function(current)
				TriggerEvent('skinchanger:loadClothes', current, config.clothing[data.variant].skin)
			end)
			PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0)
			Hud.clothestate[tostring(data.variant)] = false
			if data.variant == 'mask_1' or data.variant == 'helmet_1' then
				SendNUIMessage({content = true, type = 'pedface'})
			end
			local t = {
				['bool'] = Hud.clothestate[data.variant],
				['variant'] = data.variant
			}
			SendNUIMessage({
				type = "setClotheState",
				content = t
			})
		else
			if Hud.oldclothes[tostring(data.variant)] == config.clothing[tostring(data.variant)]['default'] then
				Hud:Notify("warning","Clothe System","No Variant for this type")
			else 
				Hud:TaskAnimation(config.clothing[data.variant]['taskplay'])
				Hud:Notify("success","Clothe System",""..data.variant.." is put on")
				local Changes = {}
				if data.variant == 'mask_1' or data.variant == 'helmet_1' then
					SendNUIMessage({content = true, type = 'pedface'})
				end
				Changes[tostring(data.variant)], Changes[tostring(data.variant2)] = skin[tostring(data.variant)], skin[tostring(data.variant2)]
				if data.variant == 'torso_1' then
					Changes['arms'], Changes['arms_2'] = skin['arms'], skin['arms_2']
				end
				TriggerEvent('skinchanger:getSkin', function(current)
					TriggerEvent('skinchanger:loadClothes', current, Changes)
				end)
				Hud.clothestate[tostring(data.variant)] = true
				PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0)
				local t = {
					['bool'] = Hud.clothestate[data.variant],
					['variant'] = data.variant
				}
				SendNUIMessage({
					type = "setClotheState",
					content = t
				})
			end
		end
		Wait(500)
		clothebusy = false
	end
end)

RegisterNUICallback('hideclothing', function(data)
	clothing = false
	local t = {
		['bool'] = clothing,
		['equipped'] = Hud.clothestate
	}
	SendNUIMessage({
		type = "setShowClothing",
		content = t
	})
	SetNuiFocusKeepInput(clothing)
	SetNuiFocus(clothing,clothing)
end)

RegisterNUICallback('resetclothing', function()
	Hud:TaskAnimation(config.clothing['reset']['taskplay'])
	TriggerEvent('skinchanger:loadClothes', Hud.oldclothes, Hud.oldclothes)
	Citizen.Wait(100)
	Hud:SaveCurrentClothes(true)
	Citizen.Wait(100)
	Hud:ClotheState()
	SendNUIMessage({type = 'ResetClotheState', content = Hud.clothestate})
end)

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

--ENGINE SYSTEM

local busy_install = false
RegisterNetEvent('renzu_hud:change_engine')
AddEventHandler('renzu_hud:change_engine', function(engine)
	if not busy_install then
		local oldengine = engine
		local handling = Hud:GetHandlingfromModel(GetHashKey(engine))
		local getcurrentvehicleweight = GetVehStats(Hud:getveh(), "CHandlingData","fMass")
		print(getcurrentvehicleweight,handling['fMass'])
		if getcurrentvehicleweight <= config.motorcycle_weight_check and handling['Mass'] > 600 then
			Hud:Notify('warning','Engine System',"this engine is not fit to this vehicle")
		else
			local bone = GetEntityBoneIndexByName(Hud:getveh(),'engine')
			local x,y,z = table.unpack(GetWorldPositionOfEntityBone(Hud:getveh(), bone))
			if Hud:getveh() ~= 0 and #(GetEntityCoords(Hud.ped) - vector3(x,y,z)) <= config.engine_dis then
				busy_install = true
				SetVehicleFixed(Hud:getveh())
				plate = tostring(GetVehicleNumberPlateText(Hud:getveh()))
				--plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
				Hud:get_veh_stats(Hud:getveh(), plate)
				Hud.veh_stats[plate].engine = engine
				--print("loop item")
				Citizen.Wait(2000)
				Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
				--ExecuteCommand("e petting")
				Wait(2500)
				ClearPedTasks(Hud.ped)
				Hud:playanimation('mp_player_int_uppergang_sign_a','mp_player_int_gang_sign_a')
				--ExecuteCommand("e gangsign")
				Wait(200)
				SetVehicleDoorOpen(Hud:getveh(),4,false,false)
				Wait(400)
				ClearPedTasks(Hud.ped)
				SetVehicleDoorOpen(Hud:getveh(),4,false,false)
				Wait(1000)
				SetVehicleDoorBroken(Hud:getveh(),4,true)
				Wait(1000)
				if config.enable_engine_prop then
					installing = true
					for k,v in pairs(config.blacklistvehicle) do
						print(GetVehicleClass(Hud:getveh()))
						if tonumber(GetVehicleClass(Hud:getveh())) == tonumber(v) then
							installing = false
							busy_install = false
						end
					end
					if installing then
						Hud:repairengine(plate)
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

				Hud:playanimation('creatures@rottweiler@tricks@','petting_franklin')
				Wait(10000)
				busy_install = false
				installing = false
				Hud:ReqAndDelete(enginemodel,true)
				Hud:ReqAndDelete(standmodel,true)
				ClearPedTasks(Hud.ped)
				SetVehicleFixed(Hud:getveh())
				TriggerServerEvent('renzu_hud:change_engine', plate, Hud.veh_stats[plate])
			else
				Hud:Notify('warning','Engine System',"You must be infront of the vehicle engine - Walk to the engine position now")
				while engine == oldengine do
					--print(#(vector3(x,y,z) - GetEntityCoords(Hud.ped)), oldengine)
					if #(vector3(x,y,z) - GetEntityCoords(Hud.ped)) <= 2.2 then
						busy_install = false
						TriggerEvent('renzu_hud:change_engine',oldengine)
						break
					end
					Wait(100)
				end
			end
		end
	else
		Hud:Notify('warning','Engine System',"You have ongoing installation, go to the vehicle")
	end
end)

RegisterNetEvent('renzu_hud:syncengine')
AddEventHandler('renzu_hud:syncengine', function(plate, t)
	while Hud.veh_stats == nil do Wait(1) Hud.veh_stats = LocalPlayer.state.adv_stat end
    Hud.veh_stats[tostring(plate)] = t
	Hud.onlinevehicles[tostring(plate)] = t
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
	print(off,low,high)
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


-- CreateThread(function()
-- 	Wait(10000)
-- 	collectgarbage() -- collect all destroyed threads from memory
-- end)