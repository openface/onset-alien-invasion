local Storages = {}

AddEvent("OnPackageStart", function()
    log.info("Loading storages...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/storage/storages.json")
    for _, config in pairs(_table) do
        -- todo: move storage name to config
        CreateStorage(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all storages..."
    for object in pairs(Storages) do
        Storages[object] = nil
        DestroyObject(object)
    end
end)

-- world created storage container
function CreateStorage(config)
    log.debug("Creating storage: " .. config['name'])
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'], config['ry'],
                       config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", {
        message = "Open",
        remote_event = "OpenStorage",
        options = {
            type = 'object',
            name = config['name']
        }
    })

    -- provide random things
    if config['random_spawn'] then
        local items = getTableKeys(GetItemConfigs())
        local random_items = getRandomSample(items, config['random_spawn'])

        local random_content = {}
        for _, item in pairs(random_items) do
            table.insert(random_content, {
                item = item,
                quantity = 1
            })
        end
        ReplaceStorageContents(object, 'object', random_content)
    end
    Storages[object] = true
end

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
    local inventory = GetPlayerPropertyValue(player, "inventory")
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

function ReplaceStorageContents(object, type, data)
    local new_storage = {}
    for i, item in ipairs(data) do
        -- lookup item configuration before storing it to ensure they are still valid
        local item_cfg = GetItemConfig(item.item)
        if item_cfg then
            new_storage[i] = {
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
