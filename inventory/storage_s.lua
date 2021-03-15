Storages = {}

InitTable("storages", {
    uuid = {
        type = 'char',
        length = 36,
        unique = true
    },
    type = {
        type = 'char',
        length = '12'
    },
    contents = {
        type = 'json'
    },
    locked = {
        type = 'bool',
        default = 0
    }
}, true) -- true to recreate table

function MakeStorage(uuid, type, name, locked, contents)
    Storages[uuid] = {
        type = type,
        name = name,
        locked = locked,
        contents = contents
    }
end

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

AddRemoteEvent("OpenGlovebox", function(player, vehicle, uuid)
    CallEvent("OpenStorage", player, {
        hit_object = vehicle,
        storage = {
            uuid = uuid,
            type = 'vehicle'
        }
    })
end)

AddEvent("OpenStorage", function(player, ActiveProp)
    log.trace("OpenStorage " .. dump(ActiveProp))

    local uuid = ActiveProp.storage.uuid
    local storage_type = ActiveProp.storage.type

    if not Storages[uuid] then
        log.error("Cannot open non-storage object!")
        return
    end

    if Storages[uuid].type ~= ActiveProp.storage.type then
        log.error("Invalid storage!")
        return
    end

    if Storages[uuid].locked then
        CallRemoteEvent(player, "ShowError", "Locked")
        return
    end

    log.info(GetPlayerName(player) .. " opens storage object " .. ActiveProp.hit_object)

    local x, y, z = GetPlayerLocation(player)
    PlaySoundSync("sounds/storage_open.wav", x, y, z)

    local storage_items = Storages[uuid].contents or {}
    local _send = {
        uuid = uuid,
        name = Storages[uuid].name,
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
AddRemoteEvent("UpdateStorage", function(player, uuid, data)
    log.trace("UpdateStorage", uuid, dump(data))
    ReplaceStorageContents(uuid, json_decode(data))
end)

-- storage type is either 'object' or 'vehicle' or 'npc'
function ReplaceStorageContents(uuid, data)
    local old_storage = Storages[uuid].contents

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

    Storages[uuid].contents = new_storage
end

