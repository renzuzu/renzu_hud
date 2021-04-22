maxgear = 5
RenzuCommand('manual', function()
	if manual then
	    local topspeed = GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel") * 0.64
	    LockSpeed(vehicle,topspeed)
	    ForceVehicleGear(vehicle, 1)
	    SetVehicleHandbrake(vehicle,false)
    elseif not manual then
        Creation(function()
            maxgear = GetVehicleHandlingFloat(vehicle, "CHandlingData","nInitialDriveGears")
            vehicletopspeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
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
                --savegear = GetVehicleCurrentGear(vehicle)
                if IsControlJustReleased(2, 193) and manual or IsControlPressed(2, 193) or IsControlJustReleased(1, 20) and manual or IsControlPressed(1, 20) and manual or IsControlPressed(1, 20) and IsControlPressed(1, 32) and manual then
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
-- 			if not IsControlPressed(0, 162) and not IsControlPressed(0, 110) and not IsControlPressed(0, 163) and not IsControlPressed(0, 117) and not IsControlPressed(0, 111) and not IsControlPressed(0, 118) and shifter then
-- 				Renzuzu.Wait(2000)
-- 				if not IsControlPressed(0, 162) and not IsControlPressed(0, 110) and not IsControlPressed(0, 163) and not IsControlPressed(0, 117) and not IsControlPressed(0, 111) and not IsControlPressed(0, 118) and shifter then
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

                if not enginerunning and IsControlPressed(1, 32) then
                    SetVehicleEngineOn(vehicle,true,false,false)
                    savegear = 0
                end

                --up shifting with or power shifting mode (while clutch is pressed)
                if IsControlJustReleased(1, 172) and clutch or IsControlPressed(1, 32) and IsControlJustReleased(1, 172) and clutch and IsControlJustReleased(1, 20) or IsControlPressed(1, 32) and IsControlJustReleased(1, 172) and clutch and IsControlJustReleased(2, 193) then
                    if reverse then
                        savegear = 0
                        reverse = false
                        Renzu_SetGear(vehicle,0)
                        ShowHelpNotification("Neutral", true, 1, 5)
                    else
                        if maxgear >= (savegear + 1) then
                            savegear = savegear + 1
                            Renzu_SetGear(vehicle,currentgear + 1)
                            ShowHelpNotification(savegear, true, 1, 5)
                        end
                    end
                    Renzuzu.Wait(100)
                end

                --down shifting with or power shifting mode
                if IsControlJustReleased(1, 173) and savegear > 0 and clutch or IsControlPressed(1, 32) and IsControlJustReleased(1, 173) and savegear > 0 and clutch and IsControlJustReleased(1, 20) then
                    savegear = savegear - 1
                    Renzu_SetGear(vehicle,currentgear - 1)
                    if savegear == 0 then
                        ShowHelpNotification('NEUTRAL', true, 1, 5)
                    else
                        ShowHelpNotification(savegear, true, 1, 5)
                    end
                    Renzuzu.Wait(100)
                end

                --clutch mode with force handbrake if less than 10 kmh
                if IsControlPressed(1, 20) or IsControlPressed(2, 193) then
                    --ForceVehicleGear(vehicle, 0)
                    if speed < 10 then
                        ForceVehicleGear(vehicle, 0)
                        SetVehicleHandbrake(vehicle,true)
                    end
                end

                if savegear == 0 and IsControlPressed(1, 20) and IsControlJustReleased(1, 173) or savegear == 0 and clutch and IsControlJustReleased(1, 173) then
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
                if handbrake and not IsControlPressed(1, 20) and savegear > 0 and not clutch or IsControlPressed(1, 33) and reverse and not clutch then
                    --ForceVehicleGear(vehicle, 0)
                    if speed < 10 then
                        SetVehicleHandbrake(vehicle,false)
                    end
                end

                --main loop manual system
                Renzu_Hud(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                Renzu_Hud(GetHashKey('SET_VEHICLE_NEXT_GEAR') & 0xFFFFFFFF, vehicle, savegear)
                --speedtable(speed,savegear)
                if not IsControlPressed(1, 22) and speed > 5 then
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
                -- if IsControlPressed(1, 32) then
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
                if IsControlPressed(1, 20) and IsControlPressed(1, 32) and speed < 11 and rpm >= 0.5 or clutch and IsControlPressed(1, 32) and speed < 11 and rpm >= 0.5 then
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
                --     if IsControlPressed(0, 162) and clutch then
                --         savegear = 1
                --         Renzu_SetGear(vehicle,1)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if IsControlPressed(0, 110) and clutch then
                --         savegear = 2
                --         Renzu_SetGear(vehicle,2)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if IsControlPressed(0, 163) and clutch then
                --         savegear = 3
                --         Renzu_SetGear(vehicle,3)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if IsControlPressed(0, 117) and clutch then
                --         savegear = 4
                --         Renzu_SetGear(vehicle,4)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end

                --     if IsControlPressed(0, 111) and clutch then
                --         savegear = 5
                --         Renzu_SetGear(vehicle,5)
                --         ShowHelpNotification(savegear, true, 1, 5)
                --     end
                --     if IsControlPressed(0, 118) and clutch then
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

-- MAIN MANUAL SYSTEM LOOP ( EDIT THIS if you know the system )
function speedtable(speed,gear)
    --ShowHelpNotification(percentage(20,60), true, 1, 5)
    --SetVehicleHandlingField(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 250*1.000000)
    --local drive = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
    --local force = GetVehicleHandlingFloat(vehicle ,"CHandlingData", "fInitialDriveForce")
	if vehicletopspeed ~= nil then
		--local vehicletopspeed = GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fInitialDriveMaxFlatVel")
		local first = (vehicletopspeed * 0.33) * 0.9
		local second = (vehicletopspeed * 0.57) * 0.9
		local third = (vehicletopspeed * 0.84) * 0.9
		local fourth = (vehicletopspeed * 1.22) * 0.9
		local fifth = (vehicletopspeed * 1.45) * 0.9
		local sixth = (vehicletopspeed * 1.60) * 0.9
		local currentgear = savegear
		if currentgear == 1 and speed <= first then

		LockSpeed(vehicle, first)

		return	percentage(speed,first)

		elseif currentgear == 2 and speed <= second then
		if speed <= (first - (first * 0.22925)) then
			Renzu_SetGear(vehicle,currentgear - 1)
		end
		LockSpeed(vehicle, second)

		return	percentage(speed,second)

		elseif currentgear == 3 and speed <= third then
		if speed <= (second) then
			Renzu_SetGear(vehicle,currentgear - 1)
		end
		LockSpeed(vehicle, third)

		return	percentage(speed,third)

		elseif currentgear == 4 and speed <= fourth then
		if speed <= (third) then
			Renzu_SetGear(vehicle,currentgear - 1)
		end
		LockSpeed(vehicle, fourth)

		return	percentage(speed,fourth)

		elseif currentgear == 5 and speed <= fifth then
		if speed <= (fourth - (first * 0.22925)) then
			Renzu_SetGear(vehicle,currentgear - 1)
		end
		LockSpeed(vehicle, fifth)

		return	percentage(speed,fifth)

		elseif currentgear == 6 and speed <= sixth then
		if speed <= (fifth - (fifth * 0.11525)) then
			Renzu_SetGear(vehicle,currentgear - 1)
		end
		return	percentage(speed,sixth)
		elseif currentgear > 0 then
			return 1.4
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
    --SetVehicleHighGear(vehicle, gear)
    return gear
end