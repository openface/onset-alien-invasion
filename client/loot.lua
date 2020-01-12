AddRemoteEvent('LootPickup', function()
    SetSoundVolume(CreateSound("client/sounds/health_pickup.wav"), 1)
end)

AddRemoteEvent('LootSpawnNearby', function(pos)
    local LootSpawnSound = CreateSound3D("client/sounds/flyby.mp3", pos[1], pos[2], pos[3] + 10000, 100000.0)
    SetSoundVolume(LootSpawnSound, 1)
    AddPlayerChat('There is a supply drop nearby!')

    -- fireworks/flares
    CreateCountTimer(function(pos)
        CreateFireworks(3, pos[1], pos[2], pos[3] + 150, 90, 0, 0)
    end, 3000, 10, pos)
end)