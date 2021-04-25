maxgear = 5
RenzuCommand('manual', function()
	if manual then
	    local topspeed = GetVehStats(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel") * 1.3
	    LockSpeed(vehicle,topspeed / 3.6)
	    ForceVehicleGear(vehicle, 1)
	    SetVehicleHandbrake(vehicle,false)
        RenzuSendUI({
            type = "setManual",
            content = false
        })
    elseif not manual then
        Creation(function()
            maxgear = GetVehStats(vehicle, "CHandlingData","nInitialDriveGears")
            vehicletopspeed = GetVehStats(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
            while not manual do -- ASYNC WAITING FOR MANUAL BOOL = TRUE
                Renzuzu.Wait(0)
            end
            Renzuzu.Wait(1000) -- 1 sec wait avoid bug
            Nuimanualtranny()
            NuiClutchloop()
            NuiManualEtcFunc()
            NuiMainmanualLoop()
            print("MANUAL TRUE")
        end)
	end
    manual = not manual
end)

--NUI MANUAL TRANSMISSION
function Nuimanualtranny()
    local newgear = nil
    Creation(function()
        Renzuzu.Wait(500)
        while manual do
            local sleep = 1500
            local ped = ped
            local vehicle = vehicle
            if vehicle ~= nil and vehicle ~= 0 then
                sleep = 300
                if newmanual ~= manual or newmanual == nil then
                    --vehicletopspeed = GetVehStats(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
                    newmanual = manual
                    RenzuSendUI({
                    type = "setManual",
                    content = manual
                    })
                end
                --print(savegear)
                if newgear ~= savegear or newgear == nil then
                    RenzuSendUI({
                    type = "setShift",
                    content = savegear
                    })
                    newgear = savegear
                end
            end
            Renzuzu.Wait(sleep)
        end
    end)
end

local clutch = false
-- CLUTCH LOOP 1000ms when pressed
function NuiClutchloop()
    Creation(function()
        while manual do
            local sleep = 2000
            clutch = false
            --if manual else sleep
            if manual and vehicle ~= nil then
                sleep = 6
                --savegear = GetGear(vehicle)
                if RCR(2, 193) and manual or RCP(2, 193) or RCR(1, 20) and manual or RCP(1, 20) and manual or RCP(1, 20) and RCP(1, 32) and manual then
                    clutch = true
                    sleep = 1000
                end
            end
            Renzuzu.Wait(sleep)
        end
    end)
end

--DISABLE FOR NOW H-SHIFTER LOGITECH KEYBINDS (ACTIVATE THIS IF YOU KNOW WHAT YOU ARE DOING - You need to config the logitech game profiler to use this keybinds)
-- Creation(function()
-- 	while true do
-- 		local sleep = 2000
-- 		if shifter then
-- 			sleep = 6
-- 			if not RCP(0, 162) and not RCP(0, 110) and not RCP(0, 163) and not RCP(0, 117) and not RCP(0, 111) and not RCP(0, 118) and shifter then
-- 				Renzuzu.Wait(2000)
-- 				if not RCP(0, 162) and not RCP(0, 110) and not RCP(0, 163) and not RCP(0, 117) and not RCP(0, 111) and not RCP(0, 118) and shifter then
-- 				savegear = 0
-- 				Renzu_SetGear(vehicle,0)
-- 				end
-- 			end
-- 		end
-- 		Renzuzu.Wait(sleep)
-- 	end
-- end)

local enginerunning = false
local handbrake = false
local carspeed = 0
function NuiManualEtcFunc()
    Creation(function()
        while manual do
            local sleep = 1500
            if vehicle ~= nil and vehicle ~= 0 then
            enginerunning = GetIsVehicleEngineRunning(vehicle)
            handbrake = GetVehicleHandbrake(vehicle)
            carspeed = VehicleSpeed(vehicle) * 3.6
            end
            Renzuzu.Wait(sleep)
        end
    end)
end

function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('notishit', msg)
    print(msg)
    DisplayHelpTextThisFrame('notishit', false)

end

function NuiMainmanualLoop() -- Dont edit unless you know the system how it works.
    Creation(function()
        while manual do
            --allow manual only if manual is true and if riding in vehicle
            if vehicle ~= nil and vehicle ~= 0 and manual then
                local reving = false
                --SetVehicleHighGear(vehicle,currentgear)

                --anti gear desync
                Renzu_SetGear(vehicle,savegear)
                --loop gear
                local currentgear = savegear
                currentgear = currentgear

                --speed loop
                local speed = VehicleSpeed(vehicle) * 3.6

                --simulate manual -- if rpm is lessthan 2000 rpm and gear is > 0 turn off the engine
                if rpm < 0.2 and speed < 5 and savegear > 0 then
                    SetVehicleEngineOn(vehicle,false,false,false)
                end

                if not enginerunning and RCP(1, 32) then
                    SetVehicleEngineOn(vehicle,true,false,false)
                    savegear = 0
                end

                --up shifting with or power shifting mode (while clutch is pressed)
                if RCR(1, 172) and clutch or RCP(1, 32) and RCR(1, 172) and clutch and RCR(1, 20) or RCP(1, 32) and RCR(1, 172) and clutch and RCR(2, 193) then
                    ClearVehicleTasks(vehicle)
                    if reverse then
                        savegear = 0
                        reverse = false
                        Renzu_SetGear(vehicle,0)
                        ShowHelpNotification("Neutral", true, 1, 5)
                    else
                        if maxgear >= (savegear + 1) then
                            savegear = savegear + 1
                            Renzu_SetGear(vehicle,savegear + 1)
                            ShowHelpNotification(savegear, true, 1, 5)
                        end
                    end
                    ClearVehicleTasks(vehicle)
                    Renzuzu.Wait(100)
                end

                --down shifting with or power shifting mode
                if RCR(1, 173) and savegear > 0 and clutch or RCP(1, 32) and RCR(1, 173) and savegear > 0 and clutch and RCR(1, 20) then
                    savegear = savegear - 1
                    Renzu_SetGear(vehicle,savegear - 1)
                    if savegear == 0 then
                        ShowHelpNotification('NEUTRAL', true, 1, 5)
                    else
                        ShowHelpNotification(savegear, true, 1, 5)
                    end
                    ClearVehicleTasks(vehicle)
                    Renzuzu.Wait(100)
                end

                --clutch mode with force handbrake if less than 10 kmh
                if RCP(1, 20) or RCP(2, 193) then
                    --ForceVehicleGear(vehicle, 0)
                    if speed < 10 then
                        ForceVehicleGear(vehicle, 0)
                        SetVehicleHandbrake(vehicle,true)
                    end
                end

                if savegear == 0 and RCP(1, 20) and RCR(1, 173) or savegear == 0 and clutch and RCR(1, 173) then
                    ShowHelpNotification('REVERSE', true, 1, 5)
                    marcha = "R"
                    savegear = 0
                    reverse = true
                end
                --neutral mode with handbrake
                if savegear == 0 then
                    ForceVehicleGear(vehicle, 0)
                    SetVehicleHandbrake(vehicle,true)
                    --SetVehicleBrake(vehicle, true)
                end

                --if handbrake disable it when gear is >= 1
                if handbrake and not RCP(1, 20) and savegear > 0 and not clutch or RCP(1, 33) and reverse and not clutch then
                    --ForceVehicleGear(vehicle, 0)
                    if speed < 10 then
                        SetVehicleHandbrake(vehicle,false)
                    end
                end

                --main loop manual system
                Citizen.InvokeNative(0x8923dd42, vehicle, savegear)
                Renzu_Hud(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                Renzu_Hud(GetHashKey('SET_VEHICLE_NEXT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                --SetVehicleHighGear(vehicle, savegear)
                --speedtable(speed,savegear)
                if not RCP(1, 22) and speed > 5 then
                    if rpm >=0.3 and rpm <= 0.5 then
                    --SetRpm(vehicle, 1.0)
                    --else
                        --speedtable(speed,savegear)
                    --SetRpm(vehicle, speedtable(speed,savegear))
                    end
                    if rpm >=0.2 and rpm <= 1.1 then
                    --SetRpm(vehicle, 1.0)
                    --else
                        --speedtable(speed,savegear)
                        if (VehicleRpm(vehicle) * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 85.0) then
                            SetRpm(vehicle, speedtable(speed,savegear))
                        elseif rpm > 0.5 then
                            SetRpm(vehicle, rpm+0.1)
                            LockSpeed(vehicle,speed)
                            Wait(51)
                            SetRpm(vehicle, speedtable(speed,savegear))
                            SetRpm(vehicle, rpm)
                            --SetRpm(vehicle, 1.2)
                        end
                    end
                end
                -- local pedal = false
                -- if RCP(1, 32) then
                --     pedal = true
                -- end
                -- if not pedal then
                --     SetRpm(vehicle, speedtable(speed,savegear))
                -- end
                --Renzu_SetGear(vehicle,savegear)

                if speed < 35 then
                --SetVehicleEngineTorqueMultiplier(vehicle, 25.5)
                --SetLaunchControlEnabled(true)
                --SetVehicleReduceTraction(vehicle,true)

                -- if rpm < 0.3 and rpm > 0.5 and savegear == 1 then
                -- SetRpm(vehicle,0.8)
                -- end
                end
                if speed < 5 and savegear > 3 then
                    Renzu_SetGear(vehicle,1)
                end

                --neutral launch control
                if RCP(1, 20) and RCP(1, 32) and speed < 11 and rpm >= 0.5 and speed <= 5 or clutch and RCP(1, 32) and speed < 11 and rpm >= 0.5 and speed <= 5 then
                    SetRpm(vehicle,0.6)
                        Renzuzu.Wait(11)
                            SetRpm(vehicle,0.5)
                                 Renzuzu.Wait(11)	
                                    SetRpm(vehicle,1.2)
                                        Renzuzu.Wait(55)
                                            SetRpm(vehicle,0.7)
                                        Renzuzu.Wait(11)
                                    SetRpm(vehicle,1.4)
                                Renzuzu.Wait(11)
                            SetRpm(vehicle,0.7)
                        Renzuzu.Wait(55)
                        SetRpm(vehicle,0.8)
                    Renzuzu.Wait(55)
                end
                
                --DISABLE FOR NOW H-SHIFTER LOGITECH KEYBINDS (ACTIVATE THIS IF YOU KNOW WHAT YOU ARE DOING - You need to config the logitech game profiler to use this keybinds)
                -- if shifter then
                --     -- SHIFTER
                --     if RCP(0, 162) and clutch then
                --         savegear = 1
                --         Renzu_SetGear(vehicle,1)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if RCP(0, 110) and clutch then
                --         savegear = 2
                --         Renzu_SetGear(vehicle,2)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if RCP(0, 163) and clutch then
                --         savegear = 3
                --         Renzu_SetGear(vehicle,3)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if RCP(0, 117) and clutch then
                --         savegear = 4
                --         Renzu_SetGear(vehicle,4)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if RCP(0, 111) and clutch then
                --         savegear = 5
                --         Renzu_SetGear(vehicle,5)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end
                --     if RCP(0, 118) and clutch then
                --         savegear = 6
                --         Renzu_SetGear(vehicle,6)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end
                -- end
            else
                --sleep if not in vehicle and reset gears
                savegear = 0
                Renzuzu.Wait(1000)
            end
            Renzuzu.Wait(0)
        end
    end)
end

-- RPM FACTORING
function percentage(partialValue, totalValue)
    local needle = partialValue / totalValue
    if needle >= 1.0 then
        needle = 1.0
    end
    if needle <= 0.0 then
        needle = 0.0
    end
    return needle
end

function gearspeed(sg)

	local first = (vehicletopspeed * 0.33) * 0.9
	local second = (vehicletopspeed * 0.57) * 0.9
	local third = (vehicletopspeed * 0.84) * 0.9
	local fourth = (vehicletopspeed * 1.22) * 0.9
	local fifth = (vehicletopspeed * 1.45) * 0.9
	local sixth = (vehicletopspeed * 1.60) * 0.9

	if sg == 1 then
		return first
	elseif sg == 2 then
		return second
	elseif sg == 3 then
		return third
	elseif sg == 4 then
		return fourth
	elseif sg == 5 then
		return fifth
	elseif sg == 6 then
		return sixth
	else
		return 0.0
	end
end

function tractioncontrol(s,sg)
	local vehicle_speed = s
	local needle = vehicle_speed / gearspeed(sg)
	if needle > 1.0 then
		needle = 1.0
	end
	return needle 
end

function DrawScreenText2D(x, y, message, dropShadow, outline)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.3)
    SetTextColour(180, 20, 20, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)

    if dropShadow then
        SetTextDropShadow()
    end

    if outline then
        SetTextOutline()
    end

    SetTextEntry("STRING")
    AddTextComponentString(message)
    DrawText(x, y)
end

local finaldrive = 4.44
local gear_ratio = {
    [0] = 0.0,
    [1] = 3.230,
    [2] = 2.105,
    [3] = 1.458,
    [4] = 1.107,
    [5] = 0.848,
    [6] = 0.678
}

local gearup = false
function antistall(speed, speedreduce, savegear, gearname, rpm, vehicle, currentgear, saferpm, driveforce)
    if speed - (speedreduce * driveforce) <= (gearname - speedreduce) then
        gearup = currentgear
        Renzu_SetGear(vehicle,currentgear - 1)
        if RCP(1, 32) then
            SetVehicleBoost(vehicle, 1.0)
            Wait(1)
            if mode == 'SPORTS' then
                SetVehicleClutch(vehicle,0.8)
                Wait(10)
                print("ANTI STALL")
                torque = GetVehicleCheatPowerIncrease(vehicle) * topspeedmodifier
                SetVehicleBoost(vehicle, boost * maxgear + (torque / currentgear))
            else
                SetVehicleClutch(vehicle,0.9)
                print("ANTI STALL")
                SetVehicleReduceTraction(vehicle, true)
                ModifyVehicleTopSpeed(vehicle, 0.5)
                torque = GetVehicleCheatPowerIncrease(vehicle)
                SetVehicleBoost(vehicle, (saferpm * maxgear) + (torque / currentgear))
            end
        end
    end
end

-- MAIN MANUAL SYSTEM LOOP ( EDIT THIS if you know the system )
function speedtable(speed,gear)
    olddriveinertia = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
    oldriveforce = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
    oldtopspeed = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel") * olddriveinertia -- normalize
    local engineload = oldriveforce + ((rpm * olddriveinertia) * (gear / oldriveforce))
    local speedreduce = (oldtopspeed) * (config.gears[gear] * olddriveinertia) / gear * oldriveforce * engineload
    speedreduce = (speedreduce / maxgear) * oldriveforce + (gear / rpm) / maxgear
    --ShowHelpNotification(percentage(20,60), true, 1, 5)
    --SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 250*1.000000)
    --local drive = GetVehStats(vehicle, "CHandlingData", "fDriveInertia")
    --local force = GetVehStats(vehicle ,"CHandlingData", "fInitialDriveForce")
    if mode == 'SPORTS' and globaltopspeed ~= nil then
        vehicletopspeed = globaltopspeed
    end
	if vehicletopspeed ~= nil then
		--local vehicletopspeed = GetVehStats(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel")
		local first = (vehicletopspeed * config.firstgear) * 0.9
		local second = (vehicletopspeed * config.secondgear) * 0.9
		local third = (vehicletopspeed * config.thirdgear) * 0.9
		local fourth = (vehicletopspeed * config.fourthgear) * 0.9
		local fifth = (vehicletopspeed * config.fifthgear) * 0.9
		local sixth = (vehicletopspeed * config.sixthgear) * 0.9
		local currentgear = savegear
		if currentgear == 1 and speed <= first then
		    LockSpeed(vehicle, first)
            return	percentage(speed,first)
		elseif currentgear == 2 and speed <= second then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, first, rpm, vehicle, currentgear, saferpm, oldriveforce)
		    LockSpeed(vehicle, second)
		    return	percentage(speed,second)
		elseif currentgear == 3 and speed <= third then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, second, rpm, vehicle, currentgear, saferpm, oldriveforce)
		    LockSpeed(vehicle, third)
		    return	percentage(speed,third)
		elseif currentgear == 4 and speed <= fourth then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, third, rpm, vehicle, currentgear, saferpm, oldriveforce)
		    LockSpeed(vehicle, fourth)
		    return	percentage(speed,fourth)
		elseif currentgear == 5 and speed <= fifth then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, fourth, rpm, vehicle, currentgear, saferpm, oldriveforce)
		    LockSpeed(vehicle, fifth)
		    return	percentage(speed,fifth)
		elseif currentgear == 6 and speed <= sixth then
		    --if speed <= (fifth - (fifth * 0.11525)) then
			Renzu_SetGear(vehicle,currentgear - 1)
		    --end
		    return	percentage(speed,sixth)
		elseif currentgear > 0 then
			return 1.1
		else
			return 0.2
		end

	end
end
-- function speedtable(speed,gear)
--     if savegear < 1 then return end
--     olddriveinertia = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
--     oldriveforce = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
--     oldtopspeed = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel") -- normalize
--     local real_ratio = oldtopspeed * olddriveinertia * oldriveforce / 4.2
--     --ShowHelpNotification(percentage(20,60), true, 1, 5)
--     --SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 250*1.000000)
--     --local drive = GetVehStats(vehicle, "CHandlingData", "fDriveInertia")
--     --local force = GetVehStats(vehicle ,"CHandlingData", "fInitialDriveForce")
-- 	if vehicletopspeed ~= nil then
-- 		--local vehicletopspeed = GetVehStats(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel")
-- 		local first = (vehicletopspeed * config.firstgear) * 0.9
-- 		local second = (vehicletopspeed * config.secondgear) * 0.9
-- 		local third = (vehicletopspeed * config.thirdgear) * 0.9
-- 		local fourth = (vehicletopspeed * config.fourthgear) * 0.9
-- 		local fifth = (vehicletopspeed * config.fifthgear) * 0.9
-- 		local sixth = (vehicletopspeed * config.sixthgear) * 0.9
--         local ratio = (vehicletopspeed / real_ratio) * olddriveinertia
--         engineload = (2.0 * (savegear / savegear))
--         local currentspeed = ratio / gear_ratio[savegear]
-- 		local currentgear = savegear
--         local shitspeed = currentspeed * 3.6
--         print(speed,shitspeed)
-- 		if currentgear == 1 and speed <= shitspeed then
--             SetEntityMaxSpeed(vehicle,currentspeed)
-- 		--LockSpeed(vehicle, speedPerGear)
-- 		return	percentage(speed,shitspeed)

-- 		elseif currentgear == 2 and speed <= shitspeed then
-- 		if speed <= (ratio / gear_ratio[savegear - 1] * 3.5) then
-- 			Renzu_SetGear(vehicle,currentgear - 1)
-- 		end
--         --LockSpeed(vehicle, second)
--         SetEntityMaxSpeed(vehicle,currentspeed)
-- 		return	percentage(speed,shitspeed)

-- 		elseif currentgear == 3 and speed <= shitspeed then
-- 		--if speed <= ratio / gear_ratio[currentgear] * 3.6 then
-- 			Renzu_SetGear(vehicle,currentgear - 1)
--             print(ratio / gear_ratio[currentgear] * 3.6)
-- 		--end
--         SetEntityMaxSpeed(vehicle,currentspeed)
--         --LockSpeed(vehicle, third)
--         return	percentage(speed,shitspeed)

-- 		elseif currentgear == 4 and speed <= shitspeed then
-- 		--if speed <= (ratio / gear_ratio[currentgear - 1] * 3.4) then
-- 			Renzu_SetGear(vehicle,currentgear - 1)
-- 		--end
-- 		LockSpeed(vehicle, currentspeed)

-- 		return	percentage(speed,shitspeed)

-- 		elseif currentgear == 5 and speed <= shitspeed then
-- 		--if speed <= (ratio / gear_ratio[currentgear - 1] * 3.7) then
-- 			Renzu_SetGear(vehicle,currentgear - 1)
-- 		--end
-- 		LockSpeed(vehicle, currentspeed)

-- 		return	percentage(speed,shitspeed)

-- 		elseif currentgear == 6 and speed <= sixth then
-- 		if speed <= (fifth - (fifth * 0.11525)) then
-- 			Renzu_SetGear(vehicle,currentgear - 1)
-- 		end
-- 		return	percentage(speed,sixth)
-- 		elseif currentgear > 0 then
-- 			return 1.4
-- 		else
-- 			return 0.2
-- 		end

-- 	end
-- end

-- FORCE GTA NATIVE TO STOP SWITCHING GEARS AUTOMATICALLY
function ForceVehicleGear (vehicle, gear)
    ----print(GetVehicleThrottleOffset(vehicle))
    SetVehicleCurrentGear(vehicle, gear)
    SetVehicleNextGear(vehicle, gear)
    --savegear = gear
    --SetVehicleHighGear(vehicle, gear)
    --SetVehicleHighGear(vehicle, gear)
    return gear
end