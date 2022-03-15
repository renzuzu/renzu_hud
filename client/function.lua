-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
-----------------------------------------------------------------------------------------------------------------------------------------
-- RENZU HUD function Hud: https://github.com/renzuzu/renzu_hud
-----------------------------------------------------------------------------------------------------------------------------------------
function Hud:timeformat()
	self.date = ""..self.hour..":"..self.minute..""
	if self.newdate ~= self.date or self.newdate == nil and self.vehicle  ~= nil and self.vehicle  ~= 0 then
		format = {
			min = self.minute,
			hour = self.hour
		}
		SendNUIMessage({
			type = "setTime",
			content = format
		})
		self.newdate = self.date
	end
end

function Hud:CalculateTimeToDisplay()
	self.hour = GetClockHours()
	self.minute = GetClockMinutes()
	if self.hour <= 9 then
		self.hour = "0" .. self.hour
	end
	if self.minute <= 9 then
		self.minute = "0" .. self.minute
	end
end

function Hud:setVoice()
	NetworkSetTalkerProximity(self.proximity)
end

function Hud:isplayer()
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

function Hud:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return tonumber(count)
end

function Hud:getawsomeface(force)
	if config.statusui ~= 'normal' and not force then return end
    self:ClearPedHeadshots()
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
		self.headshot = headshotTxd
	end

	if headshotTxd == 'none' or headshotTxd == 0 or tempHandle == 0 then
		tempHandle = RegisterPedheadshot_3(PlayerPedId())
		timer = 2000
		while ((not tempHandle or not IsPedheadshotReady(tempHandle) or not IsPedheadshotValid(tempHandle)) and timer > 0) do
			Wait(10)
			timer = timer - 10
		end
		if (IsPedheadshotReady(tempHandle) and IsPedheadshotValid(tempHandle)) then
			headshotTxd = GetPedheadshotTxdString(tempHandle)
			self.headshot = headshotTxd
		end
	end
	return headshotTxd
end

function Hud:ClearPedHeadshots()
	if self.headshot ~= nil or self.headshot ~= 0 then
		UnregisterPedheadshot(self.headshot)
	end
end

function Hud:UpdateStatus(export,vitals)
	if not export and vitals == nil then return end
	self.vitals = vitals
	if self.notloaded then return end
	if export and not config.QbcoreStatusDefault and config.framework == 'QBCORE' and self.esx_status ~= nil or export and config.framework ~= 'QBCORE' and self.esx_status ~= nil then
		if not self.esx_status then
			self.vitals = exports['renzu_status']:GetStatus(self.statuses)
		end
	elseif export and config.framework == 'QBCORE' and config.QbcoreStatusDefault then
		QBCore.Functions.GetPlayerData(function(PlayerData)
			if PlayerData ~= nil and PlayerData.metadata ~= nil then
				hunger, thirst, stress = PlayerData.metadata["hunger"] * 10000, PlayerData.metadata["thirst"] * 10000, PlayerData.metadata["stress"] * 10000
				vitals = {
					['hunger'] = hunger,
					['thirst'] = thirst,
					['stress'] = stress -- this should be registered at config
				}
				self.vitals = vitals
			end
		end)
	end
	self.statusloop = 0
	sleep = 11
	
	if export and not self.esx_status or not export and self.vitals ~= nil then
		for k1,v1 in pairs(config.statusordering) do
			if v1.status == 'stamina' then
				v1.value = (100 - GetPlayerSprintStaminaRemaining(self.pid))
			end
			if v1.status == 'oxygen' then
				v1.value = (self.underwatertime / 30) * 100
				if self.underwatertime == 0 then
					SetPedDiesInWater(self.ped,true)
					SetPlayerUnderwaterTimeRemaining(self.pid,0)
					SetPedMaxTimeUnderwater(self.ped,0)
				end
				--print(v1.value)
			end
			if v1.custom and self.statusloop <= 1  then
				if self.vitals and self.vitals[v1.status] ~= nil and self.vitals[v1.status] then
					v1.value = self.vitals[v1.status] / 10000
				end
			end

			if config.statusnotify and self.statusloop <= 1 then
				if not v1.notify_lessthan and v1.rpuidiv ~= 'null' then
					if self.notifycd[v1.status] ~= nil and v1.value < v1.notify_value and self.notifycd[v1.status] < 1 then
						self.notifycd[v1.status] = 120
						self:Notify('error',v1.status,v1.notify_message)
					end
				elseif v1.rpuidiv ~= 'null' then
					if self.notifycd[v1.status] ~= nil and v1.value > v1.notify_value and self.notifycd[v1.status] < 1 then
						self.notifycd[v1.status] = 120
						self:Notify('error',v1.status,v1.notify_message)
					end
				end
				for k,v in pairs(self.notifycd) do
					if v > 1 then
						v = v - 1
					end
				end
			end
			Wait(sleep)
		end
		self.statusloop = self.statusloop + 1
		SendNUIMessage({
			type = "setStatus",
			content = {['type']= config.status_type, ['data'] = config.statusordering}
		})
	end
end

function Hud:EnterVehicleEvent(state,vehicle)
	if state and vehicle ~= nil and vehicle ~= 0 then
		if not NetworkGetEntityIsNetworked(vehicle) then return end -- do not show in non network entity, ex. vehicle shop, garage etc..
		if config.enable_carui_perclass then
			self:DefineCarUI(config.carui_perclass[GetVehicleClass(vehicle)])
		end
		-- self.plate = tostring(GetVehicleNumberPlateText(vehicle))
		-- self.plate = string.gsub(self.plate, '^%s*(.-)%s*$', '%1')
		self.hp = GetVehicleEngineHealth(vehicle)
		self.gasolina = GetVehicleFuelLevel(vehicle)
		self.lastplate = self:GetPlate(vehicle)
		SendNUIMessage({type = "SetMetrics", content = config.carui_metric})
		if self.uimove and config.enable_carui then
			Wait(500)
			local content = {
				['bool'] = true,
				['type'] = config.carui
			}
			SendNUIMessage({
				type = "setShow",
				content = content
			})
		end
		self.uimove = false
		if not self.invehicle then
			if config.statusplace == 'bottom-right' then
				SendNUIMessage({type = "setMoveStatusUi",content = true})
			end
			if GetPedInVehicleSeat(vehicle, -1) == self.ped and self.entering then
				self.breakstart = false
				SetNuiFocus(true, true)
				while not self.start and not self.breakstart and config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(vehicle)]  == 'modern' and config.push_start or not self.start and not self.breakstart and not config.enable_carui_perclass and config.carui == 'modern' and config.push_start do
					SetVehicleEngineOn(vehicle,false,true,true)
					if GetVehiclePedIsIn(self.ped) == 0 then
						self.start = false
						self.breakstart = true
					end
					Wait(1)
				end
				if config.carui_perclass[GetVehicleClass(vehicle)] == 'modern' and not config.push_start then
					SendNUIMessage({type = "bukas",content = true})
				end
				self.start = true
				SetNuiFocus(false,false)
				Wait(100)
				SetVehicleEngineOn(vehicle,true,false,true)
				--print("starting engine")
				while not GetIsVehicleEngineRunning do
					--print("starting")
					SetVehicleEngineOn(vehicle,true,false,true)
					Wait(0)
				end
				Wait(200)
				self.start = true
				SendNUIMessage({
					type = "setStart",
					content = self.start
				})
			end
			Wait(200)
			self.cansmoke = true
			self:inVehicleFunctions()
			Wait(100)
			if self.manual then
				SendNUIMessage({
					type = "setManual",
					content = true
				})
			end
			SendNUIMessage({
				type = "setDifferential",
				content = GetVehStats(vehicle, "CHandlingData","fDriveBiasFront")
			})
		end
		self.invehicle = true
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
		SendNUIMessage({
			type = "setHeadlights",
			content = light
		})
	else
		--print("outveh loop")
		self.globaltopspeed = nil
		self.entering = false
		self.start = false
		self.invehicle = false
		self.enginespec = false
		self.speed = 0
		self.rpm = 0
		marcha = 0
		--print(self.lastplate,"LAST PLATE")
		if self.veh_stats and self.veh_stats[self.lastplate] ~= nil then
			self.veh_stats[self.lastplate].entity = nil
			self.currentengine[self.lastplate] = nil
			self.lastplate = nil
		end
		VehIndicatorLight = 0
		--DisplayRadar(false)
		if config.statusplace == 'bottom-right' then
			SendNUIMessage({type = "setMoveStatusUi",content = false})
		end
		if self.alreadyturbo then
			SendNUIMessage({
				type = "setShowTurboBoost",
				content = false
			})
		end
		if not self.uimove then
			Wait(500)
			local content = {
				['bool'] = false,
				['type'] = config.carui
			}
			SendNUIMessage({
				type = "setShow",
				content = content
			})

			SendNUIMessage({
				type = "setStart",
				content = false
			})
		end
		if self.ismapopen then
			SendNUIMessage({map = true, type = 'sarado'})
			self.ismapopen = false
		end
		if self.manual then
			SendNUIMessage({
				type = "setManual",
				content = false
			})
			self.manual = false
		end
		self.alreadyturbo = false
		Wait(1000)
		self.uimove = true
	end
end

function Hud:GetPlate(v)
	self.plate = GetVehicleNumberPlateText(v)
	return self.plate
end

function Hud:GetHandling(plate)
	return self.handlings[plate]
end

function Hud:DefaultHandling()
	
end

function Hud:SavevehicleHandling()
	while self.vehicle  == nil or self.vehicle  == 0 do
		Wait(100)
	end
	self.plate = self:GetPlate(self.vehicle )
	if not DecorExistOn(self.vehicle , "INERTIA") then
		self.finaldrive = GetVehStats(self.vehicle , "CHandlingData","fDriveInertia")
		DecorSetFloat(self.vehicle , "INERTIA", self.finaldrive)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fDriveInertia", DecorGetFloat(self.vehicle ,"INERTIA"))
		self.finaldrive = DecorGetFloat(self.vehicle ,"INERTIA")
	end

	if not DecorExistOn(self.vehicle , "DRIVEFORCE") then
		self.flywheel = GetVehStats(self.vehicle , "CHandlingData","fInitialDriveForce")
		DecorSetFloat(self.vehicle , "DRIVEFORCE", self.flywheel)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveForce", DecorGetFloat(self.vehicle ,"DRIVEFORCE"))
		self.flywheel = DecorGetFloat(self.vehicle ,"DRIVEFORCE")
	end
	if not DecorExistOn(self.vehicle , "TOPSPEED") then
		self.maxspeed = GetVehStats(self.vehicle , "CHandlingData","fInitialDriveMaxFlatVel")
		DecorSetFloat(self.vehicle , "TOPSPEED", self.maxspeed)
		--print("Vehicle Data Saved")
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(self.vehicle ,"TOPSPEED"))
		self.maxspeed = DecorGetFloat(self.vehicle ,"TOPSPEED")
	end

	if not DecorExistOn(self.vehicle , "MAXGEAR") then
		self.maxgear = GetVehicleHandlingInt(self.vehicle , "CHandlingData","nInitialDriveGears")
		DecorSetInt(self.vehicle , "MAXGEAR", self.maxgear)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "nInitialDriveGears", DecorGetInt(self.vehicle ,"MAXGEAR"))
		self.maxgear = DecorGetInt(self.vehicle ,"MAXGEAR")
		--print(self.maxgear)
	end

	if not DecorExistOn(self.vehicle , "TRACTION") then
		self.traction = GetVehStats(self.vehicle , "CHandlingData","fTractionCurveMin")
		DecorSetFloat(self.vehicle , "TRACTION", self.traction)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionCurveMin", DecorGetFloat(self.vehicle ,"TRACTION"))
		self.traction = DecorGetFloat(self.vehicle ,"TRACTION")
	end
	
	if not DecorExistOn(self.vehicle , "TRACTION2") then
		self.traction2 = GetVehStats(self.vehicle , "CHandlingData","fTractionCurveLateral")
		DecorSetFloat(self.vehicle , "TRACTION2", self.traction2)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionCurveLateral", DecorGetFloat(self.vehicle ,"TRACTION2"))
		self.traction2 = DecorGetFloat(self.vehicle ,"TRACTION2")
	end

	if not DecorExistOn(self.vehicle , "TRACTION3") then
		traction3 = GetVehStats(self.vehicle , "CHandlingData","fLowSpeedTractionLossMult")
		DecorSetFloat(self.vehicle , "TRACTION3", traction3)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(self.vehicle ,"TRACTION3"))
		traction3 = DecorGetFloat(self.vehicle ,"TRACTION3")
	end

	if not DecorExistOn(self.vehicle , "TRACTION4") then
		traction4 = GetVehStats(self.vehicle , "CHandlingData","fTractionLossMult")
		DecorSetFloat(self.vehicle , "TRACTION4", traction4)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionLossMult", DecorGetFloat(self.vehicle ,"TRACTION4"))
		traction4 = DecorGetFloat(self.vehicle ,"TRACTION4")
	end

	if not DecorExistOn(self.vehicle , "TRACTION5") then
		traction5 = GetVehStats(self.vehicle , "CHandlingData","fTractionCurveMax")
		DecorSetFloat(self.vehicle , "TRACTION5", traction5)
	else
		SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionCurveMax", DecorGetFloat(self.vehicle ,"TRACTION5"))
		traction5 = DecorGetFloat(self.vehicle ,"TRACTION5")
	end

	self.handlings[self.plate] = {finaldrive = tonumber(self.finaldrive), flywheel = tonumber(self.flywheel), maxspeed = tonumber(self.maxspeed), maxgear = tonumber(self.maxgear), traction = tonumber(self.traction), traction2 = tonumber(self.traction2), traction3 = tonumber(traction3), traction4 = tonumber(traction4), traction5 = tonumber(traction5)}
end

--ASYNC function Hud:CALL VEHICLE LOOPS
function Hud:inVehicleFunctions()
	CreateThread(function()
		while not self.invehicle do
			Wait(1) -- lets wait self.invehicle to = true
		end
		self:SavevehicleHandling()
		self:get_veh_stats(self.vehicle ,self:GetPlate(self.vehicle ))
		SetForceHdVehicle(self.vehicle , true)
		self:RpmandSpeedLoop()
		self:NuiRpm()
		self:NuiCarhpandGas()
		while not self.loadedplate do
			Wait(100)
		end
		if config.WaypointMarkerLarge then
			self:NuiDistancetoWaypoint()
		end
		self:NuiMileAge()
		if not config.enable_carui_perclass then
			self:NuiShowMap()
		end
		self:NuiEngineTemp()
		self:fuelusagerun()
		self:SendNuiSeatBelt()
		self:NuiWheelSystem()
		if not self.manual and self.manualstatus and DecorGetBool(self.vehicle , "MANUAL") then
			--print("Starting self.manual")
			self:startmanual()
		end
		self:SetVehicleOnline()
		-- SendNUIMessage({
		-- 	type = "inVehicle",
		-- 	content = vtable
		-- })
		return
	end)
end
local vtable = {}
Creation(function()
	RenzuNuiCallback('getvehicledata', function(data, cb)
		self.rpm = VehicleRpm(self.vehicle )
		self.speed = VehicleSpeed(self.vehicle )
		vtable = {
			['rpm'] = self.rpm,
			['speed'] = self.speed
		}
		cb(vtable)
	end)
end)

RenzuCommand('test', function(source, args, raw)
	bool = not bool
	SetNuiFocus(bool,false)
	SetNuiFocusKeepInput(bool)
end)

function Hud:SetVehicleOnline() -- for vehicle loop
	while self.veh_stats[self.plate] == nil do
		Wait(100)
	end
	self.plate = self:GetPlate(self.vehicle )
	if self.veh_stats[self.plate] ~= nil then
		self.veh_stats[self.plate].entity = VehToNet(self.vehicle )
		TriggerServerEvent('renzu_hud:savedata', self.plate, self.veh_stats[tostring(self.plate)],true)
		LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] self.veh_stats, --[[replicate to server]] true)
	end
end

function Hud:RpmandSpeedLoop()
	CreateThread(function()
		while ESX == nil do
			Wait(2000)
		end
		while self.ped == nil do
			Wait(1000)
			self.ped = PlayerPedId()
		end
		SendNUIMessage({
			type = "SetMetrics",
			content = config.carui_metric
		})
		while self.invehicle do
			local sleep = 2000
			if self.vehicle  ~= nil and self.vehicle  ~= 0 then
				--vtable = {}
				if not DoesEntityExist(self.vehicle ) then
					self:EnterVehicleEvent(false,self.vehicle )
					break
				end
				sleep = config.rpm_speed_loop
				self.rpm = VehicleRpm(self.vehicle)
				self.speed = VehicleSpeed(self.vehicle )
				if self.speed < 0 then self.speed = 0 end
				if self.rpm < 0 then self.rpm = VehicleRpm(self.vehicle ) end
				if self.rpm > 1.2 then self.rpm = VehicleRpm(self.vehicle ) end
				--if self.rpm == '-nan(ind)' or self.rpm == tonumber('-nan(ind)') then self.rpm = VehicleRpm(self.vehicle ) end
				if not tonumber(self.rpm) then self.rpm = 1.0 end
				if not tonumber(self.speed) then self.speed = 1.0 end
				vtable = {
					['rpm'] = tonumber(self.rpm) or 0.5,
					['speed'] = self.speed or 10,
				}
			end
			Wait(sleep)
		end
		--TerminateThisThread()
		return
	end)
end

function Hud:NuiRpm()
	CreateThread(function()
		while ESX == nil do
			Wait(2000)
		end
		while self.ped == nil do
			Wait(1000)
		end
		newrpm = nil
		newspeed = nil
		while self.invehicle do
			local sleep = 2500
			if self.vehicle  ~= nil and self.vehicle  ~= 0 then
				sleep = tonumber(config.Rpm_sleep)
				if self.rpm < 0.21 then
				Wait(tonumber(config.idle_rpm_speed_sleep))
				end
				if newrpm ~= self.rpm or newrpm == nil or newspeed == nil or newspeed ~= self.speed then
					newrpm = self.rpm
					SendNUIMessage({
						type = "SetVehData",
						content = vtable
					})
				end
			end
			Wait(sleep)
		end
		--TerminateThisThread()
		return
	end)
end

function Hud:NuiCarhpandGas()
	CreateThread(function()
		while ESX == nil do
			Wait(2000)
		end
		local newgas = nil
		self.newgear = nil
		local vehealth = nil
		local belt= nil
		local wait = 2500
		self.loadedplate = true
		newcarhealth = nil
		newgas = nil
		newlight = nil
		newdoorstatus = nil
		newhood = nil
		newtrunk = nil
		metric = nil
		while self.invehicle do
			self.plate = GetVehicleNumberPlateText(self.vehicle )
			if self.vehicle  ~= nil and self.vehicle  ~= 0 then
				self.hp = GetVehicleEngineHealth(self.vehicle )
				--print(self.hp)
				self.gasolina = GetVehicleFuelLevel(self.vehicle )
				wait = config.NuiCarhpandGas_sleep
				if self.gasolina ~= newgas or newgas == nil then
					--print("car fuel")
					SendNUIMessage({
						type = "setFuelLevel",
						content = self.gasolina
					})
					newgas = self.gasolina
				end
				if newcarhealth ~= self.hp or newcarhealth == nil then
					--print("carhp")
					SendNUIMessage({
						hud = "setCarhp",
						content = self.hp
					})
					newcarhealth = self.hp
				end
				if self.manual then
					self.gear = self.savegear
				else
					self.gear = GetGear(self.vehicle )
				end
				if self.newgear ~= self.gear or self.newgear == nil then
					self.newgear = self.gear
					SendNUIMessage({
						type = "setGear",
						content = self.gear
					})
				end
				self:CalculateTimeToDisplay()
				self:timeformat()
				if metric == nil then
					metric = config.carui_metric
					SendNUIMessage({type = "SetMetrics", content = config.carui_metric})
				end
				local sleep = 2000
				local door = true
				local hood = 0
				local trunk = 0
				if self.vehicle  ~= nil and self.vehicle  ~= 0 then
					----print(GetVehicleDoorStatus(self.vehicle ))
					for i = 0, 6 do
						Wait(100)
						if GetVehicleDoorAngleRatio(self.vehicle ,i) ~= 0.0 then
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
					if GetVehicleDoorAngleRatio(self.vehicle ,4) ~= 0.0 then
						hood = 2
					end

					if newhood ~= hood or newhood == nil then
						newhood = hood
						SendNUIMessage({
						type = "setHood",
						content = hood
						})
					end

					if GetVehicleDoorAngleRatio(self.vehicle ,5) ~= 0.0 then
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
					--SetVehicleHighGear(self.vehicle ,self.maxgear)
			end
			Wait(wait)
		end
		metric = nil
		--TerminateThisThread()
		return
	end)
end

function Hud:NuiDistancetoWaypoint()
	--NUI DISTANCE to Waypoint
	CreateThread(function()
		local hided = false
		newdis = nil
		while self.invehicle do
			local sleep = config.direction_sleep
			
			
			local waypoint = GetFirstBlipInfoId(8)
			if self.vehicle  ~= 0 and DoesBlipExist(waypoint) then
				local coord = GetEntityCoords(self.ped, true)
				local dis = #(coord - GetBlipCoords(waypoint))
				if newdis ~= dis or newdis == nil then
					hided = false
					newdis = dis
					SendNUIMessage({
					type = "setWaydistance",
					content = dis
					})
				end
			elseif self.vehicle  ~=0 and not DoesBlipExist(waypoint) then
				--if newdis ~= dis or newdis == nil then
				if not hided then
					hided = true
					newdis = 0
					SendNUIMessage({
					type = "setWaydistance",
					content = 0
					})
				end
				Wait(config.direction_sleep)
			end
			Wait(sleep)
		end
		return
		--TerminateThisThread()
	end)

	CreateThread(function()
		while self.invehicle do
			local sleep = config.direction_sleep
			
			
			local waypoint = GetFirstBlipInfoId(8)
			if self.vehicle  ~= 0 and DoesBlipExist(waypoint) then
				sleep = 5
				local coord = GetEntityCoords(self.ped, true)
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
			Wait(sleep)
		end
		--TerminateThisThread()
		return
	end)
end

function Hud:GetVehicleStat(plate)
	local stat = self.veh_stats[tostring(plate)]
	if stat ~= nil then return stat end
end

function Hud:get_veh_stats(v,p)
	--if self.veh_stats[plate] ~= nil then return end
	while not LocalPlayer.state.loaded do
		Wait(10)
	end
	while self.veh_stats == nil do Wait(1) self.veh_stats = LocalPlayer.state.adv_stat and LocalPlayer.state.adv_stat or {} end
	self.veh_stats = LocalPlayer.state.adv_stat or {}
	--while self.veh_stats[self.plate] == nil do Wait(10) self.veh_ end
	if v ~= nil and p ~= nil then
		self.vehicle  = v
		self.plate = p
	end
	local lets_save = false
	if self.plate ~= nil and self.veh_stats[self.plate] == nil then
		print("CREATING VEHSTATS")
		lets_save = true
		self.veh_stats[self.plate] = {}
		self.veh_stats[self.plate].plate = self.plate
		self.veh_stats[self.plate].mileage = 0
		self.veh_stats[self.plate].oil = 100
		self.veh_stats[self.plate].coolant = 100
		self.veh_stats[self.plate].nitro = 0
		local numwheel = GetVehicleNumberOfWheels(self.vehicle )
		for i = 0, numwheel - 1 do
			if self.veh_stats[self.plate][tostring(i)] == nil then
				self.veh_stats[self.plate][tostring(i)] = {}
			end
			self.veh_stats[self.plate][tostring(i)].tirehealth = config.tirebrandnewhealth
		end
	end
	if self.veh_stats[self.plate].coolant == nil then
		self.veh_stats[self.plate].coolant = 100
	end
	if self.veh_stats[self.plate].oil == nil then
		self.veh_stats[self.plate].oil = 100
	end
	if self.veh_stats[self.plate].nitro == nil then
		self.veh_stats[self.plate].nitro = 0
	end
	if self.veh_stats[self.plate].turbo == nil then
		self.veh_stats[self.plate].turbo = 'default'
	end
	if self.veh_stats[self.plate].manual == nil then
		self.veh_stats[self.plate].manual = false
	end
	if self.veh_stats[self.plate].tires == nil then
		self.veh_stats[self.plate].tires = 'default'
	end
	if self.veh_stats[self.plate].engine == nil then
		self.veh_stats[self.plate].engine = 'default'
	end
	if self.veh_stats[self.plate].engine ~= nil and self.veh_stats[self.plate].engine ~= 'default' and self.currentengine[self.plate] ~= GetHashKey(tostring(self.veh_stats[self.plate].engine)) and self.invehicle then
		self:SetEngineSpecs(self.vehicle , GetHashKey(tostring(self.veh_stats[self.plate].engine)))
		print("new ENGINE",self.veh_stats[self.plate].engine)
		Citizen.Wait(1500)
	end
	if self.veh_stats[self.plate].tires ~= nil and self.veh_stats[self.plate].tires ~= 'default' and self.invehicle then
		self:TireFunction(self.veh_stats[self.plate].tires)
	end
	if self.veh_stats[self.plate].manual and not self.manual and self.invehicle then
		TriggerEvent('renzu_hud:manual', self.veh_stats[self.plate].manual)
	end
	if self.veh_stats[self.plate].turbo ~= nil and self.veh_stats[self.plate].turbo ~= 'default' and not self.alreadyturbo and self.invehicle then
		TriggerEvent('renzu_hud:hasturbo', self.veh_stats[self.plate].turbo)
		self.alreadyturbo = true
	end
	local numwheel = GetVehicleNumberOfWheels(self.vehicle )
	for i = 0, numwheel - 1 do
		if self.veh_stats[self.plate][tostring(i)] == nil then
			self.veh_stats[self.plate][tostring(i)] = {}
			self.veh_stats[self.plate][tostring(i)].tirehealth = config.tirebrandnewhealth
		end
	end
	if lets_save then
		TriggerServerEvent('renzu_hud:savedata', saveplate, self.veh_stats[tostring(saveplate)])
		LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] self.veh_stats, --[[replicate to server]] true)
		lets_save = false -- why?
	end
end

function Hud:NuiMileAge()
	local lastve = nil
	local savemile = false
	local saveplate = nil
	CreateThread(function()
		local count = 0
		while not LocalPlayer.state.playerloaded and count < 3 do
			Wait(1000)
			count = count + 1
		end
		if not LocalPlayer.state.playerloaded then
			TriggerServerEvent("renzu_hud:getdata",self.charslot)
		end
		Wait(1000)
		while self.veh_stats == nil and self.invehicle do
			Wait(100)
		end
		CreateThread(function()
			oldnitro = nil
			while self.invehicle do
				local wait = 10000
				--local self.plate = tostring(GetVehicleNumberPlateText(self.vehicle ))
				while self.veh_stats[self.plate] == nil and self.invehicle do
					Wait(1000)
				end
				nitros = self.veh_stats[self.plate].nitro
				if oldnitro == nil or oldnitro ~= nitros then
					oldnitro = self.veh_stats[self.plate].nitro
					SendNUIMessage({
						type = "setNitro",
						content = nitros
					})
				end
				local mileage = self.veh_stats[self.plate].mileage
				self.degrade = 1.0
				while mileage >= config.mileagemax do
					wait = 1
					--print(mileage)
					self.degrade = config.degrade_engine
					while self.mode == 'SPORTS' or self.mode == 'ECO' do
						wait = 1000
						if not self.invehicle then
							break
						end
						self.degrade = config.degrade_engine
						Wait(wait)
					end
					SetVehicleBoost(self.vehicle , config.degrade_engine)
					Wait(wait)
				end
				Wait(wait)
			end
		end)
		--print("NUI DATA")
		tirecache = {}
		newmileage = nil
		while self.invehicle do
			Wait(config.mileage_update)
			
			
			local driver = GetPedInVehicleSeat(self.vehicle , -1)
			if self.vehicle  ~= nil and self.vehicle  ~= 0 and driver == self.ped then
				-- local self.plate = tostring(GetVehicleNumberPlateText(self.vehicle ))
				--self.plate = string.gsub(self.plate, '^%s*(.-)%s*$', '%1')
				local newPos = GetEntityCoords(self.ped)
				savemile = true
				lastve = GetVehiclePedIsIn(self.ped, false)
				if self.plate ~= nil then
					saveplate = self.plate
					if self.veh_stats[self.plate] == nil then
						self:get_veh_stats()
					end
					--print(self.veh_stats[self.plate].coolant)
					if self.plate ~= nil and self.veh_stats[self.plate].plate == self.plate then
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
							self.veh_stats[self.plate].mileage = self.veh_stats[self.plate].mileage+(( dist / 1000 ) * config.mileage_speed) -- dist = meter / 1000 = kmh, this might be inaccurate
							oldPos = newPos
							if config.useturboitem and self.veh_stats[self.plate].turbo_health ~= nil then
								self.veh_stats[self.plate].turbo_health = self.veh_stats[self.plate].turbo_health - (( dist / 1000 ) * config.mileage_speed)
							end
						end
						if config.enabletiresystem then
							local dist3 = #(newPos-oldPos3)
							local ct = GetGameTimer()
							if dist3 > config.driving_status_radius then
								oldPos3 = newPos
								local numwheel = GetVehicleNumberOfWheels(self.vehicle )
								for i = 0, numwheel - 1 do
									Wait(100)
									if self.veh_stats[self.plate][tostring(i)] ~= nil and self.veh_stats[self.plate][tostring(i)].tirehealth > 0 then
										local bonuswear = 0.0
										if config.wearspeedmultiplier then
											bonuswear = (self.speed / 20)
										end
										self.veh_stats[self.plate][tostring(i)].tirehealth = self.veh_stats[self.plate][tostring(i)].tirehealth - (config.tirewear + bonuswear)
									end
									if self.veh_stats[self.plate][tostring(i)] ~= nil and self.veh_stats[self.plate][tostring(i)].tirehealth <= 0 then
										SetVehicleWheelHealth(self.vehicle , i, GetVehicleWheelHealth(self.vehicle ,i) - config.tirewear)
										if config.reducetraction then
											SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionCurveMin", self:GetHandling(self:GetPlate(self.vehicle )).traction * config.curveloss)
											SetVehicleHandlingField(self.vehicle , "CHandlingData", "fTractionCurveLateral", self:GetHandling(self:GetPlate(self.vehicle )).traction2 * config.acceleratetractionloss)
										end
									end
									--print("reduct tires")
									--self.Notify("Tire Wear: Wheel #"..i.." - "..self.veh_stats[self.plate][tostring(i)].tirehealth.."")
									local wheeltable = {
										['index'] = i,
										['tirehealth'] = self.veh_stats[self.plate][tostring(i)].tirehealth
									}
									if tirecache[i] == nil or tirecache[i] < ct then
										tirecache[i] = ct + 5000
										SendNUIMessage({
											type = "setWheelHealth",
											content = wheeltable
										})
									end
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
						if newmileage ~= nil and newmileage+0.5 < Round(self.veh_stats[self.plate].mileage) or newmileage == nil then
							newmileage = self.veh_stats[self.plate].mileage
							SendNUIMessage({
								type = "setMileage",
								content = self.veh_stats[self.plate].mileage
							})
						end
					end
				end
			elseif savemile and lastve ~= nil and saveplate ~= nil then
				savemile = false
				TriggerServerEvent('renzu_hud:savedata', saveplate, self.veh_stats[tostring(saveplate)])
				LocalPlayer.state:set( --[[keyName]] 'adv_stat', --[[value]] self.veh_stats, --[[replicate to server]] true)
				Wait(1000)
				lastve = nil
				saveplate = nil
			else
				Wait(1000)
			end
		end
		tirecache = nil
		--TerminateThisThread()
		return
	end)
end

function Hud:NuiVehicleHandbrake()
	--NUI HANDBRAKE
	
	
	if self.vehicle  ~= nil and self.vehicle  ~= 0 then
		SendNUIMessage({
		type = "setBrake",
		content = true
		})
		while RCP(0, 22) do
			Wait(100)
		end
		SendNUIMessage({
			type = "setBrake",
			content = false
		})
	end
	--TerminateThisThread()
end

function Hud:NuiShowMap(force)
	CreateThread(function()
		Wait(2000)
		print(config.carui,"MAP")
		if config.centercarhud == 'map' and config.carui == 'modern' or force then
			Wait(1000)
			while not self.start and config.push_start and not force do
				Wait(10)
			end
			SendNUIMessage({map = true, type = 'bukas'})
			local t = {['custom'] = config.usecustomlink,['type'] = config.mapversion,['link'] = config.mapurl}
			SendNUIMessage({type = "setMapVersion",content = t})
			self.ismapopen =  true
			Wait(250)
			while self.invehicle do
				--print("map ui")
				local sleep = 2000
				--print(GetNuiCursorPosition())
				if config.carui ~= 'modern' and not force then
					break
				end
				if self.start and config.carui == 'modern' or force then
					sleep = 250
					local myh = GetEntityHeading(self.ped) + GetCamhead()
					local camheading = GetCamhead()
					local xz, yz, zz = table.unpack(GetEntityCoords(self.ped))
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
						SendNUIMessage({map = true, type = "updatemapa",content = table})
						--SendNUIMessage({map = true, type = 'bukas'})
					end
				end
				Wait(sleep)
			end
			--TerminateThisThread()
		end
		return
	end)
end

function Hud:getveh()
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	self.lastveh = GetVehiclePedIsIn(PlayerPedId(), true)
	local dis = -1
	if v == 0 then
		if #(GetEntityCoords(self.ped) - GetEntityCoords(self.lastveh)) < 5 then
			v = self.lastveh
		end
		dis = #(GetEntityCoords(self.ped) - GetEntityCoords(self.lastveh))
	end
	if dis > 3 then
		v = 0
	end
	if v == 0 then
		local count = 5
		v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
		while #(GetEntityCoords(self.ped) - GetEntityCoords(v)) > 5 and count >= 0 do
			v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
			count = count - 1
			Wait(400)
			--print("fucker")
		end
	end
	return tonumber(v)
end

function Hud:LoadPTFX(lib)
	UseParticleFxAsset(lib)
	if not HasNamedPtfxAssetLoaded(lib) then
    	RequestNamedPtfxAsset(lib)
	end
    while not HasNamedPtfxAssetLoaded(lib) do
        Wait(10)
    end
end

local smokes = {}

function Hud:StartSmoke(ent)
	self:Notify('error','Engine',"Engine too Hot")
    CreateThread(function()
		local ent = ent
		while GetVehicleEngineTemperature(ent) > config.overheatmin do
			local Smoke = 0
			local part1 = false
			CreateThread(function()
				self:LoadPTFX('core')
				Smoke = self:Renzu_Hud(0xDDE23F30CC5A0F03, 'ent_amb_stoner_vent_smoke', ent, 0.05, 0, 0, 0, 0, 0, 28, 0.4, false, false, false, 0, 0, 0, 0)
				RemoveNamedPtfxAsset("core")
				part1 = true
			end)
			while not part1 do
				Wait(1011)
			end
			Wait(400)
			table.insert(smokes, {handle = Smoke})
			self:RemoveParticles()
			Wait(500)
		end
		self.refresh = false
		Wait(5000)
		return
    end)
end

function Hud:RemoveParticles()
	CreateThread(function()
		for _,parts in pairs(smokes) do
			--print("removing "..parts.handle.."")
			if parts.handle ~= nil and parts.handle ~= 0 and self:isparticleexist(parts.handle) then
				self:stopparticles(parts.handle, true)
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

function Hud:usefuckingshit(val)
    return self:Renzu_Hud(0x6C38AF3693A69A91, val)
end

function Hud:isparticleexist(val)
    return self:Renzu_Hud(0x74AFEF0D2E1E409B, val)
end

function Hud:stopparticles(val,bool)
    return self:Renzu_Hud(0x8F75998877616996, val, 0)
end

function Hud:startfuckingbullshit(effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3)
    return self:Renzu_Hud(0xDDE23F30CC5A0F03, effect, ent, shit1, shit2, shit3, shit4, shit5, shit6, bone, size, fuck1, fuck2, fuck3, 0, 0, 0, 0)
end

function Hud:NuiEngineTemp()
	--NUI ENGINE TEMPERATURE STATUS
	CreateThread(function()
		while self.veh_stats == nil or self.veh_stats[self.plate] == nil do
			Wait(100)
		end
		local newtemp = 0
		if GetVehicleEngineTemperature(self.vehicle ) < config.overheatmin then
			RemoveParticleFxFromEntity(self.vehicle )
		end
		--PREVENT PLAYER VEHICLE FOR STARTING UP A VERY HOT ENGINE
		local toohot = false
		CreateThread(function()
			while GetVehicleEngineTemperature(self.vehicle ) > config.overheatmin and self.invehicle do
				--print("still hot")
				toohot = true
				SetVehicleCurrentRpm(self.vehicle , 0.0)
				SetVehicleEngineOn(self.vehicle ,false,true,true)
				Wait(0)
			end
			-- IF ENGINE IS OKAY REPEAT BELOW LOOP IS BROKEN DUE TO toohot boolean
			if toohot and GetVehicleEngineTemperature(self.vehicle ) < config.overheatmin then
				self:NuiEngineTemp()
				--TerminateThisThread()
			end
			return
		end)
		Wait(1000)
		--self.triggered = false
		local vehiclemodel = GetEntityModel(self.vehicle )
		while self.invehicle and not toohot do
			local sleep = 2000
			
			
			newtemp = nil
			if self.vehicle  ~= nil and self.vehicle  ~= 0 then
				--print(self.veh_stats[self.plate].coolant)
				sleep = 4000
				local temp = GetVehicleEngineTemperature(self.vehicle )
				local overheat = false
				while self.rpm > config.dangerrpm and config.engineoverheat and not config.driftcars[vehiclemodel] do
					--self.rpm = VehicleRpm(self.vehicle )
					Wait(1000)
					--print("Overheat")
					SetVehicleEngineCanDegrade(self.vehicle , true)
					SetVehicleEngineTemperature(self.vehicle , GetVehicleEngineTemperature(self.vehicle ) + config.addheat)
					if newtemp ~= GetVehicleEngineTemperature(self.vehicle ) or newtemp == nil then
						newtemp = GetVehicleEngineTemperature(self.vehicle )
						SendNUIMessage({
						type = "setTemp",
						content = GetVehicleEngineTemperature(self.vehicle )
						})
						if self.plate ~= nil and GetVehicleEngineTemperature(self.vehicle ) >= config.overheatmin and self.veh_stats[self.plate].coolant ~= nil and self.veh_stats[self.plate].coolant <= 20 then
							explosion = 0
							explode = PlaySoundFromEntity(GetSoundId(), "Engine_fail", self.vehicle , "DLC_PILOT_ENGINE_FAILURE_SOUNDS", 0, 0)
							SetVehicleEngineTemperature(self.vehicle , GetVehicleEngineTemperature(self.vehicle ) + config.overheatadd)
							if not self.triggered then
								self.triggered = true
								TriggerServerEvent("renzu_hud:smokesync", VehToNet(self.vehicle ), GetEntityCoords(self.vehicle ,false))
							end
							self:Notify('error','Engine',"Engine Problem")
							while explosion < 500 do
								--print("explode")
								SetVehicleCurrentRpm(self.vehicle , 0.0)
								SetVehicleEngineOn(self.vehicle ,false,true,true)
								explosion = explosion + 1
								Wait(0)
							end
							--removeFCK()
							Wait(500)
							smokeonhood = false
							if not overheat then
								overheat = true
								CreateThread(function()
										Wait(5000)
										if self.vehicle  == 0 then
											self.vehicle  = GetVehiclePedIsIn(self.ped,true)
										end
										Wait(1000)
										SetVehicleEngineOn(self.vehicle ,false,true,true)
										if self.cansmoke and self.invehicle then
											--self.StartSmoke(self.vehicle )
										end
									--end
									Wait(1000)
									smokeonhood = true
									--TerminateThisThread()
								end)
							end
							explosion = 0
							Wait(3000)
							if GetVehicleEngineTemperature(self.vehicle ) < config.overheatmin then
								StopSound(explode)
								ReleaseSoundId(explode)
							end
						elseif GetVehicleEngineTemperature(self.vehicle ) >= config.overheatmin and self.veh_stats[self.plate] ~= nil and (self.veh_stats[self.plate].coolant ~= nil and self.veh_stats[self.plate].coolant >= 20) then
							self.veh_stats[self.plate].coolant = self.veh_stats[self.plate].coolant - config.reduce_coolant
							SendNUIMessage({
								type = "setCoolant",
								content = self.veh_stats[self.plate].coolant
							})
						end
					end
					--print(temp)
				end
				--print(temp)
				if newtemp ~= nil and newtemp + 2 < temp or newtemp ~= nil and newtemp > temp + 2 or newtemp == nil then
					newtemp = temp
					SendNUIMessage({
						type = "setTemp",
						content = temp
					})
				end
			end
			Wait(sleep)
		end
		Wait(2000)
		while self.invehicle do
			Wait(111)
		end
		Wait(1000)
		overheatoutveh = false
		--removeFCK()
		Wait(1000)
		CreateThread(function()
			while GetVehicleEngineTemperature(GetVehiclePedIsIn(self.ped,true)) > config.overheatmin and not toohot do
				overheatoutveh = true
				while not smokeonhood do
					Wait(111)
				end
				self.vehicle  = GetVehiclePedIsIn(self.ped,true)
				--print("SMOKING")
				local done = false
				Wait(5000)
				self:Notify('warning','Engine System',"Engine Temp: "..GetVehicleEngineTemperature(GetVehiclePedIsIn(self.ped,true)).."")
				Wait(1000)
			end
			overheatoutveh = false
			--TerminateThisThread()
			return
		end)
		Wait(2000)
		while overheatoutveh do
			Wait(100)
		end
		local cleanup = false
		--removeFCK()
		if not cleanup then
			--RemoveParticleFxFromEntity(self.vehicle )
		end
		self.refresh = true
		--RemoveParticleFxInRange(GetWorldPositionOfEntityBone(GetVehiclePedIsIn(self.ped,true), 28),20.0)
		--RemoveParticleFxFromEntity(getveh())
		Wait(2000)
		self.triggered = false
		--TerminateThisThread()
		return
	end)
end

function Hud:Myinfo()
	if config.framework == 'ESX' then
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Wait(0)
		end

		while ESX.GetPlayerData().job == nil do
			Wait(0)
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
		SendNUIMessage({
			hud = "setInfo",
			content = info
		})
		collectgarbage()
	elseif config.framework == 'QBCORE' then
		QBCore.Functions.GetPlayerData(function(PlayerData)
			local money = PlayerData.money['cash']
			local black = 0
			local bank = PlayerData.money['bank']
            info = {
				job = PlayerData.job.name or PlayerData.gang.name,
				joblabel = PlayerData.job.label or PlayerData.gang.label,
				money = money,
				black = black,
				bank = bank,
				id = GetPlayerServerId(PlayerId())
			}
			SendNUIMessage({
				hud = "setInfo",
				content = info
			})
			collectgarbage()
        end)
	end
end

local firstload = 0
function Hud:updateplayer(instant)
	if self.ped == nil then return end
	health = (GetEntityHealth(self.ped)-100) * 0.99
	armor = GetPedArmour(self.ped) * 0.99
	self.pid = PlayerId()
	if Hud.esx_status ~= nil and Hud.esx_status and config.statusordering['armor'] and config.statusordering['health'] then
		config.statusordering['armor'].value = armor
		config.statusordering['health'].value = health
	elseif Hud.esx_status ~= nil and not Hud.esx_status and config.statusordering[1] and config.statusordering[0] then
		config.statusordering[0].value = health
		config.statusordering[1].value = armor
	end
	SendNUIMessage({
		hud = "setArmor",
		content = armor
	})
	if health <= 0 then
		health = 0
	end
	SendNUIMessage({
		hud = "setHp",
		content = health
	})
end

function Hud:haveseatbelt()
local vc = GetVehicleClass(self.vehicle )
return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

function Hud:looking(entity)
local hr = GetEntityHeading(entity) + 90.0
if hr < 0.0 then
	hr = 360.0 + hr
end
hr = hr * 0.0174533
return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

function Hud:forwardvect(speed)
self.speed = self.speed / 10
return GetEntityForwardVector(self:getveh()) * self.speed
end

function Hud:DoblackOut()
	if not self.alreadyblackout then
		self.alreadyblackout = true
		Citizen.CreateThread(function()
			DoScreenFadeOut(1150)
			while not IsScreenFadedOut() do
				Citizen.Wait(0)
			end
			Citizen.Wait(1000)
			DoScreenFadeIn(250)
			self.alreadyblackout = false
			return
		end)
	end
end

function Hud:accidentsound()
	if not self.sounded then
		self.sounded = true
		Citizen.CreateThread(function()
			PlaySoundFrontend(-1, "SCREEN_FLASH", "CELEBRATION_SOUNDSET", 0)
			Citizen.Wait(1)
			self.sounded = false
			return
		end)
	end
end

function Hud:impactdamagetoveh()
	if self.alreadyblackout then
		if not accident then
			accident = true
			Citizen.CreateThread(function()
				
				local index = math.random(0, 15)
				local tankdamage = math.random(1, config.randomdamage)
				local enginedamage = math.random(1, config.randomdamage) 
				local vehiclebodydamage = math.random(1, config.randomdamage)
				SetVehiclePetrolTankHealth(self.vehicle ,GetVehiclePetrolTankHealth(self.vehicle ) - tankdamage )
				SetVehicleTyreBurst(self.vehicle ,index, 0 , 80.0)
				SetVehicleEngineHealth(self.vehicle  ,GetVehicleEngineHealth(self.vehicle ) - enginedamage)
				SetVehicleBodyHealth(self.vehicle , GetVehicleBodyHealth(self.vehicle ) - vehiclebodydamage) 
				SetVehicleOilLevel(self.vehicle , GetVehicleOilLevel(self.vehicle ) + 5.0 ) -- max is 15?
				SetVehicleCanLeakOil(self.vehicle , true)
				SetVehicleEngineTemperature(self.vehicle , GetVehicleEngineTemperature(self.vehicle ) + 45.0 )
				Citizen.Wait(3000) 
				accident = false
				return
			end)
		end 
	end
end

function Hud:hazyeffect()
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

function Hud:SendNuiSeatBelt()
	Citizen.Wait(300)
	if config.seatbelt_2 then
		SetFlyThroughWindscreenParams(config.seatbeltminspeed, 12.2352, 0.0, 0.0)
		SetPedConfigFlag(PlayerPedId(), 32, true)
	end
	if self.vehicle  ~= nil and self.vehicle  ~= 0 and config.enableseatbeltfunc and not config.seatbelt_2 then
		CreateThread(function()
			local Session = {}
			local Velocity = {}
			local lastspeed = 0
			while config.enableseatbeltfunc and not self.belt and self.invehicle do
				local sleep = 500

				Session[2] = Session[1]
				Session[1] = GetEntitySpeed(self.vehicle )
				if Session[1] > 15 then
					sleep = 100
				end
				if Session[1] > 30 then
					sleep = 50
				end
				if self.speed > config.seatbeltminspeed and HasEntityCollidedWithAnything(self.vehicle ) and Session[2] ~= nil and not self.belt and GetEntitySpeedVector(self.vehicle ,true).y > 5.2 and Session[1] > 15.25 and (Session[2] - Session[1]) > (Session[1] * 0.105) then
					local coord = GetEntityCoords(self.ped)
					local ahead = self:forwardvect(Session[1])
					if config.reducepedhealth then
						local kmh = lastspeed
						local damage = GetEntityHealth(self.ped) - (kmh * config.impactdamagetoped)
						if damage < 0 then
							damage = 0
						end
						SetEntityHealth(self.ped,damage)
					end
					if config.shouldblackout then
						self:DoblackOut()
						self:accidentsound()
					end
					if config.hazyeffect then
						self:hazyeffect()
					end
					if config.impactdamagetoveh then
						self:impactdamagetoveh()
					end
					Citizen.Wait(100)
					SetEntityCoords(self.ped,coord.x+ahead.x,coord.y+ahead.y,coord.z-0.47,true,true,true)
					SetEntityVelocity(self.ped,Velocity[2].x,Velocity[2].y,Velocity[2].z)
					Citizen.Wait(1)
					SetPedToRagdoll(self.ped, 1000, 1000, 0, 0, 0, 0)
					PopOutVehicleWindscreen(self.vehicle )
				end
				if not skip then
					lastspeed = GetEntitySpeed(self.vehicle ) * 3.6
					skip = true
				else
					skip = false
				end
				Velocity[2] = Velocity[1]
				Velocity[1] = GetEntityVelocity(self.vehicle )
				Wait(sleep)
			end
			while config.enableseatbeltfunc and self.belt and self.invehicle do
				local sleep = 5
				if self.belt then
					DisableControlAction(1, 75, true)  -- Disable exit vehicle when stop
					DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
								end
				Wait(sleep)
			end
			Session[1],Session[2] = 0.0,0.0
			return
		end)
	end
end

function Hud:sendsignaltoNUI()
	--NUI SIGNAL LIGHTS
	CreateThread(function()
		if self.vehicle  ~= nil and self.vehicle  ~= 0 then
			sleep = 100
			while self.signal_state ~= false do
				SendNUIMessage({
					type = "setSignal",
					content = self.signal_state
				})
				Wait(500)
			end
		end
		return
	end)
end

function Hud:entervehicle()
	if not config.push_start or self.customcarui then return end
	CreateThread(function()
		local p = PlayerPedId()
		local mycoords = GetEntityCoords(p)
		if not IsPedInAnyVehicle(p) and IsAnyVehicleNearPoint(mycoords.x,mycoords.y,mycoords.z,10.0) then
			--print("ENTERING")
			v = GetVehiclePedIsEntering(p)
			local c = 0
			while not GetVehiclePedIsTryingToEnter(p) or GetVehiclePedIsTryingToEnter(p) == 0 do
				v = GetVehiclePedIsTryingToEnter(p)
				if c > 2000 then
					break
				end
				c = c + 10
				--print(GetVehiclePedIsTryingToEnter(p))
				Wait(0)
			end
			local count = 0
			while not IsPedInAnyVehicle(p) and not self.start and count < 400 and config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)]  == 'modern' or not IsPedInAnyVehicle(p) and not self.start and count < 400 and not config.enable_carui_perclass and config.carui  == 'modern' do
				self.entering = true
				Wait(1)
				count = count + 1
				--print(count)
				SetVehicleEngineOn(self:getveh(),false,true,true)
				--print("waiting to get in")
				if GetVehiclePedIsTryingToEnter(p) ~= 0 then
					v = GetVehiclePedIsTryingToEnter(p)
				end
			end
			if config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)] ~= 'modern' or not config.enable_carui_perclass and config.carui ~= 'modern' then self.entering = false SetVehicleEngineOn(self:getveh(),false,true,false) return end
			if GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)]  == 'modern' or GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and not config.enable_carui_perclass and config.carui == 'modern' then
				self.entering = true
				--print("Disable auto self.start")
				SetVehicleEngineOn(v,false,true,true)
				while not self.start and IsPedInAnyVehicle(p) do
					if not self.start and IsVehicleEngineStarting(v) then
						SetVehicleEngineOn(v,false,true,true)
						--print("not started yet")
					end
					Wait(0)
				end
			end
		elseif self.start and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 or self.manual and IsPedInAnyVehicle(p) and GetVehicleDoorLockStatus(v) ~= 2 then
			Wait(500)
			if self.start then
				SendNUIMessage({
					type = "setStart",
					content = false
				})
			end
			if self.manual then
				SendNUIMessage({
					type = "setManual",
					content = false
				})
				self.manual = false
			end
			local content = {
				['bool'] = false,
				['type'] = config.carui
			}
			if self.ismapopen then
				SendNUIMessage({map = true, type = 'sarado'})
				self.ismapopen = false
			end
			while IsPedInAnyVehicle(self.ped, false) do
				Wait(11)
			end
			Wait(1000)
			SendNUIMessage({
				type = "setShow",
				content = content
			})
		end
	end)
end

function Hud:drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function Hud:turbolevel(value, lvl)
    if value > lvl then
        return lvl
    end
    return value
end

function Hud:maxnum(b, rpm)
    if b > 3.0 then
        b = 3.0
    end
    if b < 0.0 then
        return 0.0
    end
    return self:turbolevel(b, self.turbo)

end
function Hud:maxforce(b, min)
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

function Hud:Round(num,numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function Hud:Fuel()
	if IsVehicleEngineOn(self.vehicle ) and rpm ~= nil and rpm > 0 then
		self.rpm = self.rpm
		self.gear = GetGear(self.vehicle )
		local engineload = (self.rpm * (self.gear / 10))
		local formulagasusage = 1.0
		if config.usecustomfuel and config.mileage_affect_gasusage then
			currentmileage = self.veh_stats[self.plate].mileage
			formulagasusage = 1 + (currentmileage/config.mileagemax)
		end
		--print(formulagasusage,"formula")
		local boostgas = config.boost
		if config.turbo_boost_usage and self.boost > config.boost_min_level_usage then
			config.boost = self.boost * (engineload / (GetVehicleTurboPressure(self.vehicle ) * self.rpm))
		end
		local result = (config.fuelusage[self.Round(self.rpm,1)] * (config.classes[GetVehicleClass(self.vehicle )] or 1.0) / 15) * (formulagasusage)
		local advformula = result + (result * engineload)
		if self.mode == 'SPORTS' or config.turbo_boost_usage and self.boost > config.boost_min_level_usage then
			advformula = advformula * (1 + config.boost)
		end
		if self.mode == 'ECO' then
			advformula = advformula * config.eco
		end
		--print("FUEL USAGE: "..result..", ADV: "..advformula.." EngineLoad: "..engineload.."")
		SetVehicleFuelLevel(self.vehicle ,GetVehicleFuelLevel(self.vehicle ) - advformula)
		DecorSetFloat(self.vehicle ,config.fueldecor,GetVehicleFuelLevel(self.vehicle))
		config.boost = boostgas
	end
end

function Hud:fuelusagerun()
	CreateThread(function()
		if config.usecustomfuel then
			if not self.regdecor and not DecorExistOn(vehicle,config.fueldecor) then
				self.regdecor = true
				DecorRegister(config.fueldecor,1)
			end
			while self.invehicle do
				Wait(2000)
				if GetPedInVehicleSeat(self.vehicle ,-1) == self.ped then
					self:Fuel(self.vehicle )
				end
			end
		end
		return
	end)
end

function Hud:turboboost(gear)
	local engineload = 0.05
	if gear == 1 then
		engineload = 0.21
	elseif gear == 2 then
		engineload = 0.25
	elseif gear == 3 then
		engineload = 0.35
	elseif gear == 4 then
		engineload = 0.45
	elseif gear == 5 then
		engineload = 0.45
	elseif gear == 6 then
		engineload = 0.45
	end
	return engineload 
end

function Hud:Boost(hasturbo)
	self.newgear = 0
	self.rpm = VehicleRpm(self.vehicle )
	self.gear = GetGear(self.vehicle )
	self.boost = 1.0
	local boost_pressure = 0.0
	CreateThread(function()
		while self.invehicle do
			local sleep = 2000
			
			if self.vehicle  ~= 0 then
				sleep = 10
				self.rpm = VehicleRpm(self.vehicle )
				self.gear = GetGear(self.vehicle )
			end
			Wait(sleep)
		end
		return
	end)
	if hasturbo and config.turbo_boost[self.veh_stats[self.plate].turbo] > config.boost then
		self.turbo = config.turbo_boost[self.veh_stats[self.plate].turbo]
		ToggleVehicleMod(self.vehicle , 18, true)
	else
		self.turbo = config.boost
	end
	local torque = 0
	CreateThread(function()
		--print("starting boost func")
		local turbo_type = tostring(self.veh_stats[self.plate].turbo or 'default')
		local lag = 0
		while hasturbo and self.invehicle do
			local sleep = 2000
			--local ply = PlayerPedId()
			local reset = true
			
			if self.vehicle  ~= 0 then
				sleep = 50
				self.boost = 1.0
				self.newgear = self.gear
				local vehicleSpeed = 0
				self.rpm2 = self.rpm
				local engineload = (self.rpm / (self.gear / 10)) / 100
				if self.rpm > 1.15 then
				elseif self.rpm > 0.1 then
					self.rpm = (self.rpm * self.turbo)
				elseif self.rpm < 0.0 then
					self.rpm = 0.2
				end
				if self.rpm2 < 0.0 then
					self.rpm2 = 0.2
				end
				--print("RPM",self.rpm,"LAG",lag)
				if tonumber(self.rpm2) > 0.3 then
					--local speed = VehicleSpeed(self.vehicle ) * 3.6
					if sound and IsControlJustReleased(1, 32) then
						StopSound(soundofnitro)
						ReleaseSoundId(soundofnitro)
						sound = false
					end

					local pressure = 0.5
					if not IsControlPressed(0, 32) then
						lag = 0
					end
					if IsControlPressed(1, 32) and self.plate ~= nil and self.veh_stats[self.plate] ~= nil then
						if not sound then
							soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", self.vehicle , "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
							sound = true
						end
						--print(engineload,"ENGINELOAD")
						--SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed*3.500000)
						local turbolag = 5 + config.turbo_boost[turbo_type]
						self.maxspeed = self.maxspeed
						if self.maxspeed > 200 then
							self.maxspeed = 200
						end
						local lag = 0
						while self.veh_stats[self.plate] ~= nil and IsControlPressed(1, 32) do
							--while self.veh_stats[self.plate] ~= nil and lag < (config.lagamount[turbo_type] * config.turbo_boost[turbo_type]) and (engineload / ((self.maxspeed) / (config.lagamount[turbo_type] * lag))) < turboboost(self.gear) and IsControlPressed(1, 32) do
							local localrpm = GetVehicleCurrentRpm(self.vehicle )
							local load = (self.gear * localrpm) * ((self.flywheel + self.finaldrive))
							engineload = tonumber((localrpm * (self.gear / turbolag)))
							--ShowHelpNotification(tostring(engineload), true, 1, 5)
							if tonumber(engineload) then
								--engineload =  tonumber(maxnum(((self.rpm2 + 0.1) * config.turbo_boost[tostring(self.veh_stats[self.plate].turbo)])) * (1 + engineload))
								lag = (lag + (10.08 * localrpm)) * (localrpm * load)
								if lag > config.lagamount[turbo_type] then
									lag = config.lagamount[turbo_type]
								end
								power_percent = lag / config.lagamount[turbo_type]
								--print("RPM2",self.rpm,"PERCENT",power_percent)
								if engineload > 0.0 and engineload < 10.0 and tonumber(engineload) then
									pressure = ((tonumber(config.turbo_boost[turbo_type] * power_percent)) + engineload) * power_percent
									if turbo_type == 'sports' then -- temporary to correct sports value
										pressure = pressure * 1.4
									end
									SetVehicleTurboPressure(self.vehicle , pressure)
									boost_pressure = GetVehicleTurboPressure(self.vehicle )
									if boost_pressure > config.turbo_boost[turbo_type] then
										boost_pressure = config.turbo_boost[turbo_type]
									end
								end
							end
							local boosttemp = 0.1 + (self.rpm2 / 2)
							if boosttemp < 0.3 then
								boosttemp = 0.3
							end
							--SetVehicleBoost(self.vehicle , boosttemp)
							Wait(10)
							--self.Notify('success',"PRESSURE",lag)
							--self.drawTxt("BOOST lag:  "..lag.."",4,0.5,0.93,0.50,255,255,255,180)
							--self.drawTxt("BOOST engineload:  "..boost_pressure.."",4,0.5,0.83,0.50,255,255,255,180)
							if IsControlPressed(1, 32) and self.rpm > 0.4 and not RCR(1, 32) then
								self.pressed = true
								if self.boost < 1.0 then
									self.boost = 1.0
								end
								if self.boost < 0.0 or self.boost > 45.0 then
									self.boost = 1.0
								end
								--boost_pressure = GetVehicleTurboPressure(self.vehicle )
								self.boost = (boost_pressure)
								if config.turbogauge and self.turbo ~= nil and boost_pressure ~= nil and boost_pressure > 0 then
									SendNUIMessage({
										type = "setTurboBoost",
										content = {
											['speed'] = boost_pressure,
											['max'] = self.turbo
										}
									})
									Wait(1)
								end
								--self.Notify('success',"PRESSURE",lag)
								--print(self.rpm2 > 0.65 , self.rpm2 < 0.95 , self.turbosound < 500 , self.gear ~= self.oldgear , power_percent <= 1.0)
								if config.boost_sound and self.rpm2 > 0.65 and self.rpm2 < 0.95 and self.turbosound < 500 and self.gear == self.oldgear and power_percent < 1.0 then
									self.turbosound = self.turbosound + 1
									SetVehicleBoostActive(self.vehicle , 1, 0)
									Wait(10)
									SetVehicleBoostActive(self.vehicle , 0, 0)
								else
									self.turbosound = 0
								end
								self.oldgear = self.gear
							end
						end
						--self.drawTxt("BOOST pressure:  "..pressure.."",4,0.5,0.79,0.50,255,255,255,180)
						if config.boost_sound and self.rpm2 > 0.65 and self.rpm2 < 0.95 and self.turbosound < 500 and self.gear == self.oldgear and power_percent <= 1.0 then
							self.turbosound = self.turbosound + 1
							SetVehicleBoostActive(self.vehicle , true, false)
							Wait(5)
							SetVehicleBoostActive(self.vehicle , false, false)
						else
							self.turbosound = 0
						end
						self.oldgear = self.gear
					else
						if sound then
							StopSound(soundofnitro)
							ReleaseSoundId(soundofnitro)
							sound = false
						end
						Wait(500) -- TURBO LAG
					end
					if reset and not IsControlPressed(1, 32) then
						SetVehicleTurboPressure(self.vehicle , 0.0)
					end
					SetVehicleTurboPressure(self.vehicle , pressure)
					boost_pressure = GetVehicleTurboPressure(self.vehicle )
					if self.gear == 0 then
						self.gear = 1
					end
					self.boost = (boost_pressure * 1)
					--print(self.boost)
					-- if IsControlPressed(1, 32) and self.rpm > 0.4 and not RCR(1, 32) then
					-- 	self.pressed = true
					-- 	if self.boost < 1.0 then
					-- 		self.boost = 1.0
					-- 	end
					-- 	if self.boost < 0.0 or self.boost > 45.0 then
					-- 		self.boost = 1.0
					-- 	end
					-- 	if config.turbogauge and turbo ~= nil and boost_pressure ~= nil and boost_pressure > 0 then
					-- 		SendNUIMessage({
					-- 			type = "setTurboBoost",
					-- 			content = {
					-- 				['speed'] = boost_pressure / 2.65,
					-- 				['max'] = turbo
					-- 			}
					-- 		})
					-- 		Wait(1)
					-- 	end
					-- else
					-- 	Wait(100)
					-- end
					if GetVehicleThrottleOffset(self.vehicle ) <= 0.0 then
						Wait(200)
						self.pressed = false
						local t = {
							['speed'] = 0.0,
							['max'] = self.turbo
						}
						SendNUIMessage({
							type = "setTurboBoost",
							content = t
						})
						Wait(10)
					end
					if self.degrade ~= 1.0 then -- config.turbo_boost[self.veh_stats[self.plate].turbo]
						if self.plate ~= nil and self.veh_stats[self.plate] and config.turbo_boost[turbo_type] > config.boost then
							boostlevel = config.turbo_boost[turbo_type]
						else
							boostlevel = config.boost
						end
						self.boost = self.boost * (self.degrade / boostlevel)
					end
					--ShowHelpNotification(self.boost, true, 1, 5)
				else
					self.rpm = VehicleRpm(self.vehicle )
					Wait(100)
				end
			end
			Wait(sleep)
		end
		return
	end)
	-- CreateThread(function()
	-- 	local self.pressed = false
	-- 	while self.invehicle do
	-- 		if IsControlPressed(1, 32) and self.rpm > 0.4 and not RCR(1, 32) then
	-- 			self.pressed = true
	-- 			if self.boost < 1.0 then
	-- 				self.boost = 1.0
	-- 			end
	-- 			if self.boost < 0.0 or self.boost > 45.0 then
	-- 				self.boost = 1.0
	-- 			end
	-- 			if config.turbogauge then
	-- 				SendNUIMessage({
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
	-- 		if GetVehicleThrottleOffset(self.vehicle ) <= 0.0 then
	-- 			Wait(200)
	-- 			self.pressed = false
	-- 			local t = {
	-- 				['speed'] = 0.0,
	-- 				['max'] = turbo
	-- 			}
	-- 			SendNUIMessage({
	-- 				type = "setTurboBoost",
	-- 				content = t
	-- 			})
	-- 			Wait(10)
	-- 		end
	-- 		Citizen.Wait(7)
	-- 	end
	-- end)

	CreateThread(function()
		self.pressed = false
		local turbo_type = tostring(self.veh_stats[self.plate].turbo or 'default')
		while self.invehicle do
			local sleep = 100
			if self.mode ~= 'SPORTS' and not hasturbo then
				break
			end
			if IsControlPressed(1, 32) and self.rpm > 0.4 and not RCR(1, 32) then
				sleep = 5
				self.pressed = true
				if self.boost < 1.0 then
					self.boost = 1.0
				end
				if self.boost < 0.0 or self.boost > 45.0 then
					self.boost = 1.0
				end
				if self.mode == 'SPORTS' and not hasturbo then
					if self.mode ~= 'SPORTS' then
						break
					end
					SetVehicleBoost(self.vehicle , 1.0 + config.boost)
				else
					SetVehicleBoost(self.vehicle , 1+self.boost * (config.turbo_boost[turbo_type] + self.maxgear - self.gear))
				end
			else
				Wait(100)
			end
			Citizen.Wait(sleep)
		end
		SendNUIMessage({
			type = "setShowTurboBoost",
			content = false
		})
		self.alreadyturbo = false
		self.globaltopspeed = nil
		self.topspeedmodifier = 1.0
		self.busy = true
		Wait(100)
		self.vehicle  = self:getveh()
		if DoesEntityExist(self.vehicle ) and self:GetHandling(self:GetPlate(self.vehicle )).flywheel ~= 0.0 and self:GetHandling(self:GetPlate(self.vehicle )).finaldrive ~= 0.0 then
			SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveMaxFlatVel", self:GetHandling(self:GetPlate(self.vehicle )).maxspeed)
			SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", self:GetHandling(self:GetPlate(self.vehicle )).finaldrive)
			SetVehStats(self.vehicle , "CHandlingData", "fInitialDriveForce", self:GetHandling(self:GetPlate(self.vehicle )).flywheel)
			while not GetVehStats(self.vehicle , "CHandlingData","fDriveInertia") == self:GetHandling(self:GetPlate(self.vehicle )).finaldrive and self.invehicle do
				if self.GetHandling(self:GetPlate(self.vehicle )).finaldrive ~= nil then
					SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", self:GetHandling(self:GetPlate(self.vehicle )).finaldrive)
				end
				Wait(0)
			end
			while not GetVehStats(self.vehicle , "CHandlingData","fInitialDriveForce") == self:GetHandling(self:GetPlate(self.vehicle )).flywheel and self.invehicle do
				if self.GetHandling(self:GetPlate(self.vehicle )).flywheel ~= nil then
					SetVehStats(self.vehicle , "CHandlingData", "fInitialDriveForce", self:GetHandling(self:GetPlate(self.vehicle )).flywheel)
				end
				Wait(0)
			end
		end
		SetVehicleEnginePowerMultiplier(self.vehicle , 1.0) -- just incase
		self.busy = false
		StopSound(soundofnitro)
		ReleaseSoundId(soundofnitro)
		if self.propturbo ~= nil then
			--print("deleting")
			self:ReqAndDelete(self.propturbo,true)
			self.propturbo = nil
		end
		self.boost = 1.0
		return
	end)
end

function Hud:vehiclemode()
	local veh = Entity(self.vehicle).state
	PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0)
	if self.mode == 'NORMAL' then
		self.mode = 'SPORTS'
		veh:set('hudemode', self.mode, true)
		SendNUIMessage({
			type = "setMode",
			content = self.mode
		})
		Wait(500)
		self:Notify('success','Vehicle Mode',"Sports self.mode Activated")
		while self.busy do
			Wait(10)
		end
		self.rpm = VehicleRpm(self.vehicle )
		self.gear = GetGear(self.vehicle )
		CreateThread(function()
			self.newgear = 0
			while self.mode == 'SPORTS' and self.invehicle do
				local sleep = 2000
				--local ply = PlayerPedId()
				
				if self.vehicle  ~= 0 then
					sleep = 10
					self.rpm = VehicleRpm(self.vehicle )
					self.gear = GetGear(self.vehicle )
					self.topspeedmodifier = config.topspeed_multiplier
				end
				Wait(sleep)
			end
			return
		end)

		local sound = false
		CreateThread(function()
			self.newgear = 0
			olddriveinertia = self:GetHandling(self:GetPlate(self.vehicle )).finaldrive
			oldriveforce = self:GetHandling(self:GetPlate(self.vehicle )).flywheel
			oldtopspeed = self:GetHandling(self:GetPlate(self.vehicle )).maxspeed -- normalize
			local fixedshit = (config.topspeed_multiplier * 1.0)
			local old = oldtopspeed * 1.0
			self.turbosound = 0
			self.oldgear = 0
			local fo = oldtopspeed * 0.64
			if config.sports_increase_topspeed then
				if GetVehicleMod(self.vehicle ,13) > 0 then
					local bonus = (self:GetHandling(self:GetPlate(self.vehicle )).maxspeed * config.topspeed_multiplier)
					self.globaltopspeed = bonus * 1.5
				else
					self.globaltopspeed = self:GetHandling(self:GetPlate(self.vehicle )).maxspeed * config.topspeed_multiplier
				end
				SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveMaxFlatVel", self.globaltopspeed)
			end
			self.plate = GetVehicleNumberPlateText(self.vehicle)
			--self.plate = string.gsub(self.plate, '^%s*(.-)%s*$', '%1')
			while self.mode == 'SPORTS' and config.turbo_boost[self.veh_stats[self.plate].turbo] > config.boost and self.invehicle do
				Citizen.Wait(1000) -- do nothing turbo torque is more higher
			end
			self:Boost()
			return
		end)
	elseif self.mode == 'SPORTS' and self.invehicle then
		self.mode = 'DRIFT'
		veh:set('hudemode', self.mode, true)
		SendNUIMessage({
			type = "setMode",
			content = self.mode
		})
		Wait(500)
		self:Notify('success','Vehicle Mode',"DRIFT mode Activated")
		while self.busy do
			Wait(10)
		end
		local sound = false
		CreateThread(function()
			self.busy = true
			self:ToggleDrift()
			Wait(500)
			self.vehicle  = self:getveh()
			self.busy = false
			return
		end)
	elseif self.mode == 'DRIFT' and self.invehicle then
		self.mode = 'ECO'
		veh:set('hudemode', self.mode, true)
		SendNUIMessage({
			type = "setMode",
			content = self.mode
		})
		Wait(500)
		self:Notify('success','Vehicle Mode',"ECO self.mode Activated")
		while self.busy do
			Wait(10)
		end
		local sound = false
		CreateThread(function()
			local olddriveinertia = 1.0
			olddriveinertia = self:GetHandling(self:GetPlate(self.vehicle )).finaldrive
			SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", config.eco)
			while self.mode == 'ECO' and self.invehicle do
				local sleep = 2000
				local reset = true
				
				if self.vehicle  ~= 0 then
					sleep = 7
					if IsControlPressed(1, 32) then
						local power = config.eco+0.4
						if self.degrade ~= 1.0 then
							power = power * self.degrade
						end
						SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", config.eco)
						SetVehicleBoost(self.vehicle , (config.eco+0.4))
					end
				end
				Wait(sleep)
			end
			self.busy = true
			Wait(100)
			self.vehicle  = self:getveh()
			if DoesEntityExist(self.vehicle ) and self:GetHandling(self:GetPlate(self.vehicle )).finaldrive ~= 0.0 then
				SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", self:GetHandling(self:GetPlate(self.vehicle )).finaldrive)
				while not GetVehStats(self.vehicle , "CHandlingData","fDriveInertia") == self:GetHandling(self:GetPlate(self.vehicle )).finaldrive and self.invehicle do
					SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", self:GetHandling(self:GetPlate(self.vehicle )).finaldrive)
					Wait(0)
				end
			end
			self.busy = false
			StopSound(soundofnitro)
			ReleaseSoundId(soundofnitro)
			return
		end)
	else
		self.mode = 'NORMAL'
		veh:set('hudemode', self.mode, true)
		SendNUIMessage({
			type = "setMode",
			content = self.mode
		})
		self:Notify('success','Vehicle Mode',"Normal Mode Restored")
	end
end

function Hud:ToggleDrift()
	local nondrift = {}
	local currentveh = self.vehicle
	for index, value in ipairs(config.drift_handlings) do
		if value[1] == 'vecInertiaMultiplier' or value[1] == 'vecCentreOfMassOffset' then
			nondrift[value[1]] = GetVehicleHandlingVector(self.vehicle, "CHandlingData", value[1])
		elseif value[1] then
			nondrift[value[1]] = GetVehicleHandlingFloat(self.vehicle, "CHandlingData", value[1])
		end
	end
	local NonDrift = function(nondrift)
		local veh = self:getveh()
		for index, value in pairs(nondrift) do
			if index == 'vecInertiaMultiplier' or index == 'vecCentreOfMassOffset' then
				SetVehicleHandlingVector(veh, "CHandlingData", index, value)
			elseif value then
				SetVehicleHandlingFloat(veh, "CHandlingData", index, tonumber(value))
			end
			SetVehicleEnginePowerMultiplier(veh, 1.0) -- do not remove this, its a trick for flatvel
		end
		self:applyVehicleMods(veh,nondrift['fDriveBiasFront'])
	end
	local Drift = function(handling)
		for index, value in ipairs(handling) do
			if value[1] == 'fInitialDriveMaxFlatVel' and self.vehicle ~= 0 then
				--SetVehicleHandlingField(self.vehicle, "CHandlingData", value[1], tonumber(value[2]))
			elseif value[1] == 'vecInertiaMultiplier' or value[1] == 'vecCentreOfMassOffset' and self.vehicle ~= 0 then
				SetVehicleHandlingVector(self.vehicle, "CHandlingData", value[1], tonumber(value[2]))
			elseif value[1] and self.vehicle ~= 0 then
				SetVehicleHandlingFloat(self.vehicle, "CHandlingData", value[1], tonumber(value[2]))
			end
			SetVehicleEnginePowerMultiplier(self.vehicle, 1.0) -- do not remove this, its a trick for flatvel
		end
		--print(GetVehicleHandlingFloat(self.vehicle, "CHandlingData", 'fDriveInertia'),config.drift_handlings[1][1])
		self:applyVehicleMods(self.vehicle ~= 0 and self.vehicle or self:getveh(),0.0)
	end
	CreateThread(function()
		while self.mode == 'DRIFT' and self.invehicle do
			if self:angle(self.vehicle ) >= 5 and self:angle(self.vehicle ) <= 38 and GetEntityHeightAboveGround(self.vehicle ) <= 1.5 then
				SetVehicleHandlingField(self.vehicle, "CHandlingData", 'fInitialDriveMaxFlatVel', config.drift_handlings[1][2])
				SetVehicleEnginePowerMultiplier(self.vehicle, 1.0) -- do not remove this, its a trick for flatvel
				self:ForceVehicleGear (self.vehicle, GetVehicleCurrentGear(self.vehicle) > 1 and GetVehicleCurrentGear(self.vehicle) -1 or GetVehicleCurrentGear(self.vehicle))
				SetVehicleHighGear(self.vehicle,GetVehicleHighGear(self.vehicle))
			else
				SetVehicleHandlingField(self.vehicle, "CHandlingData", 'fInitialDriveMaxFlatVel', nondrift['fInitialDriveMaxFlatVel'])
				SetVehicleEnginePowerMultiplier(self.vehicle, 1.0) -- do not remove this, its a trick for flatvel
			end
			Wait(100)
		end
	end)
	while self.mode == 'DRIFT' and self.invehicle do
		local Speed = GetEntitySpeed(self.vehicle)
		if Speed < 40 then
			Drift(config.drift_handlings)
		elseif Speed > 50 then
			local veh = Entity(self.vehicle).state
			self.mode = 'NORMAL'
			veh:set('hudemode', self.mode, true)
			SendNUIMessage({
				type = "setMode",
				content = self.mode
			})
		end
		Wait(500)
	end
	NonDrift(nondrift)
end

function Hud:applyVehicleMods(veh,wheel) -- https://forum.cfx.re/t/cant-change-setvehiclehandlingfloat-transforming-vehicle-to-awd-fivem-bug/3393188
    -- Do this shit is necessary to apply the HandlingFloat
    SetVehicleModKit(veh,0)
	for i = 0 , 35 do
		SetVehicleMod(veh,i,GetVehicleMod(veh,i),false)
	end
	if wheel == 0.0 then
		for i = 0 , 3 do
			SetVehicleWheelIsPowered(veh,i,i > 1)
		end
	elseif wheel == 1.0 then
		for i = 0 , 3 do
			SetVehicleWheelIsPowered(veh,i,i < 1)
		end
	else
		for i = 0 , 3 do
			SetVehicleWheelIsPowered(veh,i,true)
		end
	end
end

function Hud:differential()
	----print("self.pressed")
	local diff = GetVehStats(self.vehicle , "CHandlingData","fDriveBiasFront")
	if diff > 0.01 and diff < 0.9 and self.old_diff == nil and not self.togglediff then -- default 4wd
		self.old_diff = diff -- save old
		diff = 0.0 -- change to rearwheel
		self.togglediff = true
		self:Notify('success','Vehicle Differential',"RWD Activated")
	elseif self.old_diff ~= nil and self.togglediff then
		diff = self.old_diff
		SetVehStats(self.vehicle , "CHandlingData", "fDriveBiasFront", diff)
		self.togglediff = false
		self.old_diff = nil
		self:Notify('success','Vehicle Differential',"Default Differential Activated")
	elseif diff == 1.0 and not self.togglediff and self.old_diff == nil then -- Front Wheel Drive
		--print("FWD")
		diff =  0.5
		self.old_diff = 1.0
		self.togglediff = true
		self:Notify('success','Vehicle Differential',"AWD Activated")
	elseif diff == 0.0 and not self.togglediff and self.old_diff == nil then -- Rear Wheel Drive
		self.old_diff = 0.0
		diff = 0.5
		self.togglediff = true
		self:Notify('success','Vehicle Differential',"AWD Activated")
	end
	if self.togglediff then
		PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0)
	else
		PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0)
	end
	SendNUIMessage({
		type = "setDifferential",
		content = diff
	})
	Wait(500)
	CreateThread(function()
		SetVehStats(self.vehicle , "CHandlingData", "fDriveBiasFront", diff)
		self:applyVehicleMods(self.vehicle, diff)
		while self.togglediff and self.invehicle do
			Wait(1000)
		end
		Wait(300)
		if not self.invehicle then
			self.togglediff = false
			self.old_diff = 0
		end
		return
	end)
end

function Hud:Notify(type,title,message)
	local table = {
		['type'] = type,
		['title'] = title,
		['message'] = message
	}
	SendNUIMessage({
		type = "SetNotify",
		content = table
	})
end

function Hud:requestmodel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do 
		Wait(1)
		RequestModel(model)
	end
end

function Hud:playanimation(animDict,name)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	TaskPlayAnim(PlayerPedId(), animDict, name, 2.0, 2.0, -1, 47, 0, 0, 0, 0)
end

function Hud:Cruisecontrol()
	PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0 )
	self.cruising = not self.cruising
	Citizen.Wait(500)
	Citizen.CreateThread(function()
		SendNUIMessage({
			type = "setCruiseControl",
			content = self.cruising
		})
		local topspeed = self:GetHandling(self:GetPlate(self.vehicle )).maxspeed * 0.64
		local speed = VehicleSpeed(self.vehicle )
		if self.cruising then
			text = "locked to "..(speed*3.6).." kmh"
		else
			text = 'Restored'
		end
		self:Notify('success','Vehicle Cruise System',"Max Speed has been "..text.."")
		while self.invehicle and self.cruising do
			SetEntityMaxSpeed(self.vehicle ,speed)
			Citizen.Wait(1000)
		end
		SetEntityMaxSpeed(self.vehicle ,topspeed)
		self.cruising = false
		return
	end)
end

local sprinting = false
function Hud:setStatusEffect()
	if config.running_affect_status then
		if IsPedRunning(self.ped) or IsPedSprinting(self.ped) then
			if not sprinting then
				sprinting = true
				Citizen.Wait(111)
				Citizen.CreateThread(function()
					while IsPedSprinting(self.ped) and (100 - GetPlayerSprintStaminaRemaining(self.pid)) > 1 or IsPedRunning(self.ped) and (100 - GetPlayerSprintStaminaRemaining(self.pid)) > 1 do
						self:UpdateStatus(true)
						TriggerEvent('esx_status:'..config.running_status_mode..'', config.running_affected_status, config.running_status_val)
						Wait(800)
					end
					sprinting = false
					return
				end)
			end
		end
	end
	if config.melee_combat_affect_status then
		if IsPedInMeleeCombat(self.ped) then
			Citizen.Wait(1000)
			TriggerEvent('esx_status:'..config.melee_combat_status_mode..'', config.melee_combat_affected_status, config.melee_combat_status_val)
		end	
	end
	if config.parachute_affect_status then
		if IsPedInParachuteFreeFall(self.ped) then
			Citizen.Wait(1000)
			TriggerEvent('esx_status:'..config.parachute_status_mode..'', config.parachute_affected_status, config.parachute_status_val)
		end	
	end
	if config.playing_animation_affect_status then
		--if IsEntityPlayingAnim(self.ped, )
		for k,v in pairs(config.status_animation) do
			Wait(0)
			if IsEntityPlayingAnim(self.ped, v.dict, v.name, 3) then
				--print("LOADED")
				TriggerEvent('esx_status:'..v.mode..'', v.status, v.val)
				Citizen.Wait(1000)
			end
		end
	end
	if IsPedSwimmingUnderWater(self.ped) then
		if self.underwatertime >= 1 then
			SetPedDiesInWater(self.ped,false)
			SetPlayerUnderwaterTimeRemaining(PlayerId(),300)
			SetPedMaxTimeUnderwater(PlayerPedId(),300)
			self.underwatertime = self.underwatertime - 2
		end
		self:UpdateStatus(true)
	elseif not IsPedSwimmingUnderWater(self.ped) and self.underwatertime < 30 then
		self.underwatertime = 30
	end
end

function Hud:statusplace()
	local placing = config.statusplace
	local table = {}
	if placing == 'top-right' then
		if config.status_type == 'icons' then
			table = {['top'] = '45px', ['right'] = '90px'}
		else
			if config.statusui == 'simple' then
				table = {['top'] = '40px', ['right'] = '110px'}
			else
				table = {['top'] = '10px', ['right'] = '150px'}
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
	SendNUIMessage({
		type = "setStatusUILocation",
		content = table
	})
end

-- BODY STATUS

function Hud:CheckPatient()
	if xPlayer.job ~= nil and xPlayer.job.name == config.checkbodycommandjob then
		local players, myPlayer = {}, PlayerId()
		for k,player in ipairs(GetActivePlayers()) do
			self.ped = GetPlayerPed(player)
			if DoesEntityExist(self.ped) and player ~= myPlayer then
				table.insert(players, player)
			end
		end
		local closest,dist
		for k,v in pairs(players) do
			local o_id = GetPlayerServerId(v)
			if o_id ~= GetPlayerServerId(PlayerId()) then
				local curDist = #(GetPlayerPed(v) - GetEntityCoords(self.ped))
				if not dist or curDist < dist then
					closest = o_id
					dist = curDist
				end
			end
		end
		if closest ~= nil then
			self:BodyUi(closest)
		else
			self:Notify('success','Body System',"No Player Around")
		end
	else
		self:Notify('success','Body System',"No Access to CheckBody")
	end
end

checkingpatient = false
function Hud:BodyUi(target)
	--print(target)
	self.healing = target
	if target ~= nil then
		checkingpatient = true
		TriggerServerEvent('renzu_hud:checkbody', tonumber(target))
	end
	self.bodyui = not self.bodyui
	if target == nil then
		SendNUIMessage({
			type = "setShowBodyUi",
			content = self.bodyui
		})
	end
	Wait(100)
	if target ~= nil then
		while self.bodyui do
			Wait(100)
		end
		checkingpatient = false
		TriggerServerEvent('renzu_hud:checkbody')
	end
end

function Hud:BodyLoop()
	if checkingpatient then return end
	if self.receive == 'new' then return end
	Citizen.Wait(2500)
	
	self.pid = self.pid
	if self.bonecategory["ped_head"] == nil then
		self.bonecategory["ped_head"] = 0
	end
	if self.bonecategory["left_leg"] == nil then
		self.bonecategory["left_leg"] = 0
	end
	if self.bonecategory["right_leg"] == nil then
		self.bonecategory["right_leg"] = 0
	end
	if self.bonecategory["ped_body"] == nil then
		self.bonecategory["ped_body"] = 0
	end
	if self.bonecategory["left_hand"] == nil then
		self.bonecategory["left_hand"] = 0
	end
	if self.bonecategory["right_hand"] == nil then
		self.bonecategory["right_hand"] = 0
	end
	if not self.head and self.bonecategory["ped_head"] > 0 then
		SetTimecycleModifier(config.headtimecycle)
		SetTimecycleModifierStrength(math.min(self.bonecategory["ped_head"] * 0.4, 1.1))
		self.head = true
		self:Notify('error','Body System',"Head has been damaged")
	elseif self.bonecategory["ped_head"] <= 0 then
		ClearTimecycleModifier()
		ClearExtraTimecycleModifier()
		if self.head then
			ClearTimecycleModifier()
			self.head = false 
		end
	end
	if self.bonecategory["ped_body"] > 0 then
		if not self.body then
			self:bodydamage()
			self:Notify('error','Body System',"Chest has been damaged")
		end
		self.body = true
		SetPlayerHealthRechargeMultiplier(self.pid, 0.0)
	elseif self.body then
		self.body = false
	else
		self.body = false
	end
	if self.bonecategory["right_hand"] > 0 or self.bonecategory["left_hand"] > 0 then
		if not self.arm then
			self:armdamage()
			self:Notify('error','Body System',"Arm has been damaged")
		end
		self.arm = true
		if self.bonecategory["left_hand"] < self.bonecategory["right_hand"] then  
			self.armbone = self.bonecategory["right_hand"]
		else 
			self.armbone2 = self.bonecategory["left_hand"]
		end
	else
		self.armbone = 0
		self.armbone2 = 0
		self.arm = false
	end
	if self.bonecategory and self.bonecategory["left_leg"] and self.bonecategory["right_leg"] and (self.bonecategory["left_leg"] >= 2 or self.bonecategory["right_leg"] >= 2) then
		if not self.leg then
			RequestAnimSet("move_m@injured")
			self:legdamage()
			self:Notify('error','Body System',"Leg has been damaged")
		end
		self.leg = true
		SetPedMoveRateOverride(self.ped, 0.6)
		SetPedMovementClipset(self.ped, "move_m@injured", true)
	elseif self.leg then
		self.leg = false
		Wait(2000)
		ResetPedMovementClipset(self.ped)
		ResetPedWeaponMovementClipset(self.ped)
		ResetPedStrafeClipset(self.ped)
		SetPedMoveRateOverride(self.ped, 1.0)
	else
		self.leg = false
	end
end

function Hud:bodydamage()
	CreateThread(function()
		while self.body do
			Citizen.Wait(5000)
			if config.disabledsprint then
				SetPlayerSprint(self.pid, false)
			end
			if config.disabledregen then
				SetPlayerHealthRechargeMultiplier(self.pid, 0.0)
			end
			if health ~= nil and health > 55.0 then
				SetEntityHealth(PlayerPedId(),(GetEntityHealth(self.ped)) - config.chesteffect_healthdegrade)
			end
		end
		SetPlayerHealthRechargeMultiplier(self.pid, 1.0)
		SetPlayerSprint(self.pid, true)
	end)
	return
end

function Hud:recoil(r)
	tv = 0
	if GetFollowPedCamViewMode() ~= 4 then
		Wait(0)
		p = GetGameplayCamRelativePitch()
		SetGameplayCamRelativePitch(p+0.3, (self.bonecategory["left_hand"] + self.bonecategory["right_hand"] / 5) * config.firstperson_armrecoil)
		tv = tv+0.1
	else
		Wait(0)
		p = GetGameplayCamRelativePitch()
		if r > 0.1 then
			SetGameplayCamRelativePitch(p+0.6, (self.bonecategory["left_hand"] + self.bonecategory["right_hand"] / 5) * config.firstperson_armrecoil)
			tv = tv+0.6
		else
			SetGameplayCamRelativePitch(p+0.016, 0.333)
			tv = tv+0.1
		end
	end
end

function Hud:armdamage() -- self.vehicle 
	CreateThread(function()
		local oldveh = nil
		while self.arm do
			if config.melee_decrease_damage then
				while IsPedInMeleeCombat(self.ped) do
					Citizen.Wait(5)
					SetPlayerMeleeWeaponDamageModifier(self.pid, config.melee_damage_decrease)
				end
			end
			while self.invehicle do
				if self.vehicle  ~= nil and self.vehicle  ~= 0 then
					if oldveh ~= self.vehicle  then
						steeringlock = GetVehStats(self.vehicle , "CHandlingData","fSteeringLock")
						DecorSetFloat(self.vehicle , "STEERINGLOCK", steeringlock)
						if self.bonecategory["left_hand"] > 0 or self.bonecategory["right_hand"] > 0 then
							local steer = (steeringlock - (self.bonecategory["left_hand"] + self.bonecategory["right_hand"]))
							if steer < 5.0 then
								steer = 5.0
							end
							SetVehStats(self.vehicle , "CHandlingData", "fSteeringLock", (steer * config.armdamage_invehicle_effect))
						end
					end
				end
				Citizen.Wait(2000)
				oldveh = self.vehicle 
			end
			if oldveh ~= nil then
				oldveh = nil
				SetVehStats(self:getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(self:getveh(),"STEERINGLOCK")) -- the back the original stats
			end
			Citizen.Wait(3000) -- Wait until self.ped goes off to self.vehicle  or until self.arm is in pain.
		end
		SetVehStats(self:getveh(), "CHandlingData", "fSteeringLock", DecorGetFloat(self:getveh(),"STEERINGLOCK")) -- the back the original stats
		return
	end)
end

function Hud:legdamage()
	CreateThread(function()
		while self.leg do
			Citizen.Wait(5)
			if config.legeffect_disabledjump and not self.invehicle then
				DisableControlAction(0,22,true)
			end
			SetPedMoveRateOverride(PlayerPedId(), config.legeffectmovement	)
			SetPedMovementClipset(PlayerPedId(), "move_m@injured", true)
		end
		return
	end)
end

function Hud:CheckBody()  
	local ok, id = GetPedLastDamageBone(self.ped)
	if ok then
		for damagetype,val in pairs(config.buto) do
			Wait(0)
			for bone,index in pairs(val) do
				if index == id and self.lastdamage ~= id then 
					self.lastdamage = id
					return bone,damagetype
				end
			end
		end
	end
	return false
end

function Hud:BodyMain()
	if health == nil then
		health = GetEntityHealth(PlayerPedId()) -100
	end
	self.life = health
	if health ~= nil and self.life < self.oldlife then
		local index,bodytype = nil, nil
		if not config.weaponsonly or not HasEntityBeenDamagedByWeapon(self.ped, 0 , 1) and HasEntityBeenDamagedByWeapon(self.ped, 0 , 2) and config.weaponsonly then
			index,bodytype = self:CheckBody()
			--if isWeapon(GetPedCauseOfDeath(PlayerPedId())) then
			if index and bodytype then
				if index ~= nil and self.parts[tostring(bodytype)] ~= nil and self.parts[tostring(bodytype)][tostring(index)] ~= nil and self.bonecategory ~= nil and self.bonecategory[tostring(bodytype)] ~= nil then
					self.parts[bodytype][index] = self.parts[bodytype][index] + config.damageadd
					self.bonecategory[bodytype] = self.bonecategory[bodytype] + config.damageadd
					--print("saving")
					SendNUIMessage({
						type = "setUpdateBodyStatus",
						content = self.bonecategory
					})
					if self.bonecategory['ped_head'] > 0 and config.bodyinjury_status_affected then
						TriggerEvent('esx_status:'..config.headbone_status_mode..'', config.headbone_status, self.bonecategory['ped_head'] * config.headbone_status_value)
					end
					ApplyPedBlood(self.ped, GetPedBoneIndex(self.ped,index), 0.0, 0.0, 0.0, "wound_sheet")
					Citizen.InvokeNative(0x8EF6B7AC68E2F01B, PlayerPedId())
					TriggerServerEvent('renzu_hud:savebody', self.bonecategory)
				end
			end
		end
	end
	self.oldlife = GetEntityHealth(self.ped) -100
end

function Hud:Makeloading(msg,ms)
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

function Hud:CarControl()
	if self.busy then return end
	self.isbusy = true
	self.vehicle  = self:getveh()
	if self.vehicle  ~= 0 and #(GetEntityCoords(self.ped) - GetEntityCoords(self.vehicle )) < 15 and GetVehicleDoorLockStatus(self.vehicle ) == 1 then
		local door = {}
		local window = {}
		for i = 0, 6 do
			Wait(10)
			door[i] = false
			if GetVehicleDoorAngleRatio(self.vehicle ,i) ~= 0.0 then
				----print("Door",GetVehicleDoorAngleRatio(self.vehicle ,i))
				door[i] = true
			end
		end
		for i = 0, 3 do
			window[i] = false
			if not IsVehicleWindowIntact(self.vehicle ,i) and GetWorldPositionOfEntityBone(self.vehicle ,GetEntityBoneIndexByName(self.vehicle ,self.windowbones[i])).x ~= 0.0 then
				window[i] = true
			end
		end

		self.carcontrol = not self.carcontrol
		local offset = {}
		local rotation = {}
		for i=0, 4 do
			offset[i] = GetVehicleWheelXOffset(self.vehicle,i)
			rotation[i] = GetVehicleWheelYRotation(self.vehicle,i)
		end
		SendNUIMessage({
			type = "setShowCarcontrol",
			content = {bool = self.carcontrol, offset = offset, rotation = rotation, height = GetVehicleSuspensionHeight(self.vehicle)}
		})
		SendNUIMessage({
			type = "setDoorState",
			content = door
		})
		SendNUIMessage({
			type = "setWindowState",
			content = window
		})
		Wait(500)
		SetNuiFocus(self.carcontrol,self.carcontrol)
		SetNuiFocusKeepInput(self.carcontrol)
		self.isbusy = false
		CreateThread(function()
			while self.carcontrol do
				self:whileinput()
				Wait(5)
			end
			SetNuiFocusKeepInput(false)
			return
		end)
	else
		if GetVehicleDoorLockStatus(self.vehicle ) ~= 1 then
			self:Notify('warning','Carcontrol System',"No Unlock Vehicle Nearby")
		else
			self:Notify('warning','Carcontrol System',"No Nearby Vehicle")
		end
	end
end

function Hud:shuffleseat(index)
	if self.invehicle then
		TaskWarpPedIntoVehicle(self.ped,self.vehicle ,index)
	else
		CreateThread(function()
			self:entervehicle()
			return
		end)
		TaskEnterVehicle(self.ped, self:getveh(), 10.0, index, 2.0, 0)
	end
end

function Hud:requestcontrol(veh)
	NetworkRequestControlOfEntity(veh)
	local count = 0
	while not NetworkHasControlOfEntity(veh) and count < 10 do
		count = count + 1
		Wait(10)
	end
end

function Hud:getColor(r1, g1, b1, r2, g2, b2)
	return self.round(math.random(0,255)), self.round(math.random(0,255)), self.round(math.random(0,255))
end

function Hud:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5)
end

--WEAPONS
function Hud:WeaponStatus()
	weapon = GetSelectedPedWeapon(self.ped)
	if self.wstatus['armed'] then return end
	self.oldweapon = nil
	if IsPedArmed(self.ped, 7) and not self.invehicle then
		if not self.shooting then
			if not self.updateweapon then
				self:WeaponLoop()
			end
			CreateThread(function()
				local count = 0
				local killed = {}
				local lastent = nil
				self.pid = self.pid
				local sleep = 1000
				while IsPedArmed(self.ped, 7) do
					sleep = 100
					if self.invehicle then
						break
					end
					while IsPedShooting(self.ped) or IsPlayerFreeAiming(self.pid) do
						--print("firing")
						sleep = 100
						--print("self.shooting")
						self.shooting = true
						if config.enablestatus and config.killing_affect_status then
							val, ent = GetEntityPlayerIsFreeAimingAt(self.pid)
							----print("self.shooting")
							if lastent ~= nil and lastent ~= 0 then
								if not killed[lastent] and IsEntityDead(lastent) and GetPedSourceOfDeath(lastent) == self.ped then
									killed[lastent] = true
									--print("LAST ENTITY IS DEAD "..lastent.."")
									lastent = nil
									TriggerEvent('esx_status:'..config.killing_status_mode..'', config.killing_affected_status, config.killing_status_val)
									Citizen.Wait(100)
								end
							end
							if ent ~= lastent then
								lastent = nil
							end
						end
						if config.enablestatus and count > config.firing_bullets then
							count = 0
							TriggerEvent('esx_status:'..config.firing_status_mode..'', config.firing_affected_status, config.firing_statusaddval)
							----print("STATUS ADDED")
						end
						count = count + 1
						----print(count)
						lastent = ent
						self.shooting = true
						self:WeaponLoop()
						if config.bodystatus then
							if self.arm and self.armbone > self.armbone2 then
								self:recoil(self.armbone / 5.0)
							elseif self.arm then
								self:recoil(self.armbone2 / 5.0)
							end
						end
						Wait(sleep)
					end
					self:WeaponLoop()
					----print("aiming")
					Citizen.Wait(sleep)
				end
				if self.weaponui then
					SendNUIMessage({
						type = "setWeaponUi",
						content = false
					})
					self.weaponui = false
					self.updateweapon = false
				end
				self.wstatus['armed'] = false	
				self.shooting = false
				return
			end)
		end
	end
end

function Hud:WeaponLoop()
	local weapon = GetSelectedPedWeapon(self.ped)
	local ammoTotal = GetAmmoInPedWeapon(self.ped,weapon)
	local bool,ammoClip = GetAmmoInClip(self.ped,weapon)
	local ammoRemaining = math.floor(ammoTotal - ammoClip)
	local maxammo = GetMaxAmmoInClip(self.ped, weapon, 1)
	self.wstatus['armed'] = true
	if self.oldweapon ~= weapon then
		for key,value in pairs(config.WeaponTable) do
			for name,v in pairs(config.WeaponTable[key]) do
				weap = weapon == GetHashKey('weapon_'..name)
				if weap then
					self.wstatus['weapon'] = 'weapon_'..name
				end
			end
		end
	end
	local weapon_ammo = {
		['clip'] = ammoClip,
		['ammo'] = ammoRemaining,
		['max'] = maxammo
	}
	SendNUIMessage({
		type = "setAmmo",
		content = weapon_ammo
	})
	if not self.weaponui then
		SendNUIMessage({
			type = "setWeaponUi",
			content = true
		})
		self.weaponui = true
	end
	if self.oldweapon ~= weapon then
		SendNUIMessage({
			type = "setWeapon",
			content = self.wstatus['weapon']
		})
		self.oldweapon = weapon
	end
end

--NOS --

function Hud:EnableNitro()
	CreateThread(function()
		while self.invehicle and self.nitromode do
			local cansleep = 2000
			if self.veh_stats[self.plate] ~= nil and self.veh_stats[self.plate].nitro ~= nil and self.hasNitro and self.invehicle and self.veh_stats[self.plate].nitro > 1 then
				if GetPedInVehicleSeat(self.vehicle , -1) == self.ped then
					cansleep = 1
					if self.veh_stats[self.plate].nitro > 5 and RCP(0, 21) and not RCR2(0, 21) then
						SetVehicleEngineHealth(self.vehicle , GetVehicleEngineHealth(self.vehicle ) - 0.05)
						if self.veh_stats[self.plate].nitro - 0.02 > 0 then
							if not self.pressed then
								self.pressed = true
								if self.speed > 5 then
									SetTimecycleModifier("ship_explosion_underwater")
									SetExtraTimecycleModifier("StreetLightingJunction")
									SetExtraTimecycleModifierStrength(0.1)
									SetTimecycleModifierStrength(0.1)
									--StartScreenEffect('MP_Celeb_Preload_Fade', 0, true)
								end
								TriggerServerEvent("renzu_hud:nitro_flame", VehToNet(self.vehicle ), GetEntityCoords(self.vehicle ))
							end
							SetVehicleEngineTorqueMultiplier(self.vehicle , config.nitroboost * 2 * self.rpm)
							self.veh_stats[self.plate].nitro = self.veh_stats[self.plate].nitro - config.nitrocost
							SendNUIMessage({
								type = "setNitro",
								content = self.veh_stats[self.plate].nitro
							})
							--TriggerEvent("laptop:nos", self.n_boost)
							if config.nitro_sound and self.speed > 5 then
								SetVehicleBoostActive(self.vehicle , 1)
							end
						else
							self.veh_stats[self.plate].nitro = 0
						end
					else
						if config.nitro_sound then
							SetVehicleBoostActive(self.vehicle , 0)
						end
					end
					if self.pressed and IsControlJustReleased(0, 21) and not RCP(0, 21) then
						Wait(100)
						TriggerServerEvent("renzu_hud:nitro_flame_stop", VehToNet(self.vehicle ), GetEntityCoords(self.vehicle ))
						self.pressed = false
						ClearExtraTimecycleModifier()
						ClearTimecycleModifier()
						StopScreenEffect('MP_Celeb_Preload_Fade')
						RemoveParticleFxFromEntity(self.vehicle )
						local vehcoords = GetEntityCoords(self.vehicle )
						Citizen.Wait(1)
						--RemoveParticleFxInRange(vehcoords.x,vehcoords.y,vehcoords.z,100.0)
						self.light_trail_isfuck = false
						self.purgefuck[VehToNet(self.vehicle )] = false
						collectgarbage()
					end
				end
			end
			Wait(cansleep)
		end
		return
	end)
end

function Hud:angle(veh)
	if not veh then return false end
	local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
	local modV = math.sqrt(vx*vx + vy*vy)


	local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	if GetEntitySpeed(veh)* 3.6 < 20 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --self.speed over 25 km/h

	local cosX = (sn*vx + cs*vy)/modV
	return math.deg(math.acos(cosX))*0.5, modV
end

--WHEEL SYSTEM
function Hud:NuiWheelSystem()
	CreateThread(function()
		while self.veh_stats == nil or self.veh_stats[self.plate] == nil do
			Citizen.Wait(100)
		end
		while self.invehicle and config.enabletiresystem do
			local numwheel = GetVehicleNumberOfWheels(self.vehicle )
			sleep = 500
			for i = 0, numwheel - 1 do
				Wait(10)
				if self.plate ~= nil and self.rpm > config.minrpm_wheelspin_detect and self.speed > 1 and (self.rpm * 100.0) < (self:tractioncontrol(WheelSpeed(self.vehicle ,i) * 3.6,GetGear(self.vehicle ), true) * 85.0) then
					if self.veh_stats[self.plate][tostring(i)] ~= nil and self.veh_stats[self.plate][tostring(i)].tirehealth > 0 then
						self.veh_stats[self.plate][tostring(i)].tirehealth = self.veh_stats[self.plate][tostring(i)].tirehealth - config.tirestress
					end
					--self.Notify("Tire Stress: Wheel #"..i.." - "..self.veh_stats[self.plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(self.vehicle , i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(self.vehicle , i, true, 0)
					end
				end
			end
			if self.speed ~= nil and self.speed > config.minspeed_curving and self:angle(self.vehicle ) >= config.minimum_angle_for_curving and self:angle(self.vehicle ) <= 18 and GetEntityHeightAboveGround(self.vehicle ) <= 1.5 then
				for i = 0, numwheel - 1 do
					Wait(10)
					if self.veh_stats[self.plate][tostring(i)] ~= nil and self.veh_stats[self.plate][tostring(i)].tirehealth > 0 then
						self.veh_stats[self.plate][tostring(i)].tirehealth = self.veh_stats[self.plate][tostring(i)].tirehealth - config.tirestress
					end
					--self.Notify('warning','Tire System',"Tire Stress2: Wheel #"..i.." - "..self.veh_stats[self.plate][tostring(i)].tirehealth.."")
					if GetVehicleWheelHealth(self.vehicle , i) <= 0 and config.bursttires then
						SetVehicleTyreBurst(self.vehicle , i, true, 0)
					end
				end
			end
			Citizen.Wait(sleep)
		end
		return
	end)
end

function Hud:tireanimation()
	--CarregarObjeto("anim@heists@box_carry@","idle","hei_prop_heist_box",50,28422)
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
	TaskPlayAnim(self.ped,dict,anim,3.0,3.0,-1,50,0,0,0,0)
	local coords = GetOffsetFromEntityInWorldCoords(self.ped,0.0,0.0,-5.0)
	self.proptire = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
	SetEntityCollision(self.proptire,false,false)
	AttachEntityToEntity(self.proptire,self.ped,GetPedBoneIndex(self.ped,28422),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
	Citizen.InvokeNative(0xAD738C3085FE7E11,self.proptire,true,true)
end

function Hud:turboanimation(type)
	--CarregarObjeto("anim@heists@box_carry@","idle","hei_prop_heist_box",50,28422)
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
	local coords = GetOffsetFromEntityInWorldCoords(self.ped,0.0,0.0,-5.0)
	if self.propturbo ~= nil then
		--print("deleting")
		self:ReqAndDelete(self.propturbo,true)
		self.propturbo = nil
	end
	if config.turboprop and self.propturbo == nil then
		self.propturbo = CreateObjectNoOffset(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
		SetEntityCollision(self.propturbo,true,true)
		AttachEntityToEntity(self.propturbo,self:getveh(),GetEntityBoneIndexByName(self:getveh(),'neon_f'),0.3,offset,offsetz,0.0,0.0,90.0,true,false,false,false,70,true)
		Citizen.InvokeNative(0xAD738C3085FE7E11,self.propturbo,true,true)
	end
end

function Hud:TireFunction(type)
	if type ~= 'default' then
		SetVehicleHandlingFloat(self.vehicle , "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(self.vehicle ,"TRACTION3") * config.wheeltype[type].fLowSpeedTractionLossMult) -- self.start burnout less = traction
		SetVehicleHandlingFloat(self.vehicle , "CHandlingData", "fTractionLossMult", DecorGetFloat(self.vehicle ,"TRACTION4") * config.wheeltype[type].fTractionLossMult)  -- asphalt mud less = traction
		SetVehicleHandlingFloat(self.vehicle , "CHandlingData", "fTractionCurveMin", DecorGetFloat(self.vehicle ,"TRACTION") * config.wheeltype[type].fTractionCurveMin) -- accelaration grip
		SetVehicleHandlingFloat(self.vehicle , "CHandlingData", "fTractionCurveMax", DecorGetFloat(self.vehicle ,"TRACTION5") * config.wheeltype[type].fTractionCurveMax) -- cornering grip
		SetVehicleHandlingFloat(self.vehicle , "CHandlingData", "fTractionCurveLateral", DecorGetFloat(self.vehicle ,"TRACTION2") * config.wheeltype[type].fTractionCurveLateral) -- curve lateral grip
	end
end

carjacking = false
function Hud:Carlock()
	if not self.keyless then return end
	while self.veh_stats == nil do
		Wait(100)
		self.veh_stats = LocalPlayer.state.adv_stat
	end
	if not self.veh_stats_loaded then
		self:get_veh_stats()
	end
	local foundveh = false
	if self.keyless then
		self.keyless = not self.keyless
		local vehicles = {}
		local checkindentifier, myidentifier = nil, nil
		local mycoords = GetEntityCoords(PlayerPedId(), false)
		local foundvehicle = {}
		local min = -1
		for k,v in pairs(GetGamePool('CVehicle')) do
			if #(mycoords - GetEntityCoords(v, false)) < config.carlock_distance then
				self.plate = GetVehicleNumberPlateText(v)
				if self.veh_stats[self.plate] ~= nil and self.veh_stats[self.plate].owner ~= nil and LocalPlayer.state.identifier ~= nil then
					checkindentifier = string.gsub(self.veh_stats[self.plate].owner, 'Char5', '')
					checkindentifier = string.gsub(checkindentifier, 'Char4', '')
					checkindentifier = string.gsub(checkindentifier, 'Char3', '')
					checkindentifier = string.gsub(checkindentifier, 'Char2', '')
					checkindentifier = string.gsub(checkindentifier, 'Char1', '')
					checkindentifier = string.gsub(checkindentifier, 'char5', '')
					checkindentifier = string.gsub(checkindentifier, 'char4', '')
					checkindentifier = string.gsub(checkindentifier, 'char3', '')
					checkindentifier = string.gsub(checkindentifier, 'char2', '')
					checkindentifier = string.gsub(checkindentifier, 'char1', '')
					checkindentifier = string.gsub(checkindentifier, 'steam', '')
					checkindentifier = string.gsub(checkindentifier,":","")
					checkindentifier = string.gsub(checkindentifier, string.gsub(config.identifier,":",""), '')
					myidentifier = string.gsub(LocalPlayer.state.identifier, 'steam', '')
					myidentifier = string.gsub(LocalPlayer.state.identifier, string.gsub(config.identifier,":",""), '')
					myidentifier = string.gsub(myidentifier,":","")
					myidentifier = string.gsub(myidentifier, 'Char5', '')
					myidentifier = string.gsub(myidentifier, 'Char4', '')
					myidentifier = string.gsub(myidentifier, 'Char3', '')
					myidentifier = string.gsub(myidentifier, 'Char2', '')
					myidentifier = string.gsub(myidentifier, 'Char1', '')
					myidentifier = string.gsub(myidentifier, 'char5', '')
					myidentifier = string.gsub(myidentifier, 'char4', '')
					myidentifier = string.gsub(myidentifier, 'char3', '')
					myidentifier = string.gsub(myidentifier, 'char2', '')
					myidentifier = string.gsub(myidentifier, 'char1', '')
					myidentifier = string.gsub(myidentifier, 'steam', '')
					if self.veh_stats[self.plate] ~= nil and checkindentifier == myidentifier then
						foundvehicle[self.plate] = {}
						foundvehicle[self.plate].entity = v
						foundvehicle[self.plate].plate = self.plate
						if checkindentifier ~= nil then
							foundvehicle[self.plate].owner = myidentifier
						end
						foundvehicle[self.plate].distance = #(mycoords - GetEntityCoords(v, false))
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
			SendNUIMessage({
				type = "setKeyless",
				content = table
			})
			foundveh = true
			self:Notify('success','Vehicle Lock System','Owned Vehicle Found with Plate # '..nearestplate..'')
			Wait(200)
			SetNuiFocus(true,true)
		end
		self.keyless = not self.keyless
		Wait(500)
		if foundveh then
			SendNUIMessage({
				type = "setShowKeyless",
				content = self.keyless
			})
		elseif config.enable_carjacking and not carjacking then
			self.keyless = true
			carjacking = true
			local bone = GetEntityBoneIndexByName(self:getveh(),'door_dside_f')
			if self:getveh() ~= 0 and #(GetEntityCoords(self.ped) - GetWorldPositionOfEntityBone(self:getveh(),bone)) < config.carjackdistance and GetVehicleDoorLockStatus(self:getveh()) ~= 1 then
				self.playanimation('creatures@rottweiler@tricks@','petting_franklin')
				local carnap = exports["cd_keymaster"]:StartKeyMaster()
				--print(carnap)
				if carnap then
					--print("good")
					SetVehicleNeedsToBeHotwired(self:getveh(),true)
					TaskEnterVehicle(self.ped, self:getveh(), 10.0, -1, 2.0, 0)
					TriggerServerEvent("renzu_hud:synclock", VehToNet(self:getveh()), 'carjack', GetEntityCoords(self.ped))
				else
					SetVehicleNeedsToBeHotwired(self:getveh(),true)
					TaskEnterVehicle(self.ped, self:getveh(), 10.0, -1, 2.0, 0)
					SetVehicleAlarm(self:getveh(), 1)
					StartVehicleAlarm(self:getveh())
					SetVehicleAlarmTimeLeft(self:getveh(), 180000)
					CreateIncidentWithEntity(7,self.ped,3,100.0)
					PlayPoliceReport("SCRIPTED_SCANNER_REPORT_CAR_STEAL_2_01",0.0)
					TriggerServerEvent("renzu_hud:synclock", VehToNet(self:getveh()), 'force', GetEntityCoords(self.ped))
				end
			elseif GetVehicleDoorLockStatus(self:getveh()) == 1 then
				SetVehicleNeedsToBeHotwired(self:getveh(),true)
				TaskEnterVehicle(self.ped, self:getveh(), 10.0, -1, 2.0, 0)
			end
			ClearPedTasks(self.ped)
			carjacking = false
		else
			self.keyless = true
			self:Notify('error','Vehicle Lock System',' No Vehicle in area')
		end
	else
		SetNuiFocus(false,false)
	end
end

function Hud:playsound(vehicle,max,file,maxvol)
	local volume = maxvol
	local mycoord = GetEntityCoords(self.ped)
	local distIs  = tonumber(string.format("%.1f", #(mycoord - vehicle)))
	if (distIs <= max) then
		distPerc = distIs / max
		volume = (1-distPerc) * maxvol
		local table = {
			['file'] = file,
			['volume'] = volume
		}
		SendNUIMessage({
			type = "playsound",
			content = table
		})
	end
end

function Hud:whileinput()
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
	DisablePlayerFiring(self.pid, true)
end

function Hud:Clothing()
	clothing = not clothing
	local table = {
		['bool'] = clothing,
		['equipped'] = self.clothestate
	}
	SendNUIMessage({
		type = "setShowClothing",
		content = table
	})
	SetNuiFocusKeepInput(clothing)
	SetNuiFocus(clothing,clothing)

	if clothing then
		CreateThread(function()
			while clothing do
				self:whileinput()
				Wait(0)
			end
			return
		end)
	end
end

function Hud:checkaccesories(accessory, changes) -- being used if ESX ACCESORIES IS enable - (mask,helmet from datastore instead of skinchangers Characters) copyright to LINK https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/client/main.lua#L30
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

			self.oldclothes[''.._accessory.. '_1'] = mAccessory
			self.oldclothes[''.._accessory.. '_2'] = mColor
			self.saveclothe[''.._accessory.. '_1'] = mAccessory
			self.saveclothe[''.._accessory.. '_2'] = mColor
			state = true
			self:Notify("success","Clothe System","Variant Loaded "..accessory.." "..mColor.." "..mAccessory.."")
		else
			state = false
			self:Notify("warning","Clothe System","No Variant for this type "..accessory.."")
		end
		load = true
	end, accessory)

	while not load do
		Wait(100)
	end
	return state
end

function Hud:SaveCurrentClothes(firstload)
	TriggerEvent('skinchanger:getSkin', function(current)
		if self.oldclothes == nil then
			self.oldclothes = current
		else
			for k,v in pairs(current) do
				if self.buclothes ~= nil and current[k] ~= self.buclothes[k] and config.clothing[k] ~= nil and config.clothing[k]['default'] ~= v then -- check if old clothes is changed
					self.oldclothes[k] = v
					self.buclothes[k] = v
				end
			end
		end
		if self.buclothes == nil then
			self.buclothes = {}
			self.buclothes = current
		end
		--self.oldclothes = current
		Wait(100)
		if config.use_esx_accesories and firstload then
			if self:checkaccesories('Mask', self.oldclothes) then
				self.hasmask = true
			end
			Wait(1000)
			--check if there is a helmet from datastore
			if self:checkaccesories('Helmet', self.oldclothes) then
				self.hashelmet = true
			end
		elseif not firstload and config.use_esx_accesories then
			if self.saveclothe['mask_1'] ~= nil and self.saveclothe['mask_1'] ~= self.oldclothes['mask_1'] and config.clothing['mask_1']['default'] == self.oldclothes['mask_1'] then
				self.oldclothes['mask_1'] = self.saveclothe['mask_1']
			elseif self.saveclothe['mask_1'] ~= nil and self.saveclothe['mask_1'] ~= self.oldclothes['mask_1'] and config.clothing['mask_1']['default'] ~= self.oldclothes['mask_1'] then
				if self:checkaccesories('Mask', self.oldclothes) then
					self.hasmask = true
				end
			end
			if self.saveclothe['helmet_1'] ~= nil and self.saveclothe['helmet_1'] ~= self.oldclothes['helmet_1'] and config.clothing['helmet_1']['default'] == self.oldclothes['helmet_1'] then
				self.oldclothes['helmet_1'] = self.saveclothe['helmet_1']
			elseif self.saveclothe['helmet_1'] ~= nil and self.saveclothe['helmet_1'] ~= self.oldclothes['helmet_1'] and config.clothing['helmet_1']['default'] ~= self.oldclothes['helmet_1'] then
				if self:checkaccesories('Helmet', self.oldclothes) then
					self.hashelmet = true
				end
			end
		end
		Wait(1000)
	end)
	while self.oldclothes == nil do
		print("OLDCLOTHESNIL")
		Wait(0)
	end
	if firstload then
		self:ClotheState()
	end
end

function Hud:ClotheState()
	if self.oldclothes == nil then return end
	for k,v in pairs(self.oldclothes) do
		if config.clothing[k] then
			if self.oldclothes[k] == config.clothing[k]['default'] then
				self.clothestate[k] = false
			else
				self.clothestate[k] = true
			end
			if k == 'mask_1' and self.hasmask and self.oldclothes['mask_1'] ~= config.clothing['mask_1']['default'] then
				self.clothestate[k] = false
			end
			if k == 'helmet_1' and self.hashelmet and self.oldclothes['helmet_1'] ~= config.clothing['helmet_1']['default'] then
				self.clothestate[k] = false
			end
		end
	end
end

function Hud:TaskAnimation(t)
	if self.imbusy then
		self.imbusy = false
		local Ped = self.ped
		while not HasAnimDictLoaded(t.dictionary) do
			RequestAnimDict(t.dictionary)
			Citizen.Wait(5)
		end
		if IsPedInAnyVehicle(Ped) then
			t.speed = 51
		end
		TaskPlayAnim(Ped, t.dictionary, t.name, 3.0, 3.0, t.duration, t.speed, 0, false, false, false)
		local delay = t.duration-500 
		if delay < 500 then
			delay = 500
		end
		Citizen.Wait(delay) 
		self.imbusy = true
	end
end

function Hud:CarStatus()
	self.vehicle  = self:getveh()
	local dis = #(GetEntityCoords(self.ped) - GetEntityCoords(self.vehicle ))
	if dis > 10 then return end
	--self.plate = tostring(GetVehicleNumberPlateText(self.vehicle ))
	--self.plate = string.gsub(self.plate, '^%s*(.-)%s*$', '%1')
	if self.veh_stats[self.plate] == nil then
		self:get_veh_stats(self.vehicle , self.plate)
	end
	self.carstatus = not self.carstatus
	local turbolevel = self.veh_stats[self.plate].turbo
	if turbolevel == 'default' then
		if GetVehicleMod(self.vehicle , 18) then
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
	local tirelevel = self.veh_stats[self.plate].tires
	if tirelevel == 'street' then
		tirelevel = 1
	elseif tirelevel == 'sports' then
		tirelevel = 2
	elseif tirelevel == 'racing' then
		tirelevel = 3
	else
		tirelevel = -1
	end
	local numwheel = GetVehicleNumberOfWheels(self.vehicle )
	local tirehealth = 0
	for i = 0, numwheel - 1 do
		tirehealth = tirehealth + self.veh_stats[self.plate][tostring(i)].tirehealth
	end
	--print(tirehealth)
	local total_tirehealth = tirehealth / (config.tirebrandnewhealth * numwheel) * 100
	--print(total_tirehealth)
	local trannytype = self.veh_stats[self.plate].manual
	if trannytype then
		trannytype = 'Manual'
	else
		trannytype = 'Automatic'
	end
	local enginename = self.veh_stats[self.plate].engine
	enginename = enginename:gsub("^%l", string.upper).." Engine"
	local t = {
		['bool'] = self.carstatus,
		['engine'] = GetVehicleMod(self.vehicle , 11) + 1,
		['tranny'] = GetVehicleMod(self.vehicle , 13) + 1,
		['turbo'] = turbolevel,
		['brake'] = GetVehicleMod(self.vehicle , 12) + 1,
		['suspension'] = GetVehicleMod(self.vehicle , 15) + 1,
		['tire'] = tirelevel,
		['coolant'] = self.veh_stats[self.plate].coolant,
		['oil'] = self.veh_stats[self.plate].oil,
		['tires_health'] = total_tirehealth,
		['mileage'] = self.veh_stats[self.plate].mileage,
		['trannytype'] = trannytype,
		['enginename'] = enginename,
	}
	SendNUIMessage({
		type = "setShowCarStatus",
		content = t
	})
end

function Hud:tostringplate(plate)
    if plate ~= nil then
    return tostring(plate)
    else
    return 123454
    end
end

-- function Hud:closestveh(coords)
--     --for k,vv in pairs(GetGamePool('CVehicle')) do
--         for k,v in pairs(self.onlinevehicles) do
-- 			if v.entity ~= nil and NetworkDoesEntityExistWithNetworkId(v.entity) then
-- 				local vv = NetToVeh(v.entity)
-- 				local vehcoords = GetEntityCoords(vv)
-- 				local dist = #(coords-vehcoords)
-- 				local plate = GetVehicleNumberPlateText(vv)
-- 				--anti desync
-- 				if k ~= nil and v.engine ~= nil and v.engine ~= 'default' then
-- 					if not self.syncveh[vv] and tostringplate(plate) == tostringplate(k) and self.syncengine[tostringplate(k)] ~= nil then
-- 						self.syncengine[tostringplate(k)] = nil
-- 					end
-- 					if dist < 100 and self.syncengine[tostringplate(k)] ~= v.engine and vv ~= nil then
-- 						if tostringplate(plate) == tostringplate(k) then
-- 							--print("engine sound",v.engine,vv)
-- 							if config.custom_engine_enable and config.custom_engine[GetHashKey(v.engine)] ~= nil then
-- 								ForceVehicleEngineAudio(vv, config.custom_engine[GetHashKey(v.engine)].soundname)
-- 							else
-- 								ForceVehicleEngineAudio(vv, tostring(v.engine))
-- 							end
-- 							self.syncengine[tostringplate(k)] = v.engine
-- 							self.syncveh[vv] = v.engine
-- 						end
-- 					end
-- 				end
-- 			end
--         end
--     --end
-- end

-- function Hud:SyncVehicleSound()
-- 	if self.veh_stats == nil then return end
-- 	Citizen.CreateThread(function()
-- 		Wait(1000)
-- 		closestveh(GetEntityCoords(self.ped))
-- 		return
-- 	end)
-- end

function Hud:SetEngineSpecs(veh, model)
	if GetPedInVehicleSeat(veh, -1) == self.ped then
		self.enginespec = false
		--print("INSIDE LOOP")
		self.currentengine[self.plate] = model
		Wait(1300)
		Citizen.CreateThread(function()
			local model = model
			local handling = self:GetHandlingfromModel(model)
			local getcurrentvehicleweight = GetVehStats(self.vehicle , "CHandlingData","fMass")
			local multiplier = 1.0
			multiplier = (handling['fMass'] / getcurrentvehicleweight)
			self.enginespec = true
			Wait(10)
			if tonumber(handling['nInitialDriveGears']) > GetVehicleHandlingInt(self.vehicle , "CHandlingData","nInitialDriveGears") then
				-- another anti weird bug ( if the new engine gears is > the existing one, the existing old max gear persist, so we use this native below to cheat the bug)
				SetVehicleHighGear(self.vehicle ,tonumber(handling['nInitialDriveGears']) )
				Citizen.InvokeNative(0x8923dd42, self.vehicle , tonumber(handling['nInitialDriveGears']) )
				self:Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, self.vehicle , tonumber(handling['nInitialDriveGears']) )
				self:Renzu_Hud(nextgearhash & 0xFFFFFFFF, self.vehicle , tonumber(handling['nInitialDriveGears']) )
				Wait(11)
				self:Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, self.vehicle , 1)
			end
			while self.enginespec do
				--print(multiplier)
				for k,v in pairs(handling) do
					if k == 'nInitialDriveGears' then
						self:GetHandling(self:GetPlate(self.vehicle )).maxgear = v
						----print("gear")
						gears = tonumber(v)
						if gears < 6 and tonumber(GetVehicleMod(self.vehicle ,13)) > 0 then
							gears = tonumber(v) + 1
						end
						SetVehicleHandlingInt(self.vehicle , "CHandlingData", "nInitialDriveGears", gears)
						SetVehicleHandlingField(self:getveh(), 'CHandlingData', "nInitialDriveGears", gears)
						--SetVehicleHighGear(self.vehicle , v)
					elseif k == 'fDriveInertia' then
						self:GetHandling(self:GetPlate(self.vehicle )).finaldrive = v
						--print("final drive",self.GetHandling(self:GetPlate(self.vehicle )).finaldrive, multiplier,handling['fMass'], getcurrentvehicleweight)
						if multiplier < 0.8 then -- weight does not affect reving power
							m = 0.8
						else
							m = multiplier
						end
						SetVehStats(self.vehicle , "CHandlingData", "fDriveInertia", v * m)
					elseif k == 'fInitialDriveForce' then
						--multiplier is on everytime, this will produce realistic result, ex. Sanchez Engine to self.vehicle . sanchez is a bike/motorcycle, it have a less weight compare to sedan vehicles, so sanchez will produce very low acceleration on sedan cars
						self:GetHandling(self:GetPlate(self.vehicle )).flywheel = v
						if not self.manual2 then
							SetVehStats(self.vehicle , "CHandlingData", "fInitialDriveForce", v * multiplier)
						end
					elseif k == 'fInitialDriveMaxFlatVel' and not self.mode == 'DRIFT' then
						self:GetHandling(self:GetPlate(self.vehicle )).maxspeed = v
						if not self.manual then
							mult = 1.0
							if tonumber(GetVehicleMod(self.vehicle ,13)) > 0 then
								mult = 1.25
							end
							if not self.manual2 then
								SetVehicleHandlingField(self.vehicle , "CHandlingData", "fInitialDriveMaxFlatVel", v * mult)
							end
						end
					elseif k ~= 'fMass' then
						SetVehStats(self.vehicle , "CHandlingData", tostring(k), v * 1.0)
						--SetVehicleHandlingField(self:getveh(), 'CHandlingData', tostring(k), tonumber(v))
					end
					--SetVehicleHandlingField(self:getveh(), 'CHandlingData', tostring(k), tonumber(v))
				end
				SetVehicleEnginePowerMultiplier(self.vehicle , 1.0) -- needed if maxvel and inertia is change, weird.. this can be call once only to trick the bug, but this is a 1 sec loop it doesnt matter.
				
				Wait(1000)
			end
			return
		end)
	end
	--SetVehicleHandlingField()
end

function Hud:GetHandlingfromModel(model)
	local model = model
	if config.custom_engine_enable and config.custom_engine[model] ~= nil then
		if config.custom_engine[model].turboinstall then
			ToggleVehicleMod(self.vehicle , 18, true)
		end
		local t = {
			['fDriveInertia'] = tonumber(config.custom_engine[model].fDriveInertia),
			['nInitialDriveGears'] = tonumber(config.custom_engine[model].nInitialDriveGears),
			['fInitialDriveForce'] = tonumber(config.custom_engine[model].fInitialDriveForce),
			['fClutchChangeRateScaleUpShift'] = tonumber(config.custom_engine[model].fClutchChangeRateScaleUpShift),
			['fClutchChangeRateScaleDownShift'] = tonumber(config.custom_engine[model].fClutchChangeRateScaleDownShift),
			['fInitialDriveMaxFlatVel'] = tonumber(config.custom_engine[model].fInitialDriveMaxFlatVel),
			['fMass'] = tonumber(config.custom_engine[model].fMass),
		}
		return t
	else
		for k,v in pairs(self.vehiclehandling) do
			--print(v.VehicleModels[1],model)
			if GetHashKey(v.VehicleModels[1]) == model then
				local t = {
					['fDriveInertia'] = tonumber(v.DriveInertia),
					['nInitialDriveGears'] = tonumber(v.InitialDriveGears),
					['fInitialDriveForce'] = tonumber(v.InitialDriveForce),
					['fClutchChangeRateScaleUpShift'] = tonumber(v.ClutchChangeRateScaleUpShift),
					['fClutchChangeRateScaleDownShift'] = tonumber(v.ClutchChangeRateScaleDownShift),
					['fInitialDriveMaxFlatVel'] = tonumber(v.InitialDriveMaxFlatVel),
					['fMass'] = tonumber(v.Mass),
				}
				return t
			end
		end
	end
	return false
end

function Hud:ReqAndDelete(object, detach)
	--if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		local attempt = 0
		while not NetworkHasControlOfEntity(object) and attempt < 100 do
			NetworkRequestControlOfEntity(object)
			Citizen.Wait(11)
			attempt = attempt + 1
		end
		if detach then
			DetachEntity(self:getveh(), 0, false)
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

function Hud:DefineCarUI(ver)
	CreateThread(function()
		if config.available_carui[tostring(ver)] ~= nil and not self.customcarui then
			SendNUIMessage({type = 'setCarui', content = tostring(ver)})
			config.carui = ver
			if GetVehiclePedIsIn(PlayerPedId()) ~= 0 and ver == 'modern' then
				Wait(300)
				while config.push_start and not self.start do
					Wait(100)
				end
				self.start = true
				SendNUIMessage({
					type = "setStart",
					content = self.start
				})
				self.vehicle  = GetVehiclePedIsIn(PlayerPedId())
				if self.ismapopen then
					SendNUIMessage({map = true, type = 'sarado'})
					self.ismapopen = false
				end
				if ver == 'modern' then
					self:NuiShowMap()
				end
			end
		end
		return
	end)
end

RegisterNUICallback('openmap', function(data, cb)
	print("open map")
	Hud:NuiShowMap(true)
	cb(true)
end)

standmodel , enginemodel = nil, nil
function Hud:repairengine(plate)
	self.vehicle  = self:getveh()
	local prop_stand = 'prop_engine_hoist'
	local prop_engine = 'prop_car_engine_01'
	--print("engine repair")
	Citizen.Wait(200)
	local bone = GetEntityBoneIndexByName(self.vehicle ,'engine')
	local d1,d2 = GetModelDimensions(GetEntityModel(self.vehicle ))
	local stand = GetOffsetFromEntityInWorldCoords(self.vehicle , 0.0,d2.y+0.4,0.0)
	local obj = nil

	local veh_heading = GetEntityHeading(self.vehicle )
	local veh_coord = GetEntityCoords(self.vehicle ,false)
	local x,y,z = table.unpack(GetWorldPositionOfEntityBone(self.vehicle , bone))
	local animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	self:requestmodel('bkr_prop_meth_sacid')
	local animPos, targetHeading = GetAnimInitialOffsetPosition(animDict, "chemical_pour_long_cooker", x,y,z, 0.0,0.0,veh_heading, 0, 2), 52.8159
	local ax,ay,az = table.unpack(animPos)
	local rx,ry,rz = table.unpack(GetEntityForwardVector(self.vehicle ) * 1.5)
	local realx,realy,realz = x - ax , y - ay , z - az
	local coordf = veh_coord + GetEntityForwardVector(self.vehicle ) * 3.0
	standmodel = CreateObject(GetHashKey(prop_stand),coordf,true,true,true)
	obj = standmodel
	standprop = obj
	SetEntityAsMissionEntity(obj, true, true)
	--print("spawn stand")
	SetEntityNoCollisionEntity(self.vehicle , obj, false)
	SetEntityHeading(obj, GetEntityHeading(self.vehicle ))
	PlaceObjectOnGroundProperly(obj)
	FreezeEntityPosition(obj, true)
	SetEntityCollision(obj, false, true)
	while not DoesEntityExist(obj) do
		Citizen.Wait(100)
	end
	local d21 = GetModelDimensions(GetEntityModel(obj))
	local stand = GetOffsetFromEntityInWorldCoords(obj, 0.0,d21.y+0.2,0.0)
	Citizen.Wait(500)
	local engine_r = GetEntityBoneRotation(self.vehicle , bone)
	enginemodel = CreateObject(GetHashKey(prop_engine),stand.x+0.27,stand.y-0.2,stand.z+1.45,true,true,true)
	AttachEntityToEntity(enginemodel,self.vehicle ,GetEntityBoneIndexByName(self.vehicle ,'neon_f'),0.0,-0.45,1.5,0.0,90.0,0.0,true,false,false,false,70,true)
	--AttachEntityToEntity(enginemodel,self.vehicle ,bone,0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,1,false)
	carryModel2 = enginemodel
	engineprop = carryModel2
	--SetEntityHeading(engineprop, 0)
	SetEntityAsMissionEntity(engineprop, true, true)
	--print("spawn engine")
	SetEntityNoCollisionEntity(self.vehicle , carryModel2, false)
	FreezeEntityPosition(carryModel2, true)
	SetEntityNoCollisionEntity(carryModel2, obj, false)
	SetEntityCollision(carryModel2, false, true)
end

function Hud:SyncWheelAndSound(sounds,wheels)
	local coords = GetEntityCoords(PlayerPedId())
	while LocalPlayer.state.onlinevehicles == nil do Wait(1) print(LocalPlayer.state.onlinevehicles) end
	for k,v in pairs(LocalPlayer.state.onlinevehicles) do
		v.plate = string.gsub(v.plate, "^%s*(.-)%s*$", "%1")
		local pl = string.gsub(self:tostringplate(GetVehicleNumberPlateText(NetToVeh(v.entity))), "^%s*(.-)%s*$", "%1")
		if v.entity ~= nil and NetworkDoesEntityExistWithNetworkId(v.entity) and v.plate == pl then
			local vv = NetToVeh(v.entity)
			local vehcoords = GetEntityCoords(vv)
			local dist = #(coords-vehcoords)
			local plate = string.gsub(self:tostringplate(GetVehicleNumberPlateText(vv)), "^%s*(.-)%s*$", "%1")
			--plate = string.gsub(plate, "%s+", "")
			if wheels then
				if self.nearstancer[plate] == nil then
					self.nearstancer[plate] = {entity = vv, dist = dist, plate = plate}
				end
				self.nearstancer[plate].dist = dist
				self.nearstancer[plate].entity = vv
				self.nearstancer[plate].speed = GetEntitySpeed(vv) * 3.6
				if v.height ~= nil and not self.nearstancer[plate].wheeledit then
					SetVehicleSuspensionHeight(vv,v.height)
				end
			end
			if sounds and k ~= nil and v.engine ~= nil and v.engine ~= 'default' then
				if not self.syncveh[vv] and self:tostringplate(plate) == self:tostringplate(k) and self.syncengine[self:tostringplate(k)] ~= nil then
					self.syncengine[self:tostringplate(k)] = nil
				end
				if dist < 100 and self.syncengine[self:tostringplate(k)] ~= v.engine and vv ~= nil then
					if self:tostringplate(plate) == self:tostringplate(k) then
						--print("engine sound",v.engine,vv)
						if config.custom_engine_enable and config.custom_engine[GetHashKey(v.engine)] ~= nil then
							ForceVehicleEngineAudio(vv, config.custom_engine[GetHashKey(v.engine)].soundname)
						else
							ForceVehicleEngineAudio(vv, tostring(v.engine))
						end
						self.syncengine[self:tostringplate(k)] = v.engine
						self.syncveh[vv] = v.engine
					end
				end
			end
		elseif not NetworkDoesEntityExistWithNetworkId(v.entity) then
			local temp = LocalPlayer.state.onlinevehicles
			temp[k] = nil
			LocalPlayer.state:set('onlinevehicles', temp, true)
		end
	end
	for k,v in pairs(self.nearstancer) do
		if v.dist > 250 or not DoesEntityExist(v.entity) then
			--print(v.plate,"deleted")
			self.nearstancer[k] = nil
		end
	end
end

function Hud:Renzu_Function(func)
	local f = {}
	setmetatable(f, {
		__close = func
	})
	return f
end