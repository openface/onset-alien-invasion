local PartsLocations = {} -- parts.json
local PartPickups = {}
local PartObjectID = 1437
local NumSpawnedParts = 25 -- maximum number of parts to spawn

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

AddCommand("respawnparts", function(player)
    if not IsAdmin(player) then
        return
    end
    SpawnParts()
end)

AddCommand("part", function(player)
    if not IsAdmin(player) then
        return
    end
    PickupPart(player)
end)

AddEvent("OnPackageStart", function()
    PartsLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/parts.json")
    SpawnParts()
end)

function DespawnParts()
    for _,pickup in pairs(PartPickups) do
        --print("Destroying pickup: "..pickup)
        DestroyText3D(GetPickupPropertyValue(pickup, 'text3d'))
        DestroyPickup(pickup)
        PartPickups[pickup] = nil
    end
end

function SpawnParts()
    print "Spawning parts..."
    DespawnParts()

    -- randomize part locations
    local shuffled = {}
    for i,pos in ipairs(PartsLocations) do
        local p = math.random(1, #shuffled+1)
        table.insert(shuffled, p, pos)
    end

    -- randomly spawn a subset of parts
    for _,pos in pairs({table.unpack(shuffled, 1, NumSpawnedParts)}) do
        local pickup = CreatePickup(PartObjectID, pos[1], pos[2], pos[3])
        --CreateObject(303, pos[1], pos[2], pos[3], 0, 0, 0, 10, 10, 200) -- TODO remove me
        SetPickupPropertyValue(pickup, 'type', 'part')
        SetPickupScale(pickup, 3, 3, 3)
        SetPickupPropertyValue(pickup, 'text3d', CreateText3D("Computer Part", 9, pos[1], pos[2], pos[3]+50, 0,0,0))
        PartPickups[pickup] = pickup
        --print("Spawning part: "..dump(pos).." pickup: "..pickup)
    end
end

-- pickup part
AddEvent("OnPlayerPickupHit", function(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') ~= 'part') then
        return
    end
        
    PickupPart(player)

    -- remove from part index if it exists
    if PartPickups[pickup] ~= nil then
        PartPickups[pickup] = nil
    end
    DestroyText3D(GetPickupPropertyValue(pickup, 'text3d'))
    DestroyPickup(pickup)
end)

function PickupPart(player)
    CallEvent("AddItemToInventory", player, "Computer Part")

    AddPlayerChatAll(GetPlayerName(player)..' has found a computer part!')
    CallRemoteEvent(player, "PartPickedup", pickup)
end

-- clear satellite waypoint on death
AddEvent("OnPlayerDeath", function(player, killer)
    CallRemoteEvent(player, "HideSatelliteWaypoint")
end)

