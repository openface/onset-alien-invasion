WorldStorageConfig = {
    [504] = true,
    [505] = true,
    [556] = true,
    [561] = true,
    [994] = true,
    [1001] = true,
    [1002] = true,
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
        if not next(GetAllPlayers()) then
            return
        end
        
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

function GetWorldStorageObjectsCount()
    return #table.keys(WorldStorageObjects)
end

function AddStorageProp(object)
    local locked
    -- 1 in 5 chance of being locked
    if math.random(1,5) == 1 then
        locked = false
    else
        locked = true
    end
    WorldStorageObjects[object] = true
    SetObjectPropertyValue(object, "prop", {
        use_label = "Open",
        event = "OpenStorage",
        interacts_with = {
            screwdriver = "picklock",
            crowbar = "pry"
        },
        options = {
            storage = {
                type = 'object',
                name = "Storage Container",
                locked = false,
            }
        },
    })
end

function SpawnStorageLoot(object)
    if not IsValidObject(object) then return end

    log.debug("Spawning new loot for storage "..GetObjectModel(object).. " object ".. object)
    local items = table.keys(ItemConfig)
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

    -- unregister all existing items
    local old_storage = GetObjectStorage(object, 'object')
    if old_storage then
        for index, item in ipairs(old_storage) do
            UnregisterItemInstance(item.uuid)
        end
    end

    ReplaceStorageContents(object, 'object', random_content)
end