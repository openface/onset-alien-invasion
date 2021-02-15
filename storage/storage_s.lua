AddRemoteEvent("prop:OpenStorage", function(player, object, options)
    log.info(GetPlayerName(player) .. " opens storage " .. object .. " type " .. options['type'])

    PlaySoundSync(player, "sounds/storage_open.wav")

    local storage_items
    if options['type'] == 'vehicle' then
        storage_items = GetVehiclePropertyValue(object, "storage") or {}
    else
        storage_items = GetObjectPropertyValue(object, "storage") or {}
    end

    local _send = {
        object = object,
        type = options['type'],
        storage_name = options['name'],
        storage_items = storage_items,
        inventory_items = {}
    }

    -- inventory
    local inventory = PlayerData[player].inventory
    for index, item in ipairs(inventory) do
        -- usable, equipable, resource
        table.insert(_send.inventory_items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['image'] = item['image'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type']
        })
    end

    log.trace("STORAGE SYNC: " .. json_encode(_send))
    CallRemoteEvent(player, "LoadStorageData", json_encode(_send))
end)

-- updates storage from storage UI sorting
-- [1] = { ["quantity"] = 1,["index"] = 1,["item"] = axe,}
AddRemoteEvent("UpdateStorage", function(player, object, type, data)
    local storage_items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updates storage:" .. object .. " type:" .. type)
    ReplaceStorageContents(object, type, storage_items)
end)

AddRemoteEvent("MoveStorageItemToInventory", function(player, object, type, data)
    log.debug("MoveStorageItemToInventory", object, type, dump(data))
end)

AddRemoteEvent("MoveInventoryItemToStorage", function(player, object, type, data)
    log.debug("MoveInventoryItemToStorage", object, type, dump(data))
end)

-- type is either 'object' or 'vehicle'
function ReplaceStorageContents(object, type, data)
    local new_storage = {}
    for i, item in ipairs(data) do
        -- lookup item configuration before storing it to ensure they are still valid
        local item_cfg = GetItemConfig(item.item)
        if item_cfg then
            new_storage[i] = {
                index = i,
                item = item.item,
                quantity = item.quantity,
                name = item_cfg['name'],
                modelid = item_cfg['modelid'],
                image = item_cfg['image'],
                type = item_cfg['type']
            }
        end
    end

    if type == 'vehicle' then
        SetVehiclePropertyValue(object, "storage", new_storage)
    else
        SetObjectPropertyValue(object, "storage", new_storage)
    end
end
