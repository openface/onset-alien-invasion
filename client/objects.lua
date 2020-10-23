AddRemoteEvent("PlayObjectUseSound", function(sound, x, y, z)
    SetSoundVolume(CreateSound3D("client/"..sound, x, y, z, 1000), 1.0)
end)

-- prevent player from aiming if equipping certain items
AddEvent("OnPlayerToggleAim", function(toggle)
    local prevent_aiming = GetPlayerPropertyValue(GetPlayerId(), "prevent_aiming")

    if toggle == true and prevent_aiming == true then
        return false
    end
end)
