local LootNearbyRange = 50000 -- distance to loot that is considered nearby
local LootWaypoint

AddEvent("OnPackageStop", function()
    HideLootWaypoint()
end)


AddRemoteEvent('LootPickedup', function(pickup)
    SetSoundVolume(CreateSound("client/sounds/health_pickup.wav"), 1)
    HideLootWaypoint()
end)

function HideLootWaypoint()
    if LootWaypoint ~= nil then
        print("destroy loot wp: "..LootWaypoint)
        DestroyWaypoint(LootWaypoint)
    end
end
AddEvent("HideLootWaypoint", HideLootWaypoint)
AddRemoteEvent("HideLootWaypoint", HideLootWaypoint)

AddRemoteEvent('LootDropping', function(x, y, z)
    HideLootWaypoint()
    SetSoundVolume(CreateSound3D("client/sounds/flyby.mp3", x, y, z + 10000, 100000.0), 1)
end)

AddRemoteEvent('LootSpawned', function(pickup, x, y, z)
    local px,py,pz = GetPlayerLocation()
    if GetDistance3D(px, py, pz, x, y, z) > LootNearbyRange then
        return
    end    

    AddPlayerChat('There is a supply drop nearby!')

    LootWaypoint = CreateWaypoint(x, y, z + 200, "Supply Drop")
end)
