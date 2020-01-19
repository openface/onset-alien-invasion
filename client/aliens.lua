local AmbientSound

AddRemoteEvent("AlienAttacking", function(npc)
    AddPlayerChat('You are being attacked by an alien... RUN!')

    if AmbientSound ~= nil then
        DestroySound(AmbientSound)
    end
    AmbientSound = CreateSound("client/sounds/ambience.mp3")
    SetSoundVolume(AmbientSound, 2)

    local x, y, z = GetNPCLocation(npc)
    local AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 6000.0)
    SetSoundVolume(AttackSound, 1)
end)

AddRemoteEvent('AlienNoLongerAttacking', function()
    AddPlayerChat('You are safe for now.')
    DestroySound(AmbientSound)
end)