local LightingConfig = {
    [582] = {
        type = "pointlight",
        position = {
            x = 0,
            y = 66.3,
            z = 147.6,
            rx = 0,
            ry = 86.6,
            rz = 0
        },
        intensity = 10000
    },
    [583] = {
        type = "spotlight",
        position = {
            x = 0,
            y = 10.3,
            z = 25.6,
            rx = 0,
            ry = 91.7,
            rz = 0
        },
        intensity = 5000
    },
    [1398] = {
        type = "pointlight",
        position = {
            x = -127,
            y = 0.2,
            z = 400,
            rx = -4.9,
            ry = 5.2,
            rz = 5.2
        },
        intensity = 15000
    },
    [388] = {
        type = "rectlight",
        position = {
            x = 0,
            y = 0.2,
            z = 254.4,
            rx = -76.1,
            ry = 45.9,
            rz = 0
        },
        intensity = 50000
    }
}

local GarbageConfig = {
    [1397] = true,
    [364] = true,
    [363] = true,
    [366] = true,
    [367] = true,
    [362] = true,
    [352] = true,
    [349] = true,
    [353] = true,
    [344] = true,
    [347] = true,
    [354] = true,
    [365] = true,
    [350] = true,
    [351] = true,
    [359] = true,
    [499] = true,
    [660] = true,
    [653] = true,
    [661] = true,
}

local WorldStorageObjects = {}
local StorageLootSpawnTimer
local StorageLootSpawnInterval = 1000 * 60 * 60 * 2 -- 2 hours
local StorageConfig = {
    [504] = 1,
    [505] = 1,
    [556] = 1,
    [561] = 2,
    [994] = 2,
    [1005] = 1,
    [1006] = 2,
    [1007] = 2,
    [1009] = 1,
    [1013] = 2,
    [1014] = 2,
    [1015] = 2,
    [1016] = 2
}

local WorldObjects = {}

AddEvent("OnPackageStart", function()
    if IsPackageStarted('sandbox') then
        log.warn("Not loading alien invasion world because sandbox package is loaded.")
        return
    end

    log.info("Loading world...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/world/world.json")
    for _, v in pairs(_table) do
        if v['modelID'] ~= nil then
            local object = CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'],
                               v['sy'], v['sz'])

            if LightingConfig[v['modelID']] then
                AddLightingProp(object, LightingConfig[v['modelID']])
            elseif GarbageConfig[v['modelID']] then
                AddGarbageProp(object)
            elseif StorageConfig[v['modelID']] then
                WorldStorageObjects[object] = true
                AddStorageProp(object)
                SpawnStorageLoot(object, StorageConfig[v['modelID']])
            end

            WorldObjects[object] = true
            -- log.debug("Creating object:",v['modelID'])
        end
    end
    log.info("Alien Invasion world loaded!")

    StorageLootSpawnTimer = CreateTimer(function()
        for object,level in pairs(WorldStorageObjects) do
            SpawnStorageLoot(object,level)
        end
    end, StorageLootSpawnInterval)
end)

AddEvent("OnPackageStop", function()
    if IsPackageStarted('sandbox') then
        return
    end

    for object in pairs(WorldObjects) do
        DestroyObject(object)
    end

    if StorageLootSpawnTimer ~= nil then
        DestroyTimer(StorageLootSpawnTimer)
        StorageLootSpawnTimer = nil
    end
end)

--
-- Garbage
--
function AddGarbageProp(object)
    SetObjectPropertyValue(object, "prop", { message = "Search", remote_event = "SearchForScrap"})
end

--
-- Lighting
--

function AddLightingProp(object, component_config)
    log.debug("Adding light prop to object "..object)

    SetObjectPropertyValue(object, "light_component", component_config)
    SetObjectPropertyValue(object, "light_enabled", true)

    SetObjectPropertyValue(object, "prop", {
        message = "Enable/Disable",
        remote_event = "ToggleLight",
        options = {
            type = 'object',
        }
    })
end

AddRemoteEvent("prop:ToggleLight", function(player, object, options)
    log.info(GetPlayerName(player) .. " toggles light object " .. object)
    local light_enabled = GetObjectPropertyValue(object, "light_enabled")
    SetObjectPropertyValue(object, "light_enabled", not light_enabled)
    PlaySoundSync(player, "sounds/switch.mp3")
end)

--
-- Storage
--

function AddStorageProp(object)
    SetObjectPropertyValue(object, "prop", {
        message = "Open",
        remote_event = "OpenStorage",
        options = {
            type = 'object',
            name = "Storage Container"
        }
    })
end

-- level is 1 common or 2 military
function SpawnStorageLoot(object, level)
    if not IsValidObject(object) then return end

    local items
    local random_items
    log.info("Spawning new loot for storage "..GetObjectModel(object).. " object ".. object .." level "..level)
    if level == 1 then
        items = getTableKeys(GetItemConfigs())
        random_items = getRandomSample(items, math.random(0, 2))
    elseif level == 2 then
        items = getTableKeys(WeaponsConfig)
        random_items = getRandomSample(items, math.random(0, 1))
    end

    local random_content = {}
    for _, item in pairs(random_items) do
        table.insert(random_content, {
            item = item,
            quantity = 1
        })
    end
    log.debug(dump(random_content))

    ReplaceStorageContents(object, 'object', random_content)
end
