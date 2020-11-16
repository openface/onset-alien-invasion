AddRemoteEvent('PlayPickupSound', function(sound)
    SetSoundVolume(CreateSound("client/"..sound), 1)
end)
