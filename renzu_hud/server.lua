local adv_table = {}
Renzu = {}
charslot = {}
ESX = nil
Citizen.CreateThread(function()
	Citizen.Wait(500)
	if config.framework == 'ESX' then
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
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
	if config.framework == 'ESX' then
		ESX.RegisterUsableItem('nitro', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent('renzu_hud:addnitro', source)
			xPlayer.removeInventoryItem('nitro', 1)
		end)
	
		ESX.RegisterUsableItem('coolant', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:coolant", source)
			xPlayer.removeInventoryItem('coolant', 1)
		end)
	
		ESX.RegisterUsableItem('engineoil', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:oil", source)
			xPlayer.removeInventoryItem('engineoil', 1)
		end)
	
		ESX.RegisterUsableItem('turbo_street', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:install_turbo", source, 'default')
			xPlayer.removeInventoryItem('turbo_street', 1)
		end)
	
		ESX.RegisterUsableItem('turbo_sports', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:install_turbo", source, 'sports')
			xPlayer.removeInventoryItem('turbo_sports', 1)
		end)
	
		ESX.RegisterUsableItem('turbo_racing', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:install_turbo", source, 'racing')
			xPlayer.removeInventoryItem('turbo_racing', 1)
		end)
	
		ESX.RegisterUsableItem('head_brace', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:healbody", source, 'head')
			xPlayer.removeInventoryItem('head_brace', 1)
		end)
	
		ESX.RegisterUsableItem('leg_bandage', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:healbody", source, 'leg')
			xPlayer.removeInventoryItem('leg_bandage', 1)
		end)
	
		ESX.RegisterUsableItem('arm_bandage', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:healbody", source, 'arm')
			xPlayer.removeInventoryItem('arm_bandage', 1)
		end)
	
		ESX.RegisterUsableItem('body_bandage', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:healbody", source, 'chest')
			xPlayer.removeInventoryItem('body_bandage', 1)
		end)
	
		ESX.RegisterUsableItem('street_tirekit', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:installtire", source, 'default')
			xPlayer.removeInventoryItem('street_tirekit', 1)
		end)
	
		ESX.RegisterUsableItem('sports_tirekit', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:installtire", source, 'sports')
			xPlayer.removeInventoryItem('sports_tirekit', 1)
		end)
	
		ESX.RegisterUsableItem('racing_tirekit', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:installtire", source, 'racing')
			xPlayer.removeInventoryItem('racing_tirekit', 1)
		end)
	
		ESX.RegisterUsableItem('drag_tirekit', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:installtire", source, 'drag')
			xPlayer.removeInventoryItem('drag_tirekit', 1)
		end)
	
		ESX.RegisterUsableItem('manual_tranny', function(source)
			local xPlayer = GetPlayerFromId(source)
			TriggerClientEvent("renzu_hud:manual", source, true)
			xPlayer.removeInventoryItem('manual_tranny', 1)
		end)
	end
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

function getlastcharslot(source)
	MySQL.Async.fetchAll("SELECT charid FROM user_lastcharacter WHERE steamid=@steamid", {['@steamid'] = GetPlayerIdentifiers(source)[1]}, function(results)
		if #results > 0 then
			print("OK")
			return results[1].charid
		end
		return false
	end)
end

RegisterServerEvent("renzu_hud:getdata")
AddEventHandler("renzu_hud:getdata", function(slot, fetchslot)
	print(slot)
	print("SLOT")
	print(fetchslot)
	local source = source
	if slot ~= nil and charslot[source] == nil then
		charslot[source] = slot
	end
	if charslot[source] == nil and fetchslot then
		charslot[source] = getlastcharslot(source)
	end
	if config.multichar and adv_table ~= nil and config.multichar_advanced and charslot[source] ~= nil or not config.multichar and not config.multichar_advanced and adv_table ~= nil or config.multichar and not config.multichar_advanced and adv_table ~= nil or not config.multichar and adv_table ~= nil then
		if Renzu[tonumber(source)] == nil then
			CreatePlayer(source)
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
		CreatePlayer(source)
		Citizen.Wait(500)
		xPlayer = GetPlayerFromId(source)
		print("nil")
		print(source)
		print(charslot[source])
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

function CreatePlayer(source)
	local xPlayer = Standalone(source, GetSteam(source), GetPlayerName(source), charslot[source] or 1)
	Renzu[tonumber(source)] = xPlayer
	print("Creating New Data")
end

function GetPlayerFromId(source)
	if config.framework == 'ESX' then
		return ESX.GetPlayerFromId(tonumber(source))
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