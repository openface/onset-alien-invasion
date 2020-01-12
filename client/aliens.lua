AddRemoteEvent("AlienAttacking", function(npc)
    AddPlayerChat('You are being attacked by an alien... RUN!')
    if not IsValidSound(AmbientSound) then
        AmbientSound = CreateSound("client/sounds/ambience.mp3")
    end
    SetSoundVolume(AmbientSound, 2)

    local x, y, z = GetNPCLocation(npc)
    local AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 5000.0)
    SetSoundVolume(AttackSound, 1)

    --local px, py, pz = GetPlayerLocation(GetPlayerId())
    --local dist = GetDistance3D(x, y, z, px, py, pz)
    --if (dist < 5000) then
    -- 
    --end
end)

AddRemoteEvent('AlienNoLongerAttacking', function()
    AddPlayerChat('You are safe for now.')
    if IsValidSound(AmbientSound) then
        DeleteSound(AmbientSound)
    end
end)