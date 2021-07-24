-- Variables
-- COPYRIGHT https://github.com/codibez/streetLabel
local directions = {
    N = 360, 0,
    NE = 315,
    E = 270,
    SE = 225,
    S = 180,
    SW = 135,
    W = 90,
    NW = 45
    --  N = 0, <= will result in the HUD breaking above 315deg
  }
  
  local veh = 0;
  local streetHash1, streetHash2, playerDirection;
  
Citizen.CreateThread(function()
    -- Wait a single second before sending data NUI message :? 
    Citizen.Wait(1000);
    SendNUIMessage({
        compass = true,
        type = 'streetLabel:DATA',
        border = config.border,
        direction = config.direction,
        zone = config.current,
        street = config.crossing,
        offsetX = config.position.offsetX,
        offsetY = config.position.offsetY
    });
end)

function Hud:Compass()
    local coords = GetEntityCoords(PlayerPedId());
    local zone = GetNameOfZone(coords.x, coords.y, coords.z);
    local zoneLabel = GetLabelText(zone);

    --if(checkForVehicle == false or veh ~= 0) then 
    local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
    streetHash1 = GetStreetNameFromHashKey(var1);
    streetHash2 = GetStreetNameFromHashKey(var2);
    playerDirection = GetEntityHeading(PlayerPedId());

    for k, v in pairs(directions) do
        if (math.abs(playerDirection - v) < 22.5) then
            playerDirection = k;

            if (playerDirection == 1) then
                playerDirection = 'N';
                break;
            end

            break;
        end
    end

    local street2 = '';
    if (streetHash2 == '') then
        street2 = zoneLabel;
    else
        street2 = streetHash2..', '..zoneLabel;
    end

    SendNUIMessage({
        compass = true,
        type = 'streetLabel:MSG',
        active = true,
        direction = playerDirection,
        zone = streetHash1,
        street = street2
    });
end