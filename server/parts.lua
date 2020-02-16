local PartsLocations = {} -- parts.json
local PartObjectID = 1437

AddCommand("ppos", function(player)
    if not IsAdmin(player) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    print(string)
    table.insert(PartsLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/parts.json", PartsLocations)
end)

AddCommand("part", function(player)
    if not IsAdmin(player) then
        return
    end
    EquipPart(player)
end)

function OnPackageStart()
    PartsLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/parts.json")
    print("Spawning pickups: "..#PartsLocations)
    -- spawn all parts
    for _,pos in pairs(PartsLocations) do
        local pickup = CreatePickup(PartObjectID, pos[1], pos[2], pos[3])
        SetPickupPropertyValue(pickup, 'type', 'part')
        SetPickupScale(pickup, 3, 3, 3)
    end
end
AddEvent("OnPackageStart", OnPackageStart)

-- pickup part
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') ~= 'part') then
        return
    end
        
    EquipPart(player)

    -- hide part pickup for 5 mins from player
    SetPickupVisibility(pickup, player, false)
    Delay(5 * 60 * 1000, function()
        SetPickupVisibility(pickup, player, true)
    end)
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function EquipPart(player)
    if (GetPlayerPropertyValue(player, 'carryingPart') ~= nil) then
        -- already carrying a part
        CallRemoteEvent(player, "ShowMessage", "Take your part to the satellite computer!")
        return
    end

    -- carry with left hand
    local x,y,z = GetPlayerLocation(player)
    local part = CreateObject(PartObjectID, x, y, z)
    SetObjectAttached(part, ATTACH_PLAYER, player, 10, -5, 0, 0, 0, 90, "hand_l")

    SetPlayerPropertyValue(player, 'carryingPart', part, true)
    AddPlayerChatAll(GetPlayerName(player)..' has found a computer part!')
    CallRemoteEvent(player, "PartPickedup", pickup)
end

-- drop part on death
AddEvent("OnPlayerDeath", function(player, killer)
    local part = GetPlayerPropertyValue(player, "carryingPart")
    if part ~= nil then
        DestroyObject(part)
    end
    SetPlayerPropertyValue(player, 'carryingPart', nil, true)
    CallRemoteEvent(player, "HideSatelliteWaypoint")
end)


