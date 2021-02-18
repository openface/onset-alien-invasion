PlacedObjects = {}

AddEvent("OnPackageStart", function()
    -- TODO: create placed objects once persistence is possible
end)


AddEvent("OnPackageStop", function()
    for object in pairs(PlacedObjects) do
        log.debug("Destroying placed object " .. object)
        PlacedObjects[object] = nil
        DestroyObject(object)
    end
end)

AddRemoteEvent("PlaceItem", function(player, item, loc)
    local item_cfg = GetItemConfig(item)
    if not item_cfg or item_cfg['type'] ~= "placeable" then
        log.error("Cannot place invalid or non-placeable item!")
        return
    end

    RemoveFromInventory(player, item)

    local object = CreateObject(item_cfg['modelid'], loc.x, loc.y, loc.z)
    if not object then
        return
    end

    SetObjectPropertyValue(object, "item", item)
    SetObjectPropertyValue(object, "placeable", true)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))

    if item_cfg['prop_options'] then
        SetObjectPropertyValue(object, "prop", item_cfg['prop_options'])
    end

    PlacedObjects[object] = true

    CallRemoteEvent(player, "ObjectPlaced", object)
    AddPlayerChat(player, "Object placed.")

    AddPlayerChat(player, item_cfg["name"] .. " has been placed.")
    log.debug(GetPlayerName(player) .. " placed object " .. object .. " item " .. item)
end)

AddRemoteEvent("FinalizeObjectPlacement", function(player, object)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))
    log.debug(GetPlayerName(player) .. " placed object " .. object)
end)

AddRemoteEvent("UnplaceItem", function(player, object)
    local item = GetObjectPropertyValue(object, "item")
    if not item_cfg or item_cfg['type'] ~= "placeable" then
        log.error("Cannot unplace invalid or non-placeable item!")
        return
    end

    PlacedObjects[object] = nil
    DestroyObject(object)

    local uuid = RegisterNewItem(item)
    AddToInventory(player, uuid)

    AddPlayerChat(player, item_cfg["name"] .. " has been added to your inventory.")
    log.debug(GetPlayerName(player) .. " unplaced object " .. object .. " item " .. item)
end)
