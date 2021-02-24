AddRemoteEvent("OpenStorage", function(player, object, options)
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
    for index, inventory_item in ipairs(inventory) do
        if ItemConfig[inventory_item.item] then
            table.insert(_send.inventory_items, {
                ['index'] = index,
                ['item'] = inventory_item.item,
                ['uuid'] = inventory_item.uuid,
                ['slot'] = inventory_item.slot,
                ['quantity'] = inventory_item.quantity,

                ['name'] = ItemConfig[inventory_item.item].name,
                ['modelid'] = ItemConfig[inventory_item.item].modelid,
                ['image'] = ItemConfig[inventory_item.item].image,
                ['type'] = ItemConfig[inventory_item.item].type
            })
        end
    end

    log.trace("STORAGE SYNC: " .. json_encode(_send))
    CallRemoteEvent(player, "LoadStorageData", json_encode(_send))
end)

-- updates storage from storage UI sorting
-- [1] = { ["quantity"] = 1,["index"] = 1,["item"] = axe,}
AddRemoteEvent("UpdateStorage", function(player, object, type, data)
    local storage_items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updates storage:" .. object .. " type:" .. type .. dump(data))
    local storage_items = json_decode(data)
    log.debug(dump(storage_items))
    ReplaceStorageContents(object, type, storage_items)
end)

-- type is either 'object' or 'vehicle'
function ReplaceStorageContents(object, type, data)
    local new_storage = {}
    for index, item in ipairs(data) do
        -- lookup item configuration before storing it to ensure they are still valid
        if ItemConfig[item.item] then
            new_storage[index] = {
                item = item.item,
                uuid = item.uuid,
                slot = index,
                quantity = item.quantity,
                name = ItemConfig[item.item].name,
                modelid = ItemConfig[item.item].modelid,
                image = ItemConfig[item.item].image,
                type = ItemConfig[item.item].type
            }
        end
    end

    if type == 'vehicle' then
        SetVehiclePropertyValue(object, "storage", new_storage)
    else
        SetObjectPropertyValue(object, "storage", new_storage)
    end
end
