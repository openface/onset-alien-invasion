local Computers = {}

local GarageComputerConfig = {
    modelID = 1027,
    x = -106377.1640625,
    y = 193889.953125,
    z = 1386.6390380859,
    rx = -0.0069599621929228,
    ry = -91.021797180176,
    rz = -0.0069580078125
}
local SatelliteTerminalConfig = {
    modelID = 1027,
    x = -102958.1484375,
    y = 201182.859375,
    z = 2202.7407226563,
    rx = -0.0027184151113033,
    ry = 177.91160583496,
    rz = -0.002716064453125
}

AddEvent("OnPackageStart", function()
    log.info "Creating computer props..."
    -- garage computer
    CreateComputer("Garage Computer", GarageComputerConfig, {
        use_label = "Interact",
        remote_event = "InteractComputer"
    })

    -- satellite terminal
    CreateComputer("Satellite Terminal", SatelliteTerminalConfig, {
        use_label = "Interact",
        remote_event = "InteractComputer"
    })
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all computers..."
    for _, object in pairs(Computers) do
        Computers[object] = nil
        DestroyObject(object)
    end
end)

function CreateComputer(name, config, prop_options)
    log.debug("Creating computer: " .. name)
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'], config['ry'],
                       config['rz'])
    SetObjectPropertyValue(object, "prop", prop_options)
    Computers[object] = true
end

-- interacting with computer
AddRemoteEvent("InteractComputer", function(player, prop)
    CallRemoteEvent(player, "ShowComputer", prop.hit_object)
end)

-- spawn the mothership
AddRemoteEvent("ActivateSatellite", function(player)
    log.info(GetPlayerName(player) .. " activated the satellite")

    CallRemoteEvent(player, "BeginSatelliteTransmission", SatelliteTerminalConfig)

    Delay(4000, function()
        PlaySoundSync("sounds/alert.mp3", SatelliteTerminalConfig.x, SatelliteTerminalConfig.y, SatelliteTerminalConfig.z, 15000)
    end)

    -- call mothership
    Delay(15000, function()
        CallEvent("SpawnBoss")
    end)
end)
