ESX = nil
Citizen.CreateThread(function()
	if config.framework == 'ESX' then
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end

		while ESX.GetPlayerData().job == nil do
			Citizen.Wait(0)
		end

		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
		Citizen.Wait(5000)
	else
		ESX = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local veh_stats = {}
local date = "00:00"
local playerloaded = false
local manual = false
local vehicletopspeed
local uimove = false
local reverse = false
local savegear = 0
local rpm = 0.2
local hour = 0
local vali = false
local minute = 0
local segundos = 0
local month = ""
local dayOfMonth = 0
local voice = 2
local voiceDisplay = 2
local proximity = 25.0
local belt = false
local ExNoCarro = false
local sBuffer = {}
local vBuffer = {}
local displayValue = true
local gasolina = 0
local street = nil
local vehicle
local hp = 0
local shifter = false
local hasNitro = true
local k_nitro = 70
local n_boost = 15.0
local nitro_state = 0
local isBlack = "false"
local invehicle = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- DATE
-----------------------------------------------------------------------------------------------------------------------------------------
function timeformat()
	date = ""..hour..":"..minute..""
	if newdate ~= date or newdate == nil and vehicle ~= nil and vehicle ~= 0 then
		format = {
			min = minute,
			hour = hour
		}
		SendNUIMessage({
			type = "setTime",
			content = format
		})
		newdate = date
	end
end

function CalculateTimeToDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = "0" .. hour
	end
	if minute <= 9 then
		minute = "0" .. minute
	end
end
function CalculateDateToDisplay()
	month = GetClockMonth()
	dayOfMonth = GetClockDayOfMonth()
	if month == 0 then
		month = "January"
	elseif month == 1 then
		month = "February"
	elseif month == 2 then
		month = "March"
	elseif month == 3 then
		month = "April"
	elseif month == 4 then
		month = "May"
	elseif month == 5 then
		month = "June"
	elseif month == 6 then
		month = "July"
	elseif month == 7 then
		month = "August"
	elseif month == 8 then
		month = "September"
	elseif month == 9 then
		month = "October"
	elseif month == 10 then
		month = "November"
	elseif month == 11 then
		month = "December"
	end
end

function setVoice()
	NetworkSetTalkerProximity(proximity)
end

local ped = nil
local playerNamesDist = 3
local key_holding = false

local particlesfire = {}
local particleslight = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VOICE FUNC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(config.commands['voip'], function()
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
	setVoice()
	SendNUIMessage({
		type = "setMic",
		content = voiceDisplay
	})
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['voip'], 'Voice Proximity', 'keyboard', config.keybinds['voip'])
end)

local newfreq = nil
RegisterNetEvent("radio:freq")
AddEventHandler("radio:freq", function(freq)
		if newfreq ~= freq or newfreq == nil then
		SendNUIMessage({
		type = "setRadio",
		content = freq
		})
		newfreq = freq
		end
end)

local pedshot = false

Citizen.CreateThread(function()
	if config.framework == 'ESX' then
		RegisterNetEvent('esx:playerLoaded')
		AddEventHandler('esx:playerLoaded', function(xPlayer)
			playerloaded = true
			Citizen.Wait(2000)
			TriggerServerEvent("renzu_hud:getmile")
		end)
	else
		RegisterNetEvent('playerSpawned')
		AddEventHandler('playerSpawned', function(spawn)
			playerloaded = true
			Citizen.Wait(2000)
			TriggerServerEvent("renzu_hud:getmile")	
		end)
	end
end)


--- NEW HUD FUNC

RegisterNUICallback('requestface', function(data, cb)
	while not playerloaded do
		Citizen.Wait(1000)
	end
	Citizen.Wait(5000)
    cb(getawsomeface())
end)

-- HELPERS
local headshot = nil
function getawsomeface()
    ClearPedHeadshots()

    local playerPos = GetEntityCoords(PlayerPedId())
    local player = PlayerId()

	local tempHandle = RegisterPedheadshotTransparent(PlayerPedId())

	local timer = 2000
	while ((not tempHandle or not IsPedheadshotReady(tempHandle) or not IsPedheadshotValid(tempHandle)) and timer > 0) do
		Wait(10)
		timer = timer - 10
	end

	local headshotTxd = 'none'
	if (IsPedheadshotReady(tempHandle) and IsPedheadshotValid(tempHandle)) then
		headshotTxd = GetPedheadshotTxdString(tempHandle)
		headshot = headshotTxd
	end

	return headshotTxd
end

function ClearPedHeadshots()
		if headshot ~= nil or headshot ~= 0 then
        	UnregisterPedheadshot(headshot)
		end
end

local show = false

function updateStatus()
	Myinfo()
	local fetch = false
	sanity = 0
	thirst = 0
	hunger = 0
	oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
	energy = 0
	stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
	TriggerEvent('esx_status:getStatusm', config.status, function(status)
		for k,v in pairs(status) do
			if k == 'thirst' then
				thirst = v.getPercent()
			end
			if k == 'sanity' then
				sanity = v.getPercent()
			end
			if k == 'energy' then
				energy = v.getPercent()
			end
			if k == 'hunger' then
				hunger = v.getPercent()
			end
		end
		fetch = true
	end)
	while not fetch do
		Citizen.Wait(1)
	end
	status = {
		stress = tonumber(sanity),
		oxygen = oxygen,
		thirst = tonumber(thirst),
		hunger = hunger,
		energy = energy,
		stamina = stamina
	}
	SendNUIMessage({
		type = "setStatus",
		content = status
	})
end
RegisterCommand(config.commands['showstatus'], function()
	show = not show
	updateStatus()
    PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	SendNUIMessage({
		type = "setShowstatus",
		content = show
	})
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['showstatus'], 'HUD Status UI', 'keyboard', config.keybinds['showstatus'])
end)

Citizen.CreateThread(function()
	Citizen.Wait(4000)
	local l = 0
	while true do
		ped = PlayerPedId()
		vehicle = GetVehiclePedIsIn(ped)
		if vehicle ~= nil and vehicle ~= 0 then
			if not invehicle then
				inVehicleFunctions()
				Citizen.Wait(100)
			end
			invehicle = true
			hp = GetVehicleEngineHealth(vehicle)
			gasolina = GetVehicleFuelLevel(vehicle)
			if uimove then
				Citizen.Wait(1500)
				SendNUIMessage({
					type = "setShow",
					content = true
				})
			end
			uimove = false
		else
			invehicle = false
			speed = 0
			rpm = 0
			marcha = 0
			VehIndicatorLight = 0
			DisplayRadar(false)
			if not uimove then
				Citizen.Wait(500)
				SendNUIMessage({
					type = "setShow",
					content = false
				})
			end
			uimove = true
		end
		Citizen.Wait(config.car_mainloop_sleep)
	end
end)

--ASYNC FUNCTION CALL VEHICLE LOOPS
function inVehicleFunctions()
	Citizen.CreateThread(function()
		while not invehicle do
			Citizen.Wait(1) -- lets wait invehicle to = true
		end
		RpmandSpeedLoop()
		NuiRpm()
		NuiSpeed()
		NuiCarhpandGas()
		NuiDistancetoWaypoint()
		NuiHeadlights()
		NuiGear()
		NuiMileAge()
		NuiVehicleClock()
	end)
end

function RpmandSpeedLoop()
	Citizen.CreateThread(function()
		while ESX == nil do
			Citizen.Wait(2000)
		end
		while ped == nil do
			Citizen.Wait(1000)
		end
		while invehicle do
			local sleep = 2000
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.rpm_speed_loop
				rpm = GetVehicleCurrentRpm(vehicle)
				speed = GetEntitySpeed(vehicle)
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function NuiRpm()
	Citizen.CreateThread(function()
		while ESX == nil do
			Citizen.Wait(2000)
		end
		while ped == nil do
			Citizen.Wait(1000)
		end
		while invehicle do
			local sleep = 2500
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.Rpm_sleep
				if rpm < 0.21 then
				Citizen.Wait(config.idle_rpm_speed_sleep)
				end
				if newrpm ~= rpm or newrpm == nil then
					newrpm = rpm
					SendNUIMessage({
						type = "setRpm",
						content = rpm
					})
					Citizen.Wait(config.Rpm_sleep_2)
					SendNUIMessage({
						type = "setRpm",
						content = rpm
					})
					Citizen.Wait(config.Rpm_sleep_2)
					SendNUIMessage({
						type = "setRpm",
						content = rpm
					})
					Citizen.Wait(config.Rpm_sleep_2)
					SendNUIMessage({
						type = "setRpm",
						content = rpm
					})
				end
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function NuiSpeed()
	Citizen.CreateThread(function()
		while ESX == nil do
			Citizen.Wait(2000)
		end
		while ped == nil do
			Citizen.Wait(1000)
		end
		while invehicle do
			local sleep = 2500
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.Speed_sleep
				if rpm < 0.21 then
				Citizen.Wait(config.idle_rpm_speed_sleep)
				end
				if newspeed ~= speed or newspeed == nil then
					newspeed = speed
					SendNUIMessage({
						type = "setSpeed",
						content = speed
					})
					Citizen.Wait(config.Speed_sleep_2)
					SendNUIMessage({
						type = "setSpeed",
						content = speed
					})
					Citizen.Wait(config.Speed_sleep_2)
					SendNUIMessage({
						type = "setSpeed",
						content = speed
					})
					Citizen.Wait(config.Speed_sleep_2)
					SendNUIMessage({
						type = "setSpeed",
						content = speed
					})
				end
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function NuiCarhpandGas()
	Citizen.CreateThread(function()
		while ESX == nil do
			Citizen.Wait(2000)
		end
		local newgas = nil
		local newgear = nil
		local vehealth = nil
		local belt= nil
		local wait = 2500
		while invehicle do
			if vehicle ~= nil and vehicle ~= 0 then
				wait = config.NuiCarhpandGas_sleep
				if gasolina ~= newgas or newgas == nil then
					SendNUIMessage({
						type = "setFuelLevel",
						content = gasolina
					})
					newgas = gasolina
				end
				if newcarhealth ~= hp or newcarhealth == nil then
					SendNUIMessage({
						hud = "setCarhp",
						content = hp
					})
					newcarhealth = hp
				end
			end
			Citizen.Wait(wait)
		end
		TerminateThisThread()
	end)
end

function NuiDistancetoWaypoint()
	--NUI DISTANCE to Waypoint
	Citizen.CreateThread(function()
		while invehicle do
			local sleep = config.direction_sleep
			local ped = ped
			local vehicle = vehicle
			local waypoint = GetFirstBlipInfoId(8)
			if vehicle ~= 0 and DoesBlipExist(waypoint) then
				local coord = GetEntityCoords(ped, true)
				local dis = #(coord - GetBlipCoords(waypoint))
				if newdis ~= dis or newdis == nil then
					newdis = dis
					SendNUIMessage({
					type = "setWaydistance",
					content = dis
					})
				end
			elseif vehicle ~=0 and not DoesBlipExist(waypoint) then
				--if newdis ~= dis or newdis == nil then
					newdis = 0
					SendNUIMessage({
					type = "setWaydistance",
					content = 0
					})
				--end
				Citizen.Wait(config.direction_sleep)
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function NuiHeadlights()
	--NUI HEAD LIGHTS
	Citizen.CreateThread(function()
		while invehicle do
			local sleep = 2500
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.lights_sleep
				local off,low,high = GetVehicleLightsState(vehicle)
				if low == 1 and high == 0 then
					light = 1
				elseif high == 1 then
					light = 2
				else
					light = 0
				end
				if newlight ~= light or newlight == nil then
					newlight = light
					SendNUIMessage({
					type = "setHeadlights",
					content = light
					})
				end
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function NuiGear()
	--NUI GEAR STATUS
	Citizen.CreateThread(function()
		while invehicle do
			local sleep = 2500
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.gear_sleep
				local gear = GetVehicleCurrentGear(vehicle)
				if newgear ~= gear or newgear == nil then
					newgear = gear
					SendNUIMessage({
					type = "setGear",
					content = gear
					})
				end
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
		print("GEAR LOOP ENDED")
	end)
end

function NuiMileAge()
	local lastve = nil
	local savemile = false
	local saveplate = nil
	Citizen.CreateThread(function()
		local count = 0
		while not playerloaded and count < 3 do
			Citizen.Wait(1000)
			count = count + 1
		end
		if not playerloaded then
			TriggerServerEvent("renzu_hud:getmile")
		end
		Citizen.Wait(5000)
		while invehicle do
			Citizen.Wait(2500)
			local ped = ped
			local vehicle = vehicle
			local driver = GetPedInVehicleSeat(vehicle, -1)
			if vehicle ~= nil and vehicle ~= 0 and IsPedInAnyVehicle(ped, false) and driver == ped then
				local plate = tostring(GetVehicleNumberPlateText(vehicle))
				local newPos = GetEntityCoords(ped)
				savemile = true
				lastve = GetVehiclePedIsIn(ped, false)
				if plate ~= nil then
					--saveplate = string.match(GetVehicleNumberPlateText(vehicle), '%f[%d]%d[,.%d]*%f[%D]')
					saveplate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
					plate = saveplate
					if plate ~= nil and veh_stats[plate] == nil then
						veh_stats[plate] = {}
						veh_stats[plate].plate = plate
						veh_stats[plate].mileage = 0
					end
					if plate ~= nil and veh_stats[plate].plate == plate then
						if oldPos == nil then
							oldPos = newPos
						end
						local dist = #(newPos-oldPos)
						if dist > 10.0 then
							veh_stats[plate].mileage = veh_stats[plate].mileage+GetEntitySpeed(vehicle)*1/100
							oldPos = newPos
						end
						if newmileage ~= veh_stats[plate].mileage or newmileage == nil then
							newmileage = veh_stats[plate].mileage
							SendNUIMessage({
							type = "setMileage",
							content = veh_stats[plate].mileage
							})
						end
					end
				end
			elseif savemile and lastve ~= nil and saveplate ~= nil then
				savemile = false
				TriggerServerEvent('renzu_hud:savemile', saveplate, veh_stats[tostring(saveplate)])
				Wait(1000)
				lastve = nil
				saveplate = nil
			else
				Wait(1000)
			end
		end
		TerminateThisThread()
	end)
end

function NuiVehicleClock()
	Citizen.CreateThread(function()
		while invehicle do
			local sleep = 2000
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = 1000
				CalculateTimeToDisplay()
				CalculateDateToDisplay()
				timeformat()
			end
			Citizen.Wait(sleep)
		end
		TerminateThisThread()
	end)
end

function Myinfo()
	if config.framework == 'ESX' then
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end

		while ESX.GetPlayerData().job == nil do
			Citizen.Wait(0)
		end

		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
		local money = 0
		local black = 0
		local bank = 0
		for k,v in ipairs(ESX.PlayerData.accounts) do
			if v.name == "money" then
				money = v.money
			end
			if v.name == "black_money" then
				black = v.money
			end
			if v.name == "bank" then
				bank = v.money
			end
		end
		info = {
			job = xPlayer.job.name,
			joblabel = xPlayer.job.grade_name,
			money = money,
			black = black,
			bank = bank
		}
		SendNUIMessage({
			hud = "setInfo",
			content = info
		})
	end
end

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(55)
	end
    local currSpeed = 0.0
    local cruiseSpeed = 999.0
    local cruiseIsOn = false
    local seatbeltIsOn = false
	local newdate = nil
	local newstreet = nil
	local newmic = nil
	local newhealth = 1111
	local newarmor = 1111
	while ped == 0 or ped == nil do
		Citizen.Wait(111)
		ped = PlayerPedId()
	end
	while true do
		local sleep = config.uitop_sleep
		ped = PlayerPedId()
		health = (GetEntityHealth(ped)-100)
		armor = GetPedArmour(ped)
		if newarmor ~= armor or newarmor == nil then
			SendNUIMessage({
				hud = "setArmor",
				content = armor
			})
			newarmor = armor
		end
		if newhealth ~= health or newhealth == nil then
			SendNUIMessage({
				hud = "setHp",
				content = health
			})
			newhealth = health
		end
		Citizen.Wait(sleep)
	end
end)

function SendNuiSeatBelt()
	if vehicle ~= nil and vehicle ~= 0 then
		if newbelt ~= belt or newbelt == nil then
			newbelt = belt
			SendNUIMessage({
			type = "setBelt",
			content = belt
			})
		end
	end
end

-- YOU NEED SEATBELT SYSTEM FOR RAGDOLL, THIS IS FOR KEYBINDS ONLY for UI
Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['car_seatbelt'], 'Car Seatbelt', 'keyboard', config.keybinds['car_seatbelt'])
end)

RegisterCommand(config.commands['car_seatbelt'], function()
	if belt then
		SetTimeout(1000,function()
			belt = false
		end)
	else
		SetTimeout(1000,function()
			belt = true
		end)
	end
	SendNuiSeatBelt()
end, false)

-- SIGNAL LIGHTS
local left = false
local right = false
local hazard = false
local state = false

function sendsignaltoNUI()
	--NUI SIGNAL LIGHTS
	Citizen.CreateThread(function()
		if vehicle ~= nil and vehicle ~= 0 then
			sleep = 100
			while state ~= false do
				SendNUIMessage({
					type = "setSignal",
					content = state
				})
				Citizen.Wait(500)
			end
		end
	end)
end

RegisterCommand(config.commands['signal_left'], function()
	local ped = ped
	local vehicle = vehicle
	right = false
	Citizen.Wait(100)
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
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['signal_left'], 'Signal Left', 'keyboard', config.keybinds['signal_left'])
end)

RegisterCommand(config.commands['signal_right'], function()
	local ped = ped
	local vehicle = vehicle
	left = false
	Citizen.Wait(100)
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
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['signal_right'], 'Signal Right', 'keyboard', config.keybinds['signal_right'])
end)

RegisterCommand(config.commands['signal_hazard'], function()
	local ped = ped
	local vehicle = vehicle
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
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['signal_hazard'], 'Signal Hazard', 'keyboard', config.keybinds['signal_hazard'])
end)