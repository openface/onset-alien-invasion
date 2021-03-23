local Mechanics = {}
local VehiclesInGarage = {}
local TempColors = {}

AddEvent("OnPackageStart", function()
    log.info("Loading mechanics...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/mechanic/mechanics.json")
    for _, config in pairs(_table) do
        CreateMechanic(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all merchants..."
    for pickup,mech in pairs(Mechanics) do
        Mechanics[pickup] = nil
        DestroyPickup(pickup)
        DestroyText3D(mech.text3d)
    end
    VehiclesInGarage = {}
end)

function CreateMechanic(config)
    log.debug("Creating mechanic: " .. config.name)

    local pickup = CreatePickup(2, config.x, config.y, config.z)
    SetPickupPropertyValue(pickup, "mechanic", true)

    Mechanics[pickup] = {
        name = config.name,
        text3d = CreateText3D(config.name, 12, config.x, config.y, config.z + 100, 0, 0, 0)
    }
end

AddEvent("OnPlayerPickupHit", function(player, pickup)
    if not GetPickupPropertyValue(pickup, "mechanic") then
        return
    end
    if not Mechanics[pickup] then
        return
    end

    local vehicle = GetPlayerVehicle(player)
    if not vehicle then
        return
    end

    if GetVehicleDriver(vehicle) ~= player then
        return
    end

    OpenHood(vehicle)

    CallEvent("StartMechanic", player)
end)

function GetMechanicsCount()
    return #table.keys(Mechanics)
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

    local _send = GetVehicleData(vehicle)
    CallRemoteEvent(player, "LoadVehicleData", vehicle, json_encode(_send))
end)

function GetVehicleData(vehicle)
    local r,g,b = HexToRGBA(GetVehicleColor(vehicle))
    return {
        modelid = GetVehicleModel(vehicle),
        model_name = GetVehicleModelName(vehicle),
        health = GetVehicleHealthPercentage(vehicle),
        damage = GetVehicleDamageIndexes(vehicle),
        color = {
            r = r,
            g = g,
            b = b
        }
    }
end

AddRemoteEvent("CloseMechanic", function(player)
    local vehicle = VehiclesInGarage[player]
    if not vehicle then
        return
    end

    CloseHood(vehicle)

    if TempColors[player] then
        local prev_color = TempColors[player]
        SetVehicleColor(vehicle, RGB(prev_color.r, prev_color.g, prev_color.b))
        TempColors[player] = nil
    end

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

AddRemoteEvent("PaintVehicle", function(player, r, g, b)
    log.trace("PaintVehicle", dump(rgba))

    local vehicle = GetPlayerVehicle(player)

    TempColors[player] = nil

    local x,y,z = GetVehicleLocation(vehicle)
    PlaySoundSync("sounds/paint.mp3", x, y, z)

    Delay(6000, function()
        SetVehicleColor(vehicle, RGB(r, g, b))    
        SaveVehicle(vehicle)

        local _send = GetVehicleData(vehicle)
        CallRemoteEvent(player, "LoadVehicleData", vehicle, json_encode(_send))
    end)
end)

AddRemoteEvent("PreviewColor", function(player, r, g, b)
    log.trace("PreviewColor", r, g, b)

    local vehicle = GetPlayerVehicle(player)

    -- store temp colors until mechanic UI closes
    local _r,_g,_b = HexToRGBA(GetVehicleColor(vehicle))
    TempColors[player] = { 
        r = _r, 
        g = _g,
        b = _b
    }

    SetVehicleColor(vehicle, RGB(r, g, b))
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
