TemporaryObjects = {}
AddEvent("OnPackageStop", function()
    for _, object in pairs(TemporaryObjects) do
        log.debug("Destroying temporary object " .. object)
        DestroyObject(object)
    end
end)

AddEvent("OnPlayerQuit", function(player)
    if TemporaryObjects[player] ~= nil then
        DestroyObject(TemporaryObjects[player])
    end
    TemporaryObjects[player] = nil
end)

AddRemoteEvent("PlaceItem", function(player, item, loc)
    log.debug("placing"..item)
    local item_cfg = GetItemConfig(item)
    if not item_cfg then return end

    local object = CreateObject(item_cfg['modelid'], loc.x, loc.y, loc.z)
    if not object then
        return
    end

    SetObjectPropertyValue(object, "item", item)
    SetObjectPropertyValue(object, "placed", true)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))

    log.debug(GetPlayerName(player) .. " placed object " .. object .. " item " .. item)

    CallRemoteEvent(player, "ObjectPlaced", object)
end)

AddRemoteEvent("FinalizeObjectPlacement", function(player)
end)

AddRemoteEvent("CancelObjectPlacement", function(player, object)
    log.debug(GetPlayerName(player) .. " cancels object placement of object "..object)
    DestroyObject(object)
end)
