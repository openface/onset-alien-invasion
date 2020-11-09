AddEvent("OnPackageStart", function()
    log.info("Loading scrap heaps...")
    
    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/data/storages.json")
    for _, v in pairs(_table) do
        CreateProp(v, { message = "Hit [E] to Open", remote_event = "OpenStorage" })
    end
end)

AddRemoteEvent("OpenStorage", function(player, object)
    log.info(GetPlayerName(player).." opens storage "..object)

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
            ['image'] = item['image'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
        })
    end

    log.trace("STORAGE SYNC: " .. json_encode(_send))
    CallRemoteEvent(player, "LoadStorageData", json_encode(_send))
end)

-- updates storage from storage UI sorting
AddRemoteEvent("UpdateStorage", function(player, object, data)
  local storage_items = json_decode(data)

  local new_storage = {}
  for i,item in ipairs(storage_items) do
    -- lookup item configuration before storing it to ensure they are still valid
    local item_cfg = GetItemConfig(item.item)
    if not item_cfg then break end

    new_storage[i] = {
      item = item.item,
      quantity = item.quantity,
      name = item_cfg['name'],
      modelid = item_cfg['modelid'],
      image = item_cfg['image'],
      type = item_cfg['type']
    }
  end
  SetObjectPropertyValue(object, "storage", new_storage)
  log.debug(GetPlayerName(player) .. " updates storage:" ..object.." data:"..dump(new_storage))
end)