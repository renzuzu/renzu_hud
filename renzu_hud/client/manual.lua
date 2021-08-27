-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
local enginerunning = false
local handbrake = false
local carspeed = 0
local acceleration = nil
local mycurrentvehicle = nil
local stalling = false
local modifyt = nil
RenzuCommand('getstat', function()
    finaldrive = GetVehStats(Hud.vehicle, "CHandlingData","fDriveInertia")
    flywheel = GetVehStats(Hud.vehicle, "CHandlingData","fInitialDriveForce")
    max = GetVehStats(Hud.vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
    t = GetVehStats(Hud.vehicle, "CHandlingData","fTractionCurveMin")
    t2 = GetVehStats(Hud.vehicle, "CHandlingData","fTractionCurveLateral")
    mg = GetVehicleHandlingInt(Hud.vehicle, "CHandlingData","nInitialDriveGears")
    print(finaldrive,flywheel,max,t,t2,mg)
    print("GetVehicleAcceleration",GetVehicleAcceleration(Hud.vehicle))
    print("GetVehicleModelAcceleration",GetVehicleModelAcceleration(GetEntityModel(Hud.vehicle)))
    print("GetVehicleModelEstimatedMaxSpeed",GetVehicleModelEstimatedMaxSpeed(GetEntityModel(Hud.vehicle)) * 3.6)
    print("flatvel",(max))
    print("GetVehicleModelEstimatedAgility",GetVehicleModelEstimatedAgility(GetEntityModel(Hud.vehicle)) * 1.818)
    print(DecorGetFloat(Hud.vehicle, "DRIVEFORCE"))
    print(GetVehicleMod(Hud.vehicle,13))
    print(GetVehicleHighGear(Hud.vehicle))
end)

RenzuCommand('drivetocoord', function(source, args, raw)
    local waypoint = GetFirstBlipInfoId(8)
    if Hud.vehicle ~= 0 and DoesBlipExist(waypoint) then
        local x,y,z = table.unpack(GetBlipCoords(waypoint))
        print("driving",x,y,z,Hud.vehicle)
        TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), Hud:getveh(), x, y, z, 400.0, 787260, 10.0)
        SetDriveTaskCruiseSpeed(PlayerPedId(),300.0)
        SetDriveTaskMaxCruiseSpeed(true,300.0)
        SetVehicleHandlingField(Hud.vehicle, "CHandlingData", "AIHandling", "SPORTS_CAR")
        Creation(function()
            while Hud.invehicle do
                for k,v in pairs(GetGamePool('CVehicle')) do
                    local xv,yv,zv = table.unpack(GetEntityCoords(v))
                    if v ~= Hud.vehicle then
                        SetEntityAlpha(v,151,false)
                        SetEntityCollision(v,true,true)
                        if #(GetEntityCoords(Hud.vehicle) - GetEntityCoords(v)) < 30 then
                            SetEntityNoCollisionEntity(Hud.vehicle,v,false)
                        end
                    end
                end
                SetDriveTaskDrivingStyle(GetPlayerPed(-1), 787260)
                SetDriveTaskCruiseSpeed(GetPlayerPed(-1),400.0)
                SetDriverRacingModifier(GetPlayerPed(-1),1.0)
                SetDriverAbility(GetPlayerPed(-1), 1.0)        -- values between 0.0 and 1.0 are allowed.
                SetDriverAggressiveness(GetPlayerPed(-1), 1.0) -- values between 0.0 and 1.0 are allowed.
                SetDriveTaskMaxCruiseSpeed(GetPlayerPed(-1),400.0)
                --SetPedKeepTask(GetPlayerPed(-1), true)
                --TaskVehicleTempAction(GetPlayerPed(-1),Hud.vehicle,32,10.0)
                --TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), Hud:getveh(), x, y, z, 400.0, 787260, 10.0)
                Wait(1)
            end
        end)
    end
end)

function Hud:requestmodel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do 
		Wait(1)
		RequestModel(model)
	end
end

wheelindex = 1
function Hud:startmanual(entity,ver)
    Citizen.Wait(1000)
    Creation(function()
        if entity ~= nil then
            self.vehicle = entity
        end
        self.maxgear = tonumber(self:GetHandling(self:GetPlate(self.vehicle)).maxgear)
        self.vehicletopspeed = self:GetHandling(self:GetPlate(self.vehicle)).maxspeed
        wheelindex = GetVehStats(self.vehicle, "CHandlingData","fDriveBiasFront")
        if wheelindex == 0.0 then
            wheelindex = 3
        elseif wheelindex == 1.0 then
            wheelindex = 1
        elseif wheelindex > 0.01 and wheelindex < 0.9 then
            wheelindex = 3
        end
        --print(maxgear)
        self.savegear = GetGear(self.vehicle)
        while not self.manual do -- ASYNC WAITING FOR MANUAL BOOL = TRUE
            Wait(0)
        end
        Wait(1000) -- 1 sec wait avoid bug
        self:Nuimanualtranny()
        --self:NuiClutchloop()
        self:NuiManualEtcFunc()
        Wait(500)
        if not ver then
            self:NuiMainmanualLoop()
        else
            self:NuiMainmanualLoop2()
        end
        print("MANUAL TRUE")
        self.manualstatus = not self.manualstatus
        DecorSetBool(self.vehicle, "MANUAL", true)
        --print(DecorGetBool(self.vehicle, "MANUAL"))
    end)
    if not self.manual and self.manualstatus then
        self.manual = true
    end
end

RenzuNetEvent('renzu_hud:manual')
RenzuEventHandler('renzu_hud:manual', function(bool)
    plate = GetVehicleNumberPlateText(Hud:getveh())
	--plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    if DecorExistOn(Hud:getveh(), "MANUAL") then
		DecorRemove(Hud:getveh(), "MANUAL")
	end
    if not bool then
	    local topspeed = Hud:GetHandling(Hud:GetPlate(Hud.vehicle)).maxspeed * 1.3
	    LockSpeed(Hud:getveh(),topspeed / 3.6)
	    Hud:ForceVehicleGear(Hud:getveh(), 1)
	    SetVehicleHandbrake(Hud:getveh(),bool)
        SendNUIMessage({
            type = "setManual",
            content = bool
        })
        DecorSetBool(Hud:getveh(), "MANUAL", bool)
        Hud.newmanual = bool
        Hud.veh_stats[plate].manual = false
    elseif bool then
        if not Hud.veh_stats[plate].manual then
            Hud.veh_stats[plate].manual = true
            DecorSetBool(Hud:getveh(), "MANUAL", bool)
            TriggerServerEvent('renzu_hud:savedata', plate, Hud.veh_stats[tostring(plate)])
            Hud.manual = true
        end
        Hud:startmanual(Hud:getveh())
	end
    Hud.manual = bool
    Hud.manualstatus = bool
end)

RenzuCommand('manual', function()
	if Hud.manual then
	    local topspeed = Hud:GetHandling(Hud:GetPlate(Hud.vehicle)).maxspeed * 1.3
	    LockSpeed(Hud.vehicle,topspeed / 3.6)
	    Hud:ForceVehicleGear(Hud.vehicle, 1)
	    SetVehicleHandbrake(Hud.vehicle,false)
        SendNUIMessage({
            type = "setManual",
            content = false
        })
        DecorSetBool(Hud.vehicle, "MANUAL", false)
        Hud.newmanual = false
    else
        Hud.manual = false
        Hud.manualstatus = false
        Wait(100)
        Hud:startmanual()
	end
    Hud.manual = not Hud.manual
    --Hud.manualstatus = not Hud.manualstatus
end)

RenzuCommand('manual2', function()
	if Hud.manual then
	    local topspeed = Hud:GetHandling(Hud:GetPlate(Hud.vehicle)).maxspeed * 1.3
	    LockSpeed(Hud.vehicle,topspeed / 3.6)
	    Hud:ForceVehicleGear(Hud.vehicle, 1)
        SetVehicleHighGear(Hud.vehicle,Hud:GetHandling(Hud:GetPlate(Hud.vehicle)).maxgear)
	    SetVehicleHandbrake(Hud.vehicle,false)
        SendNUIMessage({
            type = "setManual",
            content = false
        })
        DecorSetBool(Hud.vehicle, "MANUAL", false)
        Hud.newmanual = false
    else
        Hud.manual = false
        Hud.manualstatus = false
        Wait(100)
        Hud:startmanual(nil,true)
	end
    Hud.manual = not Hud.manual
    --Hud.manualstatus = not Hud.manualstatus
end)

--NUI MANUAL TRANSMISSION
function Hud:Nuimanualtranny()
    local newgear = nil
    Creation(function()
        Wait(500)
        while self.manual and self.invehicle do
            local sleep = 1500
            local ped = ped
            local vehicle = self.vehicle
            if vehicle ~= nil and vehicle ~= 0 then
                sleep = 300
                if self.newmanual ~= self.manual or self.newmanual == nil then
                    --self.vehicletopspeed = GetVehStats(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
                    self.newmanual = self.manual
                    SendNUIMessage({
                    type = "setManual",
                    content = self.manual or false
                    })
                end
                --print(self.savegear)
                if newgear ~= self.savegear or newgear == nil then
                    SendNUIMessage({
                    type = "setShift",
                    content = self.savegear or 1
                    })
                    newgear = self.savegear
                    SendNUIMessage({
						type = "setGear",
						content = self.savegear or 1
					})
                end
            end
            modifyt = nil
            Wait(sleep)
        end
        SendNUIMessage({
            type = "setManual",
            content = false
        })
    end)
end

local clutch = false
local clutchpressed = false

function Hud:trannyupgradegear()
    local mg = tonumber(self:GetHandling(self:GetPlate(self.vehicle)).maxgear)
    if tonumber(GetVehicleMod(self.vehicle,13)) > 0 and tonumber(mg) < 6 then
        mg = mg + 1
    end
    return tonumber(mg)
end

function Hud:trannyupgradespeed()
    if self.manual2 then
        --print("manual2")
        if tonumber(GetVehicleMod(self.vehicle,13)) > 0 then
            if mode == 'SPORTS' then
                bonus = self:GetHandling(self:GetPlate(self.vehicle)).maxspeed * config.topspeed_multiplier
            else
                bonus = self:GetHandling(self:GetPlate(self.vehicle)).maxspeed * 1.5
            end
        else
            bonus = self:GetHandling(self:GetPlate(self.vehicle)).maxspeed
        end
        return bonus
    else
        if tonumber(GetVehicleMod(self.vehicle,13)) > 0 then
            if mode == 'SPORTS' then
                local bonus = (self:GetHandling(self:GetPlate(self.vehicle)).maxspeed * config.topspeed_multiplier)
                SetVehicleHandlingField(self.vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", bonus * 1.5)
                --print("BONUS")
            else
                SetVehicleHandlingField(self.vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", self:GetHandling(self:GetPlate(self.vehicle)).maxspeed * 1.5)
            end
            --SetVehStats(self.vehicle, "CHandlingData", "fInitialDriveForce", DecorGetFloat(self.vehicle,"DRIVEFORCE") * 1.5)
        end
        Wait(100)
        r = GetVehStats(self.vehicle, "CHandlingData","fInitialDriveMaxFlatVel") * 1.0
        return r
    end
end

local highgear = 5
function Hud:NuiManualEtcFunc()
    Creation(function()
        while self.manual and self.invehicle do
            local sleep = 1500
            if self.vehicle ~= nil and self.vehicle ~= 0 then
                enginerunning = GetIsVehicleEngineRunning(self.vehicle)
                handbrake = GetVehicleHandbrake(self.vehicle)
                carspeed = VehicleSpeed(self.vehicle) * 3.6
                acceleration = self:GetHandling(self:GetPlate(self.vehicle)).flywheel
                self.vehicletopspeed = self:trannyupgradespeed('speed')
                self.maxgear = self:trannyupgradegear('gear')
                highgear = tonumber(GetVehicleHighGear(self.vehicle))
                self.olddriveinertia = tonumber(self:GetHandling(self:GetPlate(self.vehicle)).finaldrive)
                self.oldriveforce = tonumber(self:GetHandling(self:GetPlate(self.vehicle)).flywheel)
            end
            Wait(sleep)
        end
    end)
end

function Hud:ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('notishit2', msg)
    DisplayHelpTextThisFrame('notishit2', true)
end

    local notraction = false
    local dummygear = 0
    local manualvehicles = {}
    RegisterNetEvent("renzu_hud:manualtrigger")
    AddEventHandler("renzu_hud:manualtrigger", function(v,gear,plate)
        local inseat = false
        if NetworkDoesEntityExistWithNetworkId(v) then
            for i = 0, 4 do
                if GetPedInVehicleSeat(NetToVeh(v),i) == PlayerPedId() then
                    inseat = true
                end
            end
            if inseat then
                Renzu_SetGear(NetToVeh(v),gear)
                dummygear = gear
                Hud.savegear = gear
            end
            if inseat and not manualvehicles[plate] and GetPedInVehicleSeat(NetToVeh(v), -1) ~= PlayerPedId() then
                manualvehicles[plate] = true
                -- while true do
                --     Wait(100)
                --     print(dummygear)
                -- end
                Wait(100)
                Creation(function()
                    while manualvehicles[plate] and Hud.invehicle do
                        local sleep = 1500
                        if NetToVeh(v) ~= nil and NetToVeh(v) ~= 0 then
                            enginerunning = GetIsVehicleEngineRunning(NetToVeh(v))
                            handbrake = GetVehicleHandbrake(NetToVeh(v))
                            carspeed = VehicleSpeed(NetToVeh(v)) * 3.6
                            acceleration = Hud:GetHandling(Hud:GetPlate(NetToVeh(v))).flywheel
                            Hud.vehicletopspeed = Hud:trannyupgradespeed('speed')
                            Hud.maxgear = trannyupgradegear('gear')
                            highgear = tonumber(GetVehicleHighGear(NetToVeh(v)))
                            Hud.olddriveinertia = tonumber(Hud:GetHandling(Hud:GetPlate(NetToVeh(v))).finaldrive)
                            Hud.oldriveforce = tonumber(Hud:GetHandling(Hud:GetPlate(NetToVeh(v))).flywheel)
                        end
                        Wait(sleep)
                    end
                    manualvehicles[plate] = false
                end)
                while Hud.olddriveinertia == nil do
                    Wait(1000)
                    print("nil")
                end
                Creation(function()
                    while manualvehicles[plate] and Hud.invehicle do
                        print("MANUAL SYNC")
                        speedlimit = (Hud.vehicletopspeed * config.gears[Hud.maxgear*1.0][dummygear]) * 0.9
                        --LockSpeed(NetToVeh(v), speedlimit)
                        Citizen.InvokeNative(0x8923dd42, NetToVeh(v), dummygear)
                        Hud:Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, NetToVeh(v), dummygear)
                        Hud:Renzu_Hud(nextgearhash & 0xFFFFFFFF, NetToVeh(v), dummygear)
                        --Renzu_SetGear(NetToVeh(v),dummygear)
                        local speed = VehicleSpeed(NetToVeh(v)) * 3.5
                        --print(speedlimit,speed)
                        correctgears = GetGear(NetToVeh(v))
                        --ShowHelpNotification(tostring(Hud.savegear,correctgears,round(Hud.maxgear)), true, 1, 5)
                        --print(Hud.savegear,correctgears,round(Hud.maxgear))
                        if dummygear < 0 then
                            dummygear = 1
                        end
                        if correctgears < 0 then
                            correctgears = 1
                        end
                        --ShowHelpNotification(tostring(Hud.savegear,correctgears,tonumber(Hud:GetHandling(Hud:GetPlate(Hud.vehicle)).Hud.maxgear)), true, 1, 5)
                        if tonumber(dummygear) > 1 and tonumber(correctgears) <= Hud.maxgear then
                            speedgearlimit = tonumber((Hud.vehicletopspeed * config.gears[Hud.maxgear*1.0][correctgears]) * 0.88)
                            if correctgears < 1 then
                                correctgears = 1
                            end
                            if dummygear <= 1 then
                                correctgears = 1
                            end
                            if speed > speedgearlimit then
                                correctgears = correctgears + 1
                                Wait(0)
                            end
                            --ShowHelpNotification(tostring(round(correctgears)), true, 1, 5)
                        else
                            correctgears = dummygear
                        end
                        Hud.savegear = dummygear
                        if speed > 3 then
                            SetRpm(NetToVeh(v), speedtable(speed,dummygear))
                        end
                        Wait(0)
                    end
                end)
            end
        end
    end)


    config.gears2 = {
        [1] = {gear_ratio = {
            0.90, -- 1st gear
        }, 
        final_drive = 5.0},
        [2] = {gear_ratio = {
            3.33, -- 1st gear
            0.90, -- 2nd gear
        }, final_drive = 3.5},
        [3] = {gear_ratio = {
            3.33, -- 1st gear
            1.57, -- 2nd gear
            0.90, -- 3rd gear
        }, final_drive = 4.5},
        [4] = {gear_ratio = {
            3.33, -- 1st gear
            1.83, -- 2nd gear
            1.22, -- 3rd gear
            0.90}, -- 4th gear
            final_drive = 4.0
        },
        [5] = {gear_ratio = { -- 5 Gears
            3.230, -- 1st gear
            2.105, -- 2nd gear
            1.458, -- 3rd gear
            1.107, -- 4th gear
            0.848, -- 5th gear
            }, final_drive = 4.4
        },
        [6] = {gear_ratio = { -- 6 Gears
            3.33, -- 1st gear
            1.95, -- 2nd gear
            1.39, -- 3rd gear
            1.09, -- 4th gear
            0.95, -- 5th gear
            0.90, -- 6th gear
            }, 
            final_drive = 5.8
        },
        [7] = {gear_ratio = {
            4.00, -- 1st gear
            2.34, -- 2nd gear
            1.67, -- 3rd gear
            1.31, -- 4th gear
            1.14, -- 5th gear
            1.08, -- 6th gear
            0.90,}, -- 7th gear
            final_drive = 4.9
        },
        [8] = {gear_ratio = {5.31, 3.11, 2.22, 1.74, 1.51, 1.43, 1.20, 0.90}, final_drive = 5.1},
        [9] = {gear_ratio = {7.70, 4.51, 3.22, 2.52, 2.20, 2.08, 1.73, 1.31, 0.90}, final_drive = 5.5},
    }

    config.custom_gears = {
        [`kanjo`] = { -- Hud.vehicle model name , important to set a backtick `kanjo`
            [5] = {gear_ratio = {3.230, 1.905, 1.458, 1.247, 1.048}, final_drive = 4.4},
            [6] = {gear_ratio = {3.33, 1.95, 1.39, 1.09, 0.95, 0.90}, final_drive = 4.8}
        }
    }

    function Hud:NuiMainmanualLoop2()
        Creation(function()
            self.manual2 = true
            while self.manual and self.invehicle do
                local sleep = 100
                DisableControlAction(0,73,true)
                while tonumber(self.rpm) >= 1.0 and not clutchpressed do
                    if IsControlJustReleased(0, config.clutch) then
                        break
                    end
                    SetVehicleCurrentRpm(self.vehicle,math.random(95,99) * 0.01)
                    Wait(0)
                    --SetVehicleForwardSpeed(self.vehicle,totalValue)
                end
                if self.rpm < 0.5 and GetVehicleThrottleOffset(self.vehicle) <= 0 then -- disable GTA auto set self.rpm to 0.2 if not reving on this level
                    sleep = 5
                    SetVehicleCurrentRpm(self.vehicle,self.rpm)
                end
                Wait(sleep)
            end
            self.manual2 = false
        end)
        
        Creation(function()
            while self.manual and self.invehicle do
                local gear_ratio = 1.0
                if self.maxgear ~= nil and self.savegear ~= nil and self.savegear > 0 then
                    if config.custom_gears[GetEntityModel(self.vehicle)] ~= nil then
                        gear_ratio = config.custom_gears[GetEntityModel(self.vehicle)][self.maxgear].gear_ratio[self.savegear] / ( self.maxgear / config.custom_gears[GetEntityModel(self.vehicle)][self.maxgear].final_drive)
                    else
                        gear_ratio = config.gears2[self.maxgear].gear_ratio[self.savegear] / ( self.maxgear / config.gears2[self.maxgear].final_drive)
                    end
                end
                crank = gear_ratio * Hud:GetHandling(Hud:GetPlate(self.vehicle)).flywheel
                gearspeedratio = (self.vehicletopspeed / gear_ratio)
                speedmeters = (gearspeedratio * 1.3) / 3.4
                SetVehicleHighGear(self.vehicle,1)
                SetVehicleHandlingFloat(self.vehicle, "CHandlingData", "fInitialDriveForce", crank)
                --Hud:GetHandling(Hud:GetPlate(self.vehicle)).flywheel = crank
                --Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxspeed = gearspeedratio
                SetVehicleHandlingFloat(self.vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", gearspeedratio)
                LockSpeed(self.vehicle,speedmeters) -- make sure speed will be limited flatvel handling does not work flawlessly without this.
                ModifyVehicleTopSpeed(self.vehicle,1.0) -- anti gear speedlimit glitch
                if not clutchpressed and self.rpm <= 0.21 and self.speed < 3 and self.savegear > 0 then -- turn off engine if current very low self.rpm and gear > 0
                    if GetVehicleThrottleOffset(self.vehicle) <= 0 then
                        SetVehicleEngineOn(self.vehicle,false,false,false)
                    end
                end

                if not enginerunning and RCP(1, 32) then -- turn on engine when Pressed [W]
                    SetVehicleEngineOn(self.vehicle,true,false,false)
                    self.savegear = 0
                end

                if self.savegear == 0 and RCP(1, config.clutch) and RCR(1, config.downshift) or self.savegear == 0 and clutch and RCR(1, config.downshift) then -- self.reverse info
                    --ShowHelpNotification('REVERSE', true, 1, 5)
                    marcha = "R"
                    self.savegear = 0
                    self.reverse = true
                end
                --neutral mode with handbrake
                if self.savegear == 0 then -- neutral mode if Gear == 0
                    ForceVehicleGear(self.vehicle, 0)
                    SetVehicleHandbrake(self.vehicle,true)
                    --SetVehicleBrake(self.vehicle, true)
                end

                --if handbrake disable it when gear is >= 1
                --print(handbrake , not RCP(1, config.clutch) , self.savegear > 0 , not clutch)
                if handbrake and not RCP(1, config.clutch) and self.savegear > 0 and not clutch or self.reverse and not clutch then
                    --ForceVehicleGear(self.vehicle, 0)
                    if self.speed < 10 then
                        SetVehicleHandbrake(self.vehicle,false)
                    end
                end
                Wait(250)
            end
            self.vehicle = Hud:getveh()
            SetVehicleHighGear(self.vehicle,Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxgear)
            SetVehicleHandlingFloat(self.vehicle, "CHandlingData", "fInitialDriveForce", Hud:GetHandling(Hud:GetPlate(self.vehicle)).flywheel)
            SetVehicleHandlingFloat(self.vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxspeed)
        end)
    end

    RenzuCommand('clutch', function()
        local sleep = 1000
        if Hud.invehicle and Hud.manual then
            if Hud.speed < 3 then
                Hud:ForceVehicleGear(Hud.vehicle, 0)
                SetVehicleHandbrake(Hud.vehicle,true)
            end
            if Hud.savegear == 0 and RCR(1, 173) or Hud.savegear == 0 and clutch and RCR(1, 173) then
                Hud:ShowHelpNotification('REVERSE', true, 1, 5)
                marcha = "R"
                Hud.savegear = 0
                Hud.reverse = true
            end
            
            while IsDisabledControlPressed(0, 73) or RCP(0,73) do -- if still pressed
                if Hud.savegear == 0 and RCR(1, 173) or Hud.savegear == 0 and clutch and RCR(1, 173) then
                    Hud:ShowHelpNotification('REVERSE', true, 1, 5)
                    marcha = "R"
                    Hud.savegear = 0
                    Hud.reverse = true
                end
                clutchpressed = true
                Citizen.Wait(0)
                --LockSpeed(Hud.vehicle,Hud.speed)
                SetVehicleClutch(Hud.vehicle, 1.0)
                clutch = true
                sleep = 1000
                DisableControlAction(0,73,true)
            end
            clutchpressed = false
            Wait(sleep)
            clutch = false
        end
    end, false)

    RenzuCommand('upshift', function()
        if RCP(0, 172) and clutch and Hud.manual then
            --ClearVehicleTasks(Hud.vehicle)
            if Hud.reverse then
                Hud.savegear = 0
                Hud.reverse = false
                if not Hud.manual2 then
                    Renzu_SetGear(Hud.vehicle,0)
                end
                --ShowHelpNotification("Neutral", true, 1, 5)
            else
                if Hud.maxgear >= (Hud.savegear + 1) then
                    --SetVehicleReduceGrip(Hud.vehicle,false)
                    Hud.savegear = Hud.savegear + 1
                    if not Hud.manual2 then
                        Renzu_SetGear(Hud.vehicle,Hud.savegear + 1)
                        TriggerServerEvent("renzu_hud:manualsync",VehToNet(Hud.vehicle),Hud.savegear,plate)
                    end
                    --ShowHelpNotification(Hud.savegear, true, 1, 5)
                end
            end
            --ClearVehicleTasks(Hud.vehicle)
            Wait(500)
        end
    end, false)

    RenzuCommand('downshift', function()
        if RCP(0, 173) and Hud.savegear > 0 and clutch and Hud.manual then
            Hud.savegear = Hud.savegear - 1
            if not Hud.manual2 then
                Renzu_SetGear(Hud.vehicle,Hud.savegear - 1)
                TriggerServerEvent("renzu_hud:manualsync",VehToNet(Hud.vehicle),Hud.savegear,Hud.plate)
            end
            --ClearVehicleTasks(Hud.vehicle)
            Wait(500)
        end
    end, false)
    
    Creation(function()
        RenzuKeybinds('clutch', 'Vehicle Clutch', 'keyboard', 'X')
        RenzuKeybinds('upshift', 'Vehicle UpShift Gear', 'keyboard', 'UP')
        RenzuKeybinds('downshift', 'Vehicle DownShift Gear', 'keyboard', 'DOWN')
        return
    end)

function Hud:NuiMainmanualLoop() -- Dont edit unless you know the system how it works.
    Creation(function()
        while self.manual and self.invehicle do
            --allow self.manual only if self.manual is true and if riding in self.vehicle
            if self.vehicle ~= 0 and self.manual then
                if clutchpressed then
                    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, self.vehicle, 0)
                    Renzu_Hud(nextgearhash & 0xFFFFFFFF, self.vehicle, 0)
                elseif self.speed > 2 then
                    --Citizen.InvokeNative(0x8923dd42, self.vehicle, correctgears)
                    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, self.vehicle, correctgears)
                    Renzu_Hud(nextgearhash & 0xFFFFFFFF, self.vehicle, correctgears)
                end
                DisableControlAction(0,73,true)
                local reving = false

                --anti gear desync
                if clutchpressed then
                    Renzu_SetGear(self.vehicle,0)
                end
                --loop gear
                local currentgear = self.savegear
                currentgear = currentgear

                --speed loop
                local speed = VehicleSpeed(self.vehicle) * 3.6

                --simulate self.manual -- if self.rpm is lessthan 2000 self.rpm and gear is > 0 turn off the engine
                if not clutchpressed and self.rpm <= 0.21 and speed < 3 and self.savegear > 0 then
                    if GetVehicleThrottleOffset(self.vehicle) <= 0 then
                        SetVehicleEngineOn(self.vehicle,false,false,false)
                    end
                end

                if not enginerunning and RCP(1, 32) then
                    SetVehicleEngineOn(self.vehicle,true,false,false)
                    self.savegear = 0
                end

                --neutral mode with handbrake
                if self.savegear == 0 and not self.reverse then
                    self:ForceVehicleGear(self.vehicle, 0)
                    SetVehicleHandbrake(self.vehicle,true)
                    Wait(100)
                    --SetVehicleBrake(self.vehicle, true)
                end

                --main loop self.manual system
                if highgear ~= self.maxgear then
                    SetVehicleHighGear(self.vehicle,GetVehicleHandlingInt(self.vehicle, "CHandlingData","nInitialDriveGears"))
                    self.maxgear = tonumber(self:GetHandling(self:GetPlate(self.vehicle)).maxgear)
                end

                --if handbrake disable it when gear is >= 1
                if handbrake and not RCP(0, 73) and self.savegear > 0 and not clutch or self.reverse and not clutch then
                    --ForceVehicleGear(self.vehicle, 0)
                    if speed < 10 then
                        SetVehicleHandbrake(self.vehicle,false)
                        Wait(100)
                        while self.reverse do
                            DisableControlAction(0,32,true)
                            Wait(0)
                        end
                    end
                end

                correctgears = GetGear(self.vehicle)
                if self.savegear < 0 then
                    self.savegear = 1
                end
                if correctgears < 0 then
                    correctgears = 1
                end
                --ShowHelpNotification(tostring(self.savegear,correctgears,tonumber(self:GetHandling(self:GetPlate(self.vehicle)).maxgear)), true, 1, 5)
                if self.savegear > 1 and correctgears <= self.maxgear then
                    local speedgearlimit = (self.vehicletopspeed * config.gears[self.maxgear*1.0][correctgears]) * 0.88
                    if correctgears < 1 then
                        correctgears = 1
                    end
                    if self.savegear <= 1 then
                        correctgears = 1
                    end
                    if speed > speedgearlimit then
                        correctgears = correctgears + 1
                        Wait(0)
                    end
                    --ShowHelpNotification(tostring(round(correctgears)), true, 1, 5)
                else
                    correctgears = self.savegear
                end

                if self.savegear == 1 and RCP(0, 32) and speed < 15 and self.rpm > 0.8 and self.rpm < 1.1 and (self.rpm * 100.0) > (self:tractioncontrol(WheelSpeed(self.vehicle,wheelindex) * 3.6,self.savegear) * 95.0) and not clutchpressed then
                    while not RCP(0, 172) and self.savegear == 1 and speed > 2 and RCP(0, 32) and self.rpm < 1.19 and (self.rpm * 100.0) > (self:tractioncontrol(WheelSpeed(self.vehicle,wheelindex) * 3.6,self.savegear) * 95.0) and speed < 25 do
                        SetRpm(self.vehicle, self:speedtable(speed,self.savegear))
                        SetRpm(self.vehicle, self.rpm + 0.1)
                        if self.veh_stats[self.plate].tirespec ~= nil then
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveMin", self.veh_stats[self.plate].tirespec['fTractionCurveMin'] * 0.7)
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveLateral", self.veh_stats[self.plate].tirespec['fTractionCurveLateral'] * 0.7)
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fLowSpeedTractionLossMult", self.veh_stats[self.plate].tirespec['fLowSpeedTractionLossMult'] * 1.7)
                        else
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveMin", self:GetHandling(self:GetPlate(self.vehicle)).traction * 0.7)
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveLateral", self:GetHandling(self:GetPlate(self.vehicle)).traction2 * 0.7)
                            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fLowSpeedTractionLossMult", self:GetHandling(self:GetPlate(self.vehicle)).traction3 * 1.7)
                        end
                        print('notraction')
                        notraction = true
                        Wait(0)
                    end
                end
                
                if speed > 5 and not RCP(0, 22) then
                    if self.rpm >=0.2 and self.rpm <= 1.1 then
                        local tcs = 70.0
                        if speed < ((maxspeed * 1.3) / 1.5) then
                            tcs = 85.0
                        end
                        if speed > 5 and (self.rpm * 100.0) > (self:tractioncontrol(WheelSpeed(self.vehicle,wheelindex) * 3.6,self.savegear) * tcs) and not clutchpressed then
                            SetRpm(self.vehicle, self:speedtable(speed,self.savegear))
                            if notraction then
                                print('notraction')
                                if self.veh_stats[self.plate].tirespec ~= nil then
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveMin", self.veh_stats[self.plate].tirespec['fTractionCurveMin'] * 1.0)
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveLateral", self.veh_stats[self.plate].tirespec['fTractionCurveLateral'] * 1.0)
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fLowSpeedTractionLossMult", self.veh_stats[self.plate].tirespec['fLowSpeedTractionLossMult'] * 1.0)
                                else
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveMin", self:GetHandling(self:GetPlate(self.vehicle)).traction * 1.0)
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fTractionCurveLateral", self:GetHandling(self:GetPlate(self.vehicle)).traction2 * 1.0)
                                    SetVehicleHandlingField(self.vehicle, "CHandlingData", "fLowSpeedTractionLossMult", self:GetHandling(self:GetPlate(self.vehicle)).traction3 * 1.0)
                                end
                                notraction = false
                            end
                        elseif self.rpm > 0.5 then
                            sleep = 300
                            local difference = (self:tractioncontrol(WheelSpeed(self.vehicle,wheelindex) * 3.6,self.savegear) * 100 / (self.rpm * 100.0)) * 0.1
                            local r = self.rpm + (self.rpm * difference)
                            if r > 1.1 then
                                r = 1.1
                            end
                            if clutchpressed and RCP(1, 32) and self.rpm < 1.0 then
                                SetRpm(self.vehicle, r)
                            elseif not clutchpressed then
                                SetRpm(self.vehicle, r)
                            end
                            if not clutchpressed and speed > 20 and self.rpm < 0.6 then
                                SetRpm(self.vehicle, self:speedtable(speed,self.savegear))
                            end
                            if speed < 20 then
                                SetRpm(self.vehicle, 1.2)
                            else
                                SetRpm(self.vehicle, r)
                            end
                            if boost > 1 then
                                Wait(500)
                            end
                        end
                    end
                end

                if speed < 5 and self.savegear > 3 then
                    Renzu_SetGear(self.vehicle,1)
                end

                if not clutch and speed < 5 and self.savegear == 0 then
                    Wait(1)
                end
            else
                --sleep if not in self.vehicle and reset gears
                self.savegear = 0
            end
            Wait(1)
        end
        self.manual = false
        self.newmanual = nil
        Wait(500)
        if self.vehicle == 0 then
            self.vehicle = self:getveh()
        end
        if self.vehicle ~= nil and self:GetPlate(self.vehicle) ~= nil and self:GetHandling(self:GetPlate(self.vehicle)).finaldrive ~= 0.0 and self:GetHandling(self:GetPlate(self.vehicle)).flywheel ~= 0.0 then
            SetVehicleHandlingField(self.vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", self:GetHandling(self:GetPlate(self.vehicle)).maxspeed)
            SetVehStats(self.vehicle, "CHandlingData", "fDriveInertia", self:GetHandling(self:GetPlate(self.vehicle)).finaldrive)
            SetVehStats(self.vehicle, "CHandlingData", "fInitialDriveForce", self:GetHandling(self:GetPlate(self.vehicle)).flywheel)
        end
    end)
end

-- RPM FACTORING
function Hud:percentage(partialValue, totalValue)
    local needle = partialValue / totalValue
    if tonumber(needle) > 1.2 then
        needle = 1.1
        SetVehicleCurrentRpm(self.vehicle,1.1)
        --SetVehicleForwardSpeed(self.vehicle,totalValue)
    end
    if needle <= 0.0 then
        needle = 0.0
    end
    return needle
end

function Hud:gearspeed(sg, wheel)
    if wheel then
        if tonumber(GetVehicleMod(self.vehicle,13)) > 0 then
            if mode == 'SPORTS' then
                local bonus = (Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxspeed * config.topspeed_multiplier)
                self.vehicletopspeed = bonus * 1.5
            else
                self.vehicletopspeed = Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxspeed * 1.5
            end
        elseif Hud:GetPlate(self.vehicle) ~= nil then
            self.vehicletopspeed = Hud:GetHandling(Hud:GetPlate(self.vehicle)).maxspeed * 1.0
        end
    end
    if self.maxgear == nil then
        self.maxgear = GetVehicleHandlingInt(Hud:getveh(), "CHandlingData","nInitialDriveGears")
    end
    output = (self.vehicletopspeed * config.gears[self.maxgear*1.0][tonumber(sg)]) * 0.9
    return output
end

function Hud:tractioncontrol(s,sg,wheel)
	local vehicle_speed = s
    if tonumber(sg) then
        local needle = vehicle_speed / Hud:gearspeed(sg,wheel)
        if needle > 1.0 then
            needle = 1.0
        end
        return needle
    end
end

function Hud:DrawScreenText2D(x, y, message, dropShadow, outline)
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
newfgear = 1
function Hud:antistall(speed, speedreduce, savegear, gearname, rpm, vehicle, currentgear, saferpm, driveforce, engineload, lastgear)
    if drivechange then
        drivechange = false
    end
    if speed - (speedreduce * driveforce) <= (gearname - speedreduce) and currentgear > 0 then
        gearup = currentgear
        stalling = true
        Renzu_SetGear(self.vehicle,self.savegear - 1)
        newfgear = self.savegear - 1
        correctgears = correctgears - 1
        local startkick = gearname - (lastgear / 1.5)
        if RCP(1, 32) and speed > startkick and speed <= gearname or dummygear > 0 and speed > startkick and speed then
            drivechange = true
            local invertrpm = 1.0 - rpm
            local mg = self.maxgear
            if mg > 6 then
                mg = 6
            end
            local invertgear = mg - self.savegear
            engineload = driveforce + ((invertrpm * saferpm) * (self.savegear / driveforce)) * (rpm / speedreduce) * (1 + self.maxgear - self.savegear)
            if mode == 'SPORTS' then
                ModifyVehicleTopSpeed(self.vehicle, 0.9)
                torque = GetVehicleCheatPowerIncrease(self.vehicle)
                torque = torque * ( self.savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                local finalboost = boost + (engineload / (mg - (mg-self.savegear)) * (invertrpm + saferpm)) / mg * self.savegear + engineload
                if not alreadyturbo then
                    SetVehicleBoost(self.vehicle, finalboost)
                end
            elseif dummygear == 0 then
                ModifyVehicleTopSpeed(self.vehicle, 1.0)
                torque = GetVehicleCheatPowerIncrease(self.vehicle)
                torque = torque * ( self.savegear / mg )
                local formulafuck = (saferpm / mg) + (torque * currentgear)
                local finalboost = (engineload / (mg - (mg-self.savegear)) * (invertrpm + saferpm)) / mg * self.savegear + engineload
                if speed > (lastgear * 0.80) and speed < (lastgear * 1.05) then -- method to help unstuck rpm due to gta native
                    finalboost = finalboost * 0.5
                    if not alreadyturbo then
                        SetVehicleBoost(self.vehicle, finalboost)
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
function Hud:speedtable(speed,gear)
    if clutchpressed then return 1.0 end
    oldtopspeed = maxspeed * self.olddriveinertia -- normalize
    local engineload = self.oldriveforce + ((self.rpm * self.olddriveinertia) * (gear / self.oldriveforce))
    local speedreduce = (oldtopspeed) * (config.gears[self.maxgear*1.0][gear] * self.olddriveinertia) / gear * self.oldriveforce * engineload
    local mg = self.maxgear
    if mg > 6 then
        mg = 6
    end
    speedreduce = (speedreduce / mg) * self.oldriveforce + (gear / self.rpm) / mg
    if mode == 'SPORTS' and globaltopspeed ~= nil then
        self.vehicletopspeed = globaltopspeed
    end
	if self.vehicletopspeed ~= nil and self.savegear >= 0 then
        if dummygear > 1 then
            mult = 0.95
        else
            mult = 0.9
        end
        local speedlimit = (self.vehicletopspeed * config.gears[self.maxgear*1.0][gear]) * mult
		local currentgear = self.savegear
        saferpm = self.olddriveinertia
        if self.savegear >= 1 then
            if mycurrentvehicle ~= self.vehicle and self.maxgear == 6 and self.savegear == 1 then -- anti 1st gear glitch for upgraded trannys / or after flatvel handling is change, weird.
                ModifyVehicleTopSpeed(self.vehicle, 1.0)
            end
            if modifyt == nil then -- anti gear ratio bug
                ModifyVehicleTopSpeed(self.vehicle, 1.0)
                modifyt = true
            end
            if og == 0 or og ~= self.savegear then
                og = self.savegear
                LockSpeed(self.vehicle, speedlimit/3.6)
            end
            if self.savegear > 0 then
                local minusgear = correctgears - 1
                local recent_speed = (self.vehicletopspeed * config.gears[self.maxgear*1.0][minusgear]) * 0.9
                Hud:antistall(speed, speedreduce, correctgears, recent_speed, self.rpm, self.vehicle, currentgear, saferpm, self.oldriveforce, engineload, recent_speed)
            end
            return	Hud:percentage(speed,speedlimit)
        else
            return 0.2
        end
    else
        return 1.0
	end
end

-- FORCE GTA NATIVE TO STOP SWITCHING GEARS AUTOMATICALLY
function Hud:ForceVehicleGear (vehicle, gear)
    ----print(GetVehicleThrottleOffset(Hud.vehicle))
    SetVehicleCurrentGear(vehicle, gear)
    SetVehicleNextGear(vehicle, gear)
    --Hud.savegear = gear
    --SetVehicleHighGear(vehicle, round(gear))
    --SetVehicleHighGear(vehicle, gear)
    return gear
end