AddRemoteEvent('PartPickedup', function(pickup)
    SetSoundVolume(CreateSound("client/sounds/part_pickup.wav"), 1)
    ShowMessage("You have found a computer part.  Use this part on the satellite computer!")

    ShowSatelliteWaypoint()    
end)
