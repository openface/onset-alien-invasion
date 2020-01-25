AddRemoteEvent('LootPickedup', function(pickup)
    SetSoundVolume(CreateSound("client/sounds/health_pickup.wav"), 1)

    local waypoints = GetAllWaypoints()
    for _,w in pairs(waypoints) do
        DestroyWaypoint(w)
    end
end)

AddRemoteEvent('LootSpawned', function(pos, pickup)
    local waypoints = GetAllWaypoints()
    for _,w in pairs(waypoints) do
        DestroyWaypoint(w)
    end

    local x,y,z = GetPlayerLocation()
    if GetDistance3D(x, y, z, pos[1], pos[2], pos[3]) > 5000 then
        return
    end    

    local LootSpawnSound = CreateSound3D("client/sounds/flyby.mp3", pos[1], pos[2], pos[3] + 10000, 100000.0)
    SetSoundVolume(LootSpawnSound, 1)
    AddPlayerChat('There is a supply drop nearby!')

    CreateWaypoint(pos[1], pos[2], pos[3], "Supply Drop")

    -- fireworks/flares
    CreateCountTimer(function(pos)
        CreateFireworks(3, pos[1], pos[2], pos[3] + 150, 90, 0, 0)
    end, 3000, 10, pos)
end)