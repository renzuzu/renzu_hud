
Citizen.CreateThread(function()
	if config.centercarhud == 'map' then
		Citizen.Wait(1000)
		while true do
			--print(GetNuiCursorPosition())
			local Plyped = PlayerPedId()
			if IsPedInAnyVehicle(Plyped) == 1 and start then
				if not ismapopen then
					Citizen.Wait(2000)
					SendNUIMessage({type = 'bukas'})
					ismapopen =  true
					Wait(250)
				end
				local myh = GetEntityHeading(Plyped) + GetGameplayCamRelativeHeading()
				local camheading = GetGameplayCamRelativeHeading()
				local xz, yz, zz = table.unpack(GetEntityCoords(Plyped))
				if oldxz ~= xz or oldcamheading ~= camheading or camheading == nil and xz == nil then
					oldcamheading = camheading
					oldxz = xz
					--print("updating")
					SendNUIMessage({type = "updatemapa",myheading = myh,camheading = camheading,x = xz,y = yz,})
				end
			elseif ismapopen and IsPedInAnyVehicle(ped) ~= 1 then
				SendNUIMessage({type = 'bukas'})
				ismapopen = false
				Wait(250)
				Citizen.Wait(1000)
			end
			Wait(100)
		end
	end
end)