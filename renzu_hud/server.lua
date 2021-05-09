ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local adv_table = {}
Renzu = {}
charslot = {}
Citizen.CreateThread(function()
	--Citizen.Wait(10000)
	MySQL.Async.fetchAll("SELECT adv_stats,plate,owner FROM owned_vehicles", {}, function(results)
		if #results > 0 then
			for k,v in pairs(results) do
				if v.adv_stats and v.plate ~= nil then
					local stats = json.decode(v.adv_stats)
					stats.plate = string.gsub(v.plate, "%s+", "")
					stats.owner = v.owner
					adv_table[v.plate] = stats
				end
			end
		end
	end)
	print("^g RENZU HUD STARTED!")
end)

RegisterServerEvent("renzu_hud:savedata")
AddEventHandler("renzu_hud:savedata", function(plate,table)
	local plate = plate
	if plate ~= nil then
		print("SAVING")
		adv_table[tostring(plate)] = table
		TriggerClientEvent('renzu_hud:receivemile', -1, adv_table)
		MySQL.Async.fetchAll("SELECT adv_stats,plate,owner FROM owned_vehicles WHERE plate=@plate", {['@plate'] = plate}, function(results)
			if #results > 0 then
				MySQL.Sync.execute("UPDATE owned_vehicles SET adv_stats = @adv_stats WHERE plate = @plate", {
					['@adv_stats'] = json.encode(adv_table[tostring(plate)]),
					['@plate'] = plate
				})
			end
		end)
	end
end)

RegisterServerEvent("renzu_hud:getdata")
AddEventHandler("renzu_hud:getdata", function(slot)
	local source = source
	if slot ~= nil and charslot[source] == nil then
		charslot[source] = slot
	end
	if config.multichar and adv_table ~= nil and config.multichar_advanced and charslot[source] ~= nil or not config.multichar and not config.multichar_advanced and adv_table ~= nil or config.multichar and not config.multichar_advanced and adv_table ~= nil or not config.multichar and adv_table ~= nil then
		if Renzu[tonumber(source)] == nil then
			local xPlayer = Standalone(source, GetSteam(source), GetPlayerName(source), charslot[source] or 1)
			Renzu[tonumber(source)] = xPlayer
			print("Creating New Data")
		end
		TriggerClientEvent('renzu_hud:receivemile', source, adv_table, GetPlayerIdentifier(source))
	end
end)

RegisterServerEvent("renzu_hud:smokesync")
AddEventHandler("renzu_hud:smokesync", function(ent,coord)
	local ent = ent
	local coord = coord
	TriggerClientEvent('start:smoke', -1, ent,coord)
end)

bodytable = {}
RegisterServerEvent('renzu_hud:checkbody')
AddEventHandler('renzu_hud:checkbody', function()
	local source = source
	local xPlayer = GetPlayerFromId(source)
	local done = false
	while xPlayer == nil do
		Citizen.Wait(500)
		xPlayer = GetPlayerFromId(source)
		print("nil")
	end
	MySQL.Async.fetchAll("SELECT bodystatus FROM users WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier},	function(res)
		if res[1].bodystatus and json.decode(res[1].bodystatus) ~= nil then 
			done = json.decode(res[1].bodystatus)
		end
		TriggerClientEvent('renzu_hud:bodystatus', source, done)
	end)
end)

RegisterServerEvent('renzu_hud:savebody')
AddEventHandler('renzu_hud:savebody', function(bodystatus)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	bodytable[identifier] = bodystatus
	MySQL.Async.execute('UPDATE users SET bodystatus=@bodystatus WHERE identifier=@identifier',{['@bodystatus'] = json.encode(bodystatus),['@identifier'] = identifier})
end)
if config.framework == 'ESX' then
	ESX.RegisterUsableItem('nitro', function(source)
		print(source)
		local xPlayer = GetPlayerFromId(source)
		TriggerClientEvent('renzu_hud:addnitro', source)
		xPlayer.removeInventoryItem('nitro', 1)
	end)
end

RegisterServerEvent("renzu_hud:nitro_flame")
AddEventHandler("renzu_hud:nitro_flame", function(entity,coords)
	TriggerClientEvent("renzu_hud:nitro_flame", -1, entity,coords)
end)

RegisterServerEvent("renzu_hud:synclock")
AddEventHandler("renzu_hud:synclock", function(entity,type,coords)
	TriggerClientEvent("renzu_hud:synclock", -1, entity,type,coords)
end)

RegisterServerEvent("renzu_hud:airsuspension")
AddEventHandler("renzu_hud:airsuspension", function(entity,val,coords)
	TriggerClientEvent("renzu_hud:airsuspension", -1, entity,val,coords)
end)

RegisterServerEvent("mumble:SetVoiceData")
AddEventHandler("mumble:SetVoiceData", function(mode,prox)
	local source = source
	if mode == 'mode' then
		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'proximity', prox)
	end
	if mode == 'radio' then
		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'radio', prox)
	end
end)

function GetSteam(source)
	local source = source
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, config.identifier) then
			license = v
			break
		end
	end
	if config.multichar and config.multichar_advanced then
		license = string.gsub(license, "steam", ""..config.charprefix..""..charslot[source].."")
	end
	return license
end

function Standalone(playerId, identifier, name, slot)
	local self = {}
	self.source = playerId
	self.identifier = identifier
	self.name = name
	self.charslot = slot
	return self
end

function GetPlayerFromId(source)
	if config.framework == 'ESX' then
		return ESX.Players[tonumber(source)]
	end
	return Renzu[tonumber(source)]
end

RegisterServerEvent(config.characterchosenevent)
AddEventHandler(config.characterchosenevent, function(charid, ischar)
    local source = source
    charslot[source] = charid
	TriggerClientEvent('renzu_hud:charslot', source, charid)
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function(reason)
	Renzu[tonumber(source)] = nil
end)