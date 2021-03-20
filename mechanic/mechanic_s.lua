local Mechanics = {}
local VehiclesInGarage = {}

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
    VehiclesInGarage = {}
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
    local vehicle, dist = GetNearestVehicle(player)
    if vehicle == 0 or dist > 350 then
        CallRemoteEvent(player, "ShowError", "Cannot find nearby vehicle!")
        return
    end
    if (GetVehicleHoodRatio(vehicle) == 0.0) then
        CallRemoteEvent(player, "ShowError", "Hood must be open to repair or inspect vehicle!")
        return
    end

    VehiclesInGarage[player] = vehicle

    StartVehicleEngine(vehicle)
    SetVehicleLightEnabled(vehicle, true)

    local _send = GetVehicleData(vehicle)
    CallRemoteEvent(player, "LoadVehicleData", vehicle, json_encode(_send))
end)

function GetVehicleData(vehicle)    
    return {
        modelid = GetVehicleModel(vehicle),
        model_name = GetVehicleModelName(vehicle),
        health = GetVehicleHealthPercentage(vehicle),
        damage = GetVehicleDamageIndexes(vehicle)
    }
end

AddRemoteEvent("CloseMechanic", function(player)
    local vehicle = VehiclesInGarage[player]
    if not vehicle then
        log.error "No vehicle found in garage!"
        return
    end

    StopVehicleEngine(vehicle)
    SetVehicleLightEnabled(vehicle, false)

    VehiclesInGarage[player] = nil

    CallRemoteEvent(player, "SendMessage", "Thank you come again!")
end)

AddRemoteEvent("RepairVehicle", function(player)
    local vehicle = VehiclesInGarage[player]
    if not vehicle then
        log.error "No vehicle found in garage!"
        return
    end

    log.info(GetPlayerName(player) .. " inspects vehicle " .. vehicle)

    CallRemoteEvent(player, "ShowMessage", "You begin to repair the vehicle...")

    local x,y,z = GetVehicleLocation(vehicle)
    PlaySoundSync("sounds/drill.wav", x, y, z)

    IncreaseVehicleHealth(vehicle, 100)
    Delay(3000, function()
        local _send = GetVehicleData(vehicle)
        CallRemoteEvent(player, "LoadVehicleData", vehicle, json_encode(_send))
    end)
end)

function GetNearestVehicle(player)
    local vehicles = GetStreamedVehiclesForPlayer(player)
    local found = 0
    local nearest_dist = 999999.9
    local x, y, z = GetPlayerLocation(player)

    for _, v in pairs(vehicles) do
        local x2, y2, z2 = GetVehicleLocation(v)
        local dist = GetDistance3D(x, y, z, x2, y2, z2)
        if dist < nearest_dist then
            nearest_dist = dist
            found = v
        end
    end
    return found, nearest_dist
end
