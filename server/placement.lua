PlacedObjects = {}

AddEvent("OnPackageStart", function()
    -- TODO: create placed objects once persistence is possible
end)


AddEvent("OnPackageStop", function()
    for object in pairs(PlacedObjects) do
        log.debug("Destroying placed object " .. object)
        DestroyObject(object)
    end
end)

AddRemoteEvent("PlaceItem", function(player, item, loc)
    log.debug("placing" .. item)
    local item_cfg = GetItemConfig(item)
    if not item_cfg then
        return
    end

    local object = CreateObject(item_cfg['modelid'], loc.x, loc.y, loc.z)
    if not object then
        return
    end

    SetObjectPropertyValue(object, "item", item)
    SetObjectPropertyValue(object, "placeable", true)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))

    PlacedObjects[object] = true

    CallRemoteEvent(player, "ObjectPlaced", object)

    log.debug(GetPlayerName(player) .. " placed object " .. object .. " item " .. item)
end)

AddRemoteEvent("FinalizeObjectPlacement", function(player, object)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))
    log.debug(GetPlayerName(player) .. " placed object " .. object)
end)

