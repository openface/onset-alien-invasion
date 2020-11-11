local AmbientSound
local AttackSound

AddEvent("OnPackageStop", function()
    if AmbientSound ~= nil then
        DestroySound(AmbientSound)
    end
    if AttackSound ~= nil then
      DestroySound(AttackSound)
  end
end)

AddRemoteEvent("AlienAttacking", function(npc)
    if AmbientSound == nil then
        AmbientSound = CreateSound("client/sounds/ambience.mp3")
        SetSoundVolume(AmbientSound, 2.5)
    end

    AddPlayerChat('You are being attacked by an alien... RUN!')

    -- alien attack sound
    if AttackSound == nil then
        local x, y, z = GetNPCLocation(npc)
        if x and y and z then
            AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 6000.0)
            SetSoundVolume(AttackSound, 0.6)
        end
    end
end)

AddRemoteEvent('AlienNoLongerAttacking', function()
    AddPlayerChat('You are safe for now.')

    if AmbientSound ~= nil then
        DestroySound(AmbientSound)
    end
    if AttackSound ~= nil then
        DestroySound(AttackSound)
    end
end)

AddRemoteEvent("OnAlienHit", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    InvokeDamageFX(1000)
end)
