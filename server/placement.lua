local TemporaryObjects = {}

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

AddRemoteEvent("PlaceItem", function(player, item)
    local item_cfg = GetItemConfig(item)

    local x, y, z = GetPlayerLocation(player)
    local object = CreateObject(item_cfg['modelid'], x + 50, y, z)
    if not object then
        return
    end
    SetObjectPropertyValue(object, "temporary", true)
    SetObjectPropertyValue(object, "item", item)
    SetObjectPropertyValue(object, "created_by", GetPlayerSteamId(player))

    TemporaryObjects[player] = object

    log.debug(GetPlayerName(player) .. " created temporary object " .. object .. " item " .. item)
end)

AddCommand("edit", function(player)
    CallRemoteEvent(player, "EnableEditMode")
end)


