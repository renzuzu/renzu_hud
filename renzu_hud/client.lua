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
	DecorRegister("INERTIA", 1)
	DecorRegister("DRIVEFORCE", 1)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
veh_stats = {}
entering = false
ismapopen = false
date = "00:00"
playerloaded = false
manual = false
vehicletopspeed = nil
uimove = false
reverse = false
savegear = 0
rpm = 0.2
hour = 0
vali = false
minute = 0
segundos = 0
month = ""
dayOfMonth = 0
voice = 2
voiceDisplay = 2
proximity = 25.0
belt = false
ExNoCarro = false
sBuffer = {}
vBuffer = {}
displayValue = true
gasolina = 0
street = nil
vehicle = nil
hp = 0
shifter = false
hasNitro = true
k_nitro = 70
n_boost = 15.0
nitro_state = 0
isBlack = "false"
invehicle = false

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

function updateStatus(pressed)
	if not config.statusv2 or pressed then
		Myinfo()
	end
	local fetch = false
	sanity = 0
	thirst = 0
	hunger = 0
	oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
	energy = 0
	stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
	local status = exports['standalone_status']:GetStatus(config.status)--, function(status)
	for k,v in pairs(status) do
		--print(k)
		Wait(100)
		--print(v)
		if k == 'thirst' then
			thirst = v / 10000
		end
		if k == 'sanity' then
			sanity = v / 10000
		end
		if k == 'energy' then
			energy = v / 10000
		end
		if k == 'hunger' then
			hunger = v / 10000
		end
	end
	fetch = true
	while not fetch do
		Citizen.Wait(111)
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

	Citizen.CreateThread(function()
		Citizen.Wait(1000)
		SendNUIMessage({
			type = "setShowstatusv2",
			content = config.statusv2
		})
		if config.statusv2 then
			while true do
				local sleep = config.statusv2_sleep
				updateStatus()
				Citizen.Wait(sleep)
			end
		end
	end)

RegisterCommand(config.commands['showstatus'], function()
	show = not show
	updateStatus(true)
    PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	SendNUIMessage({
		type = "setShowstatus",
		content = show
	})
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['showstatus'], 'HUD Status UI', 'keyboard', config.keybinds['showstatus'])
end)

start = false
breakstart = false

RegisterNUICallback('pushtostart', function(data, cb)
	start = true
	breakstart = false
end)

RegisterNUICallback('getoutvehicle', function(data, cb)
	start = false
	breakstart = false
	SetNuiFocus(false,false)
	TaskLeaveVehicle(ped,vehicle,0)
end)

Citizen.CreateThread(function()
	Citizen.Wait(3000)
	--WHEN RESTARTED IN CAR
	if not uimove then
		SendNUIMessage({
			type = "setShow",
			content = false
		})
	end
	uimove = true
	SendNUIMessage({map = true, type = 'sarado'})
	if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
		Citizen.Wait(100)
		start = true
		SendNUIMessage({
			type = "setStart",
			content = start
		})
	end
	--WHEN RESTARTED IN CAR
	local l = 0
	while true do
		ped = PlayerPedId()
		vehicle = GetVehiclePedIsIn(ped)
		if vehicle ~= nil and vehicle ~= 0 then
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
			if not invehicle then
				if GetPedInVehicleSeat(vehicle, -1) == ped and entering then
					breakstart = false
					SetNuiFocus(true, true)
					while not start and not breakstart do
						SetVehicleEngineOn(vehicle,false,true,true)
						if GetVehiclePedIsIn(ped) == 0 then
							start = false
							breakstart = true
						end
						--print("loop not started")
						Citizen.Wait(1)
					end
					start = true
					SetNuiFocus(false,false)
					Citizen.Wait(100)
					SetVehicleEngineOn(vehicle,true,false,true)
					print("starting engine")
					while not GetIsVehicleEngineRunning do
						print("starting")
						SetVehicleEngineOn(vehicle,true,false,true)
						Citizen.Wait(0)
					end
					Citizen.Wait(200)
					start = true
					SendNUIMessage({
						type = "setStart",
						content = start
					})
				end
				Citizen.Wait(200)
				cansmoke = true
				inVehicleFunctions()
				Citizen.Wait(100)
				if manual then
					SendNUIMessage({
						type = "setManual",
						content = true
					})
				end
				SendNUIMessage({
					type = "setDifferential",
					content = GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveBiasFront")
				})
			end
			invehicle = true
		else
			entering = false
			start = false
			invehicle = false
			speed = 0
			rpm = 0
			marcha = 0
			VehIndicatorLight = 0
			--DisplayRadar(false)
			if not uimove then
				Citizen.Wait(500)
				SendNUIMessage({
					type = "setShow",
					content = false
				})
			end
			if ismapopen then
				SendNUIMessage({map = true, type = 'sarado'})
				ismapopen = false
			end
			if manual then
				SendNUIMessage({
					type = "setManual",
					content = false
				})
			end
			Citizen.Wait(1000)
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
		NuiVehicledoorstatus()
		NuiVehicleHandbrake()
		NuiShowMap()
		NuiEngineTemp()
		fuelusagerun()
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
		--TerminateThisThread()
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
		--TerminateThisThread()
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
		--TerminateThisThread()
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
		--TerminateThisThread()
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
		--TerminateThisThread()
	end)

	Citizen.CreateThread(function()
		while invehicle do
			local sleep = config.direction_sleep
			local ped = ped
			local vehicle = vehicle
			local waypoint = GetFirstBlipInfoId(8)
			if vehicle ~= 0 and DoesBlipExist(waypoint) then
				sleep = 0
				local coord = GetEntityCoords(ped, true)
				local x, y, z = table.unpack(GetBlipCoords(waypoint))
				local dis = #(coord - GetBlipCoords(waypoint))
				unusedBool, spawnZ = GetGroundZAndNormalFor_3dCoord(x, y, 9999.0, 1)
				local zsize = dis * 0.5
				if zsize < 2 then
					zsize = 2
				end
				DrawMarker(0,x,y,spawnZ+1.5,0,0,0,0.0,0,0,zsize*0.05,zsize*0.01,zsize+0.0+(zsize*0.45),0,196,255,50,0,0,0,1)
				DrawMarker(22,x,y,spawnZ+zsize+0.0,0,0,0,0.0,0,0,zsize*0.1,zsize*0.1,zsize*0.1,0,196,255,50,0,0,0,1)
			end
			Citizen.Wait(sleep)
		end
		--TerminateThisThread()
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
		--TerminateThisThread()
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
		--TerminateThisThread()
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
						veh_stats[plate].oil = 100
						veh_stats[plate].coolant = 100
					end
					if veh_stats[plate].coolant == nil then
						veh_stats[plate].coolant = 100
					end
					if veh_stats[plate].oil == nil then
						veh_stats[plate].oil = 100
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
		--TerminateThisThread()
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
		--TerminateThisThread()
	end)
end

function NuiVehicledoorstatus()
	--NUI DOOR OPEN STATUS
	Citizen.CreateThread(function()
		Citizen.Wait(1000)
		while invehicle do
			local sleep = 2000
			local ped = ped
			local vehicle = vehicle
			local door = true
			local hood = 0
			local trunk = 0
			if vehicle ~= nil and vehicle ~= 0 then
				----print(GetVehicleDoorStatus(vehicle))
				for i = 0, 6 do
					Wait(10)
					if GetVehicleDoorAngleRatio(vehicle,i) ~= 0.0 then
						door = false
						break
					end
				end
				if door then
					doorstatus = 0
				else
					doorstatus = 2
				end
				if newdoorstatus ~= doorstatus or newdoorstatus == nil then
					newdoorstatus = doorstatus
					SendNUIMessage({
					type = "setDoor",
					content = doorstatus
					})
				end
				if GetVehicleDoorAngleRatio(vehicle,4) ~= 0.0 then
					hood = 2
				end

				if newhood ~= hood or newhood == nil then
					newhood = hood
					SendNUIMessage({
					type = "setHood",
					content = hood
					})
				end

				if GetVehicleDoorAngleRatio(vehicle,5) ~= 0.0 then
					trunk = 2
				end
				if newtrunk ~= trunk or newtrunk == nil then
					newtrunk = trunk
					SendNUIMessage({
					type = "setTrunk",
					content = trunk
					})
				end
			end
			Citizen.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiVehicleHandbrake()
	--NUI HANDBRAKE
	Citizen.CreateThread(function()
		while invehicle do
			local sleep = 2500
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = 500
				local brake = GetVehicleHandbrake(vehicle)
				if newbrake ~= brake or newbrake == nil then
					newbrake = brake
					SendNUIMessage({
					type = "setBrake",
					content = brake
					})
				end
			end
			Citizen.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiShowMap()
	CreateThread(function()
		if config.centercarhud == 'map' then
			Citizen.Wait(1000)
			while not start do
				Citizen.Wait(10)
			end
			SendNUIMessage({map = true, type = 'bukas'})
			ismapopen =  true
			Wait(250)
			while invehicle do
				--print(GetNuiCursorPosition())
				local Plyped = PlayerPedId()
				if start then
					local myh = GetEntityHeading(Plyped) + GetGameplayCamRelativeHeading()
					local camheading = GetGameplayCamRelativeHeading()
					local xz, yz, zz = table.unpack(GetEntityCoords(Plyped))
					if oldxz ~= xz or oldcamheading ~= camheading or camheading == nil and xz == nil then
						oldcamheading = camheading
						oldxz = xz
						SendNUIMessage({map = true, type = "updatemapa",myheading = myh,camheading = camheading,x = xz,y = yz,})
					end
				end
				Wait(200)
			end
			--TerminateThisThread()
		end
	end)
end

lastveh = nil
cansmoke = true

RegisterNetEvent('start:smoke')
AddEventHandler('start:smoke', function(ent,coord)
	local mycoord = GetEntityCoords(ped,false)
	local dis = #(mycoord - coord)
	local ent = ent
	if dis < 100 then --SILLY WAY TO AVOID ONE SYNC INFINITY ISSUE, you can input < 200 up to 400 radius, yes its 400 not 300
		StartSmoke(ent)
	end
end)

refresh = false

function getveh()
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	if v == 0 then
		v = GetPlayersLastVehicle()
		print("last veh")
	end
	if v == 0 then
		v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
		print("NEAR VEH")
	end
	print(v)
	return tonumber(v)
end

RegisterCommand('testsmoke', function(source, args, raw)
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) + config.addheat)
	Citizen.Wait(100)
	StartSmoke(getveh())
end)

function LoadPTFX(lib)
	UseParticleFxAsset(lib)
	if not HasNamedPtfxAssetLoaded(lib) then
    	RequestNamedPtfxAsset(lib)
	end
    while not HasNamedPtfxAssetLoaded(lib) do
        Wait(10)
    end
end

local smokes = {}

function StartSmoke(ent)
    Citizen.CreateThread(function()
		local ent = ent
		print(GetVehicleEngineTemperature(ent))
		while GetVehicleEngineTemperature(ent) > config.overheatmin do
			local Smoke = 0
			local part1 = false
			Citizen.CreateThread(function()
				LoadPTFX('core')
				Smoke = Citizen.InvokeNative(0xDDE23F30CC5A0F03, 'ent_amb_stoner_vent_smoke', ent, 0.05, 0, 0, 0, 0, 0, 28, 0.4, false, false, false, 0, 0, 0, 0)
				RemoveNamedPtfxAsset("core")
				print("start shit")
				print(Smoke)
				part1 = true
			end)
			while not part1 do
				Citizen.Wait(1011)
			end
			Citizen.Wait(400)
			table.insert(smokes, {handle = Smoke})
			removeFCK()
			Citizen.Wait(500)
			print("waiting for Particles to gone")
		end
		refresh = false
		Citizen.Wait(5000)
    end)
end

function removeFCK()
	Citizen.CreateThread(function()
		for _,parts in pairs(smokes) do
			print("removing "..parts.handle.."")
			if parts.handle ~= nil and parts.handle ~= 0 and isparticleexist(parts.handle) then
				print("deleted "..parts.handle.."")
				stopparticles(parts.handle, true)
				-- Wait(0)
				--RemoveParticleFx(parts.handle, true)
				smokes[_].handle = nil
				smokes[_] = nil
			else
				print("checking "..parts.handle.."")
				--Citizen.InvokeNative(0x8F75998877616996, parts.handle, 0)
				--stopparticles(parts.handle, true)
				smokes[_] = nil
				--RemoveParticleFxFromEntity(getveh())
			end
		end
		smokes = {}
	end)
end

local useshit = GetHashKey('USE_PARTICLE_FX_ASSET') & 0x9C720B61
function usefuckingshit(val)
    return Citizen.InvokeNative(0x6C38AF3693A69A91, val)
end

function isparticleexist(val)
    return Citizen.InvokeNative(0x74AFEF0D2E1E409B, val)
end

function stopparticles(val,bool)
    return Citizen.InvokeNative(0x8F75998877616996, val, 0)
end

local shitfuck = GetHashKey('START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE') & 0xF478EFCF
function startfuckingbullshit(effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3)
    return Citizen.InvokeNative(0xDDE23F30CC5A0F03, effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3, 0, 0, 0, 0)
end

local triggered = false
function NuiEngineTemp()
	--NUI ENGINE TEMPERATURE STATUS
	Citizen.CreateThread(function()
		local newtemp = 0
		if GetVehicleEngineTemperature(vehicle) < config.overheatmin then
			RemoveParticleFxFromEntity(vehicle)
		end
		--PREVENT PLAYER VEHICLE FOR STARTING UP A VERY HOT ENGINE
		local toohot = false
		Citizen.CreateThread(function()
			while GetVehicleEngineTemperature(vehicle) > config.overheatmin and invehicle do
				--print("still hot")
				toohot = true
				SetVehicleCurrentRpm(vehicle, 0.0)
				SetVehicleEngineOn(vehicle,false,true,true)
				Citizen.Wait(0)
			end
			-- IF ENGINE IS OKAY REPEAT BELOW LOOP IS BROKEN DUE TO toohot boolean
			if toohot and GetVehicleEngineTemperature(vehicle) < config.overheatmin then
				NuiEngineTemp()
				--TerminateThisThread()
			end
		end)
		Citizen.Wait(1000)
		--triggered = false
		while invehicle and not toohot do
			local sleep = 2000
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = 1000
				local temp = GetVehicleEngineTemperature(vehicle)
				local overheat = false
				while rpm > config.dangerrpm and config.engineoverheat do
					rpm = GetVehicleCurrentRpm(vehicle)
					Citizen.Wait(1000)
					SetVehicleEngineCanDegrade(vehicle, true)
					SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.addheat)
					if newtemp ~= enginetemp or newtemp == nil then
						newtemp = temp
						SendNUIMessage({
						type = "setTemp",
						content = GetVehicleEngineTemperature(vehicle)
						})
						if GetVehicleEngineTemperature(vehicle) >= config.overheatmin then
							explosion = 0
							explode = PlaySoundFromEntity(GetSoundId(), "Engine_fail", vehicle, "DLC_PILOT_ENGINE_FAILURE_SOUNDS", 0, 0)
							SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.overheatadd)
							if not triggered then
								triggered = true
								TriggerServerEvent("renzu_hud:smokesync", vehicle, GetEntityCoords(vehicle,false))
							end
							while explosion < 500 do
								--print("explode")
								SetVehicleCurrentRpm(vehicle, 0.0)
								SetVehicleEngineOn(vehicle,false,true,true)
								explosion = explosion + 1
								Citizen.Wait(0)
							end
							--removeFCK()
							Citizen.Wait(500)
							smokeonhood = false
							if not overheat then
								overheat = true
								Citizen.CreateThread(function()
										Citizen.Wait(5000)
										if vehicle == 0 then
											vehicle = GetVehiclePedIsIn(ped,true)
										end
										Citizen.Wait(1000)
										SetVehicleEngineOn(vehicle,false,true,true)
										if cansmoke and invehicle then
											--StartSmoke(vehicle)
										end
									--end
									Citizen.Wait(1000)
									smokeonhood = true
									--TerminateThisThread()
								end)
							end
							explosion = 0
							Citizen.Wait(3000)
							if GetVehicleEngineTemperature(vehicle) < config.overheatmin then
								StopSound(explode)
								ReleaseSoundId(explode)
							end
						end
					end
					--print(temp)
				end
				--print(temp)
				if newtemp ~= enginetemp or newtemp == nil then
					newtemp = temp
					SendNUIMessage({
					type = "setTemp",
					content = temp
					})
				end
			end
			Citizen.Wait(sleep)
		end
		Citizen.Wait(2000)
		while invehicle do
			Citizen.Wait(111)
		end
		Citizen.Wait(1000)
		overheatoutveh = false
		--removeFCK()
		Citizen.Wait(1000)
		Citizen.CreateThread(function()
			while GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)) > config.overheatmin and not toohot do
				overheatoutveh = true
				while not smokeonhood do
					Citizen.Wait(111)
				end
				vehicle = GetVehiclePedIsIn(ped,true)
				print("SMOKING")
				local done = false
				Citizen.Wait(5000)
				Notify("Engine Temp: "..GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)).."")
				Citizen.Wait(1000)
			end
			overheatoutveh = false
			--TerminateThisThread()
		end)
		Citizen.Wait(2000)
		while overheatoutveh do
			Citizen.Wait(100)
		end
		local cleanup = false
		--removeFCK()
		if not cleanup then
			--RemoveParticleFxFromEntity(vehicle)
		end
		refresh = true
		--RemoveParticleFxInRange(GetWorldPositionOfEntityBone(GetVehiclePedIsIn(ped,true), 28),20.0)
		--RemoveParticleFxFromEntity(getveh())
		Citizen.Wait(2000)
		triggered = false
		--TerminateThisThread()
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
	Citizen.Wait(1000)
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

RegisterCommand(config.commands['entering'], function()
	local p = PlayerPedId()
	v = GetVehiclePedIsEntering(p)
	local mycoords = GetEntityCoords(p)
	if not IsPedInAnyVehicle(p) and IsAnyVehicleNearPoint(mycoords.x,mycoords.y,mycoords.z,10.0) then
		print("ENTERING")
		while GetVehiclePedIsTryingToEnter(p) == 0 do
			v = GetVehiclePedIsTryingToEnter(p)
			Citizen.Wait(0)
		end
		local count = 0
		while not IsPedInAnyVehicle(p) and not start and count < 400 do
			Citizen.Wait(1)
			count = count + 1
			--print(count)
			SetVehicleEngineOn(v,false,true,true)
			--print("waiting to get in")
			if GetVehiclePedIsTryingToEnter(p) ~= 0 then
				v = GetVehiclePedIsTryingToEnter(p)
			end
		end
		print("clear")
		print(v)
		print(GetPedInVehicleSeat(v, -1))
		print(p)
		if GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) then
			entering = true
			print("Disable auto start")
			SetVehicleEngineOn(v,false,true,true)
			while not start and IsPedInAnyVehicle(p) do
				if not start and IsVehicleEngineStarting(v) then
					SetVehicleEngineOn(v,false,true,true)
					print("not started yet")
				end
				Citizen.Wait(0)
			end
		end
	elseif start and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 or manual and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 then
		if start then
			SendNUIMessage({
				type = "setStart",
				content = false
			})
		end
		if manual then
			SendNUIMessage({
				type = "setManual",
				content = false
			})
		end
		SendNUIMessage({
			type = "setShow",
			content = false
		})
		if ismapopen then
			SendNUIMessage({map = true, type = 'sarado'})
			ismapopen = false
		end
		while IsPedInAnyVehicle(ped, false) do
			Citizen.Wait(11)
		end
		invehicle = false
	end
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['entering'], 'Enter Vehicle', 'keyboard', config.keybinds['entering'])
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

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

local turbo = config.boost

function turbolevel(value, lvl)
    if value > lvl then
        return lvl
    end
    return value
end

function max(boost, rpm)
    if boost > 3.0 then
        boost = 3.0
    end
    if boost < 0.0 then
        return 0.0
    end
    return turbolevel(boost, turbo)

end

local mode = 'NORMAL'

function Round(num,numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function Fuel(vehicle)
	if IsVehicleEngineOn(vehicle) then
		local rpm = GetVehicleCurrentRpm(vehicle)
		local gear = GetVehicleCurrentGear(vehicle)
		local engineload = (rpm * (gear / 10))
		local result = (config.fuelusage[Round(GetVehicleCurrentRpm(vehicle),1)] * (config.classes[GetVehicleClass(vehicle)] or 1.0) / 15)
		local advformula = result + (result * engineload)
		if mode == 'SPORTS' then
			advformula = advformula * config.boost
		end
		if mode == 'ECO' then
			advformula = advformula * config.eco
		end
		--print("FUEL USAGE: "..result..", ADV: "..advformula.." EngineLoad: "..engineload.."")
		SetVehicleFuelLevel(vehicle,GetVehicleFuelLevel(vehicle) - advformula)
		DecorSetFloat(vehicle,config.fueldecor,GetVehicleFuelLevel(vehicle))
	end
end

local regdecor = false
function fuelusagerun()
	Citizen.CreateThread(function()
		if config.usecustomfuel then
			if not regdecor then
				regdecor = true
				DecorRegister(config.fueldecor,1)
			end
			while invehicle do
				Citizen.Wait(2000)
				local ped = ped
				if GetPedInVehicleSeat(vehicle,-1) == ped then
					Fuel(vehicle)
				end
			end
		end
	end)
end

function turboboost(gear)
	local engineload = 0.05
	if gear == 1 then
		engineload = 0.05
	elseif gear == 2 then
		engineload = 0.15
	elseif gear == 3 then
		engineload = 0.22
	elseif gear == 4 then
		engineload = 0.275
	elseif gear == 5 then
		engineload = 0.3
	elseif gear == 6 then
		engineload = 0.5
	end
	return engineload 
end

local busy = false
function vehiclemode()
	PlaySoundFrontend(PlayerId(), 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
	if mode == 'NORMAL' then
		mode = 'SPORTS'
		SendNUIMessage({
			type = "setMode",
			content = mode
		})
		Citizen.Wait(500)
		while busy do
			Citizen.Wait(10)
		end
		local rpm = GetVehicleCurrentRpm(vehicle)
		local gear = GetVehicleCurrentGear(vehicle)
		Citizen.CreateThread(function()
			local newgear = 0
			while mode == 'SPORTS' do
				local sleep = 2000
				--local ply = PlayerPedId()
				local vehicle = vehicle
				if vehicle ~= 0 then
					sleep = 10
					rpm = GetVehicleCurrentRpm(vehicle)
					gear = GetVehicleCurrentGear(vehicle)
				end
				Citizen.Wait(sleep)
			end
		end)

		local sound = false
		Citizen.CreateThread(function()
			local newgear = 0
			olddriveinertia = GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia")
			oldriveforce = GetVehicleHandlingFloat(vehicle, "CHandlingData","fInitialDriveForce")
			DecorSetFloat(vehicle, "INERTIA", olddriveinertia)
			DecorSetFloat(vehicle, "DRIVEFORCE", oldriveforce)
			while mode == 'SPORTS' do
				local sleep = 2000
				--local ply = PlayerPedId()
				local reset = true
				local vehicle = vehicle
				if vehicle ~= 0 then
					sleep = 7
					-- if newgear ~= gear then -- emulation CLUTCH delay
					-- 	SetVehicleClutch(vehicle,0.5)
					-- 	Citizen.Wait(1)
					-- 	SetVehicleClutch(vehicle,0.0)
					-- end
					newgear = gear
					local vehicleSpeed = 0
					local engineload = (rpm * (gear / 10))
					if rpm > 1.15 then
					else
						rpm = rpm * turbo
					end
					local vehicleSpeed = GetVehicleTurboPressure(vehicle)
					--local speed = GetEntitySpeed(vehicle) * 3.6
					if sound and IsControlJustReleased(1, 32) then
						StopSound(soundofnitro)
						ReleaseSoundId(soundofnitro)
						sound = false
					end

					local lag = 0
					if IsControlPressed(1, 32) then
						while lag < 200 and engineload < turboboost(gear) and IsControlPressed(1, 32) do
							engineload = (rpm * (gear / 10))
							SetVehicleTurboPressure(vehicle, max((rpm * 1) + engineload + (lag * engineload)))
							Citizen.Wait(1)
							lag = lag + 1
						end
						if not sound then
							soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
							sound = true
						end
					else
						if sound then
							StopSound(soundofnitro)
							ReleaseSoundId(soundofnitro)
							sound = false
						end
						Citizen.Wait(500) -- TURBO LAG
					end
					if reset and not IsControlPressed(1, 32) then
						SetVehicleTurboPressure(vehicle, 0)
					end
					vehicleSpeed = GetVehicleTurboPressure(vehicle)
					if gear == 0 then
						gear = 1
					end
					local boost = vehicleSpeed * 7
					if IsControlPressed(1, 32) and GetVehicleCurrentRpm(vehicle) > 0.4 and vehicleSpeed > (turbo / 2) then
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", boost / 10)
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", engineload)
						SetVehicleCheatPowerIncrease(vehicle, boost)
					end
				end
				Citizen.Wait(sleep)
			end
			busy = true
			Citizen.Wait(100)
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				Citizen.Wait(0)
			end
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fInitialDriveForce") == DecorGetFloat(vehicle,"DRIVEFORCE") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
				Citizen.Wait(0)
			end
			busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
		end)
	elseif mode == 'SPORTS' then
		mode = 'ECO'
		SendNUIMessage({
			type = "setMode",
			content = mode
		})
		Citizen.Wait(500)
		while busy do
			Citizen.Wait(10)
		end
		local sound = false
		Citizen.CreateThread(function()
			local olddriveinertia = 1.0
			olddriveinertia = GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia")
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", config.eco)
			while mode == 'ECO' do
				local sleep = 2000
				--local ply = PlayerPedId()
				local reset = true
				local vehicle = vehicle
				if vehicle ~= 0 then
					sleep = 7
					if IsControlPressed(1, 32) then
					SetVehicleCheatPowerIncrease(vehicle, config.eco+0.4)
					end
				end
				Citizen.Wait(sleep)
			end
			busy = true
			Citizen.Wait(100)
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				Citizen.Wait(0)
			end
			busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
		end)
	else
		mode = 'NORMAL'
		SendNUIMessage({
			type = "setMode",
			content = mode
		})
	end
end

RegisterCommand(config.commands['mode'], function()
	vehiclemode()
end, false)

Citizen.CreateThread(function()
	mode = 'NORMAL'
	RegisterKeyMapping(config.commands['mode'], 'Vehicle Mode', 'keyboard', config.keybinds['mode'])
end)

local old_diff = nil
local togglediff = false
function differential()
	print("pressed")
	local diff = GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveBiasFront")
	print(diff)
	if diff > 0.01 and diff < 0.9 and old_diff == nil and not togglediff then -- default 4wd
		old_diff = diff -- save old
		diff = 0.0 -- change to rearwheel
		togglediff = true
	elseif old_diff ~= nil and togglediff then
		diff = old_diff
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", diff)
		togglediff = false
		old_diff = nil
	elseif diff == 1.0 and not togglediff and old_diff == nil then -- Front Wheel Drive
		print("FWD")
		diff =  0.5
		old_diff = 1.0
		togglediff = true
	elseif diff == 0.0 and not togglediff and old_diff == nil then -- Rear Wheel Drive
		old_diff = 0.0
		diff = 0.5
		togglediff = true
	end
	if togglediff then
		PlaySoundFrontend(PlayerId(), 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
	else
		PlaySoundFrontend(PlayerId(), 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
	end
	SendNUIMessage({
		type = "setDifferential",
		content = diff
	})
	Citizen.Wait(500)
	Citizen.CreateThread(function()
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", diff)
		while togglediff and invehicle do
			Citizen.Wait(1000)
		end
		Citizen.Wait(300)
		if not invehicle then
			togglediff = false
			old_diff = 0
		end
	end)
	
end

RegisterCommand(config.commands['differential'], function()
	differential()
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping(config.commands['differential'], '4WD Mode', 'keyboard', config.keybinds['differential'])
end)

function Notify(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

--ETC

local minimap
Citizen.CreateThread(function()
	local count = 0
	while not playerloaded or count < 5 do -- REAL WAY TO REMOVE HEALTHBAR AND ARMOR WITHOUT USING THE LOOP ( LOAP minimap.gfx first ) then on spawn load the circlemap
		count = count + 1
		Citizen.Wait(1000)
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
		Citizen.Wait(100)
		SetRadarBigmapEnabled(false, false)
	end
end)

Citizen.CreateThread(function()
	if config.removemaphealthandarmor or config.useminimapeverytime then
		while true do
			Citizen.Wait(0)
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
end)