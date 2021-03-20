VehicleData = {}

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
    storage = {
        type = 'json'
    },
    location = {
        type = 'json'
    },
    health = {
        type = 'number',
        length = 11
    },
    damage = {
        type = 'json'
    },
    license = {
        type = 'char',
        length = 13
    }
}, false) -- true to recreate table

AddEvent("OnPackageStart", function()
    SpawnVehicles()

    VehicleSaveTimer = CreateTimer(function()
        if not next(GetAllPlayers()) then
            return
        end

        for vehicle, uuid in pairs(VehicleData) do
            if IsValidVehicle(vehicle) then
                SaveVehicle(vehicle)
            end
        end
    end, VehicleSaveTime)
end)

AddEvent("OnPackageStop", function()
    for veh, uuid in pairs(VehicleData) do
        VehicleData[veh] = nil
        DestroyVehicle(veh)
    end
end)

function SpawnVehicles()
    SelectRows("vehicles", "*", nil, function()
        for i = 1, mariadb_get_row_count() do
            local row = mariadb_get_assoc(i)
            local loc = json_decode(row['location'])

            local vehicle = SpawnVehicle(row['modelid'], loc.x, loc.y, loc.z, loc.h)
            if vehicle then
                -- setup items in storage
                local storage = json_decode(row['storage'])
                for i, item in ipairs(storage) do
                    SetItemInstance(item.uuid, item.item)
                end
                SetVehiclePropertyValue(vehicle, "storage", storage)
                SetVehicleLicensePlate(vehicle, row['license'])
                SetVehicleHealth(vehicle, row['health'])
                SetVehicleDamageIndexes(vehicle, json_decode(row['damage']))

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
        },
        health = GetVehicleHealth(vehicle),
        damage = GetVehicleDamageIndexes(vehicle)
    }, {
        uuid = VehicleData[vehicle]
    })
end

function GetVehicleDamageIndexes(vehicle)
    return {
        one = GetVehicleDamage(vehicle, 1),
        two = GetVehicleDamage(vehicle, 2),
        three = GetVehicleDamage(vehicle, 3),
        four = GetVehicleDamage(vehicle, 4),
        five = GetVehicleDamage(vehicle, 5),
        six = GetVehicleDamage(vehicle, 6),
        seven = GetVehicleDamage(vehicle, 7),
        eight = GetVehicleDamage(vehicle, 8)
    }
end

function SetVehicleDamageIndexes(vehicle, indexes)
    SetVehicleDamage(vehicle, 1, indexes['one'])
    SetVehicleDamage(vehicle, 2, indexes['two'])
    SetVehicleDamage(vehicle, 3, indexes['three'])
    SetVehicleDamage(vehicle, 4, indexes['four'])
    SetVehicleDamage(vehicle, 5, indexes['five'])
    SetVehicleDamage(vehicle, 6, indexes['six'])
    SetVehicleDamage(vehicle, 7, indexes['seven'])
    SetVehicleDamage(vehicle, 8, indexes['eight'])
end

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StartVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, true)

        CallRemoteEvent(player, "ShowMessage", "[G] Engine  [H] Horn  [L] Lights  [J] Hood  [K] Trunk")
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StopVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, false)
    end
end)

function OpenTrunk(vehicle)
    SetVehicleTrunkRatio(vehicle, 60.0)
end

function CloseTrunk(vehicle)
    SetVehicleTrunkRatio(vehicle, 0.0)
end

function OpenHood(vehicle)
    SetVehicleHoodRatio(vehicle, 60.0)

    local x, y, z = GetVehicleLocation(vehicle)
    PlaySoundSync("sounds/hood_open.wav", x, y, z)
end

function CloseHood(vehicle)
    SetVehicleHoodRatio(vehicle, 0.0)

    local x, y, z = GetVehicleLocation(vehicle)
    PlaySoundSync("sounds/hood_close.wav", x, y, z)
end

AddRemoteEvent("ToggleVehicleTrunk", function(player)
    local vehicle = GetPlayerVehicle(player)

    if (vehicle == 0) then
        return AddPlayerChat(player, "You must be in a vehicle")
    end

    if (GetPlayerVehicleSeat(player) ~= 1) then
        return AddPlayerChat(player, "You must be the driver of the vehicle for this!")
    end

    if (GetVehicleTrunkRatio(vehicle) > 0.0) then
        CloseTrunk(vehicle)
    else
        OpenTrunk(vehicle)
    end
end)

AddRemoteEvent("ToggleVehicleHood", function(player)
    local vehicle = GetPlayerVehicle(player)

    if (vehicle == 0) then
        return AddPlayerChat(player, "You must be in a vehicle")
    end

    if (GetPlayerVehicleSeat(player) ~= 1) then
        return AddPlayerChat(player, "You must be the driver of the vehicle for this!")
    end

    if (GetVehicleHoodRatio(vehicle) > 0.0) then
        CloseHood(vehicle)
    else
        OpenHood(vehicle)
    end
end)

AddRemoteEvent("ToggleVehicleEngine", function(player)
    local vehicle = GetPlayerVehicle(player)

    if (vehicle == 0) then
        return AddPlayerChat(player, "You must be in a vehicle")
    end

    if (GetPlayerVehicleSeat(player) ~= 1) then
        return AddPlayerChat(player, "You must be the driver of the vehicle for this!")
    end

    if GetVehicleEngineState(vehicle) then
        StopVehicleEngine(vehicle)
    else
        StartVehicleEngine(vehicle)
    end
end)

AddRemoteEvent("OpenGlovebox", function(player, vehicle)
    CallEvent("OpenStorage", player, {
        hit_object = vehicle,
        storage = {
            name = "Glovebox",
            type = 'vehicle'
        }
    })
end)

AddCommand("vehicle", function(player, modelid)
    if not IsAdmin(player) then
        return
    end

    local uuid = generate_uuid()
    local x, y, z = GetPlayerLocation(player)
    local h = GetPlayerHeading(player)
    local license = generate_license()
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
            },
            health = GetVehicleHealth(vehicle),
            damage = GetVehicleDamageIndexes(vehicle),
            license = license
        })

        SetVehicleLicensePlate(vehicle, license)
        SetVehicleHealth(vehicle, VEHICLE_MAX_HEALTH)

        VehicleData[vehicle] = uuid
    end
end)

function GetVehicleHealthPercentage(vehicle)
    return math.floor(GetVehicleHealth(vehicle) / VEHICLE_MAX_HEALTH * 100.0)
end

function IncreaseVehicleHealth(vehicle, amount)
    local new_health = GetVehicleHealth(vehicle) + amount
    local actual_new_health = math.min(new_health, VEHICLE_MAX_HEALTH)
    SetVehicleHealth(vehicle, actual_new_health)

    if actual_new_health == VEHICLE_MAX_HEALTH then
        -- full repair
        SetVehicleDamageIndexes(vehicle, {
            one = 0.0,
            two = 0.0,
            three = 0.0,
            four = 0.0,
            five = 0.0,
            six = 0.0,
            seven = 0.0,
            eight = 0.0,
        })
    else
        -- partial repair
        local new_indexes = {}
        local damages = GetVehicleDamageIndexes(vehicle)
        for k,v in pairs(damages) do
            new_indexes[k] = v - (v / (VEHICLE_MAX_HEALTH / amount))
        end
        SetVehicleDamageIndexes(vehicle, new_indexes)
    end
    SaveVehicle(vehicle)
end

function generate_license()
    local res = ""
    for i = 1, 3 do
        res = res .. string.char(math.random(97, 122))
    end
    res = res .. "-"
    for i = 1, 3 do
        res = res .. string.char(math.random(97, 122))
    end
    return res:upper()
end
