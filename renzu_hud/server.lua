local adv_table = {}
Renzu = {}
charslot = {}
ESX = nil
SetConvar("game_enableFlyThroughWindscreen", true)
Citizen.CreateThread(function()
	Wait(1000)
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
					stats.entity = nil
					adv_table[v.plate] = stats
				end
			end
		end
	end)
	print("^g RENZU HUD STARTED!")
	if config.enable_commands_as_item then
		RenzuCommand('useitem', function(source,args)
			if args[1] ~= nil and config.ESX_Items[args[1]] ~= nil then
				if havePermission(GetPlayerIdentifier(source, 0)) then
					TriggerClientEvent(config.ESX_Items[args[1]].event, source, config.ESX_Items[args[1]].value)
				end
			end
		end, false)
	end
	if config.framework == 'ESX' then
		for k,v in pairs(config.ESX_Items) do
			MySQL.Async.fetchAll('SELECT * FROM items WHERE name = @name', {
				['@name'] = v.name
			}, function(foundRow)
				if foundRow[1] == nil then
					local weight = 'limit'
					if config.weight_type then
						MySQL.Sync.execute('INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)', {
							['@name'] = v.name,
							['@label'] = ""..firstToUpper(v.label).."",
							['@weight'] = v.weight
						})
						print("Inserting "..v.name.." new item")
					else
						MySQL.Sync.execute('INSERT INTO items (name, label) VALUES (@name, @label)', {
							['@name'] = v.name,
							['@label'] = ""..firstToUpper(v.label).."",
						})
						print("Inserting "..v.item.." new item")
					end
				end
			end)
			ESX.RegisterUsableItem(v.name, function(source)
				local xPlayer = GetPlayerFromId(source)
				if v.job and xPlayer.job.name ~= tostring(v.job) then xPlayer.showNotification('You are not a '..v.job..'', false, false, 130) return end
				TriggerClientEvent(v.event, source, v.value)
				xPlayer.removeInventoryItem(v.name, 1)
			end)
		end
		if config.use_esx_accesories then
			-- COPYRIGHT TO ESX ACCESOSRIES LINK https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/server/main.lua#L31
			ESX.RegisterServerCallback('esx_accessories:get2', function(source, cb, accessory)
				print("SKINS")
				local xPlayer = GetPlayerFromId(source)
				TriggerEvent('esx_datastore:getDataStore', 'user_' .. string.lower(accessory), xPlayer.identifier, function(store)
				local hasAccessory = (store.get('has' .. accessory) and store.get('has' .. accessory) or false)
				local skin = (store.get('skin') and store.get('skin') or {})

					cb(hasAccessory, skin)
				end)
			end)
		end
	end
end)

RegisterServerEvent("renzu_hud:savedata")
AddEventHandler("renzu_hud:savedata", function(plate,table)
	local source = source
	local plate = string.gsub(plate, "%s+", "")
	local foundplate = false
	if plate ~= nil then
		print("SAVING")
		adv_table[tostring(plate)] = table
		local results = MySQL.Sync.fetchAll("SELECT adv_stats,plate,owner FROM owned_vehicles WHERE plate=@plate", {['@plate'] = plate})
		if #results > 0 then
			foundplate = true
			MySQL.Sync.execute("UPDATE owned_vehicles SET adv_stats = @adv_stats WHERE plate = @plate", {
				['@adv_stats'] = json.encode(adv_table[tostring(plate)]),
				['@plate'] = plate
			})
		end
		if not foundplate then
			adv_table[tostring(plate)].owner = nil
		end
		TriggerClientEvent('renzu_hud:receivedata', -1, adv_table)
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
		TriggerClientEvent('renzu_hud:receivedata', source, adv_table, GetPlayerIdentifier(source))
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
AddEventHandler('renzu_hud:checkbody', function(target)
	if config.framework == 'ESX' then
		while ESX == nil do
			Wait(10)
		end
	end
	local source = source
	local originalsource = source
	if target ~= nil then
		source = target
	end
	local xPlayer = GetPlayerFromId(source)
	local done = false
	print(source,target)
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
		if target == nil then
			target = false
		else
			target = true
		end
		print(target,source)
		TriggerClientEvent('renzu_hud:bodystatus', originalsource, done, target)
	end)
end)

RegisterServerEvent('renzu_hud:savebody')
AddEventHandler('renzu_hud:savebody', function(bodystatus)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	bodytable[identifier] = bodystatus
	MySQL.Async.execute('UPDATE users SET bodystatus=@bodystatus WHERE identifier=@identifier',{['@bodystatus'] = json.encode(bodystatus),['@identifier'] = identifier})
end)

RegisterServerEvent('renzu_hud:healbody')
AddEventHandler('renzu_hud:healbody', function(target,part)
	print("1",part)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	if config.framework ~= 'ESX' or config.framework == 'ESX' and xPlayer.job.name == config.checkbodycommandjob then
		if target == nil then
			target = source
		end
		TriggerClientEvent('renzu_hud:healbody', target, part, true)
	end
end)

function bandages(part)
	local b = nil
	if part == 'ped_body' then b = config.ESX_Items['body_bandage']
	elseif part == 'left_leg' or part == 'right_leg' then b = config.ESX_Items['arm_bandage']
	elseif part == 'ped_head' then b = config.ESX_Items['leg_bandage']
	elseif part == 'right_hand' or part == 'left_hand' then b = config.ESX_Items['head_brace'] end
	return b
end

RegisterServerEvent('renzu_hud:checkitem')
AddEventHandler('renzu_hud:checkitem', function(part)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local b = nil
	local part = part
	if part == 'chest' then 
		b = config.ESX_Items['body_bandage']
	elseif part == 'leg' then 
		b = config.ESX_Items['leg_bandage']
	elseif part == 'arm' then 
		b = config.ESX_Items['arm_bandage']
	elseif part == 'head' then 
		b = config.ESX_Items['head_brace'] 
	end
	local bandage = b.name
	if config.framework ~= 'ESX' or config.framework == 'ESX' and xPlayer.job.name == config.checkbodycommandjob and xPlayer.getInventoryItem(bandage).count >= 1 then
		TriggerClientEvent('renzu_hud:healpart', source, part)
		if config.framework == 'ESX' then
			xPlayer.removeInventoryItem(bandage, 1)
		end
	else
		xPlayer.showNotification('You are not a '..config.checkbodycommandjob..' or you dont have a item', false, false, 130)
	end
end)

RegisterServerEvent("renzu_hud:nitro_flame")
AddEventHandler("renzu_hud:nitro_flame", function(entity,coords)
	TriggerClientEvent("renzu_hud:nitro_flame", -1, entity,coords)
end)

RegisterServerEvent("renzu_hud:nitro_flame_stop")
AddEventHandler("renzu_hud:nitro_flame_stop", function(entity,coords)
	TriggerClientEvent("renzu_hud:nitro_flame_stop", -1, entity,coords)
end)

RegisterServerEvent("renzu_hud:synclock")
AddEventHandler("renzu_hud:synclock", function(entity,type,coords)
	TriggerClientEvent("renzu_hud:synclock", -1, entity,type,coords)
end)

RegisterServerEvent("renzu_hud:airsuspension")
AddEventHandler("renzu_hud:airsuspension", function(entity,val,coords)
	TriggerClientEvent("renzu_hud:airsuspension", -1, entity,val,coords)
end)

local wheelsetting = {}
RegisterServerEvent("renzu_hud:wheelsetting")
AddEventHandler("renzu_hud:wheelsetting", function(entity,val,coords)
	TriggerClientEvent("renzu_hud:wheelsetting", -1, entity,wheelsetting)
end)

local antispam = {}
RegisterServerEvent("mumble:SetVoiceData")
AddEventHandler("mumble:SetVoiceData", function(mode,prox)
	local source = source
	if mode == 'mode' then
		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'proximity', prox)
	end
	if mode == 'radio' and not antispam[source] then
		antispam[source] = true
		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'radio', prox)
		Wait(10)
		antispam[source] = false
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

--ENGINE SYSTEM :D

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
	if config.enable_engine_item then
		Wait(1000)
		local c = 0
		if config.custom_engine_enable then
			for k, v in pairs(config.custom_engine) do
				config.engine[tostring(v.handlingName)] = true
			end
		end
		for v, k in pairs(config.engine) do -- you can remove this for loop after you install the engine sql
			c = c + 1
			local enginename = string.lower(v)
			local label = string.upper(v)
			MySQL.Async.fetchAll('SELECT * FROM items WHERE name = @name', {
				['@name'] = "engine_"..enginename..""
			}, function(foundRow)
				if foundRow[1] == nil then
					local weight = 'limit'
					if config.weight_type then
						MySQL.Sync.execute('INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)', {
							['@name'] = "engine_"..enginename.."",
							['@label'] = ""..firstToUpper(enginename).." Engine",
							['@weight'] = config.weight
						})
						print("Inserting "..enginename.."")
					else
						MySQL.Sync.execute('INSERT INTO items (name, label) VALUES (@name, @label)', {
							['@name'] = "engine_"..enginename.."",
							['@label'] = ""..firstToUpper(enginename).." Engine",
						})
						print("Inserting "..enginename.."")
					end
				end
			end)
		end

		for v, k in pairs(config.engine) do
			local enginename = string.lower(v)
			--print("register item")
			ESX.RegisterUsableItem("engine_"..enginename.."", function(source)
				local xPlayer = ESX.GetPlayerFromId(source)
				if config.engine_jobonly and xPlayer.job.name ~= tostring(config.engine_job) then xPlayer.showNotification('You are not a '..config.engine_job..'', false, false, 130) return end
				xPlayer.removeInventoryItem("engine_"..enginename.."", 1)
				TriggerClientEvent('renzu_hud:change_engine', xPlayer.source, enginename)
			end)
		end

		if config.enable_commands then
			RenzuCommand('installengine', function(source,args)
				if args[1] ~= nil and config.ESX_Items[args[1]] ~= nil then
					if havePermission(GetPlayerIdentifier(source, 0)) then
						for v, k in pairs(config.engine) do
							if v == args[1] then
								TriggerClientEvent('renzu_hud:change_engine', source, v)
							end
						end
					end
				end
			end, false)
		end
	end
end)

RegisterServerEvent('renzu_hud:change_engine')
AddEventHandler('renzu_hud:change_engine', function(plate, stats)
	local plate = plate
	adv_table[tostring(plate)] = stats
	MySQL.Async.fetchAll("SELECT adv_stats,plate,owner FROM owned_vehicles WHERE plate=@plate", {['@plate'] = plate}, function(results)
		if #results > 0 then
			foundplate = true
			MySQL.Sync.execute("UPDATE owned_vehicles SET adv_stats = @adv_stats WHERE plate = @plate", {
				['@adv_stats'] = json.encode(adv_table[tostring(plate)]),
				['@plate'] = plate
			})
		end
	end)
	TriggerClientEvent("renzu_hud:syncengine", -1, plate, stats)
	print("syncing to all")
end)

function havePermission(i)
	for k,v in pairs(config.commanditem_permission) do
		if v == i then
		return true
		end
	end
	return false
end