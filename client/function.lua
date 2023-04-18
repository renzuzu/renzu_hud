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
	if export and config.framework == 'QBCORE' and self.esx_status ~= nil or export and config.framework ~= 'QBCORE' and self.esx_status ~= nil then
		if not self.esx_status then
			self.vitals = exports['renzu_status']:GetStatus(self.statuses)
		end
	elseif export and config.framework == 'QBCORE' then
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
				while not GetIsVehicleEngineRunning do
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
				content = GetVehicleHandlingFloat(vehicle, "CHandlingData","fDriveBiasFront")
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
		self.globaltopspeed = nil
		self.entering = false
		self.start = false
		self.invehicle = false
		self.enginespec = false
		self.speed = 0
		self.rpm = 0
		marcha = 0
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

end

--ASYNC function Hud:CALL VEHICLE LOOPS
function Hud:inVehicleFunctions()
	CreateThread(function()
		while not self.invehicle do
			Wait(1) -- lets wait self.invehicle to = true
		end
		--self:get_veh_stats(self.vehicle ,self:GetPlate(self.vehicle ))
		--SetForceHdVehicle(self.vehicle , true)
		self:RpmandSpeedLoop()
		self:NuiRpm()
		self:NuiCarhpandGas()
		while not self.loadedplate do
			Wait(100)
		end
		if config.WaypointMarkerLarge then
			self:NuiDistancetoWaypoint()
		end
		if not config.enable_carui_perclass then
			self:NuiShowMap()
		end
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

function Hud:SetVehicleOnline() -- for vehicle loop
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
				self.gasolina = GetVehicleFuelLevel(self.vehicle )
				wait = config.NuiCarhpandGas_sleep
				if self.gasolina ~= newgas or newgas == nil then
					SendNUIMessage({
						type = "setFuelLevel",
						content = self.gasolina
					})
					newgas = self.gasolina
				end
				if newcarhealth ~= self.hp or newcarhealth == nil then
					SendNUIMessage({
						hud = "setCarhp",
						content = self.hp
					})
					newcarhealth = self.hp
				end
				SendNUIMessage({
					type = "setMileage",
					content = Entity(self.vehicle).state?.mileage or 0
				})
				SendNUIMessage({
					type = "setTemp",
					content = GetVehicleEngineTemperature(self.vehicle )
				})
				if self.manual then
					self.gear = self.savegear
				else
					self.gear = GetVehicleCurrentGear(self.vehicle )
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
	
end

function Hud:NuiMileAge()

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
				local sleep = 2000
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
end

function Hud:RemoveParticles()
end

function Hud:NuiEngineTemp()

end

function Hud:Myinfo()
	if config.framework == 'ESX' then
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
	self.ped = PlayerPedId()
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
		SetFlyThroughWindscreenParams(35.0, 45.0, 17.0, 2000.0)
		SetPedConfigFlag(PlayerPedId(), 32, true)
	end

	if self.vehicle  ~= nil and self.vehicle  ~= 0 then
		Citizen.CreateThreadNow(function()
			while self.belt and self.invehicle do
				local sleep = 5

				if self.belt then
					DisableControlAction(1, 75, true)  -- Disable exit vehicle when stop
					DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
				end
				Wait(sleep)
			end
		end)

		if config.seatbelt_2 then return end

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
			v = GetVehiclePedIsEntering(p)
			local c = 0
			while not GetVehiclePedIsTryingToEnter(p) or GetVehiclePedIsTryingToEnter(p) == 0 do
				v = GetVehiclePedIsTryingToEnter(p)
				if c > 2000 then
					break
				end
				c = c + 10
				Wait(0)
			end
			local count = 0
			while not IsPedInAnyVehicle(p) and not self.start and count < 400 and config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)]  == 'modern' or not IsPedInAnyVehicle(p) and not self.start and count < 400 and not config.enable_carui_perclass and config.carui  == 'modern' do
				self.entering = true
				Wait(1)
				count = count + 1
				SetVehicleEngineOn(self:getveh(),false,true,true)
				if GetVehiclePedIsTryingToEnter(p) ~= 0 then
					v = GetVehiclePedIsTryingToEnter(p)
				end
			end
			if config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)] ~= 'modern' or not config.enable_carui_perclass and config.carui ~= 'modern' then self.entering = false SetVehicleEngineOn(self:getveh(),false,true,false) return end
			if GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and config.enable_carui_perclass and config.carui_perclass[GetVehicleClass(v)]  == 'modern' or GetPedInVehicleSeat(v, -1) == p and not GetIsVehicleEngineRunning(v) and not config.enable_carui_perclass and config.carui == 'modern' then
				self.entering = true
				SetVehicleEngineOn(v,false,true,true)
				while not self.start and IsPedInAnyVehicle(p) do
					if not self.start and IsVehicleEngineStarting(v) then
						SetVehicleEngineOn(v,false,true,true)
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

end

function Hud:fuelusagerun()

end

function Hud:turboboost(gear)

end

function Hud:Boost(hasturbo)
	
end

function Hud:vehiclemode()

end

function Hud:ToggleDrift()

end

function Hud:applyVehicleMods(veh,wheel) -- https://forum.cfx.re/t/cant-change-setvehiclehandlingfloat-transforming-vehicle-to-awd-fivem-bug/3393188

end

function Hud:differential()

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
		local topspeed = GetVehicleHandlingFloat(self.vehicle,'CHandlingData', 'fInitialDriveMaxFlatVel') * 0.64
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

end

checkingpatient = false
function Hud:BodyUi(target)

end

function Hud:BodyLoop()

end

function Hud:bodydamage()

end

function Hud:recoil(r)

end

function Hud:armdamage() -- self.vehicle 

end

function Hud:legdamage()

end

function Hud:CheckBody()  

end

function Hud:BodyMain()

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

end

function Hud:shuffleseat(index)

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
						sleep = 100
						self.shooting = true
						if config.enablestatus and config.killing_affect_status then
							val, ent = GetEntityPlayerIsFreeAimingAt(self.pid)
							if lastent ~= nil and lastent ~= 0 then
								if not killed[lastent] and IsEntityDead(lastent) and GetPedSourceOfDeath(lastent) == self.ped then
									killed[lastent] = true
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
						end
						count = count + 1
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

end

function Hud:angle(veh)

end

--WHEEL SYSTEM
function Hud:NuiWheelSystem()

end

function Hud:tireanimation()

end

function Hud:turboanimation(type)

end

function Hud:TireFunction(type)

end

carjacking = false
function Hud:Carlock()

end

function Hud:playsound(vehicle,max,file,maxvol)

end

function Hud:whileinput()

end

function Hud:Clothing()

end

function Hud:checkaccesories(accessory, changes) -- being used if ESX ACCESORIES IS enable - (mask,helmet from datastore instead of skinchangers Characters) copyright to LINK https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/client/main.lua#L30

end

function Hud:SaveCurrentClothes(firstload)

end

function Hud:ClotheState()
end

function Hud:TaskAnimation(t)

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
	local total_tirehealth = tirehealth / (config.tirebrandnewhealth * numwheel) * 100
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

function Hud:SetEngineSpecs(veh, model)

end

function Hud:GetHandlingfromModel(model)

end

function Hud:ReqAndDelete(object, detach)

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
	Hud:NuiShowMap(true)
	cb(true)
end)

standmodel , enginemodel = nil, nil
function Hud:repairengine(plate)

end

function Hud:SyncWheelAndSound(sounds,wheels)

end

function Hud:Renzu_Function(func)
	local f = {}
	setmetatable(f, {
		__close = func
	})
	return f
end