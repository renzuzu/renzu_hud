local enginerunning = false
local handbrake = false
local carspeed = 0
local acceleration = nil
local mycurrentvehicle = nil
local stalling = false
RenzuCommand('getstat', function()
    finaldrive = GetVehStats(vehicle, "CHandlingData","fDriveInertia")
    flywheel = GetVehStats(vehicle, "CHandlingData","fInitialDriveForce")
    max = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
    t = GetVehStats(vehicle, "CHandlingData","fTractionCurveMin")
    t2 = GetVehStats(vehicle, "CHandlingData","fTractionCurveLateral")
    mg = GetVehicleHandlingInt(vehicle, "CHandlingData","nInitialDriveGears")
    print(finaldrive,flywheel,max,t,t2,mg)
    print("GetVehicleAcceleration",GetVehicleAcceleration(vehicle))
    print("GetVehicleModelAcceleration",GetVehicleModelAcceleration(GetEntityModel(vehicle)))
    print("GetVehicleModelEstimatedMaxSpeed",GetVehicleModelEstimatedMaxSpeed(GetEntityModel(vehicle)) * 3.6)
    print("flatvel",(max))
    print("GetVehicleModelEstimatedAgility",GetVehicleModelEstimatedAgility(GetEntityModel(vehicle)) * 1.818)
    print(DecorGetFloat(vehicle, "DRIVEFORCE"))
    print(GetVehicleMod(vehicle,13))
    print(GetVehicleHighGear(vehicle))
    -- SetVehStats(vehicle, "CHandlingData", "fDriveInertia", olddriveinertia)
    -- SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", oldriveforce * 2.5)
    -- SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", oldtopspeed)
end)

RenzuCommand('handling', function(source, args, raw)
    SetEngineSpecs(GetHashKey(args[1]))
    -- for k,v in pairs(vehiclehandling['Item']) do
    --     --print(k)
    --     --print(v.handlingName)
    --     if v.handlingName == 'BLISTA' then
    --         print(GetHashKey(v.handlingName),GetHashKey("blista"))
    --         print(v.fDriveInertia['_value'])
    --     end
    -- end
end)

RenzuCommand('drivetocoord', function(source, args, raw)
    local waypoint = GetFirstBlipInfoId(8)
    if vehicle ~= 0 and DoesBlipExist(waypoint) then
        local x,y,z = table.unpack(GetBlipCoords(waypoint))
        print("driving",x,y,z,vehicle)
        TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), getveh(), x, y, z, 400.0, 787260, 10.0)
        -- SetVehicleHighGear(getveh(),2)
        -- SetVehicleMaxSpeed(getveh(),200.0)
        SetVehicleHandlingField(getveh(), "CHandlingData", "fDriveInertia", GetVehicleHandlingFloat(getveh(), "CHandlingData","fDriveInertia") * 4.5)
        SetVehicleHandlingField(getveh(), "CHandlingData", "fInitialDriveForce", GetVehicleHandlingFloat(getveh(), "CHandlingData","fInitialDriveForce") * 4.5)
        SetVehicleHandlingField(getveh(), "CHandlingData", "fInitialDriveMaxFlatVel", GetVehicleHandlingFloat(getveh(), "CHandlingData","fInitialDriveMaxFlatVel") * 4.0)
        SetVehicleHandlingFloat(getveh(), "CHandlingData", "fLowSpeedTractionLossMult", GetVehicleHandlingFloat(getveh(), "CHandlingData","fLowSpeedTractionLossMult") * 0.5) -- start burnout less = traction
        SetVehicleHandlingFloat(getveh(), "CHandlingData", "fTractionCurveMin", GetVehicleHandlingFloat(getveh(), "CHandlingData","fTractionCurveMin") * 1.5) -- accelaration grip
        Creation(function()
            while true do
                local autogear = GetGear(vehicle)
                if autogear > 0 then
                    -- Citizen.InvokeNative(0x8923dd42, vehicle, autogear)
                    -- Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, autogear)
                    -- Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, autogear)
                    --SetRpm(vehicle, speedtable(speed,autogear))
                    SetDriveTaskCruiseSpeed(PlayerPedId(),300.0)
                    SetDriveTaskMaxCruiseSpeed(true,300.0)
                    ModifyVehicleTopSpeed(vehicle,10.0)
                    print(GetVehicleThrottleOffset(vehicle))
                    if GetEntitySpeed(vehicle) * 3.6 > 155 then
                        SetEntityMaxSpeed(PlayerPedId(),300.0)
                        SetEntityMaxSpeed(vehicle,300.0)
                        SetPlaybackSpeed(vehicle,300.0)
                        SetRpm(vehicle, 1.0)
                    end
                end
                Wait(0)
            end
        end)
        Creation(function()
            local model = GetHashKey("gtr")
            --requestmodel(model)
            while true do
                --AddModelToCreatorBudget(model)
                for k,v in pairs(GetGamePool('CVehicle')) do
                    local xv,yv,zv = table.unpack(GetEntityCoords(v))
                    if v ~= vehicle then
                        SetEntityAlpha(v,151,false)
                        SetEntityCollision(v,true,true)
                        --CreateModelSwap(xv,yv,zv,50.0,GetEntityModel(v),model,true)
                        if #(GetEntityCoords(vehicle) - GetEntityCoords(v)) < 30 then
                            SetEntityNoCollisionEntity(vehicle,v,false)
                        else
                            SetControlNormal(0,31,1.0)
                            --TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), getveh(), x, y, z, 400.0, 787260, 10.0)
                        end
                    end
                end
                SetDriveTaskDrivingStyle(GetPlayerPed(-1), 787260)
                SetDriveTaskCruiseSpeed(GetPlayerPed(-1),400.0)
                SetDriverRacingModifier(GetPlayerPed(-1),1.0)
                SetDriverAbility(GetPlayerPed(-1), 1.0)        -- values between 0.0 and 1.0 are allowed.
                SetDriverAggressiveness(GetPlayerPed(-1), 1.0) -- values between 0.0 and 1.0 are allowed.
                SetDriveTaskMaxCruiseSpeed(GetPlayerPed(-1),400.0)
                SetPedKeepTask(GetPlayerPed(-1), true)
                --TaskVehicleTempAction(GetPlayerPed(-1),vehicle,32,10.0)
                --TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), getveh(), x, y, z, 400.0, 787260, 10.0)
                Wait(1)
            end
        end)

        Creation(function()
            while true do
                local currentzone = GetZoneAtCoords(GetEntityCoords(GetPlayerPed(-1)))
                local popzone = GetZonePopschedule(currentzone)
                local model = GetHashKey("gtr")
                requestmodel(model)
                AddModelToCreatorBudget(model)
                OverridePopscheduleVehicleModel(popzone,model)
                Wait(1000)
            end
        end)
    end
end)

-- Creation(function()
--     while true do
--         local currentzone = GetZoneAtCoords(GetEntityCoords(GetPlayerPed(-1)))
--         local popzone = GetZonePopschedule(currentzone)
--         local model = GetHashKey("gtr")
--         requestmodel(model)
--         AddModelToCreatorBudget(model)
--         OverridePopscheduleVehicleModel(popzone,model)
--         Wait(1000)
--     end
-- end)

function requestmodel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do 
		Renzuzu.Wait(1)
		RequestModel(model)
	end
end

function startmanual(entity)
    Citizen.Wait(1000)
    Creation(function()
        if entity ~= nil then
            vehicle = entity
        end
        maxgear = tonumber(GetHandling(GetPlate(vehicle)).maxgear)
        vehicletopspeed = GetHandling(GetPlate(vehicle)).maxspeed
        --print(maxgear)
        savegear = GetGear(vehicle)
        while not manual do -- ASYNC WAITING FOR MANUAL BOOL = TRUE
            Renzuzu.Wait(0)
        end
        Renzuzu.Wait(1000) -- 1 sec wait avoid bug
        Nuimanualtranny()
        NuiClutchloop()
        NuiManualEtcFunc()
        Wait(500)
        NuiMainmanualLoop()
        print("MANUAL TRUE")
        manualstatus = not manualstatus
        DecorSetBool(vehicle, "MANUAL", true)
        --print(DecorGetBool(vehicle, "MANUAL"))
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
	    local topspeed = GetHandling(GetPlate(vehicle)).maxspeed * 1.3
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
            manual = true
        end
        startmanual(getveh())
	end
    manual = bool
    manualstatus = bool
end)

RenzuCommand('manual', function()
	if manual then
	    local topspeed = GetHandling(GetPlate(vehicle)).maxspeed * 1.3
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
    --manualstatus = not manualstatus
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
                    RenzuSendUI({
						type = "setGear",
						content = savegear
					})
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
    local mg = tonumber(GetHandling(GetPlate(vehicle)).maxgear)
    if tonumber(GetVehicleMod(vehicle,13)) > 0 and tonumber(mg) < 6 then
        mg = mg + 1
    end
    return tonumber(mg)
end

function trannyupgradespeed()
    if tonumber(GetVehicleMod(vehicle,13)) > 0 then
        if mode == 'SPORTS' then
            local bonus = (GetHandling(GetPlate(vehicle)).maxspeed * config.topspeed_multiplier)
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", bonus * 1.5)
            --print("BONUS")
        else
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", GetHandling(GetPlate(vehicle)).maxspeed * 1.5)
        end
        --SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(vehicle,"DRIVEFORCE") * 1.5)
    end
    Wait(100)
    r = GetVehStats(vehicle, "CHandlingData","fInitialDriveMaxFlatVel") * 1.0
    return r
end

local highgear = 5
function NuiManualEtcFunc()
    Creation(function()
        while manual and invehicle do
            local sleep = 1500
            if vehicle ~= nil and vehicle ~= 0 then
                enginerunning = GetIsVehicleEngineRunning(vehicle)
                handbrake = GetVehicleHandbrake(vehicle)
                carspeed = VehicleSpeed(vehicle) * 3.6
                acceleration = GetHandling(GetPlate(vehicle)).flywheel
                vehicletopspeed = trannyupgradespeed('speed')
                maxgear = trannyupgradegear('gear')
                highgear = tonumber(GetVehicleHighGear(vehicle))
                olddriveinertia = tonumber(GetHandling(GetPlate(vehicle)).finaldrive)
                oldriveforce = tonumber(GetHandling(GetPlate(vehicle)).flywheel)
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
    -- Creation(function()
    --     while manual and invehicle do
    --         if clutchpressed then
    --             Citizen.InvokeNative(0x8923dd42, vehicle, 0)
    --             Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, 0)
    --             Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, 0)
    --         else
    --             Citizen.InvokeNative(0x8923dd42, vehicle, savegear)
    --             Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, savegear)
    --             Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, savegear)
    --         end
    --         Renzuzu.Wait(0)
    --     end
    -- end)

    Creation(function()
        while manual and invehicle do
            --allow manual only if manual is true and if riding in vehicle
            if vehicle ~= nil and vehicle ~= 0 and manual then
                local reving = false
                --SetVehicleHighGear(vehicle,currentgear)

                --anti gear desync
                if clutchpressed then
                    Renzu_SetGear(vehicle,0)
                    -- else
                    --     Renzu_SetGear(vehicle,savegear)
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
                if RCR(1, 172) and clutch then
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
                if RCR(1, 173) and savegear > 0 and clutch then
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
                if highgear ~= maxgear then
                    SetVehicleHighGear(vehicle,round(GetVehStats(vehicle, "CHandlingData","nInitialDriveGears")))
                    maxgear = tonumber(GetHandling(GetPlate(vehicle)).maxgear)
                end

                correctgears = GetGear(vehicle)
                --ShowHelpNotification(tostring(savegear,correctgears,round(maxgear)), true, 1, 5)
                --print(savegear,correctgears,round(maxgear))
                if tonumber(savegear) > 1 and tonumber(correctgears) <= tonumber(maxgear) then
                    local speedgearlimit = (vehicletopspeed * config.gears[maxgear][correctgears]) * 0.88
                    if correctgears < 1 then
                        correctgears = 1
                    end
                    if savegear <= 1 then
                        correctgears = 1
                    end
                    if speed > speedgearlimit then
                        correctgears = correctgears + 1
                    end
                    --ShowHelpNotification(tostring(round(correctgears)), true, 1, 5)
                else
                    correctgears = savegear
                end

                if clutchpressed then
                    Citizen.InvokeNative(0x8923dd42, vehicle, 0)
                    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, 0)
                    Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, 0)
                elseif speed > 2 then
                    Citizen.InvokeNative(0x8923dd42, vehicle, correctgears)
                    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, vehicle, correctgears)
                    Renzu_Hud(nextgearhash & 0xFFFFFFFF, vehicle, correctgears)
                end
                
                if RCP(1, 32) and savegear == 1 and speed < 25 and rpm > 0.8 and rpm < 1.1 and (rpm * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 95.0) and not clutchpressed then
                    while not RCP(1, 172) and speed > 2 and RCP(1, 32) and rpm < 1.19 and (rpm * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 95.0) and speed < 25 do
                        SetRpm(vehicle, speedtable(speed,savegear))
                        --SetVehicleReduceGrip(vehicle,true)
                        SetRpm(vehicle, rpm + 0.1)
                        if veh_stats[plate].tirespec ~= nil then
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", veh_stats[plate].tirespec['fTractionCurveMin'] * 0.7)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", veh_stats[plate].tirespec['fTractionCurveLateral'] * 0.7)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] * 1.7)
                        else
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", GetHandling(GetPlate(vehicle)).traction * 0.7)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", GetHandling(GetPlate(vehicle)).traction2 * 0.7)
                            SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", GetHandling(GetPlate(vehicle)).traction3 * 1.7)
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
                        if speed > 5 and (rpm * 100.0) > (tractioncontrol(WheelSpeed(vehicle,1) * 3.6,savegear) * 85.0) and not clutchpressed then
                            SetRpm(vehicle, speedtable(speed,savegear))
                            if notraction then
                                --SetVehicleBurnout(vehicle, false)
                                --SetVehicleReduceGrip(vehicle,false)
                                if veh_stats[plate].tirespec ~= nil then
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", veh_stats[plate].tirespec['fTractionCurveMin'] * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", veh_stats[plate].tirespec['fTractionCurveLateral'] * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", veh_stats[plate].tirespec['fLowSpeedTractionLossMult'] * 1.0)
                                else
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveMin", GetHandling(GetPlate(vehicle)).traction * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fTractionCurveLateral", GetHandling(GetPlate(vehicle)).traction2 * 1.0)
                                    SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", GetHandling(GetPlate(vehicle)).traction3 * 1.0)
                                end
                                notraction = false
                            end
                        elseif rpm > 0.5 then
                            --local numwheel = GetVehicleNumberOfWheels(vehicle)
                            sleep = 300
                            -- for i = 0, numwheel - 1 do
                            --     SetVehicleWheelRotationSpeed(vehicle,i,speed*1.45)
                            -- end
                            --Notify('warning','TRACTION',"TCS Active")
                            local r = rpm + (rpm * 0.05)
                            if r > 1.1 then
                                r = 1.1
                            end
                            if clutchpressed and RCP(1, 32) and rpm < 1.0 then
                                SetRpm(vehicle, r)
                            elseif not clutchpressed then
                                SetRpm(vehicle, r)
                            end
                            -- --SetVehicleBurnout(vehicle, true)
                            -- SetVehicleWheelieState(vehicle, 65)
                            -- --Wait(1)
                            -- --SetLaunchControlEnabled(true)
                            -- SetVehicleWheelieState(vehicle, 129)
                            -- --LockSpeed(vehicle,oldspeed)
                            -- --Wait(11)
                            -- SetVehicleWheelieState(vehicle, 65)
                            -- --Wait(11)
                            -- SetVehicleWheelieState(vehicle, 0)
                            -- --SetVehicleBurnout(vehicle, false)
                            if not clutchpressed and speed > 20 then
                                SetRpm(vehicle, speedtable(speed,savegear))
                            end
                            -- SetRpm(vehicle, r)
                            if speed < 20 then
                                SetRpm(vehicle, 1.2)
                            else
                                SetRpm(vehicle, r)
                            end
                        end
                        -- if RCP(1, 32) and speed < 25 and rpm > 0.1 and GetVehicleThrottleOffset(vehicle) > 0.7 then
                        --     --SetVehicleBurnout(vehicle, true)
                        --     --SetVehicleReduceGrip(vehicle,true)
                        --     --SetVehicleWheelieState(vehicle, 65)
                        --     --Wait(22)
                        --     -- SetVehicleCurrentRpm(vehicle, 1.0)
                        --     -- --SetVehicleReduceGrip(vehicle,false)
                        --     -- --SetVehicleBurnout(vehicle, false)
                        --     -- --SetVehicleWheelieState(vehicle, 65)
                        --     -- --Wait(22)
                        --     -- --SetVehicleReduceGrip(vehicle,true)
                        --     -- --SetVehicleBurnout(vehicle, true)
                        --     -- --Wait(22)
                        --     -- --SetVehicleReduceGrip(vehicle,true)
                        --     -- SetLaunchControlEnabled(true)
                        --     -- --SetVehicleBurnout(vehicle, false)
                        --     -- SetVehicleWheelieState(vehicle, 129)
                        --     -- --LockSpeed(vehicle,speed)
                        --     -- --Wait(11)
                        --     -- SetVehicleWheelieState(vehicle, 65)
                        --     -- --Wait(11)
                        --     -- SetVehicleWheelieState(vehicle, 0)
                        --     --SetVehicleReduceGrip(vehicle,false)
                        --     --SetVehicleBurnout(vehicle, false)
                        -- end
                    end
                end

                if speed < 5 and savegear > 3 then
                    Renzu_SetGear(vehicle,1)
                end

                if not clutch and speed < 5 and savegear == 0 then
                    Wait(1000)
                end

                --neutral launch control
                -- if RCP(1, 20) and RCP(1, 32) and speed < 11 and rpm >= 0.5 and speed <= 5 or clutch and RCP(1, 32) and speed < 11 and rpm >= 0.5 and speed <= 5 then
                --     SetRpm(vehicle,0.6)
                --         Renzuzu.Wait(11)
                --             SetRpm(vehicle,0.5)
                --                  Renzuzu.Wait(11)	
                --                     SetRpm(vehicle,1.2)
                --                         Renzuzu.Wait(55)
                --                             SetRpm(vehicle,0.7)
                --                         Renzuzu.Wait(11)
                --                     SetRpm(vehicle,1.4)
                --                 Renzuzu.Wait(11)
                --             SetRpm(vehicle,0.7)
                --         Renzuzu.Wait(55)
                --         SetRpm(vehicle,0.8)
                --     Renzuzu.Wait(55)
                -- end
                
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
            Renzuzu.Wait(5)
        end
        manual = false
        newmanual = nil
        if vehicle == 0 then
            vehicle = getveh()
        end
        if GetHandling(GetPlate(vehicle)).finaldrive ~= 0.0 and GetHandling(GetPlate(vehicle)).flywheel ~= 0.0 then
            SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", GetHandling(GetPlate(vehicle)).maxspeed)
            SetVehStats(vehicle, "CHandlingData", "fDriveInertia", GetHandling(GetPlate(vehicle)).finaldrive)
            SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", GetHandling(GetPlate(vehicle)).flywheel)
        end
    end)
end

-- RPM FACTORING
function percentage(partialValue, totalValue)
    local needle = partialValue / totalValue
    --print("NEEDLE",needle)
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
        if tonumber(GetVehicleMod(vehicle,13)) > 0 then
            if mode == 'SPORTS' then
                local bonus = (GetHandling(GetPlate(vehicle)).maxspeed * config.topspeed_multiplier)
                vehicletopspeed = bonus * 1.5
            else
                vehicletopspeed = GetHandling(GetPlate(vehicle)).maxspeed * 1.5
            end
        else
            vehicletopspeed = GetHandling(GetPlate(vehicle)).maxspeed * 1.0
        end
    end
    output = (vehicletopspeed * config.gears[maxgear][tonumber(sg)]) * 0.9
    return output
end

function tractioncontrol(s,sg,wheel)
	local vehicle_speed = s
    if tonumber(sg) then
        local needle = vehicle_speed / gearspeed(sg,wheel)
        if needle > 1.0 then
            needle = 1.0
        end
        return needle
    end
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
local loop = 0
local stallgear = 0
function antistall(speed, speedreduce, savegear, gearname, rpm, vehicle, currentgear, saferpm, driveforce, engineload, lastgear)
    --print(acceleration)
    if drivechange then
        --SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", flywheel)
        drivechange = false
        --SetVehicleHighGear(vehicle, maxgear)
    end
    --Renzu_SetGear(vehicle,savegear)
    if speed - (speedreduce * driveforce) <= (gearname - speedreduce) and currentgear > 0 then
        gearup = currentgear
        stalling = true
        Renzu_SetGear(vehicle,savegear - 1)
        correctgears = correctgears - 1
        local startkick = gearname - (lastgear / 1.5)
        if RCP(1, 32) and speed > startkick and speed <= gearname then
            drivechange = true
            --SetVehStats(vehicle, "CHandlingData", "fInitialDriveForce", flywheel * 1.5)
            local invertrpm = 1.0 - rpm
            local mg = maxgear
            if mg > 6 then
                mg = 6
            end
            local invertgear = mg - savegear
            engineload = driveforce + ((invertrpm * saferpm) * (savegear / driveforce)) * (rpm / speedreduce) * (1 + maxgear - savegear)
            if mode == 'SPORTS' then
                ModifyVehicleTopSpeed(vehicle, 0.9)
                torque = GetVehicleCheatPowerIncrease(vehicle)
                torque = torque * ( savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                -- --print(engineload / (maxgear - (maxgear-savegear)) * formulafuck * saferpm)
                local finalboost = boost + (engineload / (mg - (mg-savegear)) * (invertrpm + saferpm)) / mg * savegear + engineload
                if not alreadyturbo then
                    SetVehicleBoost(vehicle, finalboost)
                end
            else
                ModifyVehicleTopSpeed(vehicle, 1.0)
                torque = GetVehicleCheatPowerIncrease(vehicle)
                torque = torque * ( savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                local finalboost = (engineload / (mg - (mg-savegear)) * (invertrpm + saferpm)) / mg * savegear + engineload
                if speed > (lastgear * 0.84) and speed < (lastgear * 1.05) then -- method to help unstuck rpm due to gta native
                    finalboost = finalboost * 3
                    if not alreadyturbo then
                        SetVehicleBoost(vehicle, finalboost)
                        --ShowHelpNotification(finalboost * 3, true, 1, 5)
                    end
                end
            end
        end
    else
        stalling = false
    end
end

-- MAIN MANUAL SYSTEM LOOP ( EDIT THIS if you know the system )
local currentlimit = 100
local og = 0
function speedtable(speed,gear)
    --SetVehicleReduceTraction(vehicle, true)
    if clutchpressed then return end
    --olddriveinertia = tonumber(GetHandling(GetPlate(vehicle)).finaldrive)
    -- if olddriveinertia > 1 then
    --     olddriveinertia = 1.0
    -- end
    --oldriveforce = tonumber(GetHandling(GetPlate(vehicle)).flywheel)
    oldtopspeed = maxspeed * olddriveinertia -- normalize
    local engineload = oldriveforce + ((rpm * olddriveinertia) * (gear / oldriveforce))
    local speedreduce = (oldtopspeed) * (config.gears[maxgear][gear] * olddriveinertia) / gear * oldriveforce * engineload
    local mg = maxgear
    if mg > 6 then
        mg = 6
    end
    speedreduce = (speedreduce / mg) * oldriveforce + (gear / rpm) / mg
    if mode == 'SPORTS' and globaltopspeed ~= nil then
        vehicletopspeed = globaltopspeed
    end
	if vehicletopspeed ~= nil and savegear >= 1 then
        local speedlimit = (vehicletopspeed * config.gears[maxgear][gear]) * 0.9
		local currentgear = savegear
        saferpm = olddriveinertia
        if savegear >= 1 then
            if mycurrentvehicle ~= vehicle and maxgear == 6 and savegear == 1 then -- anti 1st gear glitch for upgraded trannys / or after flatvel handling is change, weird.
                ModifyVehicleTopSpeed(vehicle, 1.0)
            end
            if og == 0 or og ~= savegear then
                og = savegear
                LockSpeed(vehicle, speedlimit)
            end
            if savegear > 1 then
                local minusgear = correctgears - 1
                local recent_speed = (vehicletopspeed * config.gears[maxgear][minusgear]) * 0.9
                antistall(speed, speedreduce, correctgears, recent_speed, rpm, vehicle, currentgear, saferpm, oldriveforce, engineload, recent_speed)
            end
            return	percentage(speed,speedlimit)
        end
	end
end

-- FORCE GTA NATIVE TO STOP SWITCHING GEARS AUTOMATICALLY
function ForceVehicleGear (vehicle, gear)
    ----print(GetVehicleThrottleOffset(vehicle))
    SetVehicleCurrentGear(vehicle, gear)
    SetVehicleNextGear(vehicle, gear)
    --savegear = gear
    --SetVehicleHighGear(vehicle, round(gear))
    --SetVehicleHighGear(vehicle, gear)
    return gear
end