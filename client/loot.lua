local LootNearbyRange = 50000 -- distance to loot that is considered nearby
local LootWaypoint

AddRemoteEvent('LootPickedup', function(pickup)
    SetSoundVolume(CreateSound("client/sounds/health_pickup.wav"), 1)
    HideLootWaypoint()
end)

function HideLootWaypoint()
    if LootWaypoint ~= nil then
        DestroyWaypoint(LootWaypoint)
    end
end
AddEvent("HideLootWaypoint", HideLootWaypoint)
AddRemoteEvent("HideLootWaypoint", HideLootWaypoint)

AddRemoteEvent('LootSpawned', function(pos, pickup)
    HideLootWaypoint()

    local x,y,z = GetPlayerLocation()
    if GetDistance3D(x, y, z, pos[1], pos[2], pos[3]) > LootNearbyRange then
        return
    end    

    local LootSpawnSound = CreateSound3D("client/sounds/flyby.mp3", pos[1], pos[2], pos[3] + 10000, 100000.0)
    SetSoundVolume(LootSpawnSound, 1)
    AddPlayerChat('There is a supply drop nearby!')

    LootWaypoint = CreateWaypoint(pos[1], pos[2], pos[3] + 50, "Supply Drop")

    -- fireworks/flares
    CreateCountTimer(function(pos)
        CreateFireworks(3, pos[1], pos[2], pos[3] + 150, 90, 0, 0)
    end, 3000, 10, pos)
end)