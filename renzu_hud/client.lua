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
local CintoSeguranca = false
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