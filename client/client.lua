




AddEvent('OnPlayerSpawn', function()
    StartCameraFade(1.0, 0.0, 10.0, "#000")
    local player = GetPlayerId()
    SetPlayerClothingPreset(player, 25)
    SetPostEffect("Chromatic", "Intensity", 0.0)
    SetPostEffect("Chromatic", "StartOffset", 0.0)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, 'clothing')
    SetNPCClothingPreset(npc, clothing)
end)

AddRemoteEvent('AlienAttacking', function(npc)
    AddPlayerChat('You are being attacked by an alien... RUN!')

    local x, y, z = GetNPCLocation(npc)
    local AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 3000.0)
    SetSoundVolume(AttackSound, 1)

	SetPostEffect("Chromatic", "Intensity", 2.0)
	SetPostEffect("Chromatic", "StartOffset", 0.1)
end)

AddRemoteEvent('AlienNoLongerAttacking', function(npc)
    AddPlayerChat('You are safe for now.')

    SetPostEffect("Chromatic", "Intensity", 0.0)
	SetPostEffect("Chromatic", "StartOffset", 0.0)
end)

AddRemoteEvent('HealthPickup', function()
    local HealthPickupSound = CreateSound("sounds/health_pickup.wav")
    SetSoundVolume(HealthPickupSound, 1)
end)

AddRemoteEvent('LootSpawnNearby', function(pos)
    local LootSpawnSound = CreateSound3D("client/sounds/flyby.wav", pos[1], pos[2], pos[3] + 10000, 100000.0)
    SetSoundVolume(LootSpawnSound, 1)
    AddPlayerChat('There is a supply drop nearby!')

    local timer = CreateTimer(function(pos)
        CreateFireworks(3, pos[1], pos[2], pos[3] + 150, 90, 0, 0)
    end, 3000, pos)

    -- fireworks for 30 secs
    Delay(30 * 1000, function(timer)
        DestroyTimer(timer)
    end, timer)
end)

