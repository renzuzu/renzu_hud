maxgear = 5
local enginerunning = false
local handbrake = false
local carspeed = 0
local acceleration = nil
local mycurrentvehicle = nil
RenzuCommand('getstat', function()
    finaldrive = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
    flywheel = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
    max = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
    t = GetVehStats(vehicle, "CHandlingData","fTractionCurveMin")
    t2 = GetVehStats(vehicle, "CHandlingData","fTractionCurveLateral")
    print(finaldrive,flywheel,max,t,t2)
    print(GetVehicleAcceleration(vehicle))
    print(GetVehicleModelAcceleration(GetEntityModel(vehicle)))
    print(DecorGetFloat(vehicle, "DRIVEFORCE"))
    print(GetVehicleMod(vehicle,13))
    -- SetVehStats(vehicle, "CHandlingData", "fDriveInertia", olddriveinertia)
    -- SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", oldriveforce * 2.5)
    -- SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed)
end)

function startmanual(entity)
    Citizen.Wait(1000)
    Creation(function()
        if entity ~= nil then
            vehicle = entity
        end
        maxgear = DecorGetFloat(vehicle,"MAXGEAR")
        vehicletopspeed = DecorGetFloat(vehicle,"TOPSPEED")
        print(maxgear)
        savegear = GetGear(vehicle)
        while not manual do -- ASYNC WAITING FOR MANUAL BOOL = TRUE
            Renzuzu.Wait(0)
        end
        Renzuzu.Wait(1000) -- 1 sec wait avoid bug
        Nuimanualtranny()
        NuiClutchloop()
        NuiManualEtcFunc()
        NuiMainmanualLoop()
        print("MANUAL TRUE")
        DecorSetBool(vehicle, "MANUAL", true)
        print(DecorGetBool(vehicle, "MANUAL"))
    end)
    if not manual and manualstatus then
        manual = true
    end
end

RenzuNetEvent('renzu_hud:manual')
RenzuEventHandler('renzu_hud:manual', function(bool)
    plate = string.gsub(GetVehicleNumberPlateText(getveh()), "%s+", "")
	plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if DecorExistOn(getveh(), "MANUAL") then
		DecorRemove(getveh(), "MANUAL")
	end
    if not bool then
	    local topspeed = GetVehStats(getveh(), "CHandlingData", "fInitialDriveMaxFlatVel") * 1.3
	    LockSpeed(getveh(),topspeed / 3.6)
	    ForceVehicleGear(getveh(), 1)
	    SetVehicleHandbrake(getveh(),bool)
        RenzuSendUI({
            type = "setManual",
            content = bool
        })
        DecorSetBool(getveh(), "MANUAL", bool)
        newmanual = bool
        veh_stats[plate].manual = false
    elseif bool then
        if not veh_stats[plate].manual then
            veh_stats[plate].manual = true
            DecorSetBool(getveh(), "MANUAL", bool)
            TriggerServerEvent('renzu_hud:savedata', plate, veh_stats[tostring(plate)])
        end
        startmanual(getveh())
	end
    manual = bool
    manualstatus = bool
end)

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
        DecorSetBool(vehicle, "MANUAL", false)
        newmanual = false
    elseif not manual then
        startmanual()
	end
    manual = not manual
    manualstatus = not manualstatus
end)

--NUI MANUAL TRANSMISSION
function Nuimanualtranny()
    local newgear = nil
    Creation(function()
        Renzuzu.Wait(500)
        while manual and invehicle do
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
local clutchpressed = false
-- CLUTCH LOOP 1000ms when pressed
function NuiClutchloop()
    Creation(function()
        while manual and invehicle do
            local stepclutch = 0
            local sleep = 2000
            clutch = false
            --if manual else sleep
            if manual and vehicle ~= nil and invehicle then
                sleep = 5
                --savegear = GetGear(vehicle)
                --if RCR(0, 20) or RCP(0, 20) or RCP(0, 20) and RCP(0, 32) or RCR(2, 193) or RCP(2, 193) then
                    --clutchpressed = true
                    -- while RCP(1, 20) and stepclutch < 10 and not RCR(1, 20) do
                    --     clutchpressed = true
                    --     Citizen.Wait(0)
                    --     stepclutch = stepclutch + 1.05
                    --     if stepclutch > 1 then
                    --         stepclutch = 1.0
                    --     end
                    --     --Renzu_SetGear(vehicle,0)
                    --     SetVehicleClutch(vehicle, stepclutch * 0.1)
                    -- end
                    while RCP(1, 20) do -- if still pressed
                        clutchpressed = true
                        Citizen.Wait(0)
                        --LockSpeed(vehicle,speed)
                        SetVehicleClutch(vehicle, 1.0)
                        clutch = true
                        sleep = 1000
                    end
                    clutchpressed = false
                    --clutch = true
                --end
            end
            Renzuzu.Wait(sleep)
        end
        RenzuSendUI({
            type = "setManual",
            content = false
        })
        manual = false
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

function trannyupgradegear()
    if GetVehicleMod(vehicle,13) > 0 and maxgear < 6 then
        maxgear = maxgear + 1
    end
    return maxgear
end

function trannyupgradespeed()
    if GetVehicleMod(vehicle,13) > 0 then
        if mode == 'SPORTS' then
            local bonus = (DecorGetFloat(vehicle,"TOPSPEED") * config.topspeed_multiplier)
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", bonus * 1.5)
            print("BONUS")
        else
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(vehicle,"TOPSPEED") * 1.5)
        end
        SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE") * 1.5)
        vehicletopspeed = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
    end
    return vehicletopspeed
end

function NuiManualEtcFunc()
    Creation(function()
        while manual and invehicle do
            local sleep = 1500
            if vehicle ~= nil and vehicle ~= 0 then
                enginerunning = GetIsVehicleEngineRunning(vehicle)
                handbrake = GetVehicleHandbrake(vehicle)
                carspeed = VehicleSpeed(vehicle) * 3.6
                acceleration = DecorGetFloat(vehicle,"DRIVEFORCE")
                vehicletopspeed = trannyupgradespeed('speed')
                maxgear = trannyupgradegear('gear')
            end
            Renzuzu.Wait(sleep)
        end
    end)
end

function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('notishit2', msg)
    DisplayHelpTextThisFrame('notishit2', true)
end

local notraction = false
function NuiMainmanualLoop() -- Dont edit unless you know the system how it works.
    Creation(function()
        while manual and invehicle do
            --allow manual only if manual is true and if riding in vehicle
            if vehicle ~= nil and vehicle ~= 0 and manual then
                local reving = false
                --SetVehicleHighGear(vehicle,currentgear)

                --anti gear desync
                if clutchpressed then
                    Renzu_SetGear(vehicle,0)
                else
                    Renzu_SetGear(vehicle,savegear)
                end
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
                    --ClearVehicleTasks(vehicle)
                    if reverse then
                        savegear = 0
                        reverse = false
                        Renzu_SetGear(vehicle,0)
                        --ShowHelpNotification("Neutral", true, 1, 5)
                    else
                        if maxgear >= (savegear + 1) then
                            --SetVehicleReduceGrip(vehicle,false)
                            savegear = savegear + 1
                            Renzu_SetGear(vehicle,savegear + 1)
                            --ShowHelpNotification(savegear, true, 1, 5)
                        end
                    end
                    --ClearVehicleTasks(vehicle)
                    Renzuzu.Wait(100)
                end

                --down shifting with or power shifting mode
                if RCR(1, 173) and savegear > 0 and clutch or RCP(1, 32) and RCR(1, 173) and savegear > 0 and clutch and RCR(1, 20) then
                    savegear = savegear - 1
                    Renzu_SetGear(vehicle,savegear - 1)
                    if savegear == 0 then
                        --ShowHelpNotification('NEUTRAL', true, 1, 5)
                    else
                        --ShowHelpNotification(savegear, true, 1, 5)
                    end
                    --ClearVehicleTasks(vehicle)
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
                    --ShowHelpNotification('REVERSE', true, 1, 5)
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
                --SetVehicleHighGear(vehicle, savegear)
                if clutchpressed then
                    Citizen.InvokeNative(0x8923dd42, vehicle, 0)
                    Renzu_Hud(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, 0)
                    Renzu_Hud(GetHashKey('SET_VEHICLE_NEXT_GEAR') & 0xFFFFFFFF, vehicle, 0)
                else
                    Citizen.InvokeNative(0x8923dd42, vehicle, savegear)
                    Renzu_Hud(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                    Renzu_Hud(GetHashKey('SET_VEHICLE_NEXT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                end
                --SetVehicleHighGear(vehicle, savegear)
                --speedtable(speed,savegear)
                if savegear == 1 and speed < 25 and rpm > 0.8 and rpm < 1.1 and (VehicleRpm(vehicle) * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 95.0) and not clutchpressed then
                    while not RCP(1, 172) and speed > 2 and RCP(1, 32) and rpm < 1.19 and (VehicleRpm(vehicle) * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 95.0) and speed < 25 do
                        SetRpm(vehicle, speedtable(speed,savegear))
                        --SetVehicleReduceGrip(vehicle,true)
                        SetRpm(vehicle, rpm + 0.1)
                        if veh_stats[plate].tirespec ~= nil then
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", veh_stats[plate].tirespec['fTractionCurveMin'] * 0.5)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", veh_stats[plate].tirespec['fTractionCurveLateral'] * 0.5)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] * 1.9)
                        else
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * 0.5)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * 0.5)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * 1.9)
                        end
                        notraction = true
                        Wait(0)
                    end
                end
                if not RCP(1, 22) and speed > 5 then
                    if rpm >=0.2 and rpm <= 1.1 then
                        --SetRpm(vehicle, 1.0)
                        --else
                        --speedtable(speed,savegear)
                        if (VehicleRpm(vehicle) * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 85.0) and not clutchpressed then
                            SetRpm(vehicle, speedtable(speed,savegear))
                            if notraction then
                                --SetVehicleBurnout(vehicle, false)
                                --SetVehicleReduceGrip(vehicle,false)
                                if veh_stats[plate].tirespec ~= nil then
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", veh_stats[plate].tirespec['fTractionCurveMin'] * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", veh_stats[plate].tirespec['fTractionCurveLateral'] * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] * 1.0)
                                else
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", DecorGetFloat(vehicle,"TRACTION") * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", DecorGetFloat(vehicle,"TRACTION2") * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", DecorGetFloat(vehicle,"TRACTION3") * 1.0)
                                end
                                notraction = false
                            end
                        elseif rpm > 0.5 then
                            local numwheel = GetVehicleNumberOfWheels(vehicle)
                            sleep = 300
                            -- for i = 0, numwheel - 1 do
                            --     SetVehicleWheelRotationSpeed(vehicle,i,speed*1.45)
                            -- end
                            --Notify('warning','TRACTION',"TCS Active")
                            local r = 1.1
                            if r > 1.1 then
                                r = 1.1
                            end
                            if clutchpressed and RCP(1, 32) and rpm < 1.0 then
                                SetRpm(vehicle, r)
                            elseif not clutchpressed then
                                SetRpm(vehicle, r)
                            end
                            --SetVehicleBurnout(vehicle, true)
                            SetVehicleWheelieState(vehicle, 65)
                            --Wait(1)
                            SetLaunchControlEnabled(true)
                            SetVehicleWheelieState(vehicle, 129)
                            --LockSpeed(vehicle,oldspeed)
                            --Wait(11)
                            SetVehicleWheelieState(vehicle, 65)
                            --Wait(11)
                            SetVehicleWheelieState(vehicle, 0)
                            --SetVehicleBurnout(vehicle, false)
                            if not clutchpressed then
                                SetRpm(vehicle, speedtable(speed,savegear))
                            end
                            SetRpm(vehicle, r)
                            --SetRpm(vehicle, 1.2)
                        end
                        if RCP(1, 32) and speed < 25 and rpm > 0.1 and GetVehicleThrottleOffset(vehicle) > 0.7 then
                            --SetVehicleBurnout(vehicle, true)
                            --SetVehicleReduceGrip(vehicle,true)
                            --SetVehicleWheelieState(vehicle, 65)
                            --Wait(22)
                            SetVehicleCurrentRpm(vehicle, 1.0)
                            --SetVehicleReduceGrip(vehicle,false)
                            --SetVehicleBurnout(vehicle, false)
                            --SetVehicleWheelieState(vehicle, 65)
                            --Wait(22)
                            --SetVehicleReduceGrip(vehicle,true)
                            --SetVehicleBurnout(vehicle, true)
                            --Wait(22)
                            --SetVehicleReduceGrip(vehicle,true)
                            SetLaunchControlEnabled(true)
                            --SetVehicleBurnout(vehicle, false)
                            SetVehicleWheelieState(vehicle, 129)
                            --LockSpeed(vehicle,speed)
                            --Wait(11)
                            SetVehicleWheelieState(vehicle, 65)
                            --Wait(11)
                            SetVehicleWheelieState(vehicle, 0)
                            --SetVehicleReduceGrip(vehicle,false)
                            --SetVehicleBurnout(vehicle, false)
                        end
                    end
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
        manual = false
        newmanual = nil
        if vehicle == 0 then
            vehicle = getveh()
        end
        if DecorGetFloat(vehicle,"INERTIA") ~= 0.0 and DecorGetFloat(vehicle,"DRIVEFORCE") ~= 0.0 then
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", DecorGetFloat(vehicle,"TOPSPEED"))
            SetVehStats(vehicle, "CHandlingData", "fDriveInertia", DecorGetFloat(vehicle,"INERTIA"))
            SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE"))
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

function gearspeed(sg, wheel)
    if wheel then
        if GetVehicleMod(vehicle,13) > 0 then
            if mode == 'SPORTS' then
                local bonus = (DecorGetFloat(vehicle,"TOPSPEED") * config.topspeed_multiplier)
                vehicletopspeed = bonus * 1.5
            else
                vehicletopspeed = DecorGetFloat(vehicle,"TOPSPEED") * 1.5
            end
        else
            vehicletopspeed = DecorGetFloat(vehicle,"TOPSPEED")
        end
    end
	-- local first = (vehicletopspeed * 0.33) * 0.9
	-- local second = (vehicletopspeed * 0.57) * 0.9
	-- local third = (vehicletopspeed * 0.84) * 0.9
	-- local fourth = (vehicletopspeed * 1.22) * 0.9
	-- local fifth = (vehicletopspeed * 1.45) * 0.9
	-- local sixth = (vehicletopspeed * 1.60) * 0.9
    first = (vehicletopspeed * config.gears[maxgear][1]) * 0.9
    second = (vehicletopspeed * config.gears[maxgear][2]) * 0.9
    third = (vehicletopspeed * config.gears[maxgear][3]) * 0.9
    fourth = (vehicletopspeed * config.gears[maxgear][4]) * 0.9
    fifth = (vehicletopspeed * config.gears[maxgear][5]) * 0.9
    sixth = (vehicletopspeed * config.gears[maxgear][6]) * 0.9

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

function tractioncontrol(s,sg,wheel)
	local vehicle_speed = s
	local needle = vehicle_speed / gearspeed(sg,wheel)
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
first,second,third,fourth,fifth,sixth = 1, 1, 1, 1, 1, 1
local gearlimit = {
    [1] = first,
    [2] = second,
    [3] = third,
    [4] = fourth,
    [5] = fifth,
    [6] = sixth
}
local gearup = false
local drivechange = false
function antistall(speed, speedreduce, savegear, gearname, rpm, vehicle, currentgear, saferpm, driveforce, engineload, lastgear)
    --print(acceleration)
    if drivechange then
        SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", acceleration)
        drivechange = false
    end
    if speed - (speedreduce * driveforce) <= (gearname - speedreduce) then
        gearup = currentgear
        Renzu_SetGear(vehicle,currentgear - 1)
        local startkick = gearname - (lastgear / 1.5)
        if RCP(1, 32) and speed > startkick and speed <= gearname then
            if not alreadyturbo then
                SetVehicleBoost(vehicle, 1.0)
            end
            -- Wait(1)
            -- SetDisableVehicleUnk(vehicle,true)
            -- SetDisableVehicleUnk_2(vehicle,true)
            -- SetVehicleHasStrongAxles(vehicle,true)
            -- N_0x0a436b8643716d14()
            -- N_0x4419966c9936071a(vehicle)
            drivechange = true
            SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", acceleration * 1.5)
            local invertrpm = 1.0 - rpm
            local mg = maxgear
            if mg > 6 then
                mg = 6
            end
            local invertgear = mg - savegear
            engineload = driveforce + ((invertrpm * saferpm) * (savegear / driveforce))
            if mode == 'SPORTS' then
                SetVehicleClutch(vehicle,0.8)
                Wait(10)
                print("ANTI STALL")
                --SetVehicleReduceGrip(vehicle,true)
                -- torque = GetVehicleCheatPowerIncrease(vehicle) * topspeedmodifier
                -- SetVehicleBoost(vehicle, boost * maxgear + (torque / currentgear))
                ModifyVehicleTopSpeed(vehicle, 0.5)
                torque = GetVehicleCheatPowerIncrease(vehicle)
                torque = torque * ( savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                -- print(engineload / (maxgear - (maxgear-savegear)) * formulafuck * saferpm)
                local finalboost = boost + (engineload / (mg - (mg-savegear)) * (invertrpm + saferpm)) / mg * savegear + engineload
                if not alreadyturbo then
                    SetVehicleBoost(vehicle, finalboost)
                end
            else
                SetVehicleClutch(vehicle,0.9)
                print("ANTI STALL")
                --SetVehicleReduceGrip(vehicle,true)
                SetVehicleReduceTraction(vehicle, true)
                ModifyVehicleTopSpeed(vehicle, 0.5)
                torque = GetVehicleCheatPowerIncrease(vehicle)
                torque = torque * ( savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                -- print(engineload / (maxgear - (maxgear-savegear)) * formulafuck * saferpm)
                local finalboost = (engineload / (mg - (mg-savegear)) * (invertrpm + saferpm)) / mg * savegear + engineload
                if not alreadyturbo then
                    SetVehicleBoost(vehicle, finalboost)
                end
            end
        end
    end
end

-- MAIN MANUAL SYSTEM LOOP ( EDIT THIS if you know the system )
local currentlimit = 100
function speedtable(speed,gear)
    --SetVehicleReduceTraction(vehicle, true)
    if clutchpressed then return end
    olddriveinertia = DecorGetFloat(vehicle,"INERTIA")
    oldriveforce = DecorGetFloat(vehicle,"DRIVEFORCE")
    oldtopspeed = maxspeed * olddriveinertia -- normalize
    local engineload = oldriveforce + ((rpm * olddriveinertia) * (gear / oldriveforce))
    local speedreduce = (oldtopspeed) * (config.gears[maxgear][gear] * olddriveinertia) / gear * oldriveforce * engineload
    local mg = maxgear
    if mg > 6 then
        mg = 6
    end
    speedreduce = (speedreduce / mg) * oldriveforce + (gear / rpm) / mg
    --SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 250*1.000000)
    --local drive = GetVehStats(vehicle, "CHandlingData", "fDriveInertia")
    --local force = GetVehStats(vehicle ,"CHandlingData", "fInitialDriveForce")
    if mode == 'SPORTS' and globaltopspeed ~= nil then
        vehicletopspeed = globaltopspeed
    end
	if vehicletopspeed ~= nil then
        local initial_speed = (vehicletopspeed * 1.3) / 3.6
        --ShowHelpNotification((vehicletopspeed * config.secondgear) * 0.9, true, 1, 5)
		--local vehicletopspeed = GetVehStats(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel")
		first = (vehicletopspeed * config.gears[maxgear][1]) * 0.9
		second = (vehicletopspeed * config.gears[maxgear][2]) * 0.9
		third = (vehicletopspeed * config.gears[maxgear][3]) * 0.9
		fourth = (vehicletopspeed * config.gears[maxgear][4]) * 0.9
		fifth = (vehicletopspeed * config.gears[maxgear][5]) * 0.9
		sixth = (vehicletopspeed * config.gears[maxgear][6]) * 0.9
        if maxgear > 6 then
        seventh = (vehicletopspeed * config.gears[maxgear][7]) * 0.9
        eight = (vehicletopspeed * config.gears[maxgear][8]) * 0.9
        end
		local currentgear = savegear
        -- print("loopspeed")
        -- print(currentgear == 1 and speed <= first)
        -- print(currentgear)
        -- print(first)
        -- print(speed)
        -- print(currentlimit)
        SetEntityMaxSpeed(vehicle,currentlimit / 3.6)
		if currentgear == 1 and speed <= first then
            currentlimit = first
            if mycurrentvehicle ~= vehicle and maxgear == 6 then -- anti 1st gear glitch for upgraded trannys
                SetVehicleReduceTraction(vehicle, true)
                ModifyVehicleTopSpeed(vehicle, 0.5)
            end
            --SetEntityMaxSpeed(getveh(),first)
		    LockSpeed(vehicle, first / 3.6)
            return	percentage(speed,first)
		elseif currentgear == 2 and speed <= second then
            currentlimit = second
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, first, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, first)
		    LockSpeed(vehicle, second / 3.6)
		    return	percentage(speed,second)
		elseif currentgear == 3 and speed <= third then
            currentlimit = third
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, second, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, second)
		    LockSpeed(vehicle, third / 3.6)
		    return	percentage(speed,third)
		elseif currentgear == 4 and speed <= fourth then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, third, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, third)
		    LockSpeed(vehicle, fourth / 3.6)
		    return	percentage(speed,fourth)
		elseif currentgear == 5 and speed <= fifth then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, fourth, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, fourth)
		    LockSpeed(vehicle, fifth / 3.6)
		    return	percentage(speed,fifth)
		elseif currentgear == 6 and speed <= sixth then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, fifth, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, fifth)
            LockSpeed(vehicle, sixth / 3.6)
		    return	percentage(speed,sixth)
        elseif currentgear == 7 and speed <= seventh then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, sixth, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, sixth)
            LockSpeed(vehicle, sixth)
		    return	percentage(speed,sixth / 3.6)
        elseif currentgear == 8 and speed <= eight then
            saferpm = olddriveinertia
            antistall(speed, speedreduce, savegear, seventh, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, seventh)
            LockSpeed(vehicle, sixth / 3.6)
		    return	percentage(speed,sixth)
		elseif currentgear > 0 then
			return 1.1
		else
			return 0.2
		end

	end
end

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