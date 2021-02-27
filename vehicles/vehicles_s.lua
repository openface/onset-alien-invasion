local Vehicles = {}
local VehicleRespawnTime = 10 * 60 * 1000 -- 10 mins
local VehicleMaxHealth = 1000

VehiclesConfig = {{
    uuid = "2b2a609b-8618-4776-b84a-a7e60602c411",
    modelid = 23,
    location = {
        x = -95885.109375,
        y = 174622.578125,
        z = 404.29016113281
    }
}, {
    uuid = "2e1222e6-a29d-4e04-92ea-0d804ae76a8e",
    modelid = 23,
    location = {
        x = -119527.0703125,
        y = 220396.09375,
        z = 164.50358581543
    }
}, {
    uuid = "c3637a21-dcec-4298-92cb-0cfe4b49b9a2",
    modelid = 23,
    location = {
        x = -121231.3046875,
        y = 180339.890625,
        z = 626.68872070313
    }
}, {
    uuid = "4eadd776-b6d5-47ea-88d1-2a9f6d70b46d",
    modelid = 23,
    location = {
        x = -99434.703125,
        y = 198331.09375,
        z = 1310.1840820313
    }
}, {
    uuid = "fa3047e3-e457-4385-9ae8-e973b9091618",
    modelid = 23,
    location = {
        x = -111261.5234375,
        y = 191991.234375,
        z = 1310.3996582031
    }
}}

AddEvent("OnPackageStart", function()
    SpawnVehicles()
end)

AddEvent("OnPackageStop", function()
    DespawnVehicles()
    Vehicles = {}
    VehicleLocations = {}
end)

function DespawnVehicles()
    for veh in pairs(Vehicles) do
        Vehicles[veh] = nil
        DestroyVehicle(veh)
    end
end

function SpawnVehicles()
    DespawnVehicles()

    for _, cfg in pairs(VehiclesConfig) do
        log.debug("Spawning vehicle modelid", cfg.modelid)
        local veh = CreateVehicle(cfg.modelid, cfg.location.x, cfg.location.y, cfg.location.z)
        SetVehicleRespawnParams(veh, false, VehicleRespawnTime, true)
        SetVehicleHealth(veh, VehicleMaxHealth)
        Vehicles[veh] = true
    end
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

function GetVehicleHealthPercentage(vehicle)
    return math.floor(GetVehicleHealth(vehicle) / VehicleMaxHealth * 100.0)
end

