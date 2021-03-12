local VehicleData = {}
local VehicleSaveTimer
local VehicleSaveTime = 1000 * 60 * 1 -- 1 min

local VEHICLE_MAX_HEALTH = 1000

InitTable("vehicles", {
    uuid = {
        type = 'char',
        length = 36,
        unique = true
    },
    modelid = {
        type = 'number',
        length = 11
    },
    location = {
        type = 'json'
    }
}, false) -- true to recreate table

AddEvent("OnPackageStart", function()
    SpawnVehicles()

    VehicleSaveTimer = CreateTimer(function()
        for vehicle, _ in pairs(VehicleData) do
            if IsValidVehicle(vehicle) then
                SaveVehicle(vehicle)
            end
        end
    end, VehicleSaveTime)
end)

AddEvent("OnPackageStop", function()
    DespawnVehicles()
end)

function DespawnVehicles()
    for veh, uuid in pairs(VehicleData) do
        VehicleData[veh] = nil
        DestroyVehicle(veh)
    end
end

function SpawnVehicles()
    SelectRows("vehicles", "*", nil, function()
        for i = 1, mariadb_get_row_count() do
            local row = mariadb_get_assoc(i)
            local loc = json_decode(row['location'])

            local vehicle = SpawnVehicle(row['modelid'], loc.x, loc.y, loc.z, loc.h)
            if vehicle then
                VehicleData[vehicle] = row['uuid']
            end
        end
    end)
end

function GetVehicleInstancesCount()
    return #table.keys(VehicleData)
end

function SpawnVehicle(modelid, x, y, z, h)
    local vehicle = CreateVehicle(modelid, x, y, z, h)
    if not vehicle then
        log.error("Cannot create vehicle: " .. modelid)
        return
    end
    SetVehicleRespawnParams(vehicle, false, 0, false)
    SetVehicleHealth(vehicle, VEHICLE_MAX_HEALTH)
    return vehicle
end

function SaveVehicle(vehicle)
    local uuid = VehicleData[vehicle]
    if not uuid then
        return
    end
    log.info("Saving vehicle: " .. vehicle .. " uuid: " .. uuid)
    local x, y, z = GetVehicleLocation(vehicle)
    local h = GetVehicleHeading(vehicle)
    local modelid = GetVehicleModel(vehicle)

    UpdateRows("vehicles", {
        location = {
            x = x,
            y = y,
            z = z,
            h = h
        }
    }, {
        uuid = VehicleData[vehicle]
    })
end

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StartVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, true)

        CallRemoteEvent(player, "ShowMessage", "[H] Horn  [L] Lights  [J] Hood  [K] Trunk")
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StopVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, false)
    end
end)

AddRemoteEvent("ToggleVehicleTrunk", function(player)
    local vehicle = GetPlayerVehicle(player)

    if (vehicle == 0) then
        return AddPlayerChat(player, "You must be in a vehicle")
    end

    if (GetPlayerVehicleSeat(player) ~= 1) then
        return AddPlayerChat(player, "You must be the driver of the vehicle")
    end

    if (GetVehicleTrunkRatio(vehicle) > 0.0) then
        SetVehicleTrunkRatio(vehicle, 0.0)
    else
        SetVehicleTrunkRatio(vehicle, 60.0)
    end
end)

AddRemoteEvent("ToggleVehicleHood", function(player)
    local vehicle = GetPlayerVehicle(player)

    if (vehicle == 0) then
        return AddPlayerChat(player, "You must be in a vehicle")
    end

    if (GetPlayerVehicleSeat(player) ~= 1) then
        return AddPlayerChat(player, "You must be the driver of the vehicle")
    end

    if (GetVehicleHoodRatio(vehicle) > 0.0) then
        SetVehicleHoodRatio(vehicle, 0.0)
    else
        SetVehicleHoodRatio(vehicle, 60.0)
    end
end)

AddCommand("vehicle", function(player, modelid)
    if not IsAdmin(player) then
        return
    end

    local uuid = generate_uuid()
    local x, y, z = GetPlayerLocation(player)
    local h = GetPlayerHeading(player)

    local vehicle = SpawnVehicle(modelid, x, y, z, h)
    if vehicle then
        InsertRow("vehicles", {
            uuid = uuid,
            modelid = modelid,
            location = {
                x = x,
                y = y,
                z = z,
                h = h
            }
        })
    end
end)

function GetVehicleHealthPercentage(vehicle)
    return math.floor(GetVehicleHealth(vehicle) / VEHICLE_MAX_HEALTH * 100.0)
end

