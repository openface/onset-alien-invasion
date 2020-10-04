AddRemoteEvent('PartPickedup', function()
    SetSoundVolume(CreateSound("client/sounds/part_pickup.wav"), 1)
    ShowMessage("You have found a computer part.  Use this on the satellite computer!")

    CallEvent("ShowSatelliteWaypoint")
end)
