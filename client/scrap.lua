AddEvent("OnKeyPress", function(key)
    if key == "E" then
        CallRemoteEvent("SearchForScrap")
    end
end)