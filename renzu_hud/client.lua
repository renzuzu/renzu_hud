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
	DecorRegister("TOPSPEED", 1)
	DecorRegister("STEERINGLOCK", 1)
	DecorRegister("MAXGEAR", 1)
	DecorRegister("TRACTION", 1)
	DecorRegister("TRACTION2", 1)
	DecorRegister("TRACTION3", 1)
end)

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
	if config.enableproximityfunc then
		setVoice()
	end
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
	Citizen.Wait(3000)
	TriggerServerEvent("renzu_hud:getmile")
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
local notifycd = {
	['hunger'] = 0,
	['thirst'] = 0,
	['sanity'] = 0,
	['energy'] = 0,
	['oxygen'] = 0
}
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
		Wait(1)
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
		Renzuzu.Wait(1)
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
	if config.statusnotify then
		if hunger < 20 and notifycd['hunger'] < 1 then
			notifycd['hunger'] = 120
			Notify('error','Hunger',"i am very hungry")
		elseif thirst < 20 and notifycd['thirst'] < 1 then
			notifycd['thirst'] = 120
			Notify('error','Thirst',"i am very thirsty")
		elseif sanity > 80 and notifycd['sanity'] < 1 then
			notifycd['sanity'] = 120
			Notify('error','Sanity',"i see some dragons")
		elseif energy < 20 and notifycd['energy'] < 1 then
			notifycd['energy'] = 120
			Notify('error','Energy',"i am very tired")
		elseif oxygen < 10 and notifycd['oxygen'] < 1 then
			notifycd['oxygen'] = 120
			Notify('error','Oxygen',"my air almost done")
		end
		for k,v in pairs(status) do
			if v > 1 then
				v = v - 1
			end
		end
	end
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

RenzuNuiCallback('closecarcontrol', function(data, cb)
	carcontrol = false
	RenzuSendUI({
		type = "setShowCarcontrol",
		content = carcontrol
	})
	SetNuiFocus(false,false)
end)

Creation(function()
	Wait(1000)
	RenzuSendUI({type = 'setCarui', content = config.carui})
	--WHEN RESTARTED IN CAR
	if not uimove then
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
			plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
			hp = GetVehicleEngineHealth(vehicle)
			gasolina = GetVehicleFuelLevel(vehicle)
			if uimove then
				Renzuzu.Wait(500)
				local content = {
					['bool'] = true,
					['type'] = config.carui
				}
				RenzuSendUI({
					type = "setShow",
					content = content
				})
			end
			uimove = false
			if not invehicle then
				if GetPedInVehicleSeat(vehicle, -1) == ped and entering then
					breakstart = false
					SetNuiFocus(true, true)
					while not start and not breakstart and config.carui == 'modern' do
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
					content = GetVehStats(vehicle, "CHandlingData","fDriveBiasFront")
				})
			end
			invehicle = true
		else
			globaltopspeed = nil
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
				local content = {
					['bool'] = false,
					['type'] = config.carui
				}
				RenzuSendUI({
					type = "setShow",
					content = content
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

finaldrive, flywheel, maxspeed = 0,0,0
function SavevehicleHandling()
	if not DecorExistOn(vehicle, "INERTIA") then
		finaldrive = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
		DecorSetFloat(vehicle, "INERTIA", finaldrive)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
		finaldrive = DecorGetFloat(vehicle,"INERTIA")
	end

	if not DecorExistOn(vehicle, "DRIVEFORCE") then
		flywheel = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
		DecorSetFloat(vehicle, "DRIVEFORCE", flywheel)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
		flywheel = DecorGetFloat(vehicle,"DRIVEFORCE")
	end
	if not DecorExistOn(vehicle, "TOPSPEED") then
		maxspeed = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
		DecorSetFloat(vehicle, "TOPSPEED", maxspeed)
		print("Vehicle Data Saved")
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(vehicle,"TOPSPEED"))
		maxspeed = DecorGetFloat(vehicle,"TOPSPEED")
	end

	if not DecorExistOn(vehicle, "MAXGEAR") then
		maxgear = GetVehStats(vehicle, "CHandlingData","nInitialDriveGears")
		DecorSetFloat(vehicle, "MAXGEAR", maxgear)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"MAXGEAR"))
		maxgear = DecorGetFloat(vehicle,"MAXGEAR")
		print(maxgear)
	end

	if not DecorExistOn(vehicle, "TRACTION") then
		traction = GetVehStats(vehicle, "CHandlingData","fTractionCurveMin")
		DecorSetFloat(vehicle, "TRACTION", traction)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION"))
		traction = DecorGetFloat(vehicle,"TRACTION")
	end
	
	if not DecorExistOn(vehicle, "TRACTION2") then
		traction2 = GetVehStats(vehicle, "CHandlingData","fTractionCurveLateral")
		DecorSetFloat(vehicle, "TRACTION2", traction2)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2"))
		traction2 = DecorGetFloat(vehicle,"TRACTION2")
	end

	if not DecorExistOn(vehicle, "TRACTION3") then
		traction3 = GetVehStats(vehicle, "CHandlingData","fLowSpeedTractionLossMult")
		DecorSetFloat(vehicle, "TRACTION3", traction3)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3"))
		traction3 = DecorGetFloat(vehicle,"TRACTION3")
	end
end

--ASYNC FUNCTION CALL VEHICLE LOOPS
function inVehicleFunctions()
	Creation(function()
		while not invehicle do
			Renzuzu.Wait(1) -- lets wait invehicle to = true
		end
		SavevehicleHandling()
		SetForceHdVehicle(vehicle, true)
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
		SendNuiSeatBelt()
		NuiWheelSystem()
		if not manual and manualstatus then
			startmanual()
		end
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
				rpm = VehicleRpm(vehicle)
				speed = VehicleSpeed(vehicle)
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
				sleep = 5
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
				local gear = GetGear(vehicle)
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

RegisterNetEvent("renzu_hud:receivemile")
AddEventHandler("renzu_hud:receivemile", function(data,i)
	veh_stats = nil
	collectgarbage()
	Citizen.Wait(100)
	veh_stats = {}
	veh_stats = data
	identifier = i
end)

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
		Renzuzu.Wait(1000)
		while veh_stats == nil and invehicle do
			Renzuzu.Wait(100)
		end
		Creation(function()
			while invehicle do
				local wait = 10000
				while veh_stats[plate] == nil and invehicle do
					Renzuzu.Wait(1000)
				end
				RenzuSendUI({
					type = "setNitro",
					content = veh_stats[plate].nitro
				})
				local mileage = veh_stats[plate].mileage
				degrade = 1.0
				while mileage >= config.mileagemax do
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
					Renzuzu.Wait(wait)
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
				plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
				local newPos = GetEntityCoords(ped)
				savemile = true
				lastve = GetVehiclePedIsIn(ped, false)
				if plate ~= nil then
					--saveplate = string.match(GetVehicleNumberPlateText(vehicle), '%f[%d]%d[,.%d]*%f[%D]')
					saveplate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
					saveplate = string.gsub(saveplate, '^%s*(.-)%s*$', '%1')
					plate = saveplate
					if plate ~= nil and veh_stats[plate] == nil then
						print("CREATING VEHSTATS")
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
					if veh_stats[plate].coolant == nil then
						veh_stats[plate].coolant = 100
					end
					if veh_stats[plate].oil == nil then
						veh_stats[plate].oil = 100
					end
					if veh_stats[plate].nitro == nil then
						veh_stats[plate].nitro = 100
					end
					local numwheel = GetVehicleNumberOfWheels(vehicle)
					for i = 0, numwheel - 1 do
						if veh_stats[plate][tostring(i)] == nil then
							veh_stats[plate][tostring(i)] = {}
							veh_stats[plate][tostring(i)].tirehealth = config.tirebrandnewhealth
						end
					end
					--print(veh_stats[plate].coolant)
					if plate ~= nil and veh_stats[plate].plate == plate then
						if oldPos == nil then
							oldPos = newPos
						end
						if oldPos2 == nil then
							oldPos2 = newPos
						end
						if oldPos3 == nil then
							oldPos3 = newPos
						end
						local dist = #(newPos-oldPos)
						if dist > 10.0 then
							veh_stats[plate].mileage = veh_stats[plate].mileage+(( dist / 1000 ) * config.mileage_speed) -- dist = meter / 1000 = kmh, this might be inaccurate
							oldPos = newPos
						end
						if config.enabletiresystem then
							local dist3 = #(newPos-oldPos3)
							if dist3 > config.driving_status_radius then
								oldPos3 = newPos
								local numwheel = GetVehicleNumberOfWheels(vehicle)
								for i = 0, numwheel - 1 do
									if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth > 0 then
										local bonuswear = 0.0
										if config.wearspeedmultiplier then
											bonuswear = (speed / 20)
										end
										veh_stats[plate][tostring(i)].tirehealth = veh_stats[plate][tostring(i)].tirehealth - (config.tirewear + bonuswear)
									end
									if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth <= 0 then
										SetVehicleWheelHealth(vehicle, i, GetVehicleWheelHealth(vehicle,i) - config.tirewear)
										if config.reducetraction then
											SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * config.curveloss)
											SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * config.acceleratetractionloss)
										end
									end
									print("reduct tires")
									--Notify("Tire Wear: Wheel #"..i.." - "..veh_stats[plate][tostring(i)].tirehealth.."")
									local wheeltable = {
										['index'] = i,
										['tirehealth'] = veh_stats[plate][tostring(i)].tirehealth
									}
									RenzuSendUI({
										type = "setWheelHealth",
										content = wheeltable
									})
								end
							end
						end
						if config.driving_affect_status then
							local dist2 = #(newPos-oldPos2)
							if dist2 > config.driving_status_radius then
								oldPos2 = newPos
								TriggerEvent('esx_status:'..config.driving_status_mode..'', config.driving_affected_status, config.driving_status_val)
							end
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
		if config.centercarhud == 'map' and config.carui == 'modern' then
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
		if #(GetEntityCoords(ped) - GetEntityCoords(GetPlayersLastVehicle())) < 5 then
			v = GetPlayersLastVehicle()
			print("last veh")
		end
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
	Notify('error','Engine',"Engine too Hot")
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
		while veh_stats == nil or veh_stats[plate] == nil do
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
					rpm = VehicleRpm(vehicle)
					Renzuzu.Wait(1000)
					print("Overheat")
					SetVehicleEngineCanDegrade(vehicle, true)
					SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.addheat)
					if newtemp ~= GetVehicleEngineTemperature(vehicle) or newtemp == nil then
						newtemp = temp
						RenzuSendUI({
						type = "setTemp",
						content = GetVehicleEngineTemperature(vehicle)
						})
						if plate ~= nil and GetVehicleEngineTemperature(vehicle) >= config.overheatmin and veh_stats[plate].coolant ~= nil and veh_stats[plate].coolant <= 20 then
							explosion = 0
							explode = PlaySoundFromEntity(GetSoundId(), "Engine_fail", vehicle, "DLC_PILOT_ENGINE_FAILURE_SOUNDS", 0, 0)
							SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.overheatadd)
							if not triggered then
								triggered = true
								TriggerServerEvent("renzu_hud:smokesync", vehicle, GetEntityCoords(vehicle,false))
							end
							Notify('error','Engine',"Engine Problem")
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
						elseif GetVehicleEngineTemperature(vehicle) >= config.overheatmin and veh_stats[plate] ~= nil and (veh_stats[plate].coolant ~= nil and veh_stats[plate].coolant >= 20) then
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
				if newtemp ~= temp or newtemp == nil then
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
				Notify('warning','Engine System',"Engine Temp: "..GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)).."")
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

function haveseatbelt(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

function looking(entity)
	local hr = GetEntityHeading(entity) + 90.0
	if hr < 0.0 then
		hr = 360.0 + hr
	end
	hr = hr * 0.0174533
	return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

function forwardvect(speed)
	speed = speed / 10
	return GetEntityForwardVector(getveh()) * speed
end

local alreadyblackout = false
local sounded = false

function DoblackOut()
	if not alreadyblackout then
		alreadyblackout = true
		Citizen.CreateThread(function()
			DoScreenFadeOut(1150)
			while not IsScreenFadedOut() do
				Citizen.Wait(0)
			end
			Citizen.Wait(1000)
			DoScreenFadeIn(250)
			alreadyblackout = false
		
		end)
	end
end
function accidentsound()
	if not sounded then
		sounded = true
		Citizen.CreateThread(function()
			PlaySoundFrontend(-1, "SCREEN_FLASH", "CELEBRATION_SOUNDSET", 1)
			Citizen.Wait(1)
			sounded = false
		end)
	end
end

function impactdamagetoveh()
	if alreadyblackout then
		if not accident then
			accident = true
			Citizen.CreateThread(function()
				local vehicle = GetVehiclePedIsIn(PlayerPedId(-1), false)
				local tyre = math.random(0, 15)
				local tankdamage = math.random(150, 300)
				local enginedamage = math.random(150, 300) 
				local vehiclebodydamage = math.random(150, 300)
				SetVehiclePetrolTankHealth(vehicle,GetVehiclePetrolTankHealth(vehicle) - tankdamage )
				SetVehicleTyreBurst(vehicle,tyre, 0 , 80.0)
				SetVehicleEngineHealth(vehicle ,GetVehicleEngineHealth(vehicle) - enginedamage)
				SetVehicleBodyHealth(vehicle, GetVehicleBodyHealth(vehicle) - vehiclebodydamage) 
				SetVehicleOilLevel(vehicle, GetVehicleOilLevel(vehicle) + 5.0 ) -- max is 15?
				SetVehicleCanLeakOil(vehicle, true)
				SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + 45.0 )
				Citizen.Wait(3000) 
				accident = false
			end)
		end 
	end
end

function hazyeffect()
	Citizen.CreateThread(function()
		Citizen.Wait(3000)
		StartScreenEffect('PeyoteEndOut', 0, true)
		StartScreenEffect('Dont_tazeme_bro', 0, true)
		StartScreenEffect('MP_race_crash', 0, true)
		local count = 0
		while not IsEntityDead(GetPlayerPed(-1)) and count < 5000 do
			count = count + 1
			StartScreenEffect('PeyoteEndOut', 0, true)
			StartScreenEffect('Dont_tazeme_bro', 0, true)
			StartScreenEffect('MP_race_crash', 0, true)
			Citizen.Wait(1)
		end
		if config.sanity_stressAdd then
			TriggerEvent('esx_status:add', 'sanity', 40000)
		end
		StopScreenEffect('PeyoteEndOut')
		StopScreenEffect('Dont_tazeme_bro')
		StopScreenEffect('MP_race_crash')
	end)
end

function SendNuiSeatBelt()
	Citizen.Wait(300)
	if vehicle ~= nil and vehicle ~= 0 and config.enableseatbeltfunc then
		Creation(function()
			local Session = {}
			local Velocity = {}
			local lastspeed = 0
			while config.enableseatbeltfunc and not belt and invehicle do
				local sleep = 500

				Session[2] = Session[1]
				Session[1] = GetEntitySpeed(vehicle)
				if Session[1] > 15 then
					sleep = 100
				end
				if Session[1] > 30 then
					sleep = 50
				end
				if Session[2] ~= nil and not belt and GetEntitySpeedVector(vehicle,true).y > 1.0 and Session[1] > 15.25 and (Session[2] - Session[1]) > (Session[1] * 0.255) then
					local coord = GetEntityCoords(ped)
					local ahead = forwardvect(Session[1])
					if config.reducepedhealth then
						local kmh = lastspeed
						local damage = GetEntityHealth(ped) - (kmh * config.impactdamagetoped)
						if damage < 0 then
							damage = 0
						end
						SetEntityHealth(ped,damage)
					end
					if config.shouldblackout then
						DoblackOut()
						accidentsound()
					end
					if config.hazyeffect then
						hazyeffect()
					end
					if config.impactdamagetoveh then
						impactdamagetoveh()
					end
					Citizen.Wait(100)
					SetEntityCoords(ped,coord.x+ahead.x,coord.y+ahead.y,coord.z-0.47,true,true,true)
					SetEntityVelocity(ped,Velocity[2].x,Velocity[2].y,Velocity[2].z)
					Citizen.Wait(1)
					SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
					PopOutVehicleWindscreen(vehicle)
				end
				if not skip then
					lastspeed = GetEntitySpeed(vehicle) * 3.6
					skip = true
				else
					skip = false
				end
				Velocity[2] = Velocity[1]
				Velocity[1] = GetEntityVelocity(vehicle)
				Renzuzu.Wait(sleep)
			end
			while config.enableseatbeltfunc and belt and invehicle do
				local sleep = 5
				if belt then
					DisableControlAction(0,75)
				end
				Renzuzu.Wait(sleep)
			end
			Session[1],Session[2] = 0.0,0.0
		end)
	end
end

-- SEATBELT
Creation(function()
	RenzuKeybinds(config.commands['car_seatbelt'], 'Car Seatbelt', 'keyboard', config.keybinds['car_seatbelt'])
end)

RenzuCommand(config.commands['car_seatbelt'], function()
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
				SendNuiSeatBelt()
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
					Notify('success','Seatbelt',"Seatbelt has been attached")
				end
				SendNuiSeatBelt()
			end)
		end
	end
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

function entervehicle()
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
		while not IsPedInAnyVehicle(p) and not start and count < 400 and config.carui == 'modern' do
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
		if GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and config.carui == 'modern' then
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
		local content = {
			['bool'] = false,
			['type'] = config.carui
		}
		RenzuSendUI({
			type = "setShow",
			content = content
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
end

RenzuCommand(config.commands['entering'], function()
	entervehicle()
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

function max(b, rpm)
    if b > 3.0 then
        b = 3.0
    end
    if b < 0.0 then
        return 0.0
    end
    return turbolevel(b, turbo)

end

function Round(num,numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function Fuel(vehicle)
	if IsVehicleEngineOn(vehicle) then
		local rpm = VehicleRpm(vehicle)
		local gear = GetGear(vehicle)
		local engineload = (rpm * (gear / 10))
		local result = (config.fuelusage[Round(VehicleRpm(vehicle),1)] * (config.classes[GetVehicleClass(vehicle)] or 1.0) / 15)
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
		Notify('success','Vehicle Mode',"Sports mode Activated")
		while busy do
			Renzuzu.Wait(10)
		end
		local rpm = VehicleRpm(vehicle)
		local gear = GetGear(vehicle)
		Creation(function()
			local newgear = 0
			while mode == 'SPORTS' do
				local sleep = 2000
				--local ply = PlayerPedId()
				local vehicle = vehicle
				if vehicle ~= 0 then
					sleep = 10
					rpm = VehicleRpm(vehicle)
					gear = GetGear(vehicle)
					topspeedmodifier = config.topspeed_multiplier
				end
				Renzuzu.Wait(sleep)
			end
		end)

		local sound = false
		Creation(function()
			local newgear = 0
			olddriveinertia = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
			oldriveforce = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
			oldtopspeed = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel") -- normalize
			-- DecorSetFloat(vehicle, "INERTIA", olddriveinertia)
			-- DecorSetFloat(vehicle, "DRIVEFORCE", oldriveforce)
			-- DecorSetFloat(vehicle, "TOPSPEED", oldtopspeed)
			globaltopspeed = DecorGetFloat(vehicle,"TOPSPEED") * config.topspeed_multiplier
			local fixedshit = (config.topspeed_multiplier * 1.0)
			local old = oldtopspeed * 1.0
			SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", old * fixedshit)
			local turbosound = 0
			local oldgear = 0
			--SetVehStats(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed * 2.0)
			local fo = oldtopspeed * 0.64
			--SetEntityMaxSpeed(vehicle,fo * 2.0)
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
					--local speed = VehicleSpeed(vehicle) * 3.6
					if sound and IsControlJustReleased(1, 32) then
						StopSound(soundofnitro)
						ReleaseSoundId(soundofnitro)
						sound = false
					end

					local lag = 0
					if IsControlPressed(1, 32) then
						if not sound then
							soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
							sound = true
						end
						--SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed*3.500000)
						while lag < 200 and engineload < turboboost(gear) and IsControlPressed(1, 32) do
							engineload = (rpm * (gear / 10))
							SetVehicleTurboPressure(vehicle, max((rpm * 1) + engineload + (lag * engineload)))
							Renzuzu.Wait(1)
							lag = lag + 1
						end
						if config.boost_sound and rpm > 0.65 and rpm < 0.95 and turbosound < 10 and gear == oldgear and engineload > turboboost(gear) then
							turbosound = turbosound + 1
							SetVehicleBoostActive(vehicle, 1, 0)
							SetVehicleBoostActive(vehicle, 0, 0)
						else
							turbosound = 0
						end
						oldgear = gear
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
					boost = (vehicleSpeed * 7)
					if degrade ~= 1.0 then
						boost = boost * (degrade / config.boost)
					end
					if IsControlPressed(1, 32) and VehicleRpm(vehicle) > 0.4 and vehicleSpeed > (turbo / 2) then
						SetVehStats(vehicle, "CHandlingData", "fDriveInertia", boost / 10)
						SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", engineload)
						SetVehicleBoost(vehicle, boost)
						if config.sports_increase_topspeed then
							SetVehicleEnginePowerMultiplier(vehicle,boost * config.topspeed_multiplier)
						end
					end
				end
				Renzuzu.Wait(sleep)
			end
			globaltopspeed = nil
			topspeedmodifier = 1.0
			busy = true
			Renzuzu.Wait(100)
			if DecorGetFloat(vehicle,"INERTIA") ~= 0.0 and DecorGetFloat(vehicle,"DRIVEFORCE") ~= 0.0 then
				SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(vehicle,"TOPSPEED"))
				SetVehStats(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
				while not GetVehStats(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
					if DecorGetFloat(vehicle,"INERTIA") ~= nil then
						SetVehStats(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
					end
					Renzuzu.Wait(0)
				end
				while not GetVehStats(vehicle, "CHandlingData","fInitialDriveForce") == DecorGetFloat(vehicle,"DRIVEFORCE") and invehicle do
					if DecorGetFloat(vehicle,"DRIVEFORCE") ~= nil then
						SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
					end
					Renzuzu.Wait(0)
				end
			end
			SetVehicleEnginePowerMultiplier(vehicle, 1.0) -- just incase
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
		Notify('success','Vehicle Mode',"ECO mode Activated")
		while busy do
			Renzuzu.Wait(10)
		end
		local sound = false
		Creation(function()
			local olddriveinertia = 1.0
			olddriveinertia = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
			SetVehStats(vehicle, "CHandlingData", "fDriveInertia", config.eco)
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
			if DecorGetFloat(vehicle,"INERTIA") ~= 0.0 then
				SetVehStats(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
				while not GetVehStats(vehicle, "CHandlingData","fDriveInertia") == DecorGetFloat(vehicle,"INERTIA") and invehicle do
					SetVehStats(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
					Renzuzu.Wait(0)
				end
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
		Notify('success','Vehicle Mode',"Normal Mode Restored")
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
	local diff = GetVehStats(vehicle, "CHandlingData","fDriveBiasFront")
	print(diff)
	if diff > 0.01 and diff < 0.9 and old_diff == nil and not togglediff then -- default 4wd
		old_diff = diff -- save old
		diff = 0.0 -- change to rearwheel
		togglediff = true
		Notify('success','Vehicle Differential',"RWD Activated")
	elseif old_diff ~= nil and togglediff then
		diff = old_diff
		SetVehStats(vehicle, "CHandlingData", "fDriveBiasFront", diff)
		togglediff = false
		old_diff = nil
		Notify('success','Vehicle Differential',"Default Differential Activated")
	elseif diff == 1.0 and not togglediff and old_diff == nil then -- Front Wheel Drive
		print("FWD")
		diff =  0.5
		old_diff = 1.0
		togglediff = true
		Notify('success','Vehicle Differential',"AWD Activated")
	elseif diff == 0.0 and not togglediff and old_diff == nil then -- Rear Wheel Drive
		old_diff = 0.0
		diff = 0.5
		togglediff = true
		Notify('success','Vehicle Differential',"AWD Activated")
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
		SetVehStats(vehicle, "CHandlingData", "fDriveBiasFront", diff)
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

function Notify(type,title,message)
	local table = {
		['type'] = type,
		['title'] = title,
		['message'] = message
	}
	RenzuSendUI({
		type = "SetNotify",
		content = table
	})
	-- SetNotificationTextEntry('STRING')
	-- AddTextComponentString(msg)
	-- DrawNotification(0,1)
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
	TaskPlayAnim(PlayerPedId(), animDict, name, 2.0, 2.0, -1, 47, 0, 0, 0, 0)
	-- while IsEntityPlayingAnim(ped, animDict, name, 3) do
	-- 	Citizen.Wait(0)
	-- 	DisableAllControlActions(0)
	-- end
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
	Notify('success','Vehicle System',"Coolant has been restore")
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
	veh_stats[plate].oil = 100
	veh_stats[plate].mileage = 0
	degrade = 1.0
	RenzuSendUI({
		type = "setMileage",
		content = 0
	})
	Notify('success','Vehicle System',"Oil has been changed")
	Renzuzu.Wait(100)
	print(plate)
end

RenzuCommand('putwater', function(source, args, raw)
	putwater()
end)

RenzuCommand('changeoil', function(source, args, raw)
	changeoil()
end)

local cruising = false
function Cruisecontrol()
	PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	cruising = not cruising
	Citizen.Wait(500)
	Citizen.CreateThread(function()
		RenzuSendUI({
			type = "setCruiseControl",
			content = cruising
		})
		local topspeed = GetVehStats(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel") * 0.64
		local speed = VehicleSpeed(vehicle)
		if cruising then
			text = "locked to "..(speed*3.6).." kmh"
		else
			text = 'Restored'
		end
		Notify('success','Vehicle Cruise System',"Max Speed has been "..text.."")
		while invehicle and cruising do
			SetEntityMaxSpeed(vehicle,speed)
			Citizen.Wait(1000)
		end
		SetEntityMaxSpeed(vehicle,topspeed)
		cruising = false
	end)
end

RenzuCommand(config.commands['cruisecontrol'], function()
	Cruisecontrol()
end, false)

Creation(function()
	RenzuKeybinds(config.commands['cruisecontrol'], 'Vehicle Cruise Control', 'keyboard', config.keybinds['cruisecontrol'])
end)

Creation(function()
	if config.firing_affect_status then
		while ped == nil or ped == 0 do
			Citizen.Wait(100)
		end
		local count = 0
		local killed = {}
		while true do
			local lastent = nil
			local pid = PlayerId()
			shooting = false
			while IsPlayerFreeAiming(pid) do
				shooting = false
				if IsPedShooting(ped) then
					if config.killing_affect_status then
						val, ent = GetEntityPlayerIsFreeAimingAt(pid)
						--print("shooting")
						if lastent ~= nil and lastent ~= 0 then
							if not killed[lastent] and IsEntityDead(lastent) and GetPedSourceOfDeath(lastent) == ped then
								killed[lastent] = true
								print("LAST ENTITY IS DEAD "..lastent.."")
								lastent = nil
								TriggerEvent('esx_status:'..config.killing_status_mode..'', config.killing_affected_status, config.killing_status_val)
								Citizen.Wait(100)
							end
						end
						if ent ~= lastent then
							lastent = nil
						end
					end
					if count > config.firing_bullets then
						count = 0
						TriggerEvent('esx_status:'..config.firing_status_mode..'', config.firing_affected_status, config.firing_statusaddval)
						--print("STATUS ADDED")
					end
					count = count + 1
					--print(count)
					lastent = ent
					shooting = true
					if config.bodystatus then
						if armbone > armbone2 then
							recoil(armbone / 5.0)
						else
							recoil(armbone2 / 5.0)
						end
					end
					Citizen.Wait(5)
				end
				--print("aiming")
				Citizen.Wait(5)
			end
			
			Citizen.Wait(2000) -- 2 seconds wait to check if player is aiming, more optimized 100x than to loop wait(0) just to check if player is firing or not
		end
	end
end)

Creation(function()
	if config.running_affect_status or config.melee_combat_affect_status or config.parachute_affect_status or config.playing_animation_affect_status then
		while true do
			if config.running_affect_status then
				while IsPedRunning(ped) do
					Citizen.Wait(1000)
					TriggerEvent('esx_status:'..config.running_status_mode..'', config.running_affected_status, config.running_status_val)
				end
			end
			if config.melee_combat_affect_status then
				while IsPedInMeleeCombat(ped) do
					Citizen.Wait(1000)
					TriggerEvent('esx_status:'..config.melee_combat_status_mode..'', config.melee_combat_affected_status, config.melee_combat_status_val)
				end	
			end
			if config.parachute_affect_status then
				while IsPedInParachuteFreeFall(ped) do
					Citizen.Wait(1000)
					TriggerEvent('esx_status:'..config.parachute_status_mode..'', config.parachute_affected_status, config.parachute_status_val)
				end	
			end
			if config.playing_animation_affect_status then
				--if IsEntityPlayingAnim(ped, )
				for k,v in pairs(config.status_animation) do
					Wait(0)
					if IsEntityPlayingAnim(ped, v.dict, v.name, 3) then
						print("LOADED")
						TriggerEvent('esx_status:'..v.mode..'', v.status, v.val)
						Citizen.Wait(1000)
					end
				end
			end
			Citizen.Wait(2000)
		end
	end
end)

-- BODY STATUS
function BodyUi()
	bodyui = not bodyui
	RenzuSendUI({
		type = "setShowBodyUi",
		content = bodyui
	})
end

RenzuCommand(config.commands['bodystatus'], function()
	BodyUi()
end, false)

Creation(function()
	RenzuKeybinds(config.commands['bodystatus'], 'Open Body Status', 'keyboard', config.keybinds['bodystatus'])
end)

RegisterNetEvent('renzu_hud:bodystatus')
AddEventHandler('renzu_hud:bodystatus', function(status)
	local status = status
	receive = true
	bodystatus = status
end)

Creation(function()
	if config.bodystatus then
		Citizen.Wait(1000)
		while not playerloaded do
			Citizen.Wait(500)
		end
		TriggerServerEvent('renzu_hud:checkbody')
		while receive == 'new' do
			Citizen.Wait(1)
		end
		for type,val in pairs(config.buto) do
			if bodystatus then 
				bonecategory[type] = bodystatus[type] 
			else 
				bonecategory[type] = 0
			end
			parts[type] = {}
			for bone,val in pairs(val) do
				parts[type][bone] = 0
			end
		end
		RenzuSendUI({
			type = "setUpdateBodyStatus",
			content = bonecategory
		})
		while config.bodystatus do
			Citizen.Wait(config.bodystatuswait)
			BodyMain()
		end
	end
end)

Creation(function()
	if config.bodystatus then
		local tick = 0
		while receive == 'new' do
			Citizen.Wait(100)
		end
		while config.bodystatus and receive do
			Citizen.Wait(3500)
			tick = tick + 1000
			local ped = ped
			local pid = PlayerId()
			if bonecategory["ped_head"] == nil then
				bonecategory["ped_head"] = 0
			end
			if not head and bonecategory["ped_head"] > 0 then
				SetTimecycleModifier(config.headtimecycle)
				SetTimecycleModifierStrength(math.min(bonecategory["ped_head"] / 1, 1.1))
				head = true
				Notify('error','Body System',"Head has been damaged")
			elseif bonecategory["ped_head"] <= 0 then
				if head then
					ClearTimecycleModifier()
					head = false 
				end
			end
			if bonecategory["ped_body"] == nil then
				bonecategory["ped_body"] = 0
			end
			if bonecategory["ped_body"] > 0 then
				if not body then
					bodydamage()
					Notify('error','Body System',"Chest has been damaged")
				end
				body = true
				if tick % (1000 / (bonecategory["ped_body"] / 10)) == 1 then
					local plyHealth = GetEntityHealth(ped)
					SetPlayerHealthRechargeMultiplier(pid, 0.0)
				end
			elseif body then
				body = false
			else
				body = false
			end

			if bonecategory["right_hand"] > 0 or bonecategory["left_hand"] > 0 then
				if not arm then
					armdamage()
					Notify('error','Body System',"Arm has been damaged")
				end
				arm = true
				if bonecategory["left_hand"] < bonecategory["right_hand"] then  
					armbone = bonecategory["right_hand"]
				else 
					armbone2 = bonecategory["left_hand"]
				end
			else
				arm = false
			end

			if bonecategory and bonecategory["left_leg"] and bonecategory["right_leg"] and (bonecategory["left_leg"] >= 2 or bonecategory["right_leg"] >= 2) then
				if not leg then
					RequestAnimSet("move_m@injured")
					legdamage()
					Notify('error','Body System',"Leg has been damaged")
				end
				leg = true
				SetPedMoveRateOverride(plyPed, 0.6)
				SetPedMovementClipset(plyPed, "move_m@injured", true)
			elseif leg then
				leg = false
				ResetPedMovementClipset(GetPlayerPed(-1))
				ResetPedWeaponMovementClipset(GetPlayerPed(-1))
				ResetPedStrafeClipset(GetPlayerPed(-1))
				SetPedMoveRateOverride(plyPed, 1.0)
			else
				leg = false
			end
		end
	end
end)

function bodydamage()
	Creation(function()
		while body do
			Citizen.Wait(5000)
			if config.disabledsprint then
				SetPlayerSprint(PlayerId(), false)
			end
			if config.disabledregen then
				SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
			end
			if GetEntityHealth(PlayerPedId()) > config.chesteffect_minhealth then
				SetEntityHealth(PlayerPedId(),GetEntityHealth(PlayerPedId()) - config.chesteffect_healthdegrade)
			end
		end
		SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
		SetPlayerSprint(PlayerId(), true)
	end)
end

function recoil(r)
	tv = 0
	if GetFollowPedCamViewMode() ~= 4 then
		--repeat 
			Wait(0)
			p = GetGameplayCamRelativePitch()
			SetGameplayCamRelativePitch(p+0.3, config.thirdperson_armrecoil)
			tv = tv+0.1
		--until tv >= r and arm and shooting
	else
		--repeat 
			Wait(0)
			p = GetGameplayCamRelativePitch()
			if r > 0.1 then
				SetGameplayCamRelativePitch(p+0.6, config.firstperson_armrecoil)
				tv = tv+0.6
			else
				SetGameplayCamRelativePitch(p+0.016, 0.333)
				tv = tv+0.1
			end
		--until tv >= r and arm and shooting
	end
end

function armdamage() -- vehicle
	Creation(function()
		local oldveh = nil
		while arm do
			if config.melee_decrease_damage then
				while IsPedInMeleeCombat(ped) do
					Citizen.Wait(5)
					SetPlayerMeleeWeaponDamageModifier(PlayerId(), config.melee_damage_decrease)
				end
			end
			while invehicle do
				if vehicle ~= nil and vehicle ~= 0 then
					if oldveh ~= vehicle then
						steeringlock = GetVehStats(vehicle, "CHandlingData","fSteeringLock")
						DecorSetFloat(vehicle, "STEERINGLOCK", steeringlock)
						print("SAVED")
						SetVehStats(vehicle, "CHandlingData", "fSteeringLock", config.armdamage_invehicle_effect)
					end
				end
				Citizen.Wait(2000)
				oldveh = vehicle
			end
			if oldveh ~= nil then
				oldveh = nil
				print("Load Default Steering lock")
				SetVehStats(getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(getveh(),"STEERINGLOCK")) -- the back the original stats
			end
			Citizen.Wait(3000) -- Wait until ped goes off to vehicle or until arm is in pain.
		end
		SetVehStats(getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(getveh(),"STEERINGLOCK")) -- the back the original stats
	end)
end

function legdamage()
	Creation(function()
		while leg do
			Citizen.Wait(5)
			if config.legeffect_disabledjump and not invehicle then
				DisableControlAction(0,22,true)
			end
			SetPedMoveRateOverride(PlayerPedId(), config.legeffectmovement	)
			SetPedMovementClipset(PlayerPedId(), "move_m@injured", true)
		end
	end)
end
lastdamage = nil
function CheckBody()  
	local ok, id = GetPedLastDamageBone(ped)
	print(ok,id)
	if ok then
		for damagetype,val in pairs(config.buto) do
			for bone,index in pairs(val) do
				if index == id and lastdamage ~= id then 
					lastdamage = id
					return bone,damagetype
				end
			end
		end
	end
	return false
end

local oldlife = GetEntityHealth(PlayerPedId())
function BodyMain()
	local life = GetEntityHealth(ped)
	if life < oldlife then
		print("new life")
		local index,bodytype = CheckBody()
		if not config.weaponsonly or not HasEntityBeenDamagedByWeapon(ped, 0 , 1) and HasEntityBeenDamagedByWeapon(ped, 0 , 2) and config.weaponsonly then
			--if isWeapon(GetPedCauseOfDeath(PlayerPedId())) then
		if index and bodytype then
			if index ~= nil and parts[bodytype] ~= nil and parts[bodytype][index] ~= nil and bonecategory ~= nil and bonecategory[bodytype] ~= nil then
				parts[bodytype][index] = parts[bodytype][index] + config.damageadd
				bonecategory[bodytype] = bonecategory[bodytype] + config.damageadd
				print("saving")
				RenzuSendUI({
					type = "setUpdateBodyStatus",
					content = bonecategory
				})
				if bonecategory['ped_head'] > 0 and config.bodyinjury_status_affected then
					TriggerEvent('esx_status:'..config.headbone_status_mode..'', config.headbone_status, bonecategory['ped_head'] * config.headbone_status_value)
				end
				Citizen.InvokeNative(0x8EF6B7AC68E2F01B, PlayerPedId())
				TriggerServerEvent('renzu_hud:savebody', bonecategory)
			end
		end
		end
	end
	oldlife = GetEntityHealth(ped)
end

function HealBody(bodypart)
	-- Preparing
	TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', -1, true)
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
	Notify('success','Body System',"You have been healed")
end

function Makeloading(msg,ms)
	BusyspinnerOff()
	Wait(10)
	AddTextEntry("CUSTOMLOADSTR", msg)
	BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
	EndTextCommandBusyspinnerOn(4)
	Citizen.CreateThread(function()
		Citizen.Wait(ms)
		BusyspinnerOff()
	end)
end

Creation(function()
	if config.enablehealcommand then
		RenzuCommand(config.commands['bodyheal'], function(source,args)
			if args[1] ~= nil then
				HealBody(args[1])
			end
		end, false)
	end
end)

local windowbones = {
	[0] = 'window_rf',
	[1] = 'window_lf',
	[2] = 'window_rr',
	[3] = 'window_lr'
}

local carcontrol = false
function CarControl()
	vehicle = getveh()
	if vehicle ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) < 15 and GetVehicleDoorLockStatus(vehicle) == 1 then
		local door = {}
		local window = {}
		for i = 0, 6 do
			Wait(10)
			door[i] = false
			if GetVehicleDoorAngleRatio(vehicle,i) ~= 0.0 then
				--print("Door",GetVehicleDoorAngleRatio(vehicle,i))
				door[i] = true
			end
		end
		for i = 0, 3 do
			window[i] = false
			if not IsVehicleWindowIntact(vehicle,i) and GetWorldPositionOfEntityBone(vehicle,GetEntityBoneIndexByName(vehicle,windowbones[i])).x ~= 0.0 then
				window[i] = true
			end
		end

		carcontrol = not carcontrol
		RenzuSendUI({
			type = "setShowCarcontrol",
			content = carcontrol
		})
		Wait(300)
		RenzuSendUI({
			type = "setDoorState",
			content = door
		})
		RenzuSendUI({
			type = "setWindowState",
			content = window
		})
		SetNuiFocus(carcontrol,carcontrol)
	else
		if GetVehicleDoorLockStatus(vehicle) ~= 1 then
			Notify('warning','Carcontrol System',"No Unlock Vehicle Nearby")
		else
			Notify('warning','Carcontrol System',"No Nearby Vehicle")
		end
	end
end

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
end)

RenzuNuiCallback('setVehicleDoor', function(data, cb)
	vehicle = getveh()
    if data.bool then
		SetVehicleDoorOpen(vehicle,tonumber(data.index),false,false)
    else     
        SetVehicleDoorShut(vehicle,tonumber(data.index),false,false)
    end
end)

function shuffleseat(index)
	if invehicle then
		TaskWarpPedIntoVehicle(ped,vehicle,index)
	else
		Creation(function()
			entervehicle()
		end)
		TaskEnterVehicle(ped, getveh(), 10.0, index, 2.0, 0)
	end
end

RenzuNuiCallback('setVehicleSeat1', function(data, cb)
	vehicle = getveh()
    if IsVehicleSeatFree(vehicle,-1) then
		shuffleseat(-1)
	elseif IsVehicleSeatFree(vehicle,0) then
		shuffleseat(0)
    end
end)

RenzuNuiCallback('setVehicleSeat2', function(data, cb)
	vehicle = getveh()
    if IsVehicleSeatFree(vehicle,1) then
		shuffleseat(1)
	elseif IsVehicleSeatFree(vehicle,2) then
		shuffleseat(2)
    end
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
end)

RegisterNetEvent("renzu_hud:airsuspension")
AddEventHandler("renzu_hud:airsuspension", function(vehicle,val,coords)
	if #(coords - GetEntityCoords(ped)) < 50 then
		playsound(GetEntityCoords(vehicle),20,'suspension',1.0)
		local max = 0
		local data = {}
		local min = GetVehicleSuspensionHeight(vehicle)
		data.val = val
		if (data.val * 100) < 15 then
			val = min
			data.val = data.val - 0.1
			print(data.val)
			print(min)
			local good = false
			while min > data.val do
				print((data.val * 0.01))
				print(data.val)
				print(min)
				SetVehicleSuspensionHeight(getveh(),GetVehicleSuspensionHeight(vehicle) - (1.0 * 0.01))
				min = GetVehicleSuspensionHeight(vehicle)
				Citizen.Wait(100)
				good = true
			end
			while not good and min < data.val do
				print((data.val * 0.01))
				print(data.val)
				print(min)
				SetVehicleSuspensionHeight(getveh(),GetVehicleSuspensionHeight(vehicle) + (1.0 * 0.01))
				min = GetVehicleSuspensionHeight(vehicle)
				Citizen.Wait(100)
			end
		else
			val = min
			local good = false
			while min < data.val do
				print((data.val * 0.01))
				print(data.val)
				print(min)
				print("FUCK")
				SetVehicleSuspensionHeight(getveh(),GetVehicleSuspensionHeight(vehicle) + (1.0 * 0.01))
				min = GetVehicleSuspensionHeight(vehicle)
				Citizen.Wait(100)
				good = true
			end

			while not good and min > data.val do
				print((data.val * 0.01))
				print(data.val)
				print(min)
				print("FUCK")
				SetVehicleSuspensionHeight(getveh(),GetVehicleSuspensionHeight(vehicle) - (1.0 * 0.01))
				min = GetVehicleSuspensionHeight(vehicle)
				Citizen.Wait(100)
			end
		end
	end
end)

RenzuNuiCallback('setvehicleheight', function(data, cb)
	vehicle = getveh()
    if vehicle ~= nil and vehicle ~= 0 then
		TriggerServerEvent("renzu_hud:airsuspension",vehicle, data.val, GetEntityCoords(vehicle))
    end
end)

RenzuNuiCallback('setvehicleneon', function(data, cb)
	vehicle = getveh()
	r,g,b = GetVehicleNeonLightsColour(vehicle)
	if r == 255 and g == 0 and b == 255 then -- lets assume this is the default and not installed neon.. change this if you want a better check if neon is install, use your framework
	else
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(vehicle, i, data.bool)
			Citizen.Wait(500)
		end
	end
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
end)

--WEAPONS
local oldweapon = nil
local weaponui = false

Creation(function()
	Citizen.Wait(500)
	if config.weaponsui then
		if config.crosshairenable then
			RenzuSendUI({
				type = "setCrosshair",
				content = config.crosshair
			})
		end
		while true do
			local sleep = 2000
			if config.weaponsui then
				local status = {}
				local weapon = nil
				sleep = 1000
				if IsPedArmed(ped, 7) and not invehicle then
					sleep = config.ammoupdatedelay
					weapon = GetSelectedPedWeapon(ped)
					local ammoTotal = GetAmmoInPedWeapon(ped,weapon)
					local bool,ammoClip = GetAmmoInClip(ped,weapon)
					local ammoRemaining = math.floor(ammoTotal - ammoClip)
					local maxammo = GetMaxAmmoInClip(ped, weapon, 1)
					status['armed'] = true
					--print(ammoRemaining)
					if oldweapon ~= weapon then
						for key,value in pairs(config.WeaponTable) do
							for name,v in pairs(config.WeaponTable[key]) do
								weap = weapon == GetHashKey('weapon_'..name)
								if weap then
									status['weapon'] = 'weapon_'..name
								end
							end
						end
					end
					local weapon_ammo = {
						['clip'] = ammoClip,
						['ammo'] = ammoRemaining,
						['max'] = maxammo
					}
					RenzuSendUI({
						type = "setAmmo",
						content = weapon_ammo
					})
					if not weaponui then
						RenzuSendUI({
							type = "setWeaponUi",
							content = true
						})
						weaponui = true
					end

				else
					if weaponui then
						RenzuSendUI({
							type = "setWeaponUi",
							content = false
						})
						weaponui = false
					end
					Citizen.Wait(1000)
					status['armed'] = false	
				end
				if oldweapon ~= weapon then
					RenzuSendUI({
						type = "setWeapon",
						content = status['weapon']
					})
					oldweapon = weapon
				end
			end
			Citizen.Wait(sleep)
		end
	end
end)

RenzuCommand(config.commands['weaponui'], function()
	config.weaponsui = not config.weaponsui
	RenzuSendUI({
		type = "setWeaponUi",
		content = config.weaponsui
	})
	weaponui = config.weaponsui
end, false)

local crosshair = 1
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

--NOS -- very old style nitro, will redo soon..

local trail = {}
nitromode = false
lightshit = {}
light_trail_isfuck = false
purgefuck = false
purgeshit = {}
pressed = false
function EnableNitro()
	Creation(function()
		while invehicle and nitromode do
			local cansleep = 2000
			if veh_stats[plate] ~= nil and veh_stats[plate].nitro ~= nil and hasNitro and invehicle and veh_stats[plate].nitro > 1 then
				if GetPedInVehicleSeat(vehicle, -1) == ped then
					cansleep = 1
					if veh_stats[plate].nitro > 5 and RCP(0, 21) and not RCR2(0, 21) then
						pressed = true
						SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - 0.05)
						if veh_stats[plate].nitro - 0.02 > 0 then
							if speed > 5 then
								SetTimecycleModifier("ship_explosion_underwater")
								SetExtraTimecycleModifier("StreetLightingJunction")
								SetExtraTimecycleModifierStrength(0.1)
								SetTimecycleModifierStrength(0.1)
								--StartScreenEffect('MP_Celeb_Preload_Fade', 0, true)
							end
							SetVehicleEngineTorqueMultiplier(vehicle, config.nitroboost * 2 * rpm)
							veh_stats[plate].nitro = veh_stats[plate].nitro - config.nitrocost
							RenzuSendUI({
								type = "setNitro",
								content = veh_stats[plate].nitro
							})
							TriggerServerEvent("renzu_hud:nitro_flame", VehToNet(vehicle), GetEntityCoords(vehicle))
							--TriggerEvent("laptop:nos", n_boost)
							if config.nitro_sound and speed > 5 then
								SetVehicleBoostActive(vehicle, 1)
							end
						else
							veh_stats[plate].nitro = 0
						end
					else
						if config.nitro_sound then
							SetVehicleBoostActive(vehicle, 0)
						end
					end
					if RCR2(0, 21) and not RCP(0, 21) then
						pressed = false
						ClearExtraTimecycleModifier()
						ClearTimecycleModifier()
						StopScreenEffect('MP_Celeb_Preload_Fade')
						RemoveParticleFxFromEntity(vehicle)
						local vehcoords = GetEntityCoords(vehicle)
						Citizen.Wait(1)
						RemoveParticleFxInRange(vehcoords.x,vehcoords.y,vehcoords.z,100.0)
						light_trail_isfuck = false
						for k,v in pairs(lightshit) do
							StopParticleFxLooped(k, 1)
							RemoveParticleFx(k, true)
							k = nil
						end
						purgefuck = false
						Creation(function()
							Wait(500)
							for k,v in pairs(purgeshit) do
								StopParticleFxLooped(k, 1)
								RemoveParticleFx(k, true)
								k = nil
							end
						end)
					end
				end
			end
			Wait(cansleep)
		end
	end)
end

RegisterNetEvent("renzu_hud:addnitro")
AddEventHandler("renzu_hud:addnitro", function(amount)
		local lib, anim = 'mini@repair', 'fixing_a_car'
        local playerPed = PlayerPedId()
		ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5555, 0, 0, false, false, false)
			exports['progressBars']:startUI(5555, 'Reloading Nitro')
            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            ESX.ShowNotification("Nitro has been reloaded")
		end)
		nitro_state = 100
end)

RegisterNetEvent("renzu_hud:nitro_flame")
AddEventHandler("renzu_hud:nitro_flame", function(c_veh,coords)
	if #(coords - GetEntityCoords(ped)) < 50 then
		if not HasNamedPtfxAssetLoaded(config.nitroasset) then
			RequestNamedPtfxAsset(config.nitroasset)
			while not HasNamedPtfxAssetLoaded(config.nitroasset) do
				Wait(1)
			end
		end
		if GetEntitySpeed(NetToVeh(c_veh)) * 3.6 > 5 then
			for _,bones in pairs(config.exhaust_bones) do
				UseParticleFxAssetNextCall(config.nitroasset)
				local index = GetEntityBoneIndexByName(vehicle, bones)
				if index ~= config.bannedindex then
					local boneposition = GetWorldPositionOfEntityBone(vehicle, index)
					local mufflerpos = GetOffsetFromEntityGivenWorldCoords(vehicle, boneposition.x, boneposition.y, boneposition.z)
					StartParticleFxNonLoopedOnEntity(config.exhaust_particle_name,vehicle,mufflerpos.x,mufflerpos.y,mufflerpos.z,0.0,0.0,0.0,config.exhaust_flame_size,false,false,false)
				end
			end
			if not light_trail_isfuck then
				light_trail_isfuck = true
				for _,bones in pairs(config.tailights_bone) do
					UseParticleFxAssetNextCall(config.nitroasset)
					lightrailparticle = StartParticleFxLoopedOnEntityBone(config.trail_particle_name, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(vehicle, bones), config.trail_size, false, false, false)
					SetParticleFxLoopedEvolution(lightrailparticle, "speed", 1.00, false)
					table.insert(lightshit, lightrailparticle)
				end
			end
		else
			if not purgefuck then
				purgefuck = true
				local index = GetEntityBoneIndexByName(vehicle, config.purge_left_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge1 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x + 0.03, particle_location.y + 0.1, particle_location.z+0.2, config.purge_size, -20.0, 0.0, 0.5)
				table.insert(purgeshit, purge1)
				local index = GetEntityBoneIndexByName(vehicle, config.purge_right_bone)
				local bone_position = GetWorldPositionOfEntityBone(vehicle, index)
				local particle_location = GetOffsetFromEntityGivenWorldCoords(vehicle, bone_position.x, bone_position.y, bone_position.z)
				UseParticleFxAssetNextCall(config.nitroasset)
				purge2 = StartParticleFxLoopedOnEntity(config.purge_paticle_name,vehicle,particle_location.x - 0.03, particle_location.y + 0.1, particle_location.z+0.2, config.purge_size, 20.0, 0.0, 0.5)
				table.insert(purgeshit, purge2)
			end
		end
	end
end)

spool = false
RenzuCommand(config.commands['enablenitro'], function()
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
end, false)

Creation(function()
	if config.enablenitro then
		RenzuKeybinds(config.commands['enablenitro'], 'Enable Nitro Control', 'keyboard', config.keybinds['enablenitro'])
	end
end)

function angle(veh)
	if not veh then return false end
	local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
	local modV = math.sqrt(vx*vx + vy*vy)


	local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	if GetEntitySpeed(veh)* 3.6 < 20 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --speed over 25 km/h

	local cosX = (sn*vx + cs*vy)/modV
	return math.deg(math.acos(cosX))*0.5, modV
end

--WHEEL SYSTEM
function NuiWheelSystem()
	Creation(function()
		while veh_stats == nil or veh_stats[plate] == nil do
			Citizen.Wait(100)
		end
		while invehicle and config.enabletiresystem do
			local numwheel = GetVehicleNumberOfWheels(vehicle)
			sleep = 300
			for i = 0, numwheel - 1 do
				if rpm > config.minrpm_wheelspin_detect and speed > 1 and (VehicleRpm(vehicle) * 100.0) < (tractioncontrol(WheelSpeed(vehicle,i) * 3.6,GetGear(vehicle), true) * 85.0) then
					if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth > 0 then
						veh_stats[plate][tostring(i)].tirehealth = veh_stats[plate][tostring(i)].tirehealth - config.tirestress
					end
					--Notify("Tire Stress: Wheel #"..i.." - "..veh_stats[plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(vehicle, i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(vehicle, i, true, 0)
					end
				end
			end
			if speed > config.minspeed_curving and angle(vehicle) >= config.minimum_angle_for_curving and angle(vehicle) <= 18 and GetEntityHeightAboveGround(vehicle) <= 1.5 then
				for i = 0, numwheel - 1 do
					if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth > 0 then
						veh_stats[plate][tostring(i)].tirehealth = veh_stats[plate][tostring(i)].tirehealth - config.tirestress
					end
					Notify('warning','Tire System',"Tire Stress2: Wheel #"..i.." - "..veh_stats[plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(vehicle, i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(vehicle, i, true, 0)
					end
				end
			end
			Citizen.Wait(sleep)
		end
	end)
end

function InstallTires(type)
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
					TriggerServerEvent('renzu_hud:savemile', plate, veh_stats[tostring(plate)])
					Notify('success','Tire System',"New Tires has been Successfully Install")
					ClearPedTasks(ped)
					break
				else
					playanimation('anim@amb@clubhouse@tutorial@bkr_tut_ig3@','machinic_loop_mechandplayer')
					Makeloading('Installing New Tire #'..i..'',10000)
					Citizen.Wait(10000)
					SetVehicleTyreFixed(vehicle, i)
					SetVehicleWheelHealth(vehicle, i, 1000.0)
					veh_stats[plate][tostring(i)].tirehealth = 999.0
					TriggerServerEvent('renzu_hud:savemile', plate, veh_stats[tostring(plate)])
					Notify('success','Tire System',"New Tire #"..i.." has been Successfully Install")
					ClearPedTasks(ped)
					local wheeltable = {
						['index'] = i,
						['tirehealth'] = veh_stats[plate][tostring(i)].tirehealth
					}
					RenzuSendUI({
						type = "setWheelHealth",
						content = wheeltable
					})
					break
				end
				ClearPedTasks(ped)
			end
		end
	end
end

Creation(function()
	if config.repaircommand then
		RenzuCommand('repairtire', function()
			InstallTires(type)
		end, false)
	end
end)

local keyless = false
function Carlock()
	keyless = not keyless
	RenzuSendUI({
		type = "setShowKeyless",
		content = keyless
	})
	if keyless then
		print("inside loop")
		local vehicles = {}
		local checkindentifier, myidentifier = nil, nil
		local mycoords = GetEntityCoords(ped, false)
		local foundvehicle = {}
		local min = -1
		for k,v in pairs(GetGamePool('CVehicle')) do
			if #(mycoords - GetEntityCoords(v, false)) < 20 then
				local plate = string.gsub(GetVehicleNumberPlateText(v), "%s+", "")
				plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
				if veh_stats[plate] ~= nil and veh_stats[plate].owner ~= nil and identifier ~= nil then
					checkindentifier = string.gsub(veh_stats[plate].owner, 'Char5', '')
					checkindentifier = string.gsub(checkindentifier, 'Char4', '')
					checkindentifier = string.gsub(checkindentifier, 'Char3', '')
					checkindentifier = string.gsub(checkindentifier, 'Char2', '')
					checkindentifier = string.gsub(checkindentifier, 'Char1', '')
					myidentifier = string.gsub(identifier, 'steam', '')
				end
				if veh_stats[plate] ~= nil and checkindentifier == myidentifier then
					if min == -1 or #(mycoords - GetEntityCoords(v, false)) < min then
						foundvehicle = {}
						foundvehicle[plate] = {}
						foundvehicle[plate].entity = v
						foundvehicle[plate].plate = plate
						foundvehicle[plate].distance = #(mycoords - GetEntityCoords(v, false))
						min = #(mycoords - GetEntityCoords(v, false))
					end
				end
			end
		end
		for k,v in pairs(foundvehicle) do
			if v.distance <= 20 then
				print(v.plate)
				print(v.entity)
				local table = {
					['type'] = 'connect',
					['bool'] = true,
					['vehicle'] = v.entity,
					['plate'] = v.plate,
					['state'] = GetVehicleDoorLockStatus(v.entity)
				}
				RenzuSendUI({
					type = "setKeyless",
					content = table
				})
				Notify('success','Vehicle Lock System','Owned Vehicle Found with Plate # '..v.plate..'')
				Wait(200)
				SetNuiFocus(true,true)
			end
		end
	else
		SetNuiFocus(false,false)
	end
end

Creation(function()
	if config.carlock then
		RenzuCommand(config.commands['carlock'], function()
			Carlock()
		end, false)
		RenzuKeybinds(config.commands['carlock'], 'Toggle Carlock System', 'keyboard', config.keybinds['carlock'])
	end
end)

function playsound(vehicle,max,file,maxvol)
	local volume = maxvol
	local mycoord = GetEntityCoords(ped)
	local distIs  = tonumber(string.format("%.1f", #(mycoord - vehicle)))
	if (distIs <= max) then
		distPerc = distIs / max
		volume = (1-distPerc) * maxvol
		local table = {
			['file'] = file,
			['volume'] = volume
		}
		RenzuSendUI({
			type = "playsound",
			content = table
		})
	end
end

RegisterNetEvent("renzu_hud:synclock")
AddEventHandler("renzu_hud:synclock", function(vehicle, type, coords)
	if #(coords - GetEntityCoords(ped)) < 50 then
		SetVehicleLights(vehicle, 2);Citizen.Wait(100);SetVehicleLights(vehicle, 0);Citizen.Wait(200);SetVehicleLights(vehicle, 2)
		Citizen.Wait(100)
		SetVehicleLights(vehicle, 0)	
		if type == 'lock' then
			print("locking shit")
			playsound(coords,20,'lock',1.0)
			SetVehicleDoorsLocked(vehicle,2)
			Wait(500)
			ClearPedTasks(ped)
		end
		if type == 'unlock' then
			print("unlocking shit")
			playsound(coords,20,'unlock',1.0)
			SetVehicleDoorsLocked(vehicle,1)
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
	keyless = false
end)

RenzuNuiCallback('setvehiclelock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Notify('success','Vehicle Lock System','Lock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", data.vehicle, 'lock', GetEntityCoords(ped))
    end
end)

RenzuNuiCallback('setvehicleunlock', function(data, cb)
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		Notify('success','Vehicle Lock System','Unlock Plate # '..GetVehicleNumberPlateText(data.vehicle)..'')
		TriggerServerEvent("renzu_hud:synclock", data.vehicle, 'unlock', GetEntityCoords(ped))
    end
end)

RenzuNuiCallback('setvehicleopendoors', function(data, cb)
	print("openall")
    if data.vehicle ~= nil and data.vehicle ~= 0 then
		playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
		--Makeloading('Opening All Doors # '..GetVehicleNumberPlateText(data.vehicle)..'',1000)
		playsound(GetEntityCoords(data.vehicle),20,'openall',1.0)
		for i = 0, 3 do
			if data.bool then
				print(i)
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
end)

RenzuNuiCallback('setvehiclealarm', function(data, cb)
	print("vehicle alarm")
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
end)