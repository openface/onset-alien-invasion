AddEvent("OnKeyPress", function(key)
    if key == "E" then
        CallRemoteEvent("SearchForScrap")
    end
end)

AddRemoteEvent('ScrapPickedup', function()
    SetSoundVolume(CreateSound("client/sounds/part_pickup.wav"), 1)
end)

AddRemoteEvent('SearchingScrap', function()
    SetSoundVolume(CreateSound("client/sounds/search.mp3"), 1)
end)