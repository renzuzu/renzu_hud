-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
local adv_table = {}
Renzu = {}
charslot = {}
ESX = nil
QBCore = nil
Citizen.CreateThread(function()
	Wait(1000)
	MySQL.Sync.execute([[
		CREATE TABLE IF NOT EXISTS `vehicle_status` (
			`stats` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
			`plate` VARCHAR(64) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
			`owner` VARCHAR(64) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
			PRIMARY KEY (`plate`) USING BTREE
		)
		COLLATE='utf8mb4_general_ci'
		ENGINE=InnoDB
		;
		CREATE TABLE IF NOT EXISTS `body_status` (
			`status` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
			`identifier` VARCHAR(64) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
			PRIMARY KEY (`identifier`) USING BTREE
		)
		COLLATE='utf8mb4_general_ci'
		ENGINE=InnoDB
		;
	]])
	if config.framework == 'ESX' then
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
	if config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetSharedObject()
	end
	MySQL.Async.fetchAll("SELECT stats,plate,owner FROM vehicle_status", {}, function(results)
		if #results > 0 then
			for k,v in pairs(results) do
				if v.stats and v.plate ~= nil then
					local stats = json.decode(v.stats)
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
	elseif config.framework == 'QBCORE' then
		for k,v in pairs(config.ESX_Items) do
			QBCore.Functions.CreateUseableItem(v.name, function(source, item)
				local xPlayer = QBCore.Functions.GetPlayer(source)
				if v.job and xPlayer.PlayerData.job.name ~= tostring(v.job) then TriggerClientEvent('QBCore:Notify', source, 'You are not a '..v.job..'', 'error') return end
				TriggerClientEvent(v.event, source, v.value)
				xPlayer.Functions.RemoveItem(v.name, 1)
			end)
		end
	end
end)

function isVehicleOwned(plate)
	local owner = MySQL.Sync.fetchAll("SELECT "..config.Owner_column.." FROM "..config.vehicle_table.." WHERE plate=@plate", {['@plate'] = plate})
	return owner
end

RegisterServerEvent("renzu_hud:savedata")
AddEventHandler("renzu_hud:savedata", function(plate,table,updatevehicles)
	local source = source
	if plate ~= nil then
		local plate = string.gsub(plate, "%s+", "")
		local foundplate = false
		local newcreated = false
		if plate ~= nil then
			print("SAVING")
			adv_table[tostring(plate)] = table
			local results = MySQL.Sync.fetchAll("SELECT stats,plate,owner FROM vehicle_status WHERE plate=@plate", {['@plate'] = plate})
			if #results <= 0 then
				local owner = isVehicleOwned(plate)
				if #owner > 0 then
					MySQL.Sync.execute("INSERT INTO vehicle_status (stats, plate, owner) VALUES (@stats, @plate, @owner)", {
						['@stats'] = json.encode(adv_table[tostring(plate)]),
						['@plate'] = plate,
						['@owner'] = owner[1][config.Owner_column]
					})
					foundplate = true
					adv_table[tostring(plate)].owner = owner[1][config.Owner_column]
				end
			end
			if #results > 0 then
				foundplate = true
				MySQL.Sync.execute("UPDATE vehicle_status SET stats = @stats WHERE plate = @plate", {
					['@stats'] = json.encode(adv_table[tostring(plate)]),
					['@plate'] = plate
				})
			end
			if not foundplate then
				adv_table[tostring(plate)].owner = nil
			end
			TriggerClientEvent('renzu_hud:receivedata', -1, adv_table)
		end
	else
		print('plate is nil')
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
	-- print(slot)
	-- print("SLOT")
	-- print(fetchslot)
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
	print(xPlayer,"PLAYERLOADED",xPlayer)
	while xPlayer == nil do
		print("Creating Player")
		CreatePlayer(source)
		Citizen.Wait(500)
		while xPlayer == nil do Wait(100) xPlayer = GetPlayerFromId(source) end
		xPlayer = GetPlayerFromId(source)
		print("Player Created...")
		local results = MySQL.Sync.fetchAll("SELECT status FROM body_status WHERE identifier=@identifier", {['@identifier'] = xPlayer.identifier})
		if #results <= 0 then
			MySQL.Sync.execute("INSERT INTO body_status (status,identifier) VALUES (@status,@identifier)", {
				['@status'] = '[]',
				['@identifier'] = xPlayer.identifier
			})
		end
	end
	MySQL.Async.fetchAll("SELECT status FROM body_status WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier},	function(res)
		if res[1] ~= nil and res[1].status and json.decode(res[1].status) ~= nil then
			done = json.decode(res[1].status)
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

function UpdateBodySql(bodystatus,identifier)
	bodytable[identifier] = bodystatus
	if json.encode(bodystatus) ~= 'null' then
		MySQL.Async.execute('UPDATE body_status SET status=@status WHERE identifier=@identifier',{['@status'] = json.encode(bodystatus),['@identifier'] = identifier})
	end
end

RegisterServerEvent('renzu_hud:savebody')
AddEventHandler('renzu_hud:savebody', function(bodystatus)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	UpdateBodySql(bodystatus,identifier)
end)

RegisterServerEvent('renzu_hud:healbody')
AddEventHandler('renzu_hud:healbody', function(target,part)
	print("1",part)
	local xPlayer = GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	if config.framework == 'Standalone' or config.framework == 'ESX' and xPlayer.job.name == config.checkbodycommandjob or config.framework == 'QBCORE' and xPlayer.PlayerData.job.name == config.checkbodycommandjob then
		if target == nil then
			target = source
		end
		TriggerClientEvent('renzu_hud:healbody', target, part, true)
	end
end)

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
	if config.framework == 'Standalone' or config.framework == 'ESX' and xPlayer.job.name == config.checkbodycommandjob and xPlayer.getInventoryItem(bandage).count >= 1 or config.framework == 'QBCORE' and xPlayer.PlayerData.job.name == config.checkbodycommandjob and xPlayer.Functions.GetItemByName(bandage) ~= nil then
		TriggerClientEvent('renzu_hud:healpart', source, part)
		if config.framework == 'ESX' then
			xPlayer.removeInventoryItem(bandage, 1)
		elseif config.framework == 'QBCORE' then
			xPlayer.Functions.RemoveItem(bandage, 1)
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
	if charslot[source] == nil or charslot[source] == 0 then
		charslot[source] = 1
	end
	local xPlayer = Standalone(source, GetSteam(source), GetPlayerName(source), charslot[source] or 1)
	Renzu[tonumber(source)] = xPlayer
end

function GetPlayerFromId(source)
	if config.framework == 'ESX' then
		return ESX.GetPlayerFromId(tonumber(source))
	elseif config.framework == 'QBCORE' then
		return QBCore.Functions.GetPlayer(tonumber(source))
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
	local bodystatus = bodytable[GetSteam(source)]
	UpdateBodySql(bodystatus,GetSteam(source))
	Renzu[tonumber(source)] = nil
end)

--ENGINE SYSTEM :D

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
	Wait(1000)
	if config.enable_engine_item and config.framework == 'ESX' then
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
		if config.framework == 'ESX' then
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
		end
	end
	if config.enable_engine_item and config.framework == 'QBCORE' then
		Wait(1000)
		local c = 0
		if config.custom_engine_enable then
			for k, v in pairs(config.custom_engine) do
				config.engine[tostring(v.handlingName)] = true
			end
		end
		if config.framework == 'QBCORE' then
			for v, k in pairs(config.engine) do
				local enginename = string.lower(v)
				--print("register item")
				QBCore.Functions.CreateUseableItem("engine_"..enginename.."", function(source, item)
					local xPlayer = QBCore.Functions.GetPlayer(source)
					if config.engine_jobonly and xPlayer.PlayerData.job.name ~= tostring(config.engine_job) then TriggerClientEvent('QBCore:Notify', source, 'You are not a '..config.engine_job..'', 'error') return end
					xPlayer.Functions.RemoveItem("engine_"..enginename.."", 1)
					TriggerClientEvent('renzu_hud:change_engine', xPlayer.source, enginename)
				end)
			end
		end
	end
	print("commands")
	if config.enable_commands then
		RenzuCommand('installengine', function(source,args)
			if args[1] ~= nil and config.engine[args[1]] ~= nil then
				if havePermission(GetPlayerIdentifier(source, 0)) then
					for v, k in pairs(config.engine) do
						if v == args[1] then
							print("install")
							TriggerClientEvent('renzu_hud:change_engine', source, v)
						end
					end
				end
			end
		end, false)
	end
end)

RegisterServerEvent('renzu_hud:change_engine')
AddEventHandler('renzu_hud:change_engine', function(plate, stats)
	local plate = plate
	adv_table[tostring(plate)] = stats
	MySQL.Async.fetchAll("SELECT stats,plate FROM vehicle_status WHERE plate=@plate", {['@plate'] = plate}, function(results)
		if #results > 0 then
			foundplate = true
			MySQL.Sync.execute("UPDATE vehicle_status SET stats = @status WHERE plate = @plate", {
				['@status'] = json.encode(adv_table[tostring(plate)]),
				['@plate'] = plate
			})
		end
	end)
	TriggerClientEvent("renzu_hud:syncengine", -1, plate, stats)
	print("syncing to all")
end)

RegisterServerEvent('renzu_hud:manualsync')
AddEventHandler('renzu_hud:manualsync', function(vehicle, gear, plate)
	local vehicle = vehicle
	TriggerClientEvent("renzu_hud:manualtrigger", -1, vehicle, gear, plate)
	print("syncing gears")
end)

function havePermission(i)
	for k,v in pairs(config.commanditem_permission) do
		if v == i then
		return true
		end
	end
	return false
end