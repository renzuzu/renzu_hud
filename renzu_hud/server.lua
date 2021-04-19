local adv_table = {}
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