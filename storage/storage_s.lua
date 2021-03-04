AddRemoteEvent("OpenStorage", function(player, prop)
    log.trace("OpenStorage")
    
    if true then
        log.debug "ShowLockpick"
        CallRemoteEvent(player, "ShowLockpick")
        return
    end

    log.info(GetPlayerName(player) .. " opens storage object " .. prop.hit_object .. " type " ..
                 prop.options['storage_type'])

    local x, y, z
    local storage_items

    if prop.options['storage_type'] == 'vehicle' then
        x, y, z = GetVehicleLocation(prop.hit_object)
        storage_items = GetVehiclePropertyValue(prop.hit_object, "storage") or {}
    else
        x, y, z = GetObjectLocation(prop.hit_object)
        storage_items = GetObjectPropertyValue(prop.hit_object, "storage") or {}
    end

    PlaySoundSync("sounds/storage_open.wav", x, y, z)

    local _send = {
        object = prop.hit_object,
        type = prop.options['storage_type'],
        storage_name = prop.options['storage_name'],
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
                ['used'] = inventory_item.used,

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
AddRemoteEvent("UpdateStorage", function(player, object, storage_type, data)
    local storage_items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updates storage:" .. object .. " type:" .. storage_type .. dump(data))
    local storage_items = json_decode(data)
    log.debug(dump(storage_items))
    ReplaceStorageContents(object, storage_type, storage_items)
end)

-- type is either 'object' or 'vehicle'
function ReplaceStorageContents(object, storage_type, data)
    local old_storage
    if storage_type == 'vehicle' then
        old_storage = GetVehiclePropertyValue(object, "storage")
    else
        old_storage = GetObjectPropertyValue(object, "storage")
    end

    local new_storage = {}
    for index, item in ipairs(data) do
        -- lookup item configuration before storing it to ensure they are still valid
        if ItemConfig[item.item] then
            new_storage[index] = {
                item = item.item,
                uuid = item.uuid,
                slot = item.slot, -- storage slot
                quantity = item.quantity,
                used = item.used,

                name = ItemConfig[item.item].name,
                modelid = ItemConfig[item.item].modelid,
                image = ItemConfig[item.item].image,
                type = ItemConfig[item.item].type
            }
        end
    end

    if storage_type == 'vehicle' then
        SetVehiclePropertyValue(object, "storage", new_storage)
    else
        SetObjectPropertyValue(object, "storage", new_storage)
    end
end
