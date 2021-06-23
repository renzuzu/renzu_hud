-----------------------------------------------------------------------------------------------------------------------------------------
-- RENZU HUD FUNCTION  https://github.com/renzuzu/renzu_hud
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

function isplayer()
	local mpm = GetHashKey("mp_m_freemode_01")
	local mpf = GetHashKey("mp_f_freemode_01")
	local model = GetEntityModel(PlayerPedId())
	--print(model,"MODEL")
	if model == mpm then
		return true
	elseif model == mpf then
		return true
	else
		return false 
	end
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return tonumber(count)
end

function getawsomeface()
	if config.statusui ~= 'normal' then return end
    ClearPedHeadshots()
	Wait(2000)
    local playerPos = GetEntityCoords(PlayerPedId())
    local player = PlayerId()

	local tempHandle = nil

	if build() == 2189 then
		tempHandle = RegisterPedheadshot_3(PlayerPedId())
	else
		tempHandle = RegisterPedheadshotTransparent(PlayerPedId())
	end

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

	if headshotTxd == 'none' then
		tempHandle = RegisterPedheadshot_3(PlayerPedId())
		timer = 2000
		while ((not tempHandle or not IsPedheadshotReady(tempHandle) or not IsPedheadshotValid(tempHandle)) and timer > 0) do
			Wait(10)
			timer = timer - 10
		end
		if (IsPedheadshotReady(tempHandle) and IsPedheadshotValid(tempHandle)) then
			headshotTxd = GetPedheadshotTxdString(tempHandle)
			headshot = headshotTxd
		end
	end

	return headshotTxd
end

function ClearPedHeadshots()
	if headshot ~= nil or headshot ~= 0 then
		UnregisterPedheadshot(headshot)
	end
end

function UpdateStatus(export,vitals)
	if notloaded then return end
	if export then
	vitals = exports['standalone_status']:GetStatus(statuses)
	end
	statusloop = 0
	sleep = 11

	for k1,v1 in pairs(config.statusordering) do
		if v1.status == 'stamina' then
			v1.value = (100 - GetPlayerSprintStaminaRemaining(pid))
		end
		if v1.status == 'oxygen' then
			v1.value = GetPlayerUnderwaterTimeRemaining(pid) * 10
			--print(v1.value)
		end
		if v1.custom and statusloop <= 1  then
			if vitals[v1.status] ~= nil and vitals[v1.status] then
				v1.value = vitals[v1.status] / 10000
			end
		end

		if config.statusnotify and statusloop <= 1 then
			if not v1.notify_lessthan and v1.rpuidiv ~= 'null' then
				if notifycd[v1.status] ~= nil and v1.value < v1.notify_value and notifycd[v1.status] < 1 then
					notifycd[v1.status] = 120
					Notify('error',v1.status,v1.notify_message)
				end
			elseif v1.rpuidiv ~= 'null' then
				if notifycd[v1.status] ~= nil and v1.value > v1.notify_value and notifycd[v1.status] < 1 then
					notifycd[v1.status] = 120
					Notify('error',v1.status,v1.notify_message)
				end
			end
			for k,v in pairs(notifycd) do
				if v > 1 then
					v = v - 1
				end
			end
		end
		Wait(sleep)
	end
	statusloop = statusloop + 1
	RenzuSendUI({
		type = "setStatus",
		content = {['type']= config.status_type, ['data'] = config.statusordering}
	})
end

function EnterVehicleEvent(state,vehicle)
	print("Enter",NetworkGetEntityIsNetworked(vehicle))
	--print(state,vehicle,"enter veh")
	if state and vehicle ~= nil and vehicle ~= 0 then
		if not NetworkGetEntityIsNetworked(vehicle) then return end -- do not show in non network entity, ex. vehicle shop, garage etc..
		if config.enable_carui_perclass then
			DefineCarUI(config.carui_perclass[GetVehicleClass(vehicle)])
		end
		--print("veh loop")
		-- plate = tostring(GetVehicleNumberPlateText(vehicle))
		-- plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
		hp = GetVehicleEngineHealth(vehicle)
		gasolina = GetVehicleFuelLevel(vehicle)
		lastplate = GetPlate(vehicle)
		if uimove and config.enable_carui then
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
			if config.statusplace == 'bottom-right' then
				RenzuSendUI({type = "setMoveStatusUi",content = true})
			end
			if GetPedInVehicleSeat(vehicle, -1) == ped and entering then
				breakstart = false
				SetNuiFocus(true, true)
				while not start and not breakstart and config.carui == 'modern' do
					SetVehicleEngineOn(vehicle,false,true,true)
					if GetVehiclePedIsIn(ped) == 0 then
						start = false
						breakstart = true
					end
					Renzuzu.Wait(1)
				end
				start = true
				SetNuiFocus(false,false)
				Renzuzu.Wait(100)
				SetVehicleEngineOn(vehicle,true,false,true)
				--print("starting engine")
				while not GetIsVehicleEngineRunning do
					--print("starting")
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
			local functions <close> = inVehicleFunctions()
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
		Wait(2000)
		local off,low,high = GetVehicleLightsState(vehicle)
		if low == 1 and high == 0 then
			light = 1
		elseif high == 1 then
			light = 2
		else
			light = 0
		end
		newlight = light
		RenzuSendUI({
			type = "setHeadlights",
			content = light
		})
	else
		--print("outveh loop")
		globaltopspeed = nil
		entering = false
		start = false
		invehicle = false
		enginespec = false
		speed = 0
		rpm = 0
		marcha = 0
		--print(lastplate,"LAST PLATE")
		if veh_stats[lastplate] ~= nil then
			veh_stats[lastplate].entity = nil
			currentengine[lastplate] = nil
			lastplate = nil
		end
		VehIndicatorLight = 0
		--DisplayRadar(false)
		if config.statusplace == 'bottom-right' then
			RenzuSendUI({type = "setMoveStatusUi",content = false})
		end
		if alreadyturbo then
			RenzuSendUI({
				type = "setShowTurboBoost",
				content = false
			})
		end
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

			RenzuSendUI({
				type = "setStart",
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
			manual = false
		end
		alreadyturbo = false
		Renzuzu.Wait(1000)
		uimove = true
	end
end

function GetPlate(v)
	plate = string.gsub(tostring(GetVehicleNumberPlateText(v)), '^%s*(.-)%s*$', '%1')
	return plate
end

function GetHandling(plate)
	return handlings[plate]
end

function DefaultHandling()
	
end

function SavevehicleHandling()
	while vehicle == nil or vehicle == 0 do
		Wait(100)
	end
	plate = GetPlate(vehicle)
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
		--print("Vehicle Data Saved")
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(vehicle,"TOPSPEED"))
		maxspeed = DecorGetFloat(vehicle,"TOPSPEED")
	end

	if not DecorExistOn(vehicle, "MAXGEAR") then
		maxgear = GetVehicleHandlingInt(vehicle, "CHandlingData","nInitialDriveGears")
		DecorSetInt(vehicle, "MAXGEAR", maxgear)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "nInitialDriveGears", DecorGetInt(vehicle,"MAXGEAR"))
		maxgear = DecorGetInt(vehicle,"MAXGEAR")
		--print(maxgear)
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

	if not DecorExistOn(vehicle, "TRACTION4") then
		traction4 = GetVehStats(vehicle, "CHandlingData","fTractionLossMult")
		DecorSetFloat(vehicle, "TRACTION4", traction4)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionLossMult", DecorGetFloat(vehicle,"TRACTION4"))
		traction4 = DecorGetFloat(vehicle,"TRACTION4")
	end

	if not DecorExistOn(vehicle, "TRACTION5") then
		traction5 = GetVehStats(vehicle, "CHandlingData","fTractionCurveMax")
		DecorSetFloat(vehicle, "TRACTION5", traction5)
	else
		SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMax", DecorGetFloat(vehicle,"TRACTION5"))
		traction5 = DecorGetFloat(vehicle,"TRACTION5")
	end

	handlings[plate] = {finaldrive = tonumber(finaldrive), flywheel = tonumber(flywheel), maxspeed = tonumber(maxspeed), maxgear = tonumber(maxgear), traction = tonumber(traction), traction2 = tonumber(traction2), traction3 = tonumber(traction3), traction4 = tonumber(traction4), traction5 = tonumber(traction5)}
end

--ASYNC FUNCTION CALL VEHICLE LOOPS
function inVehicleFunctions()
	Creation(function()
		while not invehicle do
			Renzuzu.Wait(1) -- lets wait invehicle to = true
		end
		SavevehicleHandling()
		get_veh_stats(vehicle,GetPlate(vehicle))
		SetForceHdVehicle(vehicle, true)
		RpmandSpeedLoop()
		NuiRpm()
		NuiCarhpandGas()
		while not loadedplate do
			Wait(100)
		end
		NuiDistancetoWaypoint()
		NuiMileAge()
		if not config.enable_carui_perclass then
			NuiShowMap()
		end
		NuiEngineTemp()
		fuelusagerun()
		SendNuiSeatBelt()
		NuiWheelSystem()
		if not manual and manualstatus and DecorGetBool(vehicle, "MANUAL") then
			--print("Starting manual")
			startmanual()
		end
		SetVehicleOnline()
		-- RenzuSendUI({
		-- 	type = "inVehicle",
		-- 	content = vtable
		-- })
		return
	end)
end
local vtable = {}
Creation(function()
	RenzuNuiCallback('getvehicledata', function(data, cb)
		rpm = VehicleRpm(vehicle)
		speed = VehicleSpeed(vehicle)
		vtable = {
			['rpm'] = rpm,
			['speed'] = speed
		}
		cb(vtable)
	end)
end)

RenzuCommand('test', function(source, args, raw)
	bool = not bool
	SetNuiFocus(bool,false)
	SetNuiFocusKeepInput(bool)
end)

function SetVehicleOnline() -- for vehicle loop
	while veh_stats[plate] == nil do
		Wait(100)
	end
	local plate = GetPlate(vehicle)
	if veh_stats[plate] ~= nil then
		veh_stats[plate].entity = VehToNet(vehicle)
		TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
	end
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
				--vtable = {}
				if not DoesEntityExist(vehicle) then
					EnterVehicleEvent(false,vehicle)
					break
				end
				sleep = config.rpm_speed_loop
				rpm = GetVehicleCurrentRpm(vehicle)
				speed = VehicleSpeed(vehicle)
				if speed < 0 then speed = 0 end
				if rpm < 0 then rpm = 0.2 end
				vtable = {
					['rpm'] = rpm,
					['speed'] = speed,
				}
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
		return
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
		newrpm = nil
		newspeed = nil
		while invehicle do
			local sleep = 2500
			if vehicle ~= nil and vehicle ~= 0 then
				sleep = config.Rpm_sleep
				if rpm < 0.21 then
				Renzuzu.Wait(config.idle_rpm_speed_sleep)
				end
				if newrpm ~= rpm or newrpm == nil or newspeed == nil or newspeed ~= speed then
					newrpm = rpm
					RenzuSendUI({
						type = "SetVehData",
						content = vtable
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "SetVehData",
						content = vtable
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "SetVehData",
						content = vtable
					})
					Renzuzu.Wait(config.Rpm_sleep_2)
					RenzuSendUI({
						type = "SetVehData",
						content = vtable
					})
				end
			end
			Renzuzu.Wait(sleep)
		end
		--TerminateThisThread()
		return
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
		loadedplate = true
		newcarhealth = nil
		newgas = nil
		newlight = nil
		newgear = nil
		newdoorstatus = nil
		newhood = nil
		newtrunk = nil
		while invehicle do
			plate = string.gsub(tostring(GetVehicleNumberPlateText(vehicle)), '^%s*(.-)%s*$', '%1')
			if vehicle ~= nil and vehicle ~= 0 then
				hp = GetVehicleEngineHealth(vehicle)
				--print(hp)
				gasolina = GetVehicleFuelLevel(vehicle)
				wait = config.NuiCarhpandGas_sleep
				if gasolina ~= newgas or newgas == nil then
					--print("car fuel")
					RenzuSendUI({
						type = "setFuelLevel",
						content = gasolina
					})
					newgas = gasolina
				end
				if newcarhealth ~= hp or newcarhealth == nil then
					--print("carhp")
					RenzuSendUI({
						hud = "setCarhp",
						content = hp
					})
					newcarhealth = hp
				end
				if manual then
					gear = savegear
				else
					gear = GetGear(vehicle)
				end
				if newgear ~= gear or newgear == nil then
					newgear = gear
					RenzuSendUI({
						type = "setGear",
						content = gear
					})
				end
				CalculateTimeToDisplay()
				timeformat()
				local sleep = 2000
			local ped = ped
			local vehicle = vehicle
			local door = true
			local hood = 0
			local trunk = 0
			if vehicle ~= nil and vehicle ~= 0 then
				----print(GetVehicleDoorStatus(vehicle))
				for i = 0, 6 do
					Wait(100)
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
				--SetVehicleHighGear(vehicle,maxgear)
			end
			Renzuzu.Wait(wait)
		end
		--TerminateThisThread()
		return
	end)
end

function NuiDistancetoWaypoint()
	--NUI DISTANCE to Waypoint
	Creation(function()
		local hided = false
		newdis = nil
		while invehicle do
			local sleep = config.direction_sleep
			local ped = ped
			local vehicle = vehicle
			local waypoint = GetFirstBlipInfoId(8)
			if vehicle ~= 0 and DoesBlipExist(waypoint) then
				local coord = GetEntityCoords(ped, true)
				local dis = #(coord - GetBlipCoords(waypoint))
				if newdis ~= dis or newdis == nil then
					hided = false
					newdis = dis
					RenzuSendUI({
					type = "setWaydistance",
					content = dis
					})
				end
			elseif vehicle ~=0 and not DoesBlipExist(waypoint) then
				--if newdis ~= dis or newdis == nil then
				if not hided then
					hided = true
					newdis = 0
					RenzuSendUI({
					type = "setWaydistance",
					content = 0
					})
				end
				Renzuzu.Wait(config.direction_sleep)
			end
			Renzuzu.Wait(sleep)
		end
		return
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
		return
	end)
end

function get_veh_stats(v,p)
	--if veh_stats[plate] ~= nil then return end
	while not veh_stats_loaded do
		Wait(10)
	end
	if v ~= nil and p ~= nil then
		vehicle = v
		plate = p
	end
	local lets_save = false
	if plate ~= nil and veh_stats[plate] == nil then
		--print("CREATING VEHSTATS")
		lets_save = true
		veh_stats[plate] = {}
		veh_stats[plate].plate = plate
		veh_stats[plate].mileage = 0
		veh_stats[plate].oil = 100
		veh_stats[plate].coolant = 100
		veh_stats[plate].nitro = 0
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
		veh_stats[plate].nitro = 0
	end
	if veh_stats[plate].turbo == nil then
		veh_stats[plate].turbo = 'default'
	end
	if veh_stats[plate].manual == nil then
		veh_stats[plate].manual = false
	end
	if veh_stats[plate].tires == nil then
		veh_stats[plate].tires = 'default'
	end
	if veh_stats[plate].engine == nil then
		veh_stats[plate].engine = 'default'
	end
	if veh_stats[plate].engine ~= nil and veh_stats[plate].engine ~= 'default' and currentengine[plate] ~= GetHashKey(tostring(veh_stats[plate].engine)) then
		SetEngineSpecs(vehicle, GetHashKey(tostring(veh_stats[plate].engine)))
		print("new ENGINE")
	end
	if veh_stats[plate].tires ~= nil and veh_stats[plate].tires ~= 'default' then
		TireFunction(veh_stats[plate].tires)
	end
	if veh_stats[plate].manual and not manual then
		TriggerEvent('renzu_hud:manual', veh_stats[plate].manual)
	end
	if veh_stats[plate].turbo ~= nil and veh_stats[plate].turbo ~= 'default' and not alreadyturbo then
		TriggerEvent('renzu_hud:hasturbo', veh_stats[plate].turbo)
		alreadyturbo = true
	end
	local numwheel = GetVehicleNumberOfWheels(vehicle)
	for i = 0, numwheel - 1 do
		if veh_stats[plate][tostring(i)] == nil then
			veh_stats[plate][tostring(i)] = {}
			veh_stats[plate][tostring(i)].tirehealth = config.tirebrandnewhealth
		end
	end
	if lets_save then
		TriggerServerEvent('renzu_hud:savedata', saveplate, veh_stats[tostring(saveplate)])
		lets_save = false -- why?
	end
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
			TriggerServerEvent("renzu_hud:getdata",charslot)
		end
		Renzuzu.Wait(1000)
		while veh_stats == nil and invehicle do
			Renzuzu.Wait(100)
		end
		Creation(function()
			oldnitro = nil
			while invehicle do
				local wait = 10000
				--local plate = tostring(GetVehicleNumberPlateText(vehicle))
				while veh_stats[plate] == nil and invehicle do
					Renzuzu.Wait(1000)
				end
				nitros = veh_stats[plate].nitro
				if oldnitro == nil or oldnitro ~= nitros then
					oldnitro = veh_stats[plate].nitro
					RenzuSendUI({
						type = "setNitro",
						content = nitros
					})
				end
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
		--print("NUI DATA")
		while invehicle do
			Renzuzu.Wait(config.mileage_update)
			local ped = ped
			local vehicle = vehicle
			local driver = GetPedInVehicleSeat(vehicle, -1)
			if vehicle ~= nil and vehicle ~= 0 and driver == ped then
				-- local plate = tostring(GetVehicleNumberPlateText(vehicle))
				-- plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
				local newPos = GetEntityCoords(ped)
				savemile = true
				lastve = GetVehiclePedIsIn(ped, false)
				if plate ~= nil then
					--saveplate = string.match(GetVehicleNumberPlateText(vehicle), '%f[%d]%d[,.%d]*%f[%D]')
					if veh_stats[plate] == nil then
						get_veh_stats()
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
							if config.useturboitem and veh_stats[plate].turbo_health ~= nil then
								veh_stats[plate].turbo_health = veh_stats[plate].turbo_health - (( dist / 1000 ) * config.mileage_speed)
							end
						end
						if config.enabletiresystem then
							local dist3 = #(newPos-oldPos3)
							if dist3 > config.driving_status_radius then
								oldPos3 = newPos
								local numwheel = GetVehicleNumberOfWheels(vehicle)
								for i = 0, numwheel - 1 do
									Wait(100)
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
											SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", GetHandling(GetPlate(vehicle)).traction * config.curveloss)
											SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", GetHandling(GetPlate(vehicle)).traction2 * config.acceleratetractionloss)
										end
									end
									--print("reduct tires")
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
				TriggerServerEvent('renzu_hud:savedata', saveplate, veh_stats[tostring(saveplate)])
				Wait(1000)
				lastve = nil
				saveplate = nil
			else
				Wait(1000)
			end
		end
		--TerminateThisThread()
		return
	end)
end

function NuiVehicleHandbrake()
	--NUI HANDBRAKE
	local ped = ped
	local vehicle = vehicle
	if vehicle ~= nil and vehicle ~= 0 then
		RenzuSendUI({
		type = "setBrake",
		content = true
		})
		while RCP(0, 22) do
			Wait(100)
		end
		RenzuSendUI({
			type = "setBrake",
			content = false
		})
	end
	--TerminateThisThread()
end

function NuiShowMap()
	CreateThread(function()
		Wait(2000)
		print(config.carui,"MAP")
		if config.centercarhud == 'map' and config.carui == 'modern' then
			Renzuzu.Wait(1000)
			while not start and config.push_start do
				Renzuzu.Wait(10)
			end
			RenzuSendUI({map = true, type = 'bukas'})
			local t = {['custom'] = config.usecustomlink,['type'] = config.mapversion,['link'] = config.mapurl}
			RenzuSendUI({type = "setMapVersion",content = t})
			ismapopen =  true
			Wait(250)
			while invehicle do
				--print("map ui")
				local sleep = 2000
				--print(GetNuiCursorPosition())
				if config.carui ~= 'modern' then
					break
				end
				if start and config.carui == 'modern' then
					sleep = 250
					local myh = GetEntityHeading(ped) + GetCamhead()
					local camheading = GetCamhead()
					local xz, yz, zz = table.unpack(GetEntityCoords(ped))
					if oldxz ~= xz or oldcamheading ~= camheading or camheading == nil and xz == nil then
						oldcamheading = camheading
						oldxz = xz
						local table = {
							myheading = myh,
							camheading = camheading,
							x = xz,
							y = yz
						}
						--print("send coords map ui")
						RenzuSendUI({map = true, type = "updatemapa",content = table})
						RenzuSendUI({map = true, type = 'bukas'})
					end
				end
				Wait(sleep)
			end
			--TerminateThisThread()
		end
		return
	end)
end

function getveh()
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	local lastveh = GetVehiclePedIsIn(PlayerPedId(), true)
	local dis = -1
	if v == 0 then
		if #(GetEntityCoords(ped) - GetEntityCoords(lastveh)) < 5 then
			v = lastveh
		end
		dis = #(GetEntityCoords(ped) - GetEntityCoords(lastveh))
	end
	if dis > 3 then
		v = 0
	end
	if v == 0 then
		local count = 5
		v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
		while #(GetEntityCoords(ped) - GetEntityCoords(v)) > 5 and count >= 0 do
			v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
			count = count - 1
			Wait(400)
			--print("fucker")
		end
	end
	return tonumber(v)
end

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
		while GetVehicleEngineTemperature(ent) > config.overheatmin do
			local Smoke = 0
			local part1 = false
			Creation(function()
				LoadPTFX('core')
				Smoke = Renzu_Hud(0xDDE23F30CC5A0F03, 'ent_amb_stoner_vent_smoke', ent, 0.05, 0, 0, 0, 0, 0, 28, 0.4, false, false, false, 0, 0, 0, 0)
				RemoveNamedPtfxAsset("core")
				part1 = true
			end)
			while not part1 do
				Renzuzu.Wait(1011)
			end
			Renzuzu.Wait(400)
			table.insert(smokes, {handle = Smoke})
			removeFCK()
			Renzuzu.Wait(500)
		end
		refresh = false
		Renzuzu.Wait(5000)
		return
    end)
end

function removeFCK()
	Creation(function()
		for _,parts in pairs(smokes) do
			--print("removing "..parts.handle.."")
			if parts.handle ~= nil and parts.handle ~= 0 and isparticleexist(parts.handle) then
				stopparticles(parts.handle, true)
				smokes[_].handle = nil
				smokes[_] = nil
			else
				smokes[_] = nil
			end
		end
		smokes = {}
		return
	end)
end

function usefuckingshit(val)
    return Renzu_Hud(0x6C38AF3693A69A91, val)
end

function isparticleexist(val)
    return Renzu_Hud(0x74AFEF0D2E1E409B, val)
end

function stopparticles(val,bool)
    return Renzu_Hud(0x8F75998877616996, val, 0)
end

function startfuckingbullshit(effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3)
    return Renzu_Hud(0xDDE23F30CC5A0F03, effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3, 0, 0, 0, 0)
end

function NuiEngineTemp()
	--NUI ENGINE TEMPERATURE STATUS
	Creation(function()
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
			return
		end)
		Renzuzu.Wait(1000)
		--triggered = false
		local vehiclemodel = GetEntityModel(vehicle)
		while invehicle and not toohot do
			local sleep = 2000
			local ped = ped
			local vehicle = vehicle
			newtemp = nil
			if vehicle ~= nil and vehicle ~= 0 then
				--print(veh_stats[plate].coolant)
				sleep = 2000
				local temp = GetVehicleEngineTemperature(vehicle)
				local overheat = false
				while rpm > config.dangerrpm and config.engineoverheat and not config.driftcars[vehiclemodel] do
					--rpm = VehicleRpm(vehicle)
					Renzuzu.Wait(1000)
					--print("Overheat")
					SetVehicleEngineCanDegrade(vehicle, true)
					SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + config.addheat)
					if newtemp ~= GetVehicleEngineTemperature(vehicle) or newtemp == nil then
						newtemp = GetVehicleEngineTemperature(vehicle)
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
								TriggerServerEvent("renzu_hud:smokesync", VehToNet(vehicle), GetEntityCoords(vehicle,false))
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
				--print("SMOKING")
				local done = false
				Renzuzu.Wait(5000)
				Notify('warning','Engine System',"Engine Temp: "..GetVehicleEngineTemperature(GetVehiclePedIsIn(ped,true)).."")
				Renzuzu.Wait(1000)
			end
			overheatoutveh = false
			--TerminateThisThread()
			return
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
		return
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
		xPlayer = ESX.PlayerData
		local money = 0
		local black = 0
		local bank = 0
		for k,v in ipairs(xPlayer.accounts) do
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
			bank = bank,
			id = GetPlayerServerId(PlayerId())
		}
		RenzuSendUI({
			hud = "setInfo",
			content = info
		})
		collectgarbage()
	end
end

newarmor = nil
newhealth = nil
function updateplayer(instant)
	health = (GetEntityHealth(ped)-100)
	armor = GetPedArmour(ped)
	pid = PlayerId()
	config.statusordering[1].value = armor
	config.statusordering[0].value = health
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
end

function haveseatbelt()
local vc = GetVehicleClass(vehicle)
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
			return
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
			return
		end)
	end
end

function impactdamagetoveh()
	if alreadyblackout then
		if not accident then
			accident = true
			Citizen.CreateThread(function()
				local vehicle = vehicle
				local index = math.random(0, 15)
				local tankdamage = math.random(1, config.randomdamage)
				local enginedamage = math.random(1, config.randomdamage) 
				local vehiclebodydamage = math.random(1, config.randomdamage)
				SetVehiclePetrolTankHealth(vehicle,GetVehiclePetrolTankHealth(vehicle) - tankdamage )
				SetVehicleTyreBurst(vehicle,index, 0 , 80.0)
				SetVehicleEngineHealth(vehicle ,GetVehicleEngineHealth(vehicle) - enginedamage)
				SetVehicleBodyHealth(vehicle, GetVehicleBodyHealth(vehicle) - vehiclebodydamage) 
				SetVehicleOilLevel(vehicle, GetVehicleOilLevel(vehicle) + 5.0 ) -- max is 15?
				SetVehicleCanLeakOil(vehicle, true)
				SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + 45.0 )
				Citizen.Wait(3000) 
				accident = false
				return
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
		return
	end)
end

function SendNuiSeatBelt()
	Citizen.Wait(300)
	if config.seatbelt_2 then
		SetFlyThroughWindscreenParams(config.seatbeltminspeed, 2.2352, 0.0, 0.0)
		SetPedConfigFlag(PlayerPedId(), 32, true)
	end
	if vehicle ~= nil and vehicle ~= 0 and config.enableseatbeltfunc and not config.seatbelt_2 then
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
				if speed > config.seatbeltminspeed and HasEntityCollidedWithAnything(vehicle) and Session[2] ~= nil and not belt and GetEntitySpeedVector(vehicle,true).y > 5.2 and Session[1] > 15.25 and (Session[2] - Session[1]) > (Session[1] * 0.105) then
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
			return
		end)
	end
end

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
		return
	end)
end

function entervehicle()
	if config.carui ~= 'modern' then return end
	local p = PlayerPedId()
	v = GetVehiclePedIsEntering(p)
	local mycoords = GetEntityCoords(p)
	if not IsPedInAnyVehicle(p) and IsAnyVehicleNearPoint(mycoords.x,mycoords.y,mycoords.z,10.0) then
		--print("ENTERING")
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
		if GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and config.carui == 'modern' then
			entering = true
			--print("Disable auto start")
			SetVehicleEngineOn(v,false,true,true)
			while not start and IsPedInAnyVehicle(p) do
				if not start and IsVehicleEngineStarting(v) then
					SetVehicleEngineOn(v,false,true,true)
					--print("not started yet")
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
			manual = false
		end
		local content = {
			['bool'] = false,
			['type'] = config.carui
		}
		if ismapopen then
			RenzuSendUI({map = true, type = 'sarado'})
			ismapopen = false
		end
		while IsPedInAnyVehicle(ped, false) do
			Renzuzu.Wait(11)
		end
		Wait(1000)
		RenzuSendUI({
			type = "setShow",
			content = content
		})
	end
end

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

function turbolevel(value, lvl)
    if value > lvl then
        return lvl
    end
    return value
end

function maxnum(b, rpm)
    if b > 3.0 then
        b = 3.0
    end
    if b < 0.0 then
        return 0.0
    end
    return turbolevel(b, turbo)

end
function maxforce(b, min)
    if b > 1.5 then
        b = 1.5
    end
    if b < 0.0 then
        return 0.0
    end
	if b < min then
		b = min
	end
    return b
end

function Round(num,numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function Fuel(vehicle)
	if IsVehicleEngineOn(vehicle) and rpm ~= nil and rpm > 0 then
		local rpm = rpm
		local gear = GetGear(vehicle)
		local engineload = (rpm * (gear / 10))
		local formulagasusage = 1.0
		if config.usecustomfuel and config.mileage_affect_gasusage then
			currentmileage = veh_stats[plate].mileage
			formulagasusage = 1 + (currentmileage/config.mileagemax)
		end
		--print(formulagasusage,"formula")
		local boostgas = config.boost
		if config.turbo_boost_usage and boost > config.boost_min_level_usage then
			config.boost = boost * (engineload / (GetVehicleTurboPressure(vehicle) * rpm))
		end
		local result = (config.fuelusage[Round(rpm,1)] * (config.classes[GetVehicleClass(vehicle)] or 1.0) / 15) * (formulagasusage)
		local advformula = result + (result * engineload)
		if mode == 'SPORTS' or config.turbo_boost_usage and boost > config.boost_min_level_usage then
			advformula = advformula * (1 + config.boost)
		end
		if mode == 'ECO' then
			advformula = advformula * config.eco
		end
		--print("FUEL USAGE: "..result..", ADV: "..advformula.." EngineLoad: "..engineload.."")
		SetVehicleFuelLevel(vehicle,GetVehicleFuelLevel(vehicle) - advformula)
		DecorSetFloat(vehicle,config.fueldecor,GetVehicleFuelLevel(vehicle))
		config.boost = boostgas
	end
end

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
		return
	end)
end

function turboboost(gear)
	local engineload = 0.05
	if gear == 1 then
		engineload = 0.11
	elseif gear == 2 then
		engineload = 0.25
	elseif gear == 3 then
		engineload = 0.35
	elseif gear == 4 then
		engineload = 0.45
	elseif gear == 5 then
		engineload = 0.55
	elseif gear == 6 then
		engineload = 0.65
	end
	return engineload 
end

function Boost(hasturbo)
	local newgear = 0
	local rpm = VehicleRpm(vehicle)
	local gear = GetGear(vehicle)
	boost = 1.0
	local boost_pressure = 0.0
	Creation(function()
		while invehicle do
			local sleep = 2000
			local vehicle = vehicle
			if vehicle ~= 0 then
				sleep = 10
				rpm = VehicleRpm(vehicle)
				gear = GetGear(vehicle)
			end
			Renzuzu.Wait(sleep)
		end
		return
	end)
	if hasturbo and config.turbo_boost[veh_stats[plate].turbo] > config.boost then
		turbo = config.turbo_boost[veh_stats[plate].turbo]
		ToggleVehicleMod(vehicle, 18, true)
	else
		turbo = config.boost
	end
	local torque = 0
	Creation(function()
		--print("starting boost func")
		local turbo_type = tostring(veh_stats[plate].turbo or 'default')
		while hasturbo and invehicle do
			local sleep = 2000
			--local ply = PlayerPedId()
			local reset = true
			local vehicle = vehicle
			if vehicle ~= 0 then
				sleep = 7
				boost = 1.0
				newgear = gear
				local vehicleSpeed = 0
				local rpm2 = rpm
				local engineload = (rpm / (gear / 10)) / 100
				if rpm > 1.15 then
				elseif rpm > 0.1 then
					rpm = (rpm * turbo)
				elseif rpm < 0.0 then
					rpm = 0.2
				end
				if rpm2 < 0.0 then
					rpm2 = 0.2
				end
				--print(rpm)
				if tonumber(rpm) > 0.3 then
					--local speed = VehicleSpeed(vehicle) * 3.6
					if sound and IsControlJustReleased(1, 32) then
						StopSound(soundofnitro)
						ReleaseSoundId(soundofnitro)
						sound = false
					end

					local lag = 1
					local pressure = 0.5
					if IsControlPressed(1, 32) and plate ~= nil and veh_stats[plate] ~= nil then
						if not sound then
							soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
							sound = true
						end
						--print(engineload,"ENGINELOAD")
						--SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed*3.500000)
						local turbolag = 5 + config.turbo_boost[turbo_type]
						local maxspeed = maxspeed
						if maxspeed > 200 then
							maxspeed = 200
						end
						while veh_stats[plate] ~= nil and lag < (config.lagamount[turbo_type] * config.turbo_boost[turbo_type]) and (engineload / ((maxspeed) / (config.lagamount[turbo_type] * lag))) < turboboost(gear) and IsControlPressed(1, 32) do
							engineload = tonumber((rpm * (gear / turbolag)))
							--ShowHelpNotification(tostring(engineload), true, 1, 5)
							if tonumber(engineload) then
							--engineload =  tonumber(maxnum(((rpm2 + 0.1) * config.turbo_boost[tostring(veh_stats[plate].turbo)])) * (1 + engineload))
							if engineload > 0.0 and engineload < 10.0 and tonumber(engineload) then
								pressure = (tonumber(rpm * config.turbo_boost[turbo_type]) + (engineload))
								if turbo_type == 'sports' then -- temporary to correct sports value
									pressure = pressure * 1.4
								end
							end
							lag = lag + 0.05
							end
							local boosttemp = 0.1 + (rpm2 / 2)
							if boosttemp < 0.3 then
								boosttemp = 0.3
							end
							--SetVehicleBoost(vehicle, boosttemp)
							Renzuzu.Wait(1)
							--Notify('success',"PRESSURE",lag)
							--drawTxt("BOOST lag:  "..(config.lagamount[turbo_type] * lag).."",4,0.5,0.93,0.50,255,255,255,180)
							--drawTxt("BOOST engineload:  "..(engineload / (DecorGetFloat(vehicle,"TOPSPEED") / (config.lagamount[turbo_type] * lag))).."",4,0.5,0.83,0.50,255,255,255,180)
						end
						--drawTxt("BOOST pressure:  "..pressure.."",4,0.5,0.79,0.50,255,255,255,180)
						if config.boost_sound and rpm2 > 0.65 and rpm2 < 0.95 and turbosound < 5 and gear == oldgear and engineload > turboboost(gear) then
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
						SetVehicleTurboPressure(vehicle, 0.0)
					end
					SetVehicleTurboPressure(vehicle, pressure)
					boost_pressure = GetVehicleTurboPressure(vehicle)
					if gear == 0 then
						gear = 1
					end
					boost = (boost_pressure * 7)
					if IsControlPressed(1, 32) and rpm > 0.4 and not RCR(1, 32) then
						pressed = true
						if boost < 1.0 then
							boost = 1.0
						end
						if boost < 0.0 or boost > 45.0 then
							boost = 1.0
						end
						if config.turbogauge and turbo ~= nil and boost_pressure ~= nil and boost_pressure > 0 then
							RenzuSendUI({
								type = "setTurboBoost",
								content = {
									['speed'] = boost_pressure / 2.65,
									['max'] = turbo
								}
							})
							Wait(1)
						end
					else
						Wait(100)
					end
					if GetVehicleThrottleOffset(vehicle) <= 0.0 then
						Wait(200)
						pressed = false
						local t = {
							['speed'] = 0.0,
							['max'] = turbo
						}
						RenzuSendUI({
							type = "setTurboBoost",
							content = t
						})
						Wait(10)
					end
					if degrade ~= 1.0 then -- config.turbo_boost[veh_stats[plate].turbo]
						if plate ~= nil and veh_stats[plate] and config.turbo_boost[turbo_type] > config.boost then
							boostlevel = config.turbo_boost[turbo_type]
						else
							boostlevel = config.boost
						end
						boost = boost * (degrade / boostlevel)
					end
					--ShowHelpNotification(boost, true, 1, 5)
				else
					rpm = VehicleRpm(vehicle)
					Wait(100)
				end
			end
			Renzuzu.Wait(sleep)
		end
		return
	end)
	-- Creation(function()
	-- 	local pressed = false
	-- 	while invehicle do
	-- 		if IsControlPressed(1, 32) and rpm > 0.4 and not RCR(1, 32) then
	-- 			pressed = true
	-- 			if boost < 1.0 then
	-- 				boost = 1.0
	-- 			end
	-- 			if boost < 0.0 or boost > 45.0 then
	-- 				boost = 1.0
	-- 			end
	-- 			if config.turbogauge then
	-- 				RenzuSendUI({
	-- 					type = "setTurboBoost",
	-- 					content = {
	-- 						['speed'] = boost_pressure / 2.65,
	-- 						['max'] = turbo
	-- 					}
	-- 				})
	-- 				Wait(1)
	-- 			end
	-- 		else
	-- 			Wait(100)
	-- 		end
	-- 		if GetVehicleThrottleOffset(vehicle) <= 0.0 then
	-- 			Wait(200)
	-- 			pressed = false
	-- 			local t = {
	-- 				['speed'] = 0.0,
	-- 				['max'] = turbo
	-- 			}
	-- 			RenzuSendUI({
	-- 				type = "setTurboBoost",
	-- 				content = t
	-- 			})
	-- 			Wait(10)
	-- 		end
	-- 		Citizen.Wait(7)
	-- 	end
	-- end)

	Creation(function()
		local pressed = false
		while invehicle do
			local sleep = 100
			if IsControlPressed(1, 32) and rpm > 0.4 and not RCR(1, 32) then
				sleep = 7
				pressed = true
				if boost < 1.0 then
					boost = 1.0
				end
				if boost < 0.0 or boost > 45.0 then
					boost = 1.0
				end
				if mode == 'SPORTS' and not hasturbo then
					SetVehicleBoost(vehicle, 1.0 + config.boost)
				else
					SetVehicleBoost(vehicle, boost*1.01)
				end
			else
				Wait(100)
			end
			Citizen.Wait(sleep)
		end
		RenzuSendUI({
			type = "setShowTurboBoost",
			content = false
		})
		alreadyturbo = false
		globaltopspeed = nil
		topspeedmodifier = 1.0
		busy = true
		Renzuzu.Wait(100)
		vehicle = getveh()
		if DoesEntityExist(vehicle) and GetHandling(GetPlate(vehicle)).flywheel ~= 0.0 and GetHandling(GetPlate(vehicle)).finaldrive ~= 0.0 then
			SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", GetHandling(GetPlate(vehicle)).maxspeed)
			SetVehStats(vehicle, "CHandlingData", "fDriveInertia", GetHandling(GetPlate(vehicle)).finaldrive)
			SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", GetHandling(GetPlate(vehicle)).flywheel)
			while not GetVehStats(vehicle, "CHandlingData","fDriveInertia") == GetHandling(GetPlate(vehicle)).finaldrive and invehicle do
				if GetHandling(GetPlate(vehicle)).finaldrive ~= nil then
					SetVehStats(vehicle, "CHandlingData", "fDriveInertia", GetHandling(GetPlate(vehicle)).finaldrive)
				end
				Renzuzu.Wait(0)
			end
			while not GetVehStats(vehicle, "CHandlingData","fInitialDriveForce") == GetHandling(GetPlate(vehicle)).flywheel and invehicle do
				if GetHandling(GetPlate(vehicle)).flywheel ~= nil then
					SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", GetHandling(GetPlate(vehicle)).flywheel)
				end
				Renzuzu.Wait(0)
			end
		end
		SetVehicleEnginePowerMultiplier(vehicle, 1.0) -- just incase
		busy = false
		StopSound(soundofnitro)
		ReleaseSoundId(soundofnitro)
		if propturbo ~= nil then
			--print("deleting")
			ReqAndDelete(propturbo,true)
			propturbo = nil
		end
		boost = 1.0
		return
	end)
end

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
			while mode == 'SPORTS' and invehicle do
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
			return
		end)

		local sound = false
		Creation(function()
			local newgear = 0
			olddriveinertia = GetHandling(GetPlate(vehicle)).finaldrive
			oldriveforce = GetHandling(GetPlate(vehicle)).flywheel
			oldtopspeed = GetHandling(GetPlate(vehicle)).maxspeed -- normalize
			local fixedshit = (config.topspeed_multiplier * 1.0)
			local old = oldtopspeed * 1.0
			local turbosound = 0
			local oldgear = 0
			local fo = oldtopspeed * 0.64
			if config.sports_increase_topspeed then
				if GetVehicleMod(vehicle,13) > 0 then
					local bonus = (GetHandling(GetPlate(vehicle)).maxspeed * config.topspeed_multiplier)
					globaltopspeed = bonus * 1.5
				else
					globaltopspeed = GetHandling(GetPlate(vehicle)).maxspeed * config.topspeed_multiplier
				end
				SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", globaltopspeed)
			end
			local plate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
			plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
			while mode == 'SPORTS' and config.turbo_boost[veh_stats[plate].turbo] > config.boost and invehicle do
				Citizen.Wait(1000) -- do nothing turbo torque is more higher
			end
			Boost()
			return
		end)
	elseif mode == 'SPORTS' and invehicle then
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
			olddriveinertia = GetHandling(GetPlate(vehicle)).finaldrive
			SetVehStats(vehicle, "CHandlingData", "fDriveInertia", config.eco)
			while mode == 'ECO' and invehicle do
				local sleep = 2000
				local reset = true
				local vehicle = vehicle
				if vehicle ~= 0 then
					sleep = 7
					if IsControlPressed(1, 32) then
						local power = config.eco+0.4
						if degrade ~= 1.0 then
							power = power * degrade
						end
						SetVehStats(vehicle, "CHandlingData", "fDriveInertia", config.eco)
						SetVehicleBoost(vehicle, (config.eco+0.4))
					end
				end
				Renzuzu.Wait(sleep)
			end
			busy = true
			Renzuzu.Wait(100)
			vehicle = getveh()
			if DoesEntityExist(vehicle) and GetHandling(GetPlate(vehicle)).finaldrive ~= 0.0 then
				SetVehStats(vehicle, "CHandlingData", "fDriveInertia", GetHandling(GetPlate(vehicle)).finaldrive)
				while not GetVehStats(vehicle, "CHandlingData","fDriveInertia") == GetHandling(GetPlate(vehicle)).finaldrive and invehicle do
					SetVehStats(vehicle, "CHandlingData", "fDriveInertia", GetHandling(GetPlate(vehicle)).finaldrive)
					Renzuzu.Wait(0)
				end
			end
			busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
			return
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

function differential()
	----print("pressed")
	local diff = GetVehStats(vehicle, "CHandlingData","fDriveBiasFront")
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
		--print("FWD")
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
		return
	end)
end

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
end

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
end

function Cruisecontrol()
	PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	cruising = not cruising
	Citizen.Wait(500)
	Citizen.CreateThread(function()
		RenzuSendUI({
			type = "setCruiseControl",
			content = cruising
		})
		local topspeed = GetHandling(GetPlate(vehicle)).maxspeed * 0.64
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
		return
	end)
end

local sprinting = false
function setStatusEffect()
	if config.running_affect_status then
		if IsPedRunning(ped) or IsPedSprinting(ped) then
			if not sprinting then
				sprinting = true
				Citizen.Wait(111)
				--print("running")
				Citizen.CreateThread(function()
					while IsPedSprinting(ped) or IsPedRunning(ped) do
						UpdateStatus(true)
						TriggerEvent('esx_status:'..config.running_status_mode..'', config.running_affected_status, config.running_status_val)
						Wait(500)
					end
					sprinting = false
					return
				end)
			end
		end
	end
	if config.melee_combat_affect_status then
		if IsPedInMeleeCombat(ped) then
			Citizen.Wait(1000)
			TriggerEvent('esx_status:'..config.melee_combat_status_mode..'', config.melee_combat_affected_status, config.melee_combat_status_val)
		end	
	end
	if config.parachute_affect_status then
		if IsPedInParachuteFreeFall(ped) then
			Citizen.Wait(1000)
			TriggerEvent('esx_status:'..config.parachute_status_mode..'', config.parachute_affected_status, config.parachute_status_val)
		end	
	end
	if config.playing_animation_affect_status then
		--if IsEntityPlayingAnim(ped, )
		for k,v in pairs(config.status_animation) do
			Wait(0)
			if IsEntityPlayingAnim(ped, v.dict, v.name, 3) then
				--print("LOADED")
				TriggerEvent('esx_status:'..v.mode..'', v.status, v.val)
				Citizen.Wait(1000)
			end
		end
	end
	if IsPedSwimmingUnderWater(ped) then
		UpdateStatus(true)
	end
end

function statusplace()
	local placing = config.statusplace
	local table = {}
	if placing == 'top-right' then
		if config.status_type == 'icons' then
			table = {['top'] = '45px', ['right'] = '90px'}
		else
			if config.statusui == 'simple' then
				table = {['top'] = '40px', ['right'] = '110px'}
			else
				table = {['top'] = '10px', ['right'] = '110px'}
			end
		end
	elseif placing == 'top-left' then
		if config.statusui == 'simple' then
			if config.status_type == 'icons' then
				table = {['top'] = '40px', ['left'] = '-110px'}
			else
				table = {['top'] = '85px', ['left'] = '-55px'}
			end

		else
			if config.status_type == 'icons' then
				table = {['top'] = '50px', ['left'] = '-155px'}
			else
				table = {['top'] = '25px', ['left'] = '-105px'}
			end
		end
	elseif placing == 'bottom-left' then
		if config.statusui == 'simple' then
			table = {['bottom'] = '-1vh', ['left'] = '1vh'}
		else
			table = {['bottom'] = '20px', ['left'] = '-35px'}
		end
	elseif placing == 'bottom-right' then
		if config.status_type == 'icons' then
			table = {['bottom'] = '20px', ['right'] = '25px'}
		else
			table = {['bottom'] = '0px', ['right'] = '85px'}
		end
	elseif placing == 'bottom-center' then
		table = {['bottom'] = '20px', ['left'] = '35%', ['right'] = '35%'}
	elseif placing == 'top-center' then
		if config.status_type == 'icons' then
			table = {['top'] = '40px', ['left'] = '45%', ['right'] = '45%'}
		else
			table = {['top'] = '10px', ['left'] = '25%'}
		end
	end
	RenzuSendUI({
		type = "setStatusUILocation",
		content = table
	})
end

-- BODY STATUS

function CheckPatient()
	if xPlayer.job ~= nil and xPlayer.job.name == config.checkbodycommandjob then
		local players, myPlayer = {}, PlayerId()
		for k,player in ipairs(GetActivePlayers()) do
			local ped = GetPlayerPed(player)
			if DoesEntityExist(ped) and player ~= myPlayer then
				table.insert(players, player)
			end
		end
		local closest,dist
		for k,v in pairs(players) do
			local o_id = GetPlayerServerId(v)
			if o_id ~= GetPlayerServerId(PlayerId()) then
				local curDist = #(GetPlayerPed(v) - GetEntityCoords(ped))
				if not dist or curDist < dist then
					closest = o_id
					dist = curDist
				end
			end
		end
		if closest ~= nil then
			BodyUi(closest)
		else
			Notify('success','Body System',"No Player Around")
		end
	else
		Notify('success','Body System',"No Access to CheckBody")
	end
end

checkingpatient = false
function BodyUi(target)
	--print(target)
	healing = target
	if target ~= nil then
		checkingpatient = true
		TriggerServerEvent('renzu_hud:checkbody', tonumber(target))
	end
	bodyui = not bodyui
	if target == nil then
		RenzuSendUI({
			type = "setShowBodyUi",
			content = bodyui
		})
	end
	Wait(100)
	if target ~= nil then
		while bodyui do
			Wait(100)
		end
		checkingpatient = false
		TriggerServerEvent('renzu_hud:checkbody')
	end
end

function BodyLoop()
	if checkingpatient then return end
	if receive == 'new' then return end
	Citizen.Wait(2500)
	local ped = ped
	local pid = pid
	if bonecategory["ped_head"] == nil then
		bonecategory["ped_head"] = 0
	end
	if bonecategory["left_leg"] == nil then
		bonecategory["left_leg"] = 0
	end
	if bonecategory["right_leg"] == nil then
		bonecategory["right_leg"] = 0
	end
	if bonecategory["ped_body"] == nil then
		bonecategory["ped_body"] = 0
	end
	if bonecategory["left_hand"] == nil then
		bonecategory["left_hand"] = 0
	end
	if bonecategory["right_hand"] == nil then
		bonecategory["right_hand"] = 0
	end
	if not head and bonecategory["ped_head"] > 0 then
		SetTimecycleModifier(config.headtimecycle)
		SetTimecycleModifierStrength(math.min(bonecategory["ped_head"] * 0.4, 1.1))
		head = true
		Notify('error','Body System',"Head has been damaged")
	elseif bonecategory["ped_head"] <= 0 then
		if head then
			ClearTimecycleModifier()
			head = false 
		end
	end
	if bonecategory["ped_body"] > 0 then
		if not body then
			bodydamage()
			Notify('error','Body System',"Chest has been damaged")
		end
		body = true
		SetPlayerHealthRechargeMultiplier(pid, 0.0)
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
		SetPedMoveRateOverride(ped, 0.6)
		SetPedMovementClipset(ped, "move_m@injured", true)
	elseif leg then
		leg = false
		ResetPedMovementClipset(GetPlayerPed(-1))
		ResetPedWeaponMovementClipset(GetPlayerPed(-1))
		ResetPedStrafeClipset(GetPlayerPed(-1))
		SetPedMoveRateOverride(ped, 1.0)
	else
		leg = false
	end
end

function bodydamage()
	Creation(function()
		while body do
			Citizen.Wait(5000)
			if config.disabledsprint then
				SetPlayerSprint(pid, false)
			end
			if config.disabledregen then
				SetPlayerHealthRechargeMultiplier(pid, 0.0)
			end
			--print(health)
			if health ~= nil and health > 40 then
				SetEntityHealth(PlayerPedId(),(health + 100) - config.chesteffect_healthdegrade)
			end
		end
		SetPlayerHealthRechargeMultiplier(pid, 1.0)
		SetPlayerSprint(pid, true)
	end)
	return
end

function recoil(r)
	tv = 0
	if GetFollowPedCamViewMode() ~= 4 then
		Wait(0)
		p = GetGameplayCamRelativePitch()
		SetGameplayCamRelativePitch(p+0.3, (bonecategory["left_hand"] + bonecategory["right_hand"] / 5) * config.firstperson_armrecoil)
		tv = tv+0.1
	else
		Wait(0)
		p = GetGameplayCamRelativePitch()
		if r > 0.1 then
			SetGameplayCamRelativePitch(p+0.6, (bonecategory["left_hand"] + bonecategory["right_hand"] / 5) * config.firstperson_armrecoil)
			tv = tv+0.6
		else
			SetGameplayCamRelativePitch(p+0.016, 0.333)
			tv = tv+0.1
		end
	end
end

function armdamage() -- vehicle
	Creation(function()
		local oldveh = nil
		while arm do
			if config.melee_decrease_damage then
				while IsPedInMeleeCombat(ped) do
					Citizen.Wait(5)
					SetPlayerMeleeWeaponDamageModifier(pid, config.melee_damage_decrease)
				end
			end
			while invehicle do
				if vehicle ~= nil and vehicle ~= 0 then
					if oldveh ~= vehicle then
						steeringlock = GetVehStats(vehicle, "CHandlingData","fSteeringLock")
						DecorSetFloat(vehicle, "STEERINGLOCK", steeringlock)
						if bonecategory["left_hand"] > 0 or bonecategory["right_hand"] > 0 then
							local steer = (steeringlock - (bonecategory["left_hand"] + bonecategory["right_hand"]))
							if steer < 5.0 then
								steer = 5.0
							end
							SetVehStats(vehicle, "CHandlingData", "fSteeringLock", (steer * config.armdamage_invehicle_effect))
						end
					end
				end
				Citizen.Wait(2000)
				oldveh = vehicle
			end
			if oldveh ~= nil then
				oldveh = nil
				SetVehStats(getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(getveh(),"STEERINGLOCK")) -- the back the original stats
			end
			Citizen.Wait(3000) -- Wait until ped goes off to vehicle or until arm is in pain.
		end
		SetVehStats(getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(getveh(),"STEERINGLOCK")) -- the back the original stats
		return
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
		return
	end)
end

function CheckBody()  
	local ok, id = GetPedLastDamageBone(ped)
	if ok then
		for damagetype,val in pairs(config.buto) do
			Wait(0)
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

function BodyMain()
	local life = health
	if health ~= nil and life < oldlife then
		local index,bodytype = nil, nil
		if not config.weaponsonly or not HasEntityBeenDamagedByWeapon(ped, 0 , 1) and HasEntityBeenDamagedByWeapon(ped, 0 , 2) and config.weaponsonly then
			index,bodytype = CheckBody()
			--if isWeapon(GetPedCauseOfDeath(PlayerPedId())) then
		if index and bodytype then
			if index ~= nil and parts[tostring(bodytype)] ~= nil and parts[tostring(bodytype)][tostring(index)] ~= nil and bonecategory ~= nil and bonecategory[tostring(bodytype)] ~= nil then
				parts[bodytype][index] = parts[bodytype][index] + config.damageadd
				bonecategory[bodytype] = bonecategory[bodytype] + config.damageadd
				--print("saving")
				RenzuSendUI({
					type = "setUpdateBodyStatus",
					content = bonecategory
				})
				if bonecategory['ped_head'] > 0 and config.bodyinjury_status_affected then
					TriggerEvent('esx_status:'..config.headbone_status_mode..'', config.headbone_status, bonecategory['ped_head'] * config.headbone_status_value)
				end
				ApplyPedBlood(ped, GetPedBoneIndex(ped,index), 0.0, 0.0, 0.0, "wound_sheet")
				Citizen.InvokeNative(0x8EF6B7AC68E2F01B, PlayerPedId())
				TriggerServerEvent('renzu_hud:savebody', bonecategory)
			end
		end
		end
	end
	oldlife = GetEntityHealth(ped)
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
		return
	end)
end

function CarControl()
	if busy then return end
	isbusy = true
	vehicle = getveh()
	if vehicle ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) < 15 and GetVehicleDoorLockStatus(vehicle) == 1 then
		local door = {}
		local window = {}
		for i = 0, 6 do
			Wait(10)
			door[i] = false
			if GetVehicleDoorAngleRatio(vehicle,i) ~= 0.0 then
				----print("Door",GetVehicleDoorAngleRatio(vehicle,i))
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
		RenzuSendUI({
			type = "setDoorState",
			content = door
		})
		RenzuSendUI({
			type = "setWindowState",
			content = window
		})
		Wait(500)
		SetNuiFocus(carcontrol,carcontrol)
		SetNuiFocusKeepInput(carcontrol)
		isbusy = false
		Creation(function()
			while carcontrol do
				whileinput()
				Wait(5)
			end
			SetNuiFocusKeepInput(false)
			return
		end)
	else
		if GetVehicleDoorLockStatus(vehicle) ~= 1 then
			Notify('warning','Carcontrol System',"No Unlock Vehicle Nearby")
		else
			Notify('warning','Carcontrol System',"No Nearby Vehicle")
		end
	end
end

function shuffleseat(index)
	if invehicle then
		TaskWarpPedIntoVehicle(ped,vehicle,index)
	else
		Creation(function()
			entervehicle()
			return
		end)
		TaskEnterVehicle(ped, getveh(), 10.0, index, 2.0, 0)
	end
end

function requestcontrol(veh)
	NetworkRequestControlOfEntity(veh)
	local count = 0
	while not NetworkHasControlOfEntity(veh) and count < 10 do
		count = count + 1
		Wait(10)
	end
end

function getColor(r1, g1, b1, r2, g2, b2)
	return round(math.random(0,255)), round(math.random(0,255)), round(math.random(0,255))
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5)
end

--WEAPONS
function WeaponStatus()
	if wstatus['armed'] then return end
	local weapon = nil
	if IsPedArmed(ped, 7) and not invehicle then
		while IsPedArmed(ped, 7) and not invehicle do
			sleep = config.ammoupdatedelay
			weapon = GetSelectedPedWeapon(ped)
			local ammoTotal = GetAmmoInPedWeapon(ped,weapon)
			local bool,ammoClip = GetAmmoInClip(ped,weapon)
			local ammoRemaining = math.floor(ammoTotal - ammoClip)
			local maxammo = GetMaxAmmoInClip(ped, weapon, 1)
			wstatus['armed'] = true
			----print(ammoRemaining)
			if oldweapon ~= weapon then
				for key,value in pairs(config.WeaponTable) do
					for name,v in pairs(config.WeaponTable[key]) do
						weap = weapon == GetHashKey('weapon_'..name)
						if weap then
							wstatus['weapon'] = 'weapon_'..name
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
			Wait(sleep)
		end
		wstatus['armed'] = false

	else
		if weaponui then
			RenzuSendUI({
				type = "setWeaponUi",
				content = false
			})
			weaponui = false
		end
		wstatus['armed'] = false	
	end
	if oldweapon ~= weapon then
		RenzuSendUI({
			type = "setWeapon",
			content = wstatus['weapon']
		})
		oldweapon = weapon
	end
end

--NOS --

function EnableNitro()
	Creation(function()
		while invehicle and nitromode do
			local cansleep = 2000
			if veh_stats[plate] ~= nil and veh_stats[plate].nitro ~= nil and hasNitro and invehicle and veh_stats[plate].nitro > 1 then
				if GetPedInVehicleSeat(vehicle, -1) == ped then
					cansleep = 1
					if veh_stats[plate].nitro > 5 and RCP(0, 21) and not RCR2(0, 21) then
						SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - 0.05)
						if veh_stats[plate].nitro - 0.02 > 0 then
							if not pressed then
								pressed = true
								if speed > 5 then
									SetTimecycleModifier("ship_explosion_underwater")
									SetExtraTimecycleModifier("StreetLightingJunction")
									SetExtraTimecycleModifierStrength(0.1)
									SetTimecycleModifierStrength(0.1)
									--StartScreenEffect('MP_Celeb_Preload_Fade', 0, true)
								end
								TriggerServerEvent("renzu_hud:nitro_flame", VehToNet(vehicle), GetEntityCoords(vehicle))
							end
							SetVehicleEngineTorqueMultiplier(vehicle, config.nitroboost * 2 * rpm)
							veh_stats[plate].nitro = veh_stats[plate].nitro - config.nitrocost
							RenzuSendUI({
								type = "setNitro",
								content = veh_stats[plate].nitro
							})
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
					if pressed and IsControlJustReleased(0, 21) and not RCP(0, 21) then
						Wait(100)
						TriggerServerEvent("renzu_hud:nitro_flame_stop", VehToNet(vehicle), GetEntityCoords(vehicle))
						pressed = false
						ClearExtraTimecycleModifier()
						ClearTimecycleModifier()
						StopScreenEffect('MP_Celeb_Preload_Fade')
						RemoveParticleFxFromEntity(vehicle)
						local vehcoords = GetEntityCoords(vehicle)
						Citizen.Wait(1)
						--RemoveParticleFxInRange(vehcoords.x,vehcoords.y,vehcoords.z,100.0)
						light_trail_isfuck = false
						purgefuck[VehToNet(vehicle)] = false
						collectgarbage()
					end
				end
			end
			Wait(cansleep)
		end
		return
	end)
end

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
			sleep = 500
			for i = 0, numwheel - 1 do
				Wait(10)
				if plate ~= nil and rpm > config.minrpm_wheelspin_detect and speed > 1 and (rpm * 100.0) < (tractioncontrol(WheelSpeed(vehicle,i) * 3.6,GetGear(vehicle), true) * 85.0) then
					if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth > 0 then
						veh_stats[plate][tostring(i)].tirehealth = veh_stats[plate][tostring(i)].tirehealth - config.tirestress
					end
					--Notify("Tire Stress: Wheel #"..i.." - "..veh_stats[plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(vehicle, i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(vehicle, i, true, 0)
					end
				end
			end
			if speed ~= nil and speed > config.minspeed_curving and angle(vehicle) >= config.minimum_angle_for_curving and angle(vehicle) <= 18 and GetEntityHeightAboveGround(vehicle) <= 1.5 then
				for i = 0, numwheel - 1 do
					Wait(10)
					if veh_stats[plate][tostring(i)] ~= nil and veh_stats[plate][tostring(i)].tirehealth > 0 then
						veh_stats[plate][tostring(i)].tirehealth = veh_stats[plate][tostring(i)].tirehealth - config.tirestress
					end
					--Notify('warning','Tire System',"Tire Stress2: Wheel #"..i.." - "..veh_stats[plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(vehicle, i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(vehicle, i, true, 0)
					end
				end
			end
			Citizen.Wait(sleep)
		end
		return
	end)
end

function tireanimation()
	--CarregarObjeto("anim@heists@box_carry@","idle","hei_prop_heist_box",50,28422)
	local ped = PlayerPedId()
	local prop = 'prop_wheel_tyre'

	RequestModel(GetHashKey(prop))
	while not HasModelLoaded(GetHashKey(prop)) do
		Citizen.Wait(10)
	end

	local dict = 'anim@heists@box_carry@'
	local anim = 'idle'
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
	TaskPlayAnim(ped,dict,anim,3.0,3.0,-1,50,0,0,0,0)
	local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
	proptire = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
	SetEntityCollision(proptire,false,false)
	AttachEntityToEntity(proptire,ped,GetPedBoneIndex(ped,28422),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
	Citizen.InvokeNative(0xAD738C3085FE7E11,proptire,true,true)
end

function turboanimation(type)
	--CarregarObjeto("anim@heists@box_carry@","idle","hei_prop_heist_box",50,28422)
	local ped = PlayerPedId()
	local prop = 'smallturbo'
	local offset = -0.75
	local offsetz = 0.245
	if type == 'racing' then
		prop = 'bigturbo'
		offset = -1.85
		offsetz = 0.45
	elseif type == 'sports' then
		prop = 'mediumturbo'
		offset = -1.15
		offsetz = 0.285
	elseif type == 'street' then
		prop = 'smallturbo'
		offset = -0.80
	end
	RequestModel(GetHashKey(prop))
	while not HasModelLoaded(GetHashKey(prop)) do
		Citizen.Wait(10)
	end
	local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
	if propturbo ~= nil then
		--print("deleting")
		ReqAndDelete(propturbo,true)
		propturbo = nil
	end
	if config.turboprop and propturbo == nil then
		propturbo = CreateObjectNoOffset(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
		SetEntityCollision(propturbo,true,true)
		AttachEntityToEntity(propturbo,getveh(),GetEntityBoneIndexByName(getveh(),'neon_f'),0.3,offset,offsetz,0.0,0.0,90.0,true,false,false,false,70,true)
		Citizen.InvokeNative(0xAD738C3085FE7E11,propturbo,true,true)
	end
end

function TireFunction(type)
	if type ~= 'default' then
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult) -- start burnout less = traction
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", DecorGetFloat(vehicle,"TRACTION4") * config.wheeltype[type].fTractionLossMult)  -- asphalt mud less = traction
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * config.wheeltype[type].fTractionCurveMin) -- accelaration grip
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", DecorGetFloat(vehicle,"TRACTION5") * config.wheeltype[type].fTractionCurveMax) -- cornering grip
		SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral) -- curve lateral grip
	end
end

carjacking = false
keyless = true
function Carlock()
	if not keyless then return end
	while veh_stats == nil do
		Wait(100)
	end
	if not veh_stats_loaded then
		get_veh_stats()
	end
	local foundveh = false
	if keyless then
		keyless = not keyless
		local vehicles = {}
		local checkindentifier, myidentifier = nil, nil
		local mycoords = GetEntityCoords(PlayerPedId(), false)
		local foundvehicle = {}
		local min = -1
		for k,v in pairs(GetGamePool('CVehicle')) do
			if #(mycoords - GetEntityCoords(v, false)) < config.carlock_distance then
				local plate = string.gsub(GetVehicleNumberPlateText(v), "%s+", "")
				if veh_stats[plate] ~= nil and veh_stats[plate].owner ~= nil and identifier ~= nil then
					checkindentifier = string.gsub(veh_stats[plate].owner, 'Char5', '')
					checkindentifier = string.gsub(checkindentifier, 'Char4', '')
					checkindentifier = string.gsub(checkindentifier, 'Char3', '')
					checkindentifier = string.gsub(checkindentifier, 'Char2', '')
					checkindentifier = string.gsub(checkindentifier, 'Char1', '')
					myidentifier = string.gsub(identifier, 'steam', '')
					if veh_stats[plate] ~= nil and checkindentifier == myidentifier then
						foundvehicle[plate] = {}
						foundvehicle[plate].entity = v
						foundvehicle[plate].plate = plate
						if checkindentifier ~= nil then
							foundvehicle[plate].owner = myidentifier
						end
						foundvehicle[plate].distance = #(mycoords - GetEntityCoords(v, false))
					end
				end
			end
		end

		local near = -1
		local nearestveh = nil
		local nearestplate = nil
		for k,v in pairs(foundvehicle) do
			if near == -1 or near > v.distance then
				near = v.distance
				nearestveh = v.entity
				nearestplate = v.plate
				if v.owner ~= nil and near < 20 then
					nearestowner = v.owner
				end
			end
		end
		if near ~= -1 and near <= 20 and nearestowner ~= nil and myidentifier ~= nil and nearestowner == myidentifier then
			local table = {
				['type'] = 'connect',
				['bool'] = true,
				['vehicle'] = nearestveh,
				['plate'] = nearestplate,
				['state'] = GetVehicleDoorLockStatus(nearestveh)
			}
			RenzuSendUI({
				type = "setKeyless",
				content = table
			})
			foundveh = true
			Notify('success','Vehicle Lock System','Owned Vehicle Found with Plate # '..nearestplate..'')
			Wait(200)
			SetNuiFocus(true,true)
		end
		keyless = not keyless
		Wait(500)
		if foundveh then
			RenzuSendUI({
				type = "setShowKeyless",
				content = keyless
			})
		elseif config.enable_carjacking and not carjacking then
			keyless = true
			carjacking = true
			local bone = GetEntityBoneIndexByName(getveh(),'door_dside_f')
			if getveh() ~= 0 and #(GetEntityCoords(ped) - GetWorldPositionOfEntityBone(getveh(),bone)) < config.carjackdistance and GetVehicleDoorLockStatus(getveh()) ~= 1 then
				playanimation('creatures@rottweiler@tricks@','petting_franklin')
				local carnap = exports["cd_keymaster"]:StartKeyMaster()
				--print(carnap)
				if carnap then
					--print("good")
					SetVehicleNeedsToBeHotwired(getveh(),true)
					TaskEnterVehicle(ped, getveh(), 10.0, -1, 2.0, 0)
					TriggerServerEvent("renzu_hud:synclock", VehToNet(getveh()), 'carjack', GetEntityCoords(ped))
				else
					SetVehicleNeedsToBeHotwired(getveh(),true)
					TaskEnterVehicle(ped, getveh(), 10.0, -1, 2.0, 0)
					SetVehicleAlarm(getveh(), 1)
					StartVehicleAlarm(getveh())
					SetVehicleAlarmTimeLeft(getveh(), 180000)
					CreateIncidentWithEntity(7,ped,3,100.0)
					PlayPoliceReport("SCRIPTED_SCANNER_REPORT_CAR_STEAL_2_01",0.0)
					TriggerServerEvent("renzu_hud:synclock", VehToNet(getveh()), 'force', GetEntityCoords(ped))
				end
			elseif GetVehicleDoorLockStatus(getveh()) == 1 then
				SetVehicleNeedsToBeHotwired(getveh(),true)
				TaskEnterVehicle(ped, getveh(), 10.0, -1, 2.0, 0)
			end
			ClearPedTasks(ped)
			carjacking = false
		else
			keyless = true
			Notify('error','Vehicle Lock System',' No Vehicle in area')
		end
	else
		SetNuiFocus(false,false)
	end
end

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

function whileinput()
	DisableControlAction(1, 1, true)
	DisableControlAction(1, 2, true)
	DisableControlAction(1, 18, true)
	DisableControlAction(1, 68, true)
	DisableControlAction(1, 69, true)
	DisableControlAction(1, 70, true)
	DisableControlAction(1, 91, true)
	DisableControlAction(1, 92, true)
	DisableControlAction(1, 24, true)
	DisableControlAction(1, 25, true)
	DisableControlAction(1, 14, true)
	DisableControlAction(1, 15, true)
	DisableControlAction(1, 16, true)
	DisableControlAction(1, 17, true)
	DisablePlayerFiring(pid, true)
end

function Clothing()
	clothing = not clothing
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

	if clothing then
		Creation(function()
			while clothing do
				whileinput()
				Wait(0)
			end
			return
		end)
	end
end

saveclothe = {}
function checkaccesories(accessory, changes) -- being used if ESX ACCESORIES IS enable - (mask,helmet from datastore instead of skinchangers Characters) copyright to LINK https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/client/main.lua#L30
	local state = false
	local load = false
	while ESX == nil do
		Wait(100)
	end
	ESX.TriggerServerCallback('esx_accessories:get2', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)
		if hasAccessory then
			local skin = changes
			local mAccessory = -1
			local mColor = 0

			if _accessory == "mask" then
				mAccessory = 0
			end

			if _accessory == "mask" or _accessory == "helmet" then
				mAccessory = accessorySkin[''.._accessory.. '_1']
				mColor = accessorySkin[''.._accessory.. '_2']
			end

			oldclothes[''.._accessory.. '_1'] = mAccessory
			oldclothes[''.._accessory.. '_2'] = mColor
			saveclothe[''.._accessory.. '_1'] = mAccessory
			saveclothe[''.._accessory.. '_2'] = mColor
			state = true
			Notify("success","Clothe System","Variant Loaded "..accessory.." "..mColor.." "..mAccessory.."")
		else
			state = false
			Notify("warning","Clothe System","No Variant for this type "..accessory.."")
		end
		load = true
	end, accessory)

	while not load do
		Wait(100)
	end
	return state
end

function SaveCurrentClothes(firstload)
	TriggerEvent('skinchanger:getSkin', function(current)
		oldclothes = current
		Wait(100)
		if config.use_esx_accesories and firstload then
			if checkaccesories('Mask', oldclothes) then
				hasmask = true
			end
			Wait(1000)
			--check if there is a helmet from datastore
			if checkaccesories('Helmet', oldclothes) then
				hashelmet = true
			end
		elseif not firstload and config.use_esx_accesories then
			if saveclothe['mask_1'] ~= nil and saveclothe['mask_1'] ~= oldclothes['mask_1'] and config.clothing['mask_1']['default'] == oldclothes['mask_1'] then
				oldclothes['mask_1'] = saveclothe['mask_1']
			elseif saveclothe['mask_1'] ~= nil and saveclothe['mask_1'] ~= oldclothes['mask_1'] and config.clothing['mask_1']['default'] ~= oldclothes['mask_1'] then
				if checkaccesories('Mask', oldclothes) then
					hasmask = true
				end
			end
			if saveclothe['helmet_1'] ~= nil and saveclothe['helmet_1'] ~= oldclothes['helmet_1'] and config.clothing['helmet_1']['default'] == oldclothes['helmet_1'] then
				oldclothes['helmet_1'] = saveclothe['helmet_1']
			elseif saveclothe['helmet_1'] ~= nil and saveclothe['helmet_1'] ~= oldclothes['helmet_1'] and config.clothing['helmet_1']['default'] ~= oldclothes['helmet_1'] then
				if checkaccesories('Helmet', oldclothes) then
					hashelmet = true
				end
			end
		end
		Wait(1000)
	end)
	while oldclothes == nil do
		print("OLDCLOTHESNIL")
		Wait(0)
	end
	ClotheState()
end

function ClotheState()
	if oldclothes == nil then return end
	for k,v in pairs(oldclothes) do
		if config.clothing[k] then
			if oldclothes[k] == config.clothing[k]['default'] then
				clothestate[k] = false
			else
				clothestate[k] = true
			end
			if k == 'mask_1' and hasmask and oldclothes['mask_1'] ~= config.clothing['mask_1']['default'] then
				clothestate[k] = false
			end
			if k == 'helmet_1' and  hashelmet and oldclothes['helmet_1'] ~= config.clothing['helmet_1']['default'] then
				clothestate[k] = false
			end
		end
	end
end

function TaskAnimation(table)
	if imbusy then
		imbusy = false
		local Ped = ped
		while not HasAnimDictLoaded(table.dictionary) do
			RequestAnimDict(table.dictionary)
			Citizen.Wait(5)
		end
		if IsPedInAnyVehicle(Ped) then
			table.speed = 51
		end
		TaskPlayAnim(Ped, table.dictionary, table.name, 3.0, 3.0, table.duration, table.speed, 0, false, false, false)
		local delay = table.duration-500 
		if delay < 500 then
			delay = 500
		end
		Citizen.Wait(delay) 
		imbusy = true
	end
end

function CarStatus()
	vehicle = getveh()
	local dis = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
	if dis > 10 then return end
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
	get_veh_stats(vehicle, plate)
	carstatus = not carstatus
	local turbolevel = veh_stats[plate].turbo
	if turbolevel == 'default' then
		if GetVehicleMod(vehicle, 18) then
			turbolevel = 0
		else
			turbolevel = 'NOTURBO'
		end
	elseif turbolevel == 'street' then
		turbolevel = 1
	elseif turbolevel == 'sports' then
		turbolevel = 2
	elseif turbolevel == 'racing' then
		turbolevel = 3
	end
	local tirelevel = veh_stats[plate].tires
	if tirelevel == 'street' then
		tirelevel = 1
	elseif tirelevel == 'sports' then
		tirelevel = 2
	elseif tirelevel == 'racing' then
		tirelevel = 3
	else
		tirelevel = -1
	end
	local numwheel = GetVehicleNumberOfWheels(vehicle)
	local tirehealth = 0
	for i = 0, numwheel - 1 do
		tirehealth = tirehealth + veh_stats[plate][tostring(i)].tirehealth
	end
	--print(tirehealth)
	local total_tirehealth = tirehealth / (config.tirebrandnewhealth * numwheel) * 100
	--print(total_tirehealth)
	local trannytype = veh_stats[plate].manual
	if trannytype then
		trannytype = 'Manual'
	else
		trannytype = 'Automatic'
	end
	local enginename = veh_stats[plate].engine
	enginename = enginename:gsub("^%l", string.upper).." Engine"
	local table = {
		['bool'] = carstatus,
		['engine'] = GetVehicleMod(vehicle, 11) + 1,
		['tranny'] = GetVehicleMod(vehicle, 13) + 1,
		['turbo'] = turbolevel,
		['brake'] = GetVehicleMod(vehicle, 12) + 1,
		['suspension'] = GetVehicleMod(vehicle, 15) + 1,
		['tire'] = tirelevel,
		['coolant'] = veh_stats[plate].coolant,
		['oil'] = veh_stats[plate].oil,
		['tires_health'] = total_tirehealth,
		['mileage'] = veh_stats[plate].mileage,
		['trannytype'] = trannytype,
		['enginename'] = enginename,
	}
	RenzuSendUI({
		type = "setShowCarStatus",
		content = table
	})
end

function tostringplate(plate)
    if plate ~= nil then
    return string.gsub(tostring(plate), '^%s*(.-)%s*$', '%1')
    else
    return 123454
    end
end

function closestveh(coords)
    --for k,vv in pairs(GetGamePool('CVehicle')) do
        for k,v in pairs(veh_stats) do
			if v.entity ~= nil and NetworkDoesEntityExistWithNetworkId(v.entity) then
				local vv = NetToVeh(v.entity)
				local vehcoords = GetEntityCoords(vv)
				local dist = #(coords-vehcoords)
				local plate = GetVehicleNumberPlateText(vv)
				--anti desync
				if k ~= nil and v.engine ~= nil and v.engine ~= 'default' then
					if not syncveh[vv] and tostringplate(plate) == tostringplate(k) and syncengine[tostringplate(k)] ~= nil then
						syncengine[tostringplate(k)] = nil
					end
					if dist < 100 and syncengine[tostringplate(k)] ~= v.engine and vv ~= nil then
						if tostringplate(plate) == tostringplate(k) then
							--print("engine sound",v.engine,vv)
							if config.custom_engine_enable and config.custom_engine[GetHashKey(v.engine)] ~= nil then
								ForceVehicleEngineAudio(vv, config.custom_engine[GetHashKey(v.engine)].soundname)
							else
								ForceVehicleEngineAudio(vv, tostring(v.engine))
							end
							syncengine[tostringplate(k)] = v.engine
							syncveh[vv] = v.engine
						end
					end
				end
			end
        end
    --end
end

function SyncVehicleSound()
	if veh_stats == nil then return end
	Citizen.CreateThread(function()
		Wait(1000)
		closestveh(GetEntityCoords(ped))
		return
	end)
end

function SetEngineSpecs(veh, model)
	if GetPedInVehicleSeat(veh, -1) == ped then
		enginespec = false
		--print("INSIDE LOOP")
		currentengine[plate] = model
		Wait(1300)
		Citizen.CreateThread(function()
			local model = model
			local handling = GetHandlingfromModel(model)
			local getcurrentvehicleweight = GetVehStats(vehicle, "CHandlingData","fMass")
			local multiplier = 1.0
			multiplier = (handling['fMass'] / getcurrentvehicleweight)
			enginespec = true
			Wait(10)
			if tonumber(handling['nInitialDriveGears']) > GetVehicleHandlingInt(vehicle, "CHandlingData","nInitialDriveGears") then
				-- another anti weird bug ( if the new engine gears is > the existing one, the existing old max gear persist, so we use this native below to cheat the bug)
				SetVehicleHighGear(vehicle,tonumber(handling['nInitialDriveGears']) )
				Citizen.InvokeNative(0x8923dd42, vehicle, tonumber(handling['nInitialDriveGears']) )
				Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, tonumber(handling['nInitialDriveGears']) )
				Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, tonumber(handling['nInitialDriveGears']) )
				Wait(11)
				Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, 1)
			end
			while enginespec do
				--print(multiplier)
				for k,v in pairs(handling) do
					if k == 'nInitialDriveGears' then
						GetHandling(GetPlate(vehicle)).maxgear = v
						----print("gear")
						gears = tonumber(v)
						if gears < 6 and tonumber(GetVehicleMod(vehicle,13)) > 0 then
							gears = tonumber(v) + 1
						end
						SetVehicleHandlingInt(vehicle, "CHandlingData", "nInitialDriveGears", gears)
						SetVehicleHandlingField(getveh(), 'CHandlingData', "nInitialDriveGears", gears)
						--SetVehicleHighGear(vehicle, v)
					elseif k == 'fDriveInertia' then
						GetHandling(GetPlate(vehicle)).finaldrive = v
						--print("final drive",GetHandling(GetPlate(vehicle)).finaldrive, multiplier,handling['fMass'], getcurrentvehicleweight)
						if multiplier < 0.8 then -- weight does not affect reving power
							m = 0.8
						else
							m = multiplier
						end
						SetVehStats(vehicle, "CHandlingData", "fDriveInertia", v * m)
					elseif k == 'fInitialDriveForce' then
						--multiplier is on everytime, this will produce realistic result, ex. Sanchez Engine to vehicle. sanchez is a bike/motorcycle, it have a less weight compare to sedan vehicles, so sanchez will produce very low acceleration on sedan cars
						GetHandling(GetPlate(vehicle)).flywheel = v
						SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", v * multiplier)
					elseif k == 'fInitialDriveMaxFlatVel' then
						GetHandling(GetPlate(vehicle)).maxspeed = v
						if not manual then
							mult = 1.0
							if tonumber(GetVehicleMod(vehicle,13)) > 0 then
								mult = 1.25
							end
							SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", v * mult)
						end
					elseif k ~= 'fMass' then
						SetVehStats(vehicle, "CHandlingData", tostring(k), v * 1.0)
						--SetVehicleHandlingField(getveh(), 'CHandlingData', tostring(k), tonumber(v))
					end
					--SetVehicleHandlingField(getveh(), 'CHandlingData', tostring(k), tonumber(v))
				end
				SetVehicleEnginePowerMultiplier(vehicle, 1.0) -- needed if maxvel and inertia is change, weird.. this can be call once only to trick the bug, but this is a 1 sec loop it doesnt matter.
				
				Wait(1000)
			end
			return
		end)
	end
	--SetVehicleHandlingField()
end

function GetHandlingfromModel(model)
	local model = model
	if config.custom_engine_enable and config.custom_engine[model] ~= nil then
		print("custom engine")
		if config.custom_engine[model].turboinstall then
			ToggleVehicleMod(vehicle, 18, true)
		end
		local table = {
			['fDriveInertia'] = tonumber(config.custom_engine[model].fDriveInertia),
			['nInitialDriveGears'] = tonumber(config.custom_engine[model].nInitialDriveGears),
			['fInitialDriveForce'] = tonumber(config.custom_engine[model].fInitialDriveForce),
			['fClutchChangeRateScaleUpShift'] = tonumber(config.custom_engine[model].fClutchChangeRateScaleUpShift),
			['fClutchChangeRateScaleDownShift'] = tonumber(config.custom_engine[model].fClutchChangeRateScaleDownShift),
			['fInitialDriveMaxFlatVel'] = tonumber(config.custom_engine[model].fInitialDriveMaxFlatVel),
			['fMass'] = tonumber(config.custom_engine[model].fMass),
		}
		return table
	else
		for k,v in pairs(vehiclehandling['Item']) do
			if GetHashKey(v.handlingName) == model then
				local table = {
					['fDriveInertia'] = tonumber(v.fDriveInertia['_value']),
					['nInitialDriveGears'] = tonumber(v.nInitialDriveGears['_value']),
					['fInitialDriveForce'] = tonumber(v.fInitialDriveForce['_value']),
					['fClutchChangeRateScaleUpShift'] = tonumber(v.fClutchChangeRateScaleUpShift['_value']),
					['fClutchChangeRateScaleDownShift'] = tonumber(v.fClutchChangeRateScaleDownShift['_value']),
					['fInitialDriveMaxFlatVel'] = tonumber(v.fInitialDriveMaxFlatVel['_value']),
					['fMass'] = tonumber(v.fMass['_value']),
				}
				return table
			end
		end
	end
	return false
end

function ReqAndDelete(object, detach)
	--if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		local attempt = 0
		while not NetworkHasControlOfEntity(object) and attempt < 100 do
			NetworkRequestControlOfEntity(object)
			Citizen.Wait(11)
			attempt = attempt + 1
		end
		if detach then
			DetachEntity(getveh(), 0, false)
			DetachEntity(object, 0, false)
		end
		local count = 0
		SetEntityAsNoLongerNeeded(object)
		while DoesEntityExist(object) and count < 100 do -- delete loop
			count = count + 1
			SetEntityAlpha(object, 1, true)
			SetEntityAsMissionEntity(object)
			DeleteEntity(object)
			Wait(100)
			--print("deleting")
		end
		if DoesEntityExist(object) then -- if onesync is broken :D
			--print("teleporting")
			SetEntityCoords(object,0.0,0.0,0.0)
		end
	--end
end

function DefineCarUI(ver)
	if config.available_carui[tostring(ver)] ~= nil then
		RenzuSendUI({type = 'setCarui', content = tostring(ver)})
		config.carui = ver
		if GetVehiclePedIsIn(PlayerPedId()) ~= 0 and ver == 'modern' then
			Renzuzu.Wait(300)
			start = true
			RenzuSendUI({
				type = "setStart",
				content = start
			})
			vehicle = GetVehiclePedIsIn(PlayerPedId())
			if ismapopen then
				RenzuSendUI({map = true, type = 'sarado'})
				ismapopen = false
			end
			if ver == 'modern' then
				NuiShowMap()
			end
		end
	end
end

standmodel , enginemodel = nil, nil
function repairengine(plate)
	local vehicle = getveh()
	local prop_stand = 'prop_engine_hoist'
	local prop_engine = 'prop_car_engine_01'
	--print("engine repair")
	Citizen.Wait(200)
	local bone = GetEntityBoneIndexByName(vehicle,'engine')
	local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
	local stand = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.4,0.0)
	local obj = nil

	local veh_heading = GetEntityHeading(vehicle)
	local veh_coord = GetEntityCoords(vehicle,false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(vehicle, bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Renzuzu.Wait(1)
		RequestAnimDict(animDict)
	end
	requestmodel('bkr_prop_meth_sacid')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_long_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(vehicle) * 1.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local coordf = veh_coord + GetEntityForwardVector(vehicle) * 3.0
	standmodel = CreateObject(GetHashKey(prop_stand),coordf,true,true,true)
	obj = standmodel
	standprop = obj
	SetEntityAsMissionEntity(obj, true, true)
	--print("spawn stand")
	SetEntityNoCollisionEntity(vehicle, obj, false)
	SetEntityHeading(obj, GetEntityHeading(vehicle))
	PlaceObjectOnGroundProperly(obj)
	FreezeEntityPosition(obj, true)
	SetEntityCollision(obj, false, true)
	while not DoesEntityExist(obj) do
		Citizen.Wait(100)
	end
	local d21 = GetModelDimensions(GetEntityModel(obj))
	local stand = GetOffsetFromEntityInWorldCoords(obj, 0.0,d21.y+0.2,0.0)
	Citizen.Wait(500)
	local engine_r = GetEntityBoneRotation(vehicle, bone)
	enginemodel = CreateObject(GetHashKey(prop_engine),stand.x+0.27,stand.y-0.2,stand.z+1.45,true,true,true)
	AttachEntityToEntity(enginemodel,vehicle,GetEntityBoneIndexByName(vehicle,'neon_f'),0.0,-0.45,1.5,0.0,90.0,0.0,true,false,false,false,70,true)
	--AttachEntityToEntity(enginemodel,vehicle,bone,0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,1,false)
	carryModel2 = enginemodel
	engineprop = carryModel2
	--SetEntityHeading(engineprop, 0)
	SetEntityAsMissionEntity(engineprop, true, true)
	--print("spawn engine")
	SetEntityNoCollisionEntity(vehicle, carryModel2, false)
	FreezeEntityPosition(carryModel2, true)
	SetEntityNoCollisionEntity(carryModel2, obj, false)
	SetEntityCollision(carryModel2, false, true)
end

function SyncWheelSetting()
	local coords = GetEntityCoords(PlayerPedId())
	for k,v in pairs(veh_stats) do
		if v.entity ~= nil and NetworkDoesEntityExistWithNetworkId(v.entity) and v.plate == tostringplate(GetVehicleNumberPlateText(NetToVeh(v.entity))) then
			local vv = NetToVeh(v.entity)
			local vehcoords = GetEntityCoords(vv)
			local dist = #(coords-vehcoords)
			local plate = GetVehicleNumberPlateText(vv)
			plate = string.gsub(plate, "%s+", "")
			if nearstancer[plate] == nil then
				nearstancer[plate] = {entity = vv, dist = dist, plate = plate}
			end
			nearstancer[plate].dist = dist
			nearstancer[plate].entity = vv
			nearstancer[plate].speed = GetEntitySpeed(vv) * 3.6
			if v.height ~= nil and not nearstancer[plate].wheeledit then
				SetVehicleSuspensionHeight(vv,v.height)
			end
		end
	end
	for k,v in pairs(nearstancer) do
		if v.dist > 250 or not DoesEntityExist(v.entity) then
			print(v.plate,"deleted")
			nearstancer[k] = nil
		end
	end
end

function Renzu_Function(func)
	local f = {}
	setmetatable(f, {
		__close = func
	})
	return f
end