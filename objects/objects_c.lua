AddRemoteEvent("Play3DSound", function(sound, x, y, z)
    SetSoundVolume(CreateSound3D("client/"..sound, x, y, z, 1000), 1.0)
end)
