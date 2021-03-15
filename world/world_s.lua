local WorldObjects = {}

AddEvent("OnPackageStart", function()
    if IsPackageStarted('sandbox') then
        log.warn("Not loading alien invasion world because sandbox package is loaded.")
        return
    end

    log.info("Loading world...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/world/world.json")
    for _, v in pairs(_table) do
        if v.modelID then
            local object = CreateObject(v.modelID, v.x, v.y, v.z, v.rx, v.ry, v.rz, v.sx, v.sy, v.sz)

            if WorldLightingConfig[v.modelID] then
                AddLightingProp(object, WorldLightingConfig[v.modelID])
            elseif WorldGarbageConfig[v.modelID] then
                AddGarbageProp(object)
            elseif WorldStorageConfig[v.modelID] then
                AddStorageProp(object)
            end

            WorldObjects[object] = true
            --log.debug("Creating object " .. object .." modelid " .. v.modelID)
        end
    end
    log.info("Alien Invasion world loaded!")
end)

AddEvent("OnPackageStop", function()
    if IsPackageStarted('sandbox') then
        return
    end

    for object in pairs(WorldObjects) do
        DestroyObject(object)
    end
end)

