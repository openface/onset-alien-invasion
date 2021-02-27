WorldStorageConfig = {
    [504] = true,
    [505] = true,
    [556] = true,
    [561] = true,
    [994] = true,
    [1005] = true,
    [1006] = true,
    [1007] = true,
    [1009] = true,
    [1013] = true,
    [1014] = true,
    [1015] = true,
    [1016] = true
}

local WorldStorageObjects = {}
local StorageLootSpawnTimer
local StorageLootSpawnInterval = 1000 * 60 * 15 -- 15 minutes

AddEvent("OnPackageStart", function()
    StorageLootSpawnTimer = CreateTimer(function()
        for object in pairs(WorldStorageObjects) do
            SpawnStorageLoot(object)
        end
    end, StorageLootSpawnInterval)
end)

AddEvent("OnPackageStop", function()
    if StorageLootSpawnTimer ~= nil then
        DestroyTimer(StorageLootSpawnTimer)
        StorageLootSpawnTimer = nil
    end
    WorldStorageObjects = {}
end)

function AddStorageProp(object)
    WorldStorageObjects[object] = true
    SetObjectPropertyValue(object, "prop", {
        use_label = "Open",
        remote_event = "OpenStorage",
        options = {
            storage_type = 'object',
            storage_name = "Storage Container"
        }
    })
end

function SpawnStorageLoot(object)
    if not IsValidObject(object) then return end

    log.debug("Spawning new loot for storage "..GetObjectModel(object).. " object ".. object)
    local items = getTableKeys(ItemConfig)
    local random_items = getRandomSample(items, math.random(0, 2))

    local random_content = {}
    for index, item in pairs(random_items) do
        table.insert(random_content, {
            item = item,
            uuid = RegisterNewItem(item),
            slot = index,
            quantity = 1,
            used = 0
        })
    end
    --log.trace(dump(random_content))
    ReplaceStorageContents(object, 'object', random_content)
end