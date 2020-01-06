local AmbientSound

AddEvent('OnPlayerSpawn', function()
    StartCameraFade(1.0, 0.0, 13.0, "#000")
    local player = GetPlayerId()
    SetPlayerClothingPreset(player, 25)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0.0)
    StopCameraShake(false)

    AmbientSound = CreateSound("client/sounds/ambience.mp3")
    SetSoundVolume(AmbientSound, 1)
end)

function OnPlayerDeath(player, killer)
    SetPostEffect("ImageEffects", "VignetteIntensity", 2.0)
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, 'clothing')
    SetNPCClothingPreset(npc, clothing)
end)

AddRemoteEvent('AlienAttacking', function(npc)
    AddPlayerChat('You are being attacked by an alien... RUN!')
    if not IsValidSound(AmbientSound) then
        AmbientSound = CreateSound("client/sounds/ambience.mp3")
    end
    SetSoundVolume(AmbientSound, 2)

    local x, y, z = GetNPCLocation(npc)
    local AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 3000.0)
    SetSoundVolume(AttackSound, 1)

    --local px, py, pz = GetPlayerLocation(GetPlayerId())
    --local dist = GetDistance3D(x, y, z, px, py, pz)
    --if (dist < 5000) then
    -- 
    --end
end)

AddRemoteEvent('AlienTouched', function()
    SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
    SetCameraShakeFOV(5.0, 5.0)
    PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
end)

AddRemoteEvent('AlienNoLongerAttacking', function()
    AddPlayerChat('You are safe for now.')
    if IsValidSound(AmbientSound) then
        DeleteSound(AmbientSound)
    end
end)

AddRemoteEvent('LootPickup', function()
    SetSoundVolume(CreateSound("client/sounds/health_pickup.wav"), 1)
end)

AddRemoteEvent('LootSpawnNearby', function(pos)
    local LootSpawnSound = CreateSound3D("client/sounds/flyby.mp3", pos[1], pos[2], pos[3] + 10000, 100000.0)
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

