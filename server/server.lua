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
local vehicles = {}
vehicle_stat = {}
function SQLQuery(plugin,type,query,var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
		MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:fetch(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end

function FetchVehicles()
	local ownedvehicles = SQLQuery(config.Mysql,'fetchAll',"SELECT "..config.Owner_column..", `plate` FROM "..config.vehicle_table.." ", {})
	for k,v in pairs(ownedvehicles) do
		local plate = string.gsub(v.plate:upper(), '^%s*(.-)%s*$', '%1')
		v.plate = plate
		vehicles[v.plate] = v
	end
end

Citizen.CreateThread(function()
	while true do
		FetchVehicles()
		Wait(30000)
	end
end)

Citizen.CreateThread(function()
	Wait(1000)
	local ownedvehicles = SQLQuery(config.Mysql,'fetchAll',"SELECT "..config.Owner_column..", `plate` FROM "..config.vehicle_table.." ", {})
	local stat = SQLQuery(config.Mysql,'fetchAll',"SELECT stats,plate,owner FROM vehicle_status", {})
	for k , v in pairs(ownedvehicles) do
		local plate = string.gsub(v.plate:upper(), '^%s*(.-)%s*$', '%1')
		v.plate = plate
		vehicles[v.plate] = v
	end
	for k , v in pairs(stat) do
		local plate = string.gsub(v.plate:upper(), '^%s*(.-)%s*$', '%1')
		v.plate = plate
		vehicle_stat[v.plate] = v
	end
	if config.Mysql == 'mysql-async' then
		MySQL.Sync.execute([[
			CREATE TABLE IF NOT EXISTS `vehicle_status` (
				`stats` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
				`plate` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`owner` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`plate`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
			CREATE TABLE IF NOT EXISTS `body_status` (
				`status` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
				`identifier` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`identifier`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]])
	end
	if config.framework == 'ESX' then
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
	if config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetSharedObject()
	end
	results = SQLQuery(config.Mysql,'fetchAll',"SELECT stats,plate,owner FROM vehicle_status", {})
	if #results > 0 then
		for k,v in pairs(results) do
			if v.stats and v.plate ~= nil then
				local stats = json.decode(v.stats)
				if stats ~= nil and stats ~= 'null' then
					stats.plate = v.plate
					stats.owner = v.owner
					stats.entity = nil
					adv_table[v.plate] = stats
				end
			end
		end
	end
	print('^2-------------')
	print("RENZU HUD STARTED!")
	print('FRAMEWORK: '..config.framework)
	print("PLAYER VEHICLES TABLE: "..config.vehicle_table)
	print("IDENTIFIER TO USE: "..config.identifier)
	print('^7')
	if config.enable_commands_as_item then
		RenzuCommand('useitem', function(source,args)
			if args[1] ~= nil and config.ESX_Items[args[1]] ~= nil then
				if havePermission(PlayerIdentifier(source)) then
					TriggerClientEvent(config.ESX_Items[args[1]].event, source, config.ESX_Items[args[1]].value)
				end
			end
		end, false)
	end
	if config.framework == 'ESX' then
		for k,v in pairs(config.ESX_Items) do
			results = SQLQuery(config.Mysql,'fetchAll',"SELECT * FROM items WHERE name = @name", {
				['@name'] = v.name
			})
			if results[1] == nil then
				local weight = 'limit'
				if config.weight_type then
					SQLQuery(config.Mysql,'execute',"INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)", {
						['@name'] = v.name,
						['@label'] = ""..firstToUpper(v.label).."",
						['@weight'] = v.weight
					})
					print("Inserting "..v.name.." new item")
				else
					SQLQuery(config.Mysql,'execute',"INSERT INTO items (name, label) VALUES (@name, @label)", {
						['@name'] = v.name,
						['@label'] = ""..firstToUpper(v.label).."",
					})
				end
			end
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
	local plate = string.gsub(plate:upper(), '^%s*(.-)%s*$', '%1')
	local owner = vehicles[plate] ~= nil and vehicles[plate] or nil
	return owner
end

SyncStat = function(stat)
	for i=0, GetNumPlayerIndices()-1 do
		--if IsPlayerAceAllowed(GetPlayerFromIndex(i), "ace.test") then  
		local ply = Player(GetPlayerFromIndex(i))
		if ply and ply.state then
			ply.state.adv_stat = stat
			local temp = {}
			for k,v in pairs(stat) do
				if v.entity ~= nil then
					if temp[k] == nil then
						temp[k] = {}
					end
					temp[k].entity = v.entity
					temp[k].plate = k
					if v.height ~= nil then
						temp[k].height = v.height
					end
					if v.engine ~= nil then
						temp[k].engine = v.engine
					end
				end
			end
			ply.state.onlinevehicles = temp
		end
	end
end

local kids = {}
local oldt = {}
local toupdate = 0
local lastupdate = 0
local unsaved = {}
RegisterNetEvent("renzu_hud:savedata")
AddEventHandler("renzu_hud:savedata", function(plate,table,updatevehicles)
	local source = source
	if plate ~= nil and kids[source] ~= nil and kids[source] < GetGameTimer() or plate ~= nil and kids[source] == nil then
		kids[source] = GetGameTimer() + 2000 
		local foundplate = false
		local newcreated = false
		if plate ~= nil then
			adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')] = table
			local results = vehicle_stat[string.gsub(plate, '^%s*(.-)%s*$', '%1')]
			if results == nil then
				local owner = isVehicleOwned(plate)
				if owner ~= nil then
					SQLQuery(config.Mysql,'execute',"INSERT INTO vehicle_status (stats, plate, owner) VALUES (@stats, @plate, @owner)", {
						['@stats'] = json.encode(adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')]),
						['@plate'] = plate:upper(),
						['@owner'] = owner[config.Owner_column]
					})
					foundplate = true
					print("INSERT")
					adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')].owner = owner[config.Owner_column]
					vehicle_stat[string.gsub(plate, '^%s*(.-)%s*$', '%1')] = adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')]
				end
			end
			if results then
				foundplate = true
				local owner = isVehicleOwned(plate)
				if toupdate > 10 or lastupdate == 0 or lastupdate <= GetGameTimer() then
					for k,v in pairs(unsaved) do
						SQLQuery(config.Mysql,'execute',"UPDATE vehicle_status SET stats = @stats WHERE TRIM(UPPER(plate)) = @plate", {
							['@stats'] = json.encode(unsaved[string.gsub(v.plate:upper(), '^%s*(.-)%s*$', '%1')]),
							['@plate'] = string.gsub(v.plate:upper(), '^%s*(.-)%s*$', '%1'),
							['owner'] = v.owner
						})
						print("Update"..v.plate)
					end
					unsaved = {}
					lastupdate = GetGameTimer() + 20000
					toupdate = 0
				end
				toupdate = toupdate + 1
				if toupdate < 10 then
					unsaved[string.gsub(plate, '^%s*(.-)%s*$', '%1')] = adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')]
				end
				adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')].owner = owner[config.Owner_column]
				oldt[string.gsub(plate, '^%s*(.-)%s*$', '%1')] = adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')]
			end
			if not foundplate then
				adv_table[string.gsub(plate, '^%s*(.-)%s*$', '%1')].owner = nil
			end
			SyncStat(adv_table)
			--ply.state:set( --[[keyName]] 'adv_stat', --[[value]] adv_table, --[[replicate to server]] true)
			--print(ply.state.adv_stat) -- returns true
			--TriggerClientEvent('renzu_hud:receivedata', -1, adv_table)
		end
	else
		print('plate is nil')
	end
end)

function getlastcharslot(source)
	local results = SQLQuery(config.Mysql,'fetchAll',"SELECT charid FROM user_lastcharacter WHERE steamid=@steamid", {['@steamid'] = PlayerIdentifier(source)})
	if #results > 0 then
		print("OK")
		return results[1].charid
	end
	return false
end

RegisterServerEvent("renzu_hud:getdata")
AddEventHandler("renzu_hud:getdata", function(slot, fetchslot)
	-- print(slot)
	-- print(fetchslot)
	local xPlayer = GetPlayerFromId(source)
	local ply = Player(source)
	ply.state.loaded = true
	ply.state.identifier = xPlayer.identifier
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
		--local ply = Player(source)
		-- ply.state.adv_stat = adv_table
		--TriggerClientEvent('renzu_hud:receivedata', source, adv_table, PlayerIdentifier(source))
	end
	SyncStat(adv_table)
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
	--print(xPlayer,"PLAYERLOADED",xPlayer)
	while xPlayer == nil do
		print("Creating Player")
		CreatePlayer(source)
		Citizen.Wait(500)
		while xPlayer == nil do Wait(100) xPlayer = GetPlayerFromId(source) end
		xPlayer = GetPlayerFromId(source)
		print("Player Created...", xPlayer.identifier)
	end
	local res = SQLQuery(config.Mysql,'fetchAll',"SELECT status FROM body_status WHERE identifier=@identifier", {['@identifier'] = xPlayer.identifier})
	if res[1] ~= nil and res[1].status and json.decode(res[1].status) ~= nil then
		done = json.decode(res[1].status)
	elseif res[1] == nil then
		SQLQuery(config.Mysql,'execute',"INSERT INTO body_status (status,identifier) VALUES (@status,@identifier)", {
			['@status'] = json.encode({left_hand=0.0,left_leg=0.0,right_hand=0.0,right_leg=0.0,ped_body=0.0,ped_head=0.0}),
			['@identifier'] = xPlayer.identifier
		})
		done = {left_hand=0.0,left_leg=0.0,right_hand=0.0,right_leg=0.0,ped_body=0.0,ped_head=0.0}
	end
	if target == nil then
		target = false
	else
		target = true
	end
	--print(target,source)
	TriggerClientEvent('renzu_hud:bodystatus', originalsource, done, target)
end)

function UpdateBodySql(bodystatus,identifier)
	bodytable[identifier] = bodystatus
	if json.encode(bodystatus) ~= 'null' then
		SQLQuery(config.Mysql,'execute',"UPDATE body_status SET status=@status WHERE identifier=@identifier", {['@status'] = json.encode(bodystatus),['@identifier'] = identifier})
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
	--("1",part)
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
	SyncStat(adv_table)
	Wait(100)
	TriggerClientEvent("renzu_hud:wheelsetting", -1, entity,wheelsetting)
end)

-- local antispam = {}
-- RegisterServerEvent("mumble:SetVoiceData")
-- AddEventHandler("mumble:SetVoiceData", function(mode,prox)
-- 	local source = source
-- 	if mode == 'mode' then
-- 		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'proximity', prox)
-- 	end
-- 	if mode == 'radio' and not antispam[source] then
-- 		antispam[source] = true
-- 		TriggerClientEvent("renzu_hud:SetVoiceData", source, 'radio', prox)
-- 		Wait(10)
-- 		antispam[source] = false
-- 	end
-- end)

function PlayerIdentifier(source)
	local source = source
	local license = nil
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, config.identifier) then
			license = v
			break
		end
	end
	if config.multichar and config.multichar_advanced then
		license = string.gsub(license, string.gsub(config.identifier,":",""), ""..config.charprefix..""..charslot[source].."")
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
	local xPlayer = Standalone(source, PlayerIdentifier(source), GetPlayerName(source), charslot[source] or 1)
	Renzu[tonumber(source)] = xPlayer
end

function GetPlayerFromId(source)
	if config.framework == 'ESX' then
		return ESX.GetPlayerFromId(tonumber(source))
	elseif config.framework == 'QBCORE' then
		selfcore = {}
		selfcore.data = QBCore.Functions.GetPlayer(tonumber(source))
		if selfcore.data.identifier == nil then
			selfcore.data.identifier = selfcore.data.PlayerData.citizenid
		end
		if selfcore.data.job == nil then
			selfcore.data.job = selfcore.data.PlayerData.job
		end

		selfcore.data.getMoney = function(value)
			return selfcore.data.PlayerData.money['cash']
		end
		selfcore.data.removeMoney = function(value)
				QBCore.Functions.GetPlayer(tonumber(tonumber(source))).Functions.RemoveMoney('cash',tonumber(value))
			return true
		end
		-- we only do wrapper or shortcuts for what we used here.
		-- a lot of qbcore functions and variables need to port , its possible to port all, but we only port what this script needs.
		return selfcore.data
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
	local bodystatus = bodytable[PlayerIdentifier(source)]
	UpdateBodySql(bodystatus,PlayerIdentifier(source))
	if Renzu[tonumber(source)] then
		Renzu[tonumber(source)] = nil
	end
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
			foundRow = SQLQuery(config.Mysql,'fetchAll',"SELECT * FROM items WHERE name = @name", {
				['@name'] = "engine_"..enginename..""
			})
			if foundRow[1] == nil then
				local weight = 'limit'
				if config.weight_type then
					SQLQuery(config.Mysql,'execute',"INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)", {
						['@name'] = "engine_"..enginename.."",
						['@label'] = ""..firstToUpper(enginename).." Engine",
						['@weight'] = config.weight
					})
					print("Inserting "..enginename.."")
				else
					SQLQuery(config.Mysql,'execute',"INSERT INTO items (name, label) VALUES (@name, @label)", {
						['@name'] = "engine_"..enginename.."",
						['@label'] = ""..firstToUpper(enginename).." Engine",
					})
					print("Inserting "..enginename.."")
				end
			else
				break -- assume its already all registered
			end
		end
		while ESX == nil do Wait(10) end
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
				if havePermission(PlayerIdentifier(source)) then
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
	FetchVehicles()
	results = SQLQuery(config.Mysql,'fetchAll',"SELECT stats,plate FROM vehicle_status WHERE TRIM(UPPER(plate))=@plate", {['@plate'] = string.gsub(plate:upper(), '^%s*(.-)%s*$', '%1')})
	if #results > 0 then
		foundplate = true
		SQLQuery(config.Mysql,'execute',"UPDATE vehicle_status SET stats = @status WHERE UPPER(plate) = @plate", {
			['@status'] = json.encode(adv_table[tostring(plate)]),
			['@plate'] = plate:upper()
		})
	end
	SyncStat(adv_table)
	Wait(100)
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