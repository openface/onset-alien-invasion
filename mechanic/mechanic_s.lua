local Mechanics = {}

AddEvent("OnPackageStart", function()
    log.info("Loading mechanics...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/mechanic/mechanics.json")
    for _, config in pairs(_table) do
        CreateMechanic(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all merchants..."
    for object in pairs(Mechanics) do
        Mechanics[object] = nil
        DestroyObject(object)
    end
end)

function CreateMechanic(config)
    log.debug("Creating mechanic: " .. config.name)
    local object = CreateObject(config.modelID, config.x, config.y, config.z, config.rx, config.ry, config.rz,
                       config.sx, config.sy, config.sz)
    SetObjectPropertyValue(object, "prop", {
        use_label = "Interact",
        event = "StartMechanic"
    })
    Mechanics[object] = true
end

AddEvent("StartMechanic", function(player)
    local _send = {
        ["merchant_items"] = {},
        ["player_cash"] = 1000 -- TODO
    }
    -- log.debug(dump(json_encode(_send)))
    CallRemoteEvent(player, "LoadVehicleData", json_encode(_send))
end)

