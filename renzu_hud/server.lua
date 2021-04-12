TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local adv_table = {}
MySQL.Async.fetchAll("SELECT adv_stats,plate FROM owned_vehicles", {}, function(results)
	if #results > 0 then 
		for k,v in pairs(results) do
			if v.adv_stats and v.plate ~= nil then
				local stats = json.decode(v.adv_stats)
				stats.plate = string.match(v.plate, '%f[%d]%d[,.%d]*%f[%D]')
				adv_table[v.plate] = stats
			end
		end
	end
end)

RegisterServerEvent("renzu_hud:savemile")
AddEventHandler("renzu_hud:savemile", function(plate,table)
	local plate = tonumber(plate)
	print("save")
	if plate ~= nil and tonumber(plate) then
	print("aa"..plate.."aa")
	adv_table[tostring(plate)] = table
	TriggerClientEvent('renzu_hud:receivemile', -1, adv_table)
	MySQL.Sync.execute("UPDATE owned_vehicles SET adv_stats = @adv_stats WHERE plate = @plate", {
		['@adv_stats'] = json.encode(adv_table[tostring(plate)]),
		['@plate'] = plate
	})
	else
		print("plate not digits")
	end
end)

RegisterServerEvent("renzu_hud:getmile")
AddEventHandler("renzu_hud:getmile", function()
	if adv_table ~= nil then
	local source = source
	print("sending mile")
	print(adv_table)
	TriggerClientEvent('renzu_hud:receivemile', source, adv_table)
	end
end)