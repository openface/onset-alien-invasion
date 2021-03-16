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
    rotation = {
        type = 'json'
    },
    storage = {
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
        SetObjectPropertyValue(object, "steamid", row['steamid'])

        SetObjectPropertyValue(object, "prop", ItemConfig[item].prop)

        -- rotation
        local rot = json_decode(row['rotation'])
        SetObjectRotation(object, rot.x, rot.y, rot.z)

        -- setup items in storage
        local storage = json_decode(row['storage'])
        for i, item in ipairs(storage) do
            SetItemInstance(item.uuid, item.item)
        end
        SetObjectPropertyValue(object, "storage", storage)


        PlacedObjects[object] = {
            uuid = row['uuid'],
            item = row['item']
        }
    
        -- todo: particles, components, etc

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
    SetObjectPropertyValue(object, "steamid", steamid)

    if ItemConfig[item].prop then
        SetObjectPropertyValue(object, "prop", ItemConfig[item].prop)
    end

    -- generate new uuid for each placed object
    local object_uuid = generate_uuid()
    PlacedObjects[object] = {
        uuid = object_uuid,
        item = item
    }

    log.debug(GetPlayerName(player) .. " placed object " .. object .. " item " .. item)
    CallRemoteEvent(player, "ObjectPlaced", object)

    CallEvent("items:" .. item .. ":placed", player, object)

    local rx, ry, rz = GetObjectRotation(object)

    InsertRow("placed_items", {
        uuid = object_uuid,
        item = item,
        location = {
            x = loc.x,
            y = loc.y,
            z = loc.z
        },
        rotation = {
            x = rx,
            y = ry,
            z = rz
        },
        storage = {}, -- todo
        steamid = steamid,
    })
end)

AddRemoteEvent("UpdateObjectPlacement", function(player, object, x, y, z, rx, ry, rz)
    local item = GetObjectPropertyValue(object, "item")
    if not ItemConfig[item] or ItemConfig[item].type ~= "placeable" then
        log.error "Cannot place non-placeable objects"
        return
    end

    local po = PlacedObjects[object]
    if not po.uuid then
        log.error "Cannot place unknown item"
        return
    end

    SetObjectPropertyValue(object, "steamid", GetPlayerSteamId(player))

    UpdateRows("placed_items", {
        location = {
            x = x,
            y = y,
            z = z
        },
        rotation = {
            x = rx,
            y = ry,
            z = rz
        }
    }, { uuid = po.uuid })
    log.debug(GetPlayerName(player) .. " placed object " .. object)
end)

AddRemoteEvent("UnplaceItem", function(player, object)
    local item = GetObjectPropertyValue(object, "item")
    if not ItemConfig[item] or ItemConfig[item].type ~= "placeable" then
        log.error "Cannot pick up non-placeable objects"
        return
    end

    -- ownership check?
--[[     local steamid = GetObjectPropertyValue(object, "steamid")
    if not steamid or steamid ~= tostring(GetPlayerSteamId(player)) then
        CallRemoteEvent(player, "ShowError", "Cannot pick this up!")
        return
    end ]]

    RemovePlacedObject(object)

    local uuid = RegisterNewItem(item)
    AddItemInstanceToInventory(player, uuid)

    CallRemoteEvent(player, "ShowMessage", ItemConfig[item].name .. " has been added to your inventory.")
    log.debug(GetPlayerName(player) .. " unplaced object " .. object .. " item " .. item .. " new uuid: " .. uuid)
end)

function GetPlacedObjectsByName(item)
    local placed_objects = {}
    for object,p in pairs(PlacedObjects) do
        if p.item == item then
            table.insert(placed_objects, object)
        end
    end
    return placed_objects
end

function GetPlacedObjectsCount()
    return #table.keys(PlacedObjects)
end

function RemovePlacedObject(object)
    placed = PlacedObjects[object]
    if not placed then
        return
    end

    PlacedObjects[object] = nil
    DestroyObject(object)
    DeleteRow("placed_items", { uuid = placed.uuid })
end
