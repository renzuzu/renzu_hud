ESX = nil
Creation(function()
	if config.framework == 'ESX' then
		while ESX == nil do
			ClientEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Renzuzu.Wait(0)
		end

		while ESX.GetPlayerData().job == nil do
			Renzuzu.Wait(0)
		end

		ESX.PlayerData = ESX.GetPlayerData()
		xPlayer = ESX.GetPlayerData()
		Renzuzu.Wait(5000)
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
mode = 'NORMAL'
ismapopen = false
date = "00:00"
plate = nil
degrade = 1.0
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
		RenzuSendUI({
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
	setVoice()
	RenzuSendUI({
		type = "setMic",
		content = voiceDisplay
	})
end, false)

Creation(function()
	RenzuKeybinds(config.commands['voip'], 'Voice Proximity', 'keyboard', config.keybinds['voip'])
end)

local newfreq = nil
RenzuNetEvent("radio:freq")
RenzuEventHandler("radio:freq", function(freq)
		if newfreq ~= freq or newfreq == nil then
		RenzuSendUI({
		type = "setRadio",
		content = freq
		})
		newfreq = freq
		end
end)

local pedshot = false

Creation(function()
	if config.framework == 'ESX' then
		RenzuNetEvent('esx:playerLoaded')
		RenzuEventHandler('esx:playerLoaded', function(xPlayer)
			playerloaded = true
			Renzuzu.Wait(2000)
			TriggerServerEvent("renzu_hud:getmile")
		end)
	else
		RenzuNetEvent('playerSpawned')
		RenzuEventHandler('playerSpawned', function(spawn)
			playerloaded = true
			Renzuzu.Wait(2000)
			TriggerServerEvent("renzu_hud:getmile")	
		end)
	end
end)


--- NEW HUD FUNC

RenzuNuiCallback('requestface', function(data, cb)
	while not playerloaded do
		Renzuzu.Wait(1000)
	end
	Renzuzu.Wait(5000)
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
		Renzuzu.Wait(111)
	end
	status = {
		stress = tonumber(sanity),
		oxygen = oxygen,
		thirst = tonumber(thirst),
		hunger = hunger,
		energy = energy,
		stamina = stamina
	}
	RenzuSendUI({
		type = "setStatus",
		content = status
	})
end

	Creation(function()
		Renzuzu.Wait(1000)
		RenzuSendUI({
			type = "setShowstatusv2",
			content = config.statusv2
		})
		if config.statusv2 then
			while true do
				local sleep = config.statusv2_sleep
				updateStatus()
				Renzuzu.Wait(sleep)
			end
		end
	end)

RenzuCommand(config.commands['showstatus'], function()
	show = not show
	updateStatus(true)
    PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	RenzuSendUI({
		type = "setShowstatus",
		content = show
	})
end, false)

Creation(function()
	RenzuKeybinds(config.commands['showstatus'], 'HUD Status UI', 'keyboard', config.keybinds['showstatus'])
end)

start = false
breakstart = false

RenzuNuiCallback('pushtostart', function(data, cb)
	start = true
	breakstart = false
end)

RenzuNuiCallback('getoutvehicle', function(data, cb)
	start = false
	breakstart = false
	SetNuiFocus(false,false)
	TaskLeaveVehicle(ped,vehicle,0)
end)

Creation(function()
	Renzuzu.Wait(3000)
	--WHEN RESTARTED IN CAR
	if not uimove then
		RenzuSendUI({
			type = "setShow",
			content = false
		})
	end
	uimove = true
	RenzuSendUI({map = true, type = 'sarado'})
	if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
		Renzuzu.Wait(100)
		start = true
		RenzuSendUI({
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
			plate = tostring(GetVehicleNumberPlateText(vehicle))
			hp = GetVehicleEngineHealth(vehicle)
			gasolina = GetVehicleFuelLevel(vehicle)
			if uimove then
				Renzuzu.Wait(1500)
				RenzuSendUI({
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
						Renzuzu.Wait(1)
					end
					start = true
					SetNuiFocus(false,false)
					Renzuzu.Wait(100)
					SetVehicleEngineOn(vehicle,true,false,true)
					print("starting engine")
					while not GetIsVehicleEngineRunning do
						print("starting")
						SetVehicleEngineOn(vehicle,true,false,true)
						Renzuzu.Wait(0)
					end
					Renzuzu.Wait(200)
					start = true
					RenzuSendUI({
						type = "setStart",
						content = start
					})
				end
				Renzuzu.Wait(200)
				cansmoke = true
				inVehicleFunctions()
				Renzuzu.Wait(100)
				if manual then
					RenzuSendUI({
						type = "setManual",
						content = true
					})
				end
				RenzuSendUI({
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
				Renzuzu.Wait(500)
				RenzuSendUI({
					type = "setShow",
					content = false
				})
			end
			if ismapopen then
				RenzuSendUI({map = true, type = 'sarado'})
				ismapopen = false
			end
			if manual then
				RenzuSendUI({
					type = "setManual",
					content = false
				})
			end
			Renzuzu.Wait(1000)
			uimove = true
		end
		Renzuzu.Wait(config.car_mainloop_sleep)
	end
end)

--ASYNC FUNCTION CALL VEHICLE LOOPS
function inVehicleFunctions()
	Creation(function()
		while not invehicle do
			Renzuzu.Wait(1) -- lets wait invehicle to = true
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
	Creation(function()
		while ESX == nil do
			Renzuzu.Wait(2000)
		end
		while ped == nil do
			Renzuzu.Wait(1000)
		end
		while invehicle do
			local sleep = 2000
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.rpm_speed_loop
				rpm = GetVehicleCurrentRpm(vehicle)
				speed = GetEntitySpeed(vehicle)
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiRpm()
	Creation(function()
		while ESX == nil do
			Renzuzu.Wait(2000)
		end
		while ped == nil do
			Renzuzu.Wait(1000)
		end
		while invehicle do
			local sleep = 2500
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.Rpm_sleep
				if rpm < 0.21 then
				Renzuzu.Wait(config.idle_rpm_speed_sleep)
				end
				if newrpm ~= rpm or newrpm == nil then
					newrpm = rpm
					RenzuSendUI({
						type = "setRpm",
						content = rpm
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "setRpm",
						content = rpm
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "setRpm",
						content = rpm
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "setRpm",
						content = rpm
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiSpeed()
	Creation(function()
		while ESX == nil do
			Renzuzu.Wait(2000)
		end
		while ped == nil do
			Renzuzu.Wait(1000)
		end
		while invehicle do
			local sleep = 2500
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.Speed_sleep
				if rpm < 0.21 then
				Renzuzu.Wait(config.idle_rpm_speed_sleep)
				end
				if newspeed ~= speed or newspeed == nil then
					newspeed = speed
					RenzuSendUI({
						type = "setSpeed",
						content = speed
					})
					Renzuzu.Wait(config.Speed_sleep_2)
					RenzuSendUI({
						type = "setSpeed",
						content = speed
					})
					Renzuzu.Wait(config.Speed_sleep_2)
					RenzuSendUI({
						type = "setSpeed",
						content = speed
					})
					Renzuzu.Wait(config.Speed_sleep_2)
					RenzuSendUI({
						type = "setSpeed",
						content = speed
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiCarhpandGas()
	Creation(function()
		while ESX == nil do
			Renzuzu.Wait(2000)
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
					RenzuSendUI({
						type = "setFuelLevel",
						content = gasolina
					})
					newgas = gasolina
				end
				if newcarhealth ~= hp or newcarhealth == nil then
					RenzuSendUI({
						hud = "setCarhp",
						content = hp
					})
					newcarhealth = hp
				end
			end
			Renzuzu.Wait(wait)
		end
		--TerminateThisThread()
	end)
end

function NuiDistancetoWaypoint()
	--NUI DISTANCE to Waypoint
	Creation(function()
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
					RenzuSendUI({
					type = "setWaydistance",
					content = dis
					})
				end
			elseif vehicle ~=0 and not DoesBlipExist(waypoint) then
				--if newdis ~= dis or newdis == nil then
					newdis = 0
					RenzuSendUI({
					type = "setWaydistance",
					content = 0
					})
				--end
				Renzuzu.Wait(config.direction_sleep)
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)

	Creation(function()
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
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiHeadlights()
	--NUI HEAD LIGHTS
	Creation(function()
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
					RenzuSendUI({
					type = "setHeadlights",
					content = light
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiGear()
	--NUI GEAR STATUS
	Creation(function()
		while invehicle do
			local sleep = 2500
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.gear_sleep
				local gear = GetVehicleCurrentGear(vehicle)
				if newgear ~= gear or newgear == nil then
					newgear = gear
					RenzuSendUI({
					type = "setGear",
					content = gear
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
		print("GEAR LOOP ENDED")
	end)
end

function NuiMileAge()
	local lastve = nil
	local savemile = false
	local saveplate = nil
	Creation(function()
		local count = 0
		while not playerloaded and count < 3 do
			Renzuzu.Wait(1000)
			count = count + 1
		end
		if not playerloaded then
			TriggerServerEvent("renzu_hud:getmile")
		end
		Renzuzu.Wait(5000)
		Creation(function()
			while veh_stats[plate] == nil and invehicle do
				Renzuzu.Wait(100)
			end
			while invehicle do
				local wait = 10000
				local mileage = veh_stats[plate].mileage
				degrade = 1.0
				if mileage >= config.mileagemax then
					wait = 1
					--print(mileage)
					degrade = config.degrade_engine
					while mode == 'SPORTS' or mode == 'ECO' do
						wait = 1000
						if not invehicle then
							break
						end
						degrade = config.degrade_engine
						Renzuzu.Wait(wait)
					end
					SetVehicleBoost(vehicle, config.degrade_engine)
				end
				Renzuzu.Wait(wait)
			end
		end)
		while invehicle do
			Renzuzu.Wait(config.mileage_update)
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
						veh_stats[plate].mileage = 10000
						veh_stats[plate].oil = 100
						veh_stats[plate].coolant = 100
					end
					if veh_stats[plate].coolant == nil then
						veh_stats[plate].coolant = 100
					end
					if veh_stats[plate].oil == nil then
						veh_stats[plate].oil = 100
					end
					--print(veh_stats[plate].coolant)
					if plate ~= nil and veh_stats[plate].plate == plate then
						if oldPos == nil then
							oldPos = newPos
						end
						local dist = #(newPos-oldPos)
						if dist > 10.0 then
							veh_stats[plate].mileage = veh_stats[plate].mileage+(( dist / 1000 ) * config.mileage_speed) -- dist = meter / 1000 = kmh, this might be inaccurate
							oldPos = newPos
						end
						if newmileage ~= veh_stats[plate].mileage or newmileage == nil then
							newmileage = veh_stats[plate].mileage
							RenzuSendUI({
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
	Creation(function()
		while invehicle do
			local sleep = 2000
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = 1000
				CalculateTimeToDisplay()
				CalculateDateToDisplay()
				timeformat()
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiVehicledoorstatus()
	--NUI DOOR OPEN STATUS
	Creation(function()
		Renzuzu.Wait(1000)
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
					RenzuSendUI({
					type = "setDoor",
					content = doorstatus
					})
				end
				if GetVehicleDoorAngleRatio(vehicle,4) ~= 0.0 then
					hood = 2
				end

				if newhood ~= hood or newhood == nil then
					newhood = hood
					RenzuSendUI({
					type = "setHood",
					content = hood
					})
				end

				if GetVehicleDoorAngleRatio(vehicle,5) ~= 0.0 then
					trunk = 2
				end
				if newtrunk ~= trunk or newtrunk == nil then
					newtrunk = trunk
					RenzuSendUI({
					type = "setTrunk",
					content = trunk
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiVehicleHandbrake()
	--NUI HANDBRAKE
	Creation(function()
		while invehicle do
			local sleep = 2500
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = 500
				local brake = GetVehicleHandbrake(vehicle)
				if newbrake ~= brake or newbrake == nil then
					newbrake = brake
					RenzuSendUI({
					type = "setBrake",
					content = brake
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
	end)
end

function NuiShowMap()
	CreateThread(function()
		if config.centercarhud == 'map' then
			Renzuzu.Wait(1000)
			while not start do
				Renzuzu.Wait(10)
			end
			RenzuSendUI({map = true, type = 'bukas'})
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
						RenzuSendUI({map = true, type = "updatemapa",myheading = myh,camheading = camheading,x = xz,y = yz,})
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

RenzuNetEvent('start:smoke')
RenzuEventHandler('start:smoke', function(ent,coord)
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

RenzuCommand('testsmoke', function(source, args, raw)
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) + config.addheat)
	Renzuzu.Wait(100)
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
    Creation(function()
		local ent = ent
		print(GetVehicleEngineTemperature(ent))
		while GetVehicleEngineTemperature(ent) > config.overheatmin do
			local Smoke = 0
			local part1 = false
			Creation(function()
				LoadPTFX('core')
				Smoke = Renzu_Hud(0xDDE23F30CC5A0F03, 'ent_amb_stoner_vent_smoke', ent, 0.05, 0, 0, 0, 0, 0, 28, 0.4, false, false, false, 0, 0, 0, 0)
				RemoveNamedPtfxAsset("core")
				print("start shit")
				print(Smoke)
				part1 = true
			end)
			while not part1 do
				Renzuzu.Wait(1011)
			end
			Renzuzu.Wait(400)
			table.insert(smokes, {handle = Smoke})
			removeFCK()
			Renzuzu.Wait(500)
			print("waiting for Particles to gone")
		end
		refresh = false
		Renzuzu.Wait(5000)
    end)
end

function removeFCK()
	Creation(function()
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
				--Renzu_Hud(0x8F75998877616996, parts.handle, 0)
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
    return Renzu_Hud(0x6C38AF3693A69A91, val)
end

function isparticleexist(val)
    return Renzu_Hud(0x74AFEF0D2E1E409B, val)
end

function stopparticles(val,bool)
    return Renzu_Hud(0x8F75998877616996, val, 0)
end

local shitfuck = GetHashKey('START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE') & 0xF478EFCF
function startfuckingbullshit(effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3)
    return Renzu_Hud(0xDDE23F30CC5A0F03, effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3, 0, 0, 0, 0)
end

local triggered = false
function NuiEngineTemp()
	--NUI ENGINE TEMPERATURE STATUS
	Creation(function()
		print(plate)
		while veh_stats[plate] == nil do
			Renzuzu.Wait(100)
		end
		local newtemp = 0
		if GetVehicleEngineTemperature(vehicle) < config.overheatmin then
			RemoveParticleFxFromEntity(vehicle)
		end
		--PREVENT PLAYER VEHICLE FOR STARTING UP A VERY HOT ENGINE
		local toohot = false
		Creation(function()
			while GetVehicleEngineTemperature(vehicle) > config.overheatmin and invehicle do
				--print("still hot")
				toohot = true
				SetVehicleCurrentRpm(vehicle, 0.0)
				SetVehicleEngineOn(vehicle,false,true,true)
				Renzuzu.Wait(0)
			end
			-- IF ENGINE IS OKAY REPEAT BELOW LOOP IS BROKEN DUE TO toohot boolean
			if toohot and GetVehicleEngineTemperature(vehicle) < config.overheatmin then
				NuiEngineTemp()
				--TerminateThisThread()
			end
		end)
		Renzuzu.Wait(1000)
		--triggered = false
		while invehicle and not toohot do
			local sleep = 2000
			local ped = ped
			local vehicle = vehicle
			if vehicle ~= nil and vehicle ~= 0 then
				--print(veh_stats[plate].coolant)
				sleep = 1000
				local temp = GetVehicleEngineTemperature(vehicle)
				local overheat = false
				while rpm > config.dangerrpm and config.engineoverheat do
					rpm = GetVehicleCurrentRpm(vehicle)
					Renzuzu.Wait(1000)
					SetVehicleEngineCanDegrade(vehicle, true)
					SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.addheat)
					if newtemp ~= enginetemp or newtemp == nil then
						newtemp = temp
						RenzuSendUI({
						type = "setTemp",
						content = GetVehicleEngineTemperature(vehicle)
						})
						if GetVehicleEngineTemperature(vehicle) >= config.overheatmin and veh_stats[plate].coolant ~= nil and veh_stats[plate].coolant <= 20 then
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
								Renzuzu.Wait(0)
							end
							--removeFCK()
							Renzuzu.Wait(500)
							smokeonhood = false
							if not overheat then
								overheat = true
								Creation(function()
										Renzuzu.Wait(5000)
										if vehicle == 0 then
											vehicle = GetVehiclePedIsIn(ped,true)
										end
										Renzuzu.Wait(1000)
										SetVehicleEngineOn(vehicle,false,true,true)
										if cansmoke and invehicle then
											--StartSmoke(vehicle)
										end
									--end
									Renzuzu.Wait(1000)
									smokeonhood = true
									--TerminateThisThread()
								end)
							end
							explosion = 0
							Renzuzu.Wait(3000)
							if GetVehicleEngineTemperature(vehicle) < config.overheatmin then
								StopSound(explode)
								ReleaseSoundId(explode)
							end
						elseif GetVehicleEngineTemperature(vehicle) >= config.overheatmin and (veh_stats[plate].coolant ~= nil and veh_stats[plate].coolant >= 20) then
							veh_stats[plate].coolant = veh_stats[plate].coolant - config.reduce_coolant
							RenzuSendUI({
								type = "setCoolant",
								content = veh_stats[plate].coolant
							})
						end
					end
					--print(temp)
				end
				--print(temp)
				if newtemp ~= enginetemp or newtemp == nil then
					newtemp = temp
					RenzuSendUI({
						type = "setTemp",
						content = temp
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		Renzuzu.Wait(2000)
		while invehicle do
			Renzuzu.Wait(111)
		end
		Renzuzu.Wait(1000)
		overheatoutveh = false
		--removeFCK()
		Renzuzu.Wait(1000)
		Creation(function()
			while GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)) > config.overheatmin and not toohot do
				overheatoutveh = true
				while not smokeonhood do
					Renzuzu.Wait(111)
				end
				vehicle = GetVehiclePedIsIn(ped,true)
				print("SMOKING")
				local done = false
				Renzuzu.Wait(5000)
				Notify("Engine Temp: "..GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)).."")
				Renzuzu.Wait(1000)
			end
			overheatoutveh = false
			--TerminateThisThread()
		end)
		Renzuzu.Wait(2000)
		while overheatoutveh do
			Renzuzu.Wait(100)
		end
		local cleanup = false
		--removeFCK()
		if not cleanup then
			--RemoveParticleFxFromEntity(vehicle)
		end
		refresh = true
		--RemoveParticleFxInRange(GetWorldPositionOfEntityBone(GetVehiclePedIsIn(ped,true), 28),20.0)
		--RemoveParticleFxFromEntity(getveh())
		Renzuzu.Wait(2000)
		triggered = false
		--TerminateThisThread()
	end)
end

function Myinfo()
	if config.framework == 'ESX' then
		ClientEvent('esx:getSharedObject', function(obj) ESX = obj end)
		while ESX == nil do
			ClientEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Renzuzu.Wait(0)
		end

		while ESX.GetPlayerData().job == nil do
			Renzuzu.Wait(0)
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
		RenzuSendUI({
			hud = "setInfo",
			content = info
		})
	end
end

Creation(function()
	while ESX == nil do
		Renzuzu.Wait(55)
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
	Renzuzu.Wait(1000)
	while ped == 0 or ped == nil do
		Renzuzu.Wait(111)
		ped = PlayerPedId()
	end
	while true do
		local sleep = config.uitop_sleep
		ped = PlayerPedId()
		health = (GetEntityHealth(ped)-100)
		armor = GetPedArmour(ped)
		if newarmor ~= armor or newarmor == nil then
			RenzuSendUI({
				hud = "setArmor",
				content = armor
			})
			newarmor = armor
		end
		if newhealth ~= health or newhealth == nil then
			RenzuSendUI({
				hud = "setHp",
				content = health
			})
			newhealth = health
		end
		Renzuzu.Wait(sleep)
	end
end)

function SendNuiSeatBelt()
	if vehicle ~= nil and vehicle ~= 0 then
		if newbelt ~= belt or newbelt == nil then
			newbelt = belt
			RenzuSendUI({
			type = "setBelt",
			content = belt
			})
		end
	end
end

-- YOU NEED SEATBELT SYSTEM FOR RAGDOLL, THIS IS FOR KEYBINDS ONLY for UI
Creation(function()
	RenzuKeybinds(config.commands['car_seatbelt'], 'Car Seatbelt', 'keyboard', config.keybinds['car_seatbelt'])
end)

RenzuCommand(config.commands['car_seatbelt'], function()
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
	Creation(function()
		if vehicle ~= nil and vehicle ~= 0 then
			sleep = 100
			while state ~= false do
				RenzuSendUI({
					type = "setSignal",
					content = state
				})
				Renzuzu.Wait(500)
			end
		end
	end)
end

RenzuCommand(config.commands['signal_left'], function()
	local ped = ped
	local vehicle = vehicle
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
end, false)

Creation(function()
	RenzuKeybinds(config.commands['signal_left'], 'Signal Left', 'keyboard', config.keybinds['signal_left'])
end)

RenzuCommand(config.commands['signal_right'], function()
	local ped = ped
	local vehicle = vehicle
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
end, false)

Creation(function()
	RenzuKeybinds(config.commands['signal_right'], 'Signal Right', 'keyboard', config.keybinds['signal_right'])
end)

RenzuCommand(config.commands['entering'], function()
	local p = PlayerPedId()
	v = GetVehiclePedIsEntering(p)
	local mycoords = GetEntityCoords(p)
	if not IsPedInAnyVehicle(p) and IsAnyVehicleNearPoint(mycoords.x,mycoords.y,mycoords.z,10.0) then
		print("ENTERING")
		while GetVehiclePedIsTryingToEnter(p) == 0 do
			v = GetVehiclePedIsTryingToEnter(p)
			Renzuzu.Wait(0)
		end
		local count = 0
		while not IsPedInAnyVehicle(p) and not start and count < 400 do
			Renzuzu.Wait(1)
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
				Renzuzu.Wait(0)
			end
		end
	elseif start and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 or manual and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 then
		if start then
			RenzuSendUI({
				type = "setStart",
				content = false
			})
		end
		if manual then
			RenzuSendUI({
				type = "setManual",
				content = false
			})
		end
		RenzuSendUI({
			type = "setShow",
			content = false
		})
		if ismapopen then
			RenzuSendUI({map = true, type = 'sarado'})
			ismapopen = false
		end
		while IsPedInAnyVehicle(ped, false) do
			Renzuzu.Wait(11)
		end
		invehicle = false
	end
end, false)

Creation(function()
	RenzuKeybinds(config.commands['entering'], 'Enter Vehicle', 'keyboard', config.keybinds['entering'])
end)

RenzuCommand(config.commands['signal_hazard'], function()
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

Creation(function()
	RenzuKeybinds(config.commands['signal_hazard'], 'Signal Hazard', 'keyboard', config.keybinds['signal_hazard'])
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
	Creation(function()
		if config.usecustomfuel then
			if not regdecor then
				regdecor = true
				DecorRegister(config.fueldecor,1)
			end
			while invehicle do
				Renzuzu.Wait(2000)
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
		RenzuSendUI({
			type = "setMode",
			content = mode
		})
		Renzuzu.Wait(500)
		while busy do
			Renzuzu.Wait(10)
		end
		local rpm = GetVehicleCurrentRpm(vehicle)
		local gear = GetVehicleCurrentGear(vehicle)
		Creation(function()
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
				Renzuzu.Wait(sleep)
			end
		end)

		local sound = false
		Creation(function()
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
					-- 	Renzuzu.Wait(1)
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
							Renzuzu.Wait(1)
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
						Renzuzu.Wait(500) -- TURBO LAG
					end
					if reset and not IsControlPressed(1, 32) then
						SetVehicleTurboPressure(vehicle, 0)
					end
					vehicleSpeed = GetVehicleTurboPressure(vehicle)
					if gear == 0 then
						gear = 1
					end
					local boost = (vehicleSpeed * 7)
					if degrade ~= 1.0 then
						boost = boost * (degrade / config.boost)
					end
					if IsControlPressed(1, 32) and GetVehicleCurrentRpm(vehicle) > 0.4 and vehicleSpeed > (turbo / 2) then
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", boost / 10)
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", engineload)
						SetVehicleBoost(vehicle, boost)
					end
				end
				Renzuzu.Wait(sleep)
			end
			busy = true
			Renzuzu.Wait(100)
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				Renzuzu.Wait(0)
			end
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fInitialDriveForce") == DecorGetFloat(vehicle,"DRIVEFORCE") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
				Renzuzu.Wait(0)
			end
			busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
		end)
	elseif mode == 'SPORTS' then
		mode = 'ECO'
		RenzuSendUI({
			type = "setMode",
			content = mode
		})
		Renzuzu.Wait(500)
		while busy do
			Renzuzu.Wait(10)
		end
		local sound = false
		Creation(function()
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
						local power = config.eco+0.4
						if degrade ~= 1.0 then
							power = power * degrade
						end
						SetVehicleBoost(vehicle, (config.eco+0.4))
					end
				end
				Renzuzu.Wait(sleep)
			end
			busy = true
			Renzuzu.Wait(100)
			SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
			while not GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
				SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				Renzuzu.Wait(0)
			end
			busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
		end)
	else
		mode = 'NORMAL'
		RenzuSendUI({
			type = "setMode",
			content = mode
		})
	end
end

RenzuCommand(config.commands['mode'], function()
	vehiclemode()
end, false)

Creation(function()
	mode = 'NORMAL'
	RenzuKeybinds(config.commands['mode'], 'Vehicle Mode', 'keyboard', config.keybinds['mode'])
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
	RenzuSendUI({
		type = "setDifferential",
		content = diff
	})
	Renzuzu.Wait(500)
	Creation(function()
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", diff)
		while togglediff and invehicle do
			Renzuzu.Wait(1000)
		end
		Renzuzu.Wait(300)
		if not invehicle then
			togglediff = false
			old_diff = 0
		end
	end)
	
end

RenzuCommand(config.commands['differential'], function()
	differential()
end, false)

Creation(function()
	RenzuKeybinds(config.commands['differential'], '4WD Mode', 'keyboard', config.keybinds['differential'])
end)

function Notify(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

--ETC

local minimap
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
end)

function requestmodel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do 
		Renzuzu.Wait(1)
		RequestModel(model)
	end
end

function playanimation(animDict,name)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	TaskPlayAnim(PlayerPedId(), animDict, name, 2.0, 2.0, -1, 49, 0, 0, 0, 0)
end

function putwater()
	local ped = PlayerPedId()
	--local targetRotation = vec3(180.0, 180.0, 180.0)
	local bone = GetEntityBoneIndexByName(getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(getveh(),bone)
	local vehrotation = GetEntityRotation(getveh(),2)
	--local rx,ry,rz = table.unpack(targetRotation)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(getveh())
	local veh_coord = GetEntityCoords(getveh(),false)
	print(vehrotation)
	print(GetEntityCoords(ped,false))
	--Renzuzu.Wait(90999)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	requestmodel('bkr_prop_meth_sacid')
	print(realx,realy,realz)
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_long_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(getveh()) * 0.5)
	print(rx,ry,rz)
	local realx,realy,realz = x - ax , y - ay , z - az
	print(x +realx,y +realy)
	--Renzuzu.Wait(100000)
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.1, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	--TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "look_around_v8_sacid", 8.0, -8, -1, 49, 0, 0, 0, 0)
	--Renzuzu.Wait(100000)
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
	--SetEntityCoords(ped,realx,realy,realz)
	water = CreateObject(GetHashKey('bkr_prop_meth_sacid'), x, y, z, 1, 0, 1)
	SetEntityCollision(water, false, true)
	--TaskPlayAnim(ped, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "look_around_v8_sacid", 8.0, -8, -1, 49, 0, 0, 0, 0)
	--TaskPlayAnim(ped,"anim@amb@business@meth@meth_monitoring_cooking@cooking@","chemical_pour_short_cooker",1.0, 1.0, 2.0, 9, 1.0, 0, 0, 0)
	--TaskPlayAnim(ped, animDict, 'anim@amb@business@meth@meth_monitoring_cooking@cooking@chemical_pour_long_sacid', 8.0, -8.0, 5.0, 0, 0.0, 0, 0, 0)
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
	Renzuzu.Wait(100)
	print(plate)
end

function changeoil()
	local ped = PlayerPedId()
	--local targetRotation = vec3(180.0, 180.0, 180.0)
	local bone = GetEntityBoneIndexByName(getveh(),'overheat')
	local targetRotation = GetEntityBoneRotation(getveh(),bone)
	local vehrotation = GetEntityRotation(getveh(),2)
	--local rx,ry,rz = table.unpack(targetRotation)
	local rx2,ry2,rz2 = table.unpack(vehrotation)
	local veh_heading = GetEntityHeading(getveh())
	local veh_coord = GetEntityCoords(getveh(),false)
	print(vehrotation)
	print(GetEntityCoords(ped,false))
	--Renzuzu.Wait(90999)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(getveh(), bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	requestmodel('prop_oilcan_01a')
	print(realx,realy,realz)
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_short_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(getveh()) * 0.5)
	print(rx,ry,rz)
	local realx,realy,realz = x - ax , y - ay , z - az
	print(x +realx,y +realy)
	--Renzuzu.Wait(100000)
	local netScene = NetworkCreateSynchronisedScene(x +realx+rx,y +realy+ry, z+0.2, 0.0,0.0,veh_heading, 2, false, false, 1065353216, 0, 1.3)
	--TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "look_around_v8_sacid", 8.0, -8, -1, 49, 0, 0, 0, 0)
	--Renzuzu.Wait(100000)
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
	--SetEntityCoords(ped,realx,realy,realz)
	oil = CreateObject(GetHashKey('prop_oilcan_01a'), x, y, z+0.5	, 1, 0, 1)
	SetEntityCollision(water, false, true)
	--TaskPlayAnim(ped, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "look_around_v8_sacid", 8.0, -8, -1, 49, 0, 0, 0, 0)
	--TaskPlayAnim(ped,"anim@amb@business@meth@meth_monitoring_cooking@cooking@","chemical_pour_short_cooker",1.0, 1.0, 2.0, 9, 1.0, 0, 0, 0)
	--TaskPlayAnim(ped, animDict, 'anim@amb@business@meth@meth_monitoring_cooking@cooking@chemical_pour_long_sacid', 8.0, -8.0, 5.0, 0, 0.0, 0, 0, 0)
	NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "chemical_pour_short_cooker", 1.5, -4.0, 1, 16, 1148846080, 0)
	--NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "chemical_pour_short_ammonia", 0.0, 0.0, 1, 1, 1, 0)
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
	veh_stats[plate].coolant = 100
	SetVehicleEngineTemperature(getveh(), GetVehicleEngineTemperature(getveh()) - config.reducetemp_onwateradd)
	RenzuSendUI({
		type = "setCoolant",
		content = 100
	})
	Renzuzu.Wait(100)
	print(plate)
end

RenzuCommand('putwater', function(source, args, raw)
	putwater()
end)

RenzuCommand('changeoil', function(source, args, raw)
	changeoil()
end)

function SetVehicleBoost(vehicle,val)
	Renzu_Hud(0xB59E4BD37AE292DB, vehicle,val)
end