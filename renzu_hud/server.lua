ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local adv_table = {}
Citizen.CreateThread(function()
	--Citizen.Wait(10000)
	MySQL.Async.fetchAll("SELECT adv_stats,plate FROM owned_vehicles", {}, function(results)
		if #results > 0 then
			for k,v in pairs(results) do
				if v.adv_stats and v.plate ~= nil then
					local stats = json.decode(v.adv_stats)
					stats.plate = string.gsub(v.plate, "%s+", "")
					adv_table[v.plate] = stats
				end
			end
		end
	end)
	print("^g RENZU HUD STARTED!")
end)

RegisterServerEvent("renzu_hud:savemile")
AddEventHandler("renzu_hud:savemile", function(plate,table)
	local plate = plate
	print("save")
	if plate ~= nil then
	adv_table[tostring(plate)] = table
	TriggerClientEvent('renzu_hud:receivemile', -1, adv_table)
	MySQL.Sync.execute("UPDATE owned_vehicles SET adv_stats = @adv_stats WHERE plate = @plate", {
		['@adv_stats'] = json.encode(adv_table[tostring(plate)]),
		['@plate'] = plate
	})
	end
end)

RegisterServerEvent("renzu_hud:getmile")
AddEventHandler("renzu_hud:getmile", function()
	if adv_table ~= nil then
	local source = source
	print("sending mile")
	TriggerClientEvent('renzu_hud:receivemile', source, adv_table)
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
	local xPlayer = ESX.GetPlayerFromId(source)
	local done = false
	MySQL.Async.fetchAll("SELECT bodystatus FROM users WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier},	function(res)
		if res[1].bodystatus and json.decode(res[1].bodystatus) ~= nil then 
			done = json.decode(res[1].bodystatus)
			print(res[1].bodystatus)
			print(done)
		end
		print(res[1].bodystatus)
		print(done)
		TriggerClientEvent('renzu_hud:bodystatus', source, done)
	end)
end)

RegisterServerEvent('renzu_hud:savebody')
AddEventHandler('renzu_hud:savebody', function(bodystatus)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	bodytable[identifier] = bodystatus
	MySQL.Async.execute('UPDATE users SET bodystatus=@bodystatus WHERE identifier=@identifier',{['@bodystatus'] = json.encode(bodystatus),['@identifier'] = identifier})
end)

ESX.RegisterUsableItem('nitro', function(source)
	print(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('renzu_hud:addnitro', source)
	xPlayer.removeInventoryItem('nitro', 1)
end)

RegisterServerEvent("renzu_hud:nitro_flame")
AddEventHandler("renzu_hud:nitro_flame", function(entity,coords)
	TriggerClientEvent("renzu_hud:nitro_flame", -1, entity,coords)
end)