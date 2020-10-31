local AmbientSound
local AmbientSoundTimer
local BeingAttacked = false

AddEvent("OnPackageStop", function()
    if AmbientSound ~= nil then
        DestroySound(AmbientSound)
    end
    if AmbientSoundTimer ~= nil then
      DestroyTimer(AmbientSoundTimer)
    end
    BeingAttacked = false
end)

AddRemoteEvent("AlienAttacking", function(npc)
    if BeingAttacked == false then
          -- initial sound
        AmbientSound = CreateSound("client/sounds/ambience.mp3")
        SetSoundVolume(AmbientSound, 2.5)
        -- sound loop
        AmbientSoundTimer = CreateTimer(function()
            if AmbientSound ~= nil then
                DestroySound(AmbientSound)
            end
            AmbientSound = CreateSound("client/sounds/ambience.mp3")
            SetSoundVolume(AmbientSound, 2.5)
        end, 15 * 1000)
    end

    AddPlayerChat('You are being attacked by an alien... RUN!')
    BeingAttacked = true

    -- alien attack sounds
    local x, y, z = GetNPCLocation(npc)
    if x ~= nil then
        local AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 6000.0)
        SetSoundVolume(AttackSound, 0.6)
    end
end)

AddRemoteEvent('AlienNoLongerAttacking', function()
    AddPlayerChat('You are safe for now.')
    BeingAttacked = false

    if AmbientSound ~= nil then
        DestroySound(AmbientSound)
    end
    if AmbientSoundTimer ~= nil then
        DestroyTimer(AmbientSoundTimer)
    end

end)

AddRemoteEvent("OnAlienHit", function(player)
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    InvokeDamageFX(1000)
end)
