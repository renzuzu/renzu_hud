ESX = nil
Citizen.CreateThread(function()
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
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local AdvStatsTable = {}
local playerloaded = false
local manual = false
local vehicletopspeed
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
local PedCar

-----------------------------------------------------------------------------------------------------------------------------------------
-- DATE
-----------------------------------------------------------------------------------------------------------------------------------------
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

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)	
		CalculateTimeToDisplay()
		CalculateDateToDisplay()
	end
end)

local playerNamesDist = 3
local key_holding = false

local particlesfire = {}
local particleslight = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VOICE FUNC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('voice', function()
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
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping('voice', 'Voice Proximity', 'keyboard', 'Z')
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

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	--ESX.PlayerData = xPlayer
	playerloaded = true
	Citizen.Wait(2000)
	TriggerServerEvent("renzu_hud:getmile")
end)


--- NEW HUD FUNC

RegisterNUICallback('requestface', function(data, cb)
	while not playerloaded do
		Citizen.Wait(100)
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
	print(tempHandle)
	print(tempHandle)
	print(tempHandle)
	print(tempHandle)

	return headshotTxd
end

function ClearPedHeadshots()
		if headshot ~= nil or headshot ~= 0 then
        UnregisterPedheadshot(headshot)
		end
end

local statuses = {
	'energy',
	'thirst',
	'sanity',
	'hunger'
}

local show = false
RegisterCommand('showstatus', function()
	show = not show
    PlaySoundFrontend(PlayerId(), "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true )
	SendNUIMessage({
		type = "setShowstatus",
		content = show
	})
end, false)

Citizen.CreateThread(function()
	RegisterKeyMapping('showstatus', 'HUD Status UI', 'keyboard', 'INSERT')
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		sanity = 0
		thirst = 0
		hunger = 0
		oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
		energy = 0
		stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
		TriggerEvent('esx_status:getStatusm', statuses, function(status)
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
		end)
		Citizen.Wait(100)
		Citizen.Wait(1000)
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
		print("Sending status")
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(4000)
	local l = 0
	while true do
		local wait = 4000
		--setVoice()
		ped = PlayerPedId()
		PedCar = GetVehiclePedIsIn(ped)
		vehicle = GetVehiclePedIsIn(ped)
		if vehicle ~= nil and vehicle ~= 0 then
			hp = GetVehicleEngineHealth(PedCar)
			--speed = math.ceil(GetEntitySpeed(PedCar) * 3.6)
			--rpm = GetVehicleCurrentRpm(PedCar)
			gasolina = GetVehicleFuelLevel(PedCar)
		end
		Citizen.Wait(2000)
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(2000)
	end
	while ped == nil do
		Citizen.Wait(1000)
	end
	while true do
		local sleep = 2000
		if vehicle ~= nil and vehicle ~= 0 then
			sleep = 22
			rpm = GetVehicleCurrentRpm(vehicle)
			speed = GetEntitySpeed(vehicle)
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(2000)
	end
	while ped == nil do
		Citizen.Wait(1000)
	end
	while true do
		local sleep = 500
		if vehicle ~= nil and vehicle ~= 0 then
			sleep = 22

			if rpm < 0.21 then
			Citizen.Wait(122)
			end
			if newrpm ~= rpm or newrpm == nil then
				newrpm = rpm
				SendNUIMessage({
					type = "setRpm",
					content = rpm
				})
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setRpm",
				-- 	content = rpm
				-- })
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setRpm",
				-- 	content = rpm
				-- })
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setRpm",
				-- 	content = rpm
				-- })
			end
		end
		Citizen.Wait(sleep)
	end
end)
	

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(2000)
	end
	while ped == nil do
		Citizen.Wait(1000)
	end
	while true do
		local sleep = 500
		if vehicle ~= nil and vehicle ~= 0 then
			sleep = 22
			if rpm < 0.21 then
			Citizen.Wait(111)
			end
			if newspeed ~= speed or newspeed == nil then
				newspeed = speed
				SendNUIMessage({
					type = "setSpeed",
					content = speed
				})
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setSpeed",
				-- 	content = speed
				-- })
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setSpeed",
				-- 	content = speed
				-- })
				-- Citizen.Wait(22)
				-- SendNUIMessage({
				-- 	type = "setSpeed",
				-- 	content = speed
				-- })
			end
		end
		Citizen.Wait(sleep)
	end
end)

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
		local carwait = 2000
		ped = PlayerPedId()
		health = (GetEntityHealth(ped)-100)
		armor = GetPedArmour(ped)
		local x,y,z = table.unpack(GetEntityCoords(ped,false))
		street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
		----print("hud1")
		if vehicle ~= nil and vehicle ~= 0 then
			carwait = 2500
			inCar  = true
			PedCar = GetVehiclePedIsIn(ped)
			DisplayRadar(true)		
		else	
			inCar  = false
			PedCar = 0
			speed = 0
			rpm = 0
			marcha = 0
			cruiseIsOn = false
			VehIndicatorLight = 0
			DisplayRadar(false)
		end
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
		-- ----print(newhealth)
		if newmic ~= voiceDisplay or newmic == nil then
		SendNUIMessage({
		type = "setMic",
		content = voiceDisplay
		})
		newmic = voiceDisplay
		end
	Citizen.Wait(carwait)
	end
end)

local uimove = false
Citizen.CreateThread(function()
	while ESX == nil do
	Citizen.Wait(2000)
	end
	local newgas = nil
	local newgear = nil
	local vehealth = nil
	local belt= nil
	local wait = 1500
	while true do
		----print(inCar)
		if vehicle ~= nil and vehicle ~= 0 and inCar then
			wait = 500
			inCar  = true
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
			if uimove then
			Citizen.Wait(1500)
			SendNUIMessage({
			type = "setShow",
			content = true

			})
			end
			uimove = false
		else
			wait = 2000
			if not uimove then
			Citizen.Wait(500)
			SendNUIMessage({
			type = "setShow",
			content = false
			})
			end
			uimove = true
		end
		Citizen.Wait(wait)
	end
end)

--NUI RADIO STATION
Citizen.CreateThread(function()
	while true do
		local sleep = 500
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
			Citizen.Wait(2500)
		end
		Citizen.Wait(sleep)
	end
end)

--NUI HEAD LIGHTS
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		local ped = ped
		local vehicle = vehicle
		local off,low,high = GetVehicleLightsState(PedCar)
		if low == 1 and high == 0 then
			light = 1
		elseif high == 1 then
			light = 2
		else
			light = 0
		end
		if vehicle ~= 0 then
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
end)

Citizen.CreateThread(function()
	while true do
		ped = ped
		--local car = GetVehiclePedIsIn(ped)
		local cansleep = 2000
		if vehicle ~= 0 then
			cansleep = 6
			if IsControlJustReleased(1,29) then
				if belt then
					SetTimeout(1000,function()
						belt = false
					end)
				else
					SetTimeout(1000,function()
						belt = true
					end)
				end
			end
		end
		Citizen.Wait(cansleep)
	end
end)

--NUI BELT STATUS
Citizen.CreateThread(function()
	while true do
		local sleep = 2000
		local ped = ped
		local vehicle = vehicle
		if vehicle ~= nil and vehicle ~= 0 then
			if newbelt ~= belt or newbelt == nil then
				newbelt = belt
				SendNUIMessage({
				type = "setBelt",
				content = belt
				})
			end
		end
		Citizen.Wait(sleep)
	end
end)

-- MILEAGE
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
	while true do
		Citizen.Wait(111)
		local ped = ped
		local vehicle = vehicle
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		local newPos = GetEntityCoords(ped)
		local driver = GetPedInVehicleSeat(vehicle, -1)
		if vehicle ~= nil and vehicle ~= 0 and IsPedInAnyVehicle(ped, false) and driver == ped then
			savemile = true
			lastve = GetVehiclePedIsIn(ped, false)
			if plate ~= nil then
				saveplate = string.match(GetVehicleNumberPlateText(vehicle), '%f[%d]%d[,.%d]*%f[%D]')
				plate = saveplate
				--if AdvStatsTable ~= nil and AdvStatsTable[plate] ~= nil then
					if plate ~= nil and AdvStatsTable[plate] == nil then
						AdvStatsTable[plate] = {}
						AdvStatsTable[plate].plate = plate
						AdvStatsTable[plate].mileage = 0
					end
					if plate ~= nil and AdvStatsTable[plate].plate == plate then
						if oldPos == nil then
							oldPos = newPos
						end
						local dist = #(newPos-oldPos)
						if dist > 10.0 then
							AdvStatsTable[plate].mileage = AdvStatsTable[plate].mileage+GetEntitySpeed(vehicle)*1/100
							oldPos = newPos
						end
						--print(AdvStatsTable[plate].mileage)
						if newmileage ~= AdvStatsTable[plate].mileage or newmileage == nil then
							newmileage = AdvStatsTable[plate].mileage
							SendNUIMessage({
							type = "setMileage",
							content = AdvStatsTable[plate].mileage
							})
						end
					end
				--end
			end

		elseif savemile and lastve ~= nil and saveplate ~= nil then
			savemile = false
			TriggerServerEvent('renzu_hud:savemile', tonumber(saveplate), AdvStatsTable[tostring(saveplate)])
			Wait(1000)
			lastve = nil
			saveplate = nil
		else
			Wait(1000)
		end
	end
end)