AddEvent("OnPackageStart", function()
    log.info("Loading scrap heaps...")
    CreatePropsFromJSON("data/storages.json", {
        message = "Hit [E] to Open",
        remote_event = "OpenStorage"
    })
end)

AddRemoteEvent("OpenStorage", function(player, object)
    log.info "opening storage..."
    PlaySoundSync(player, "sounds/storage_open.wav")

    local storage_items = GetObjectPropertyValue(object, "storage") or {}
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local _send = {
      object = object,
      storage_items = storage_items,
      inventory_items = {}
    }

    -- inventory
    for index, item in ipairs(inventory) do
        -- usable, equipable, resource
        table.insert(_send.inventory_items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
        })
    end

    log.trace("STORAGE SYNC: " .. json_encode(_send))
    CallRemoteEvent(player, "LoadStorageData", json_encode(_send))
end)

