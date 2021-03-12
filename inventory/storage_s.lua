AddEvent("UnlockStorage", function(player, ActiveProp)
    log.trace("UnlockStorage", ActiveProp.hit_object)

    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if not prop then
        log.error("No storage object to unlock!", ActiveProp.hit_object)
        return
    end
    prop.options['locked'] = false
    SetObjectPropertyValue(ActiveProp.hit_object, "prop", prop)
    log.debug(GetPlayerName(player) .. " unlocked storage", ActiveProp.hit_object)
    CallRemoteEvent(player, "ShowMessage", "Storage is now unlocked!")
end)

AddEvent("OpenStorage", function(player, ActiveProp)
    log.trace("OpenStorage " .. dump(ActiveProp))

    if ActiveProp.options['locked'] then
        CallRemoteEvent(player, "ShowError", "Locked")
        return
    end

    log.info(GetPlayerName(player) .. " opens storage object " .. ActiveProp.hit_object .. " type " ..
                 ActiveProp.options['storage_type'])

    local x, y, z
    local storage_items

    if ActiveProp.options['storage_type'] == 'vehicle' then
        x, y, z = GetVehicleLocation(ActiveProp.hit_object)
        storage_items = GetVehiclePropertyValue(ActiveProp.hit_object, "storage") or {}
    elseif ActiveProp.options['storage_type'] == 'npc' then
        x, y, z = GetNPCLocation(ActiveProp.hit_object)
        storage_items = GetNPCPropertyValue(ActiveProp.hit_object, "storage") or {}
    else
        x, y, z = GetObjectLocation(ActiveProp.hit_object)
        storage_items = GetObjectPropertyValue(ActiveProp.hit_object, "storage") or {}
    end

    PlaySoundSync("sounds/storage_open.wav", x, y, z)

    local _send = {
        object = ActiveProp.hit_object,
        type = ActiveProp.options['storage_type'],
        storage_name = ActiveProp.options['storage_name'],
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
    log.trace("UpdateStorage", object, storage_type, dump(data))
    ReplaceStorageContents(object, storage_type, json_decode(data))
end)

-- storage type is either 'object' or 'vehicle' or 'npc'
function ReplaceStorageContents(object, storage_type, data)
    local old_storage = GetObjectStorage(object, storage_type)

    -- UnregisterItemInstance(item.uuid)

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

    SetObjectStorage(object, storage_type, new_storage)
end

function GetObjectStorage(object, storage_type)
    if storage_type == 'vehicle' then
        return GetVehiclePropertyValue(object, "storage")
    elseif storage_type == 'npc' then
        return GetNPCPropertyValue(object, "storage")
    else
        return GetObjectPropertyValue(object, "storage")
    end
end

function SetObjectStorage(object, storage_type, data)
    if storage_type == 'vehicle' then
        SetVehiclePropertyValue(object, "storage", data)
    elseif storage_type == 'npc' then
        SetNPCPropertyValue(object, "storage", data)
    else
        SetObjectPropertyValue(object, "storage", data)
    end
end
