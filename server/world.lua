local Objects = {}
local Doors = {}
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

AddEvent("OnPackageStart", function()
    if IsPackageStarted('sandbox') then
        log.warn("Not loading alien invasion world because sandbox package is loaded.")
        return
    end

    log.info("Loading world...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/data/world.json")
    for _, v in pairs(_table) do
        if v['modelID'] ~= nil then
            local object = CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])

            if LightingConfig[v['modelID']] then
                SetObjectPropertyValue(object, "component", LightingConfig[v['modelID']])
                log.debug("Adding light component to model", v['modelID'])
            end

            -- log.debug("Creating object:",v['modelID'])
            table.insert(Objects, object)
        else
            -- log.debug("Creating door:",v['doorID'])
            table.insert(Doors, CreateDoor(v['doorID'], v['x'], v['y'], v['z'], v['yaw'], true))
        end
    end
    log.info("Alien Invasion world loaded!")
end)

AddEvent("OnPackageStop", function()
    log.info("Destroying world...")

    for _, object in pairs(Objects) do
        DestroyObject(object)
        -- TODO: need to destroy components too or is this automatic?
    end
    for _, door in pairs(Doors) do
        DestroyDoor(object)
    end
end)
