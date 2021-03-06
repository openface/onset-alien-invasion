PlacedObjects = {}

InitTable("placed_items", {
    uuid = {
        type = 'char',
        length = 36,
        unique = true
    },
    item = {
        type = 'char',
        length = 24
    },
    location = {
        type = 'json'
    },
    steamid = {
        type = 'char',
        length = 17,
    },
}, false) -- true to recreate table

AddEvent("OnPackageStart", function()
    log.info("Creating placed items....")
    SelectRows("placed_items", "*", nil, onLoadPlacedItems)
end)

function onLoadPlacedItems()
    for i=1, mariadb_get_row_count() do
        local row = mariadb_get_assoc(i)
        local item = row['item']
        local loc = json_decode(row['location'])
    
        local object = CreateObject(ItemConfig[item].modelid, loc.x, loc.y, loc.z)
        if not object then
            log.error("Cannot create placed item: "..item)
            return
        end
    
        SetObjectPropertyValue(object, "item", item)
        SetObjectPropertyValue(object, "placeable", true)
        SetObjectPropertyValue(object, "placed_by", row['placed_by'])
        SetObjectPropertyValue(object, "prop", ItemConfig[item].prop_options)
    
        PlacedObjects[object] = row['uuid']
    
        log.debug("Spawned placed object " .. object .. " item " .. item)
    end
end

AddEvent("OnPackageStop", function()
    log.info("Destroying all placed objects...")
    for object in pairs(PlacedObjects) do
        --log.debug("Destroying placed object " .. object)
        PlacedObjects[object] = nil
        DestroyObject(object)
    end
end)

AddRemoteEvent("PlaceItem", function(player, uuid, loc)
    local item = GetItemInstance(uuid)

    if not ItemConfig[item] or ItemConfig[item].type ~= "placeable" then
        log.error("Cannot place invalid or non-placeable item!")
        return
    end

    UnequipItem(player, uuid)
    RemoveFromInventory(player, uuid)

    local object = CreateObject(ItemConfig[item].modelid, loc.x, loc.y, loc.z)
    if not object then
        return
    end

    local steamid = tostring(GetPlayerSteamId(player))

    SetObjectPropertyValue(object, "item", item)
    SetObjectPropertyValue(object, "placeable", true)
    SetObjectPropertyValue(object, "placed_by", steamid)

    if ItemConfig[item].prop_options then
        SetObjectPropertyValue(object, "prop", ItemConfig[item].prop_options)
    end

    -- generate new uuid for each placed object
    local object_uuid = generate_uuid()
    PlacedObjects[object] = object_uuid

    log.debug(GetPlayerName(player) .. " placed object " .. object .. " item " .. item)
    CallRemoteEvent(player, "ObjectPlaced", object)

    InsertRow("placed_items", {
        uuid = object_uuid,
        item = item,
        location = {
            x = loc.x,
            y = loc.y,
            z = loc.z
        },
        steamid = steamid,
    })
end)

AddRemoteEvent("FinalizeObjectPlacement", function(player, object)
    SetObjectPropertyValue(object, "placed_by", GetPlayerSteamId(player))
    log.debug(GetPlayerName(player) .. " placed object " .. object)
end)

AddRemoteEvent("UnplaceItem", function(player, object)
    local item = GetObjectPropertyValue(object, "item")
    if not ItemConfig[item] or ItemConfig[item].type ~= "placeable" then
        log.error("Cannot unplace invalid or non-placeable item!")
        return
    end

    PlacedObjects[object] = nil
    DestroyObject(object)



    local uuid = RegisterNewItem(item)
    AddToInventory(player, uuid)

    AddPlayerChat(player, ItemConfig[item].name .. " has been added to your inventory.")
    log.debug(GetPlayerName(player) .. " unplaced object " .. object .. " item " .. item)
end)

function GetPlacedObjectsByName(item)
    local placed_objects = {}
    for object,name in pairs(PlacedObjects) do
        if name == item then
            table.insert(placed_objects, object)
        end
    end
    return placed_objects
end

