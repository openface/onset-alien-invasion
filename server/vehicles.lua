local VehicleLocations = {}
local Vehicles = {}
local VehicleRespawnTime = 5 * 60 * 1000 -- 5 mins
local VehicleMaxHealth = 1000

AddCommand("vpos", function(player)
    if not IsAdmin(player) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: " .. x .. " " .. y .. " " .. z
    AddPlayerChat(player, string)
    log.debug(string)
    table.insert(VehicleLocations, {x, y, z})

    File_SaveJSONTable("packages/" .. GetPackageName() .. "/server/data/vehicles.json", VehicleLocations)
end)

AddEvent("OnPackageStart", function()
    VehicleLocations = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/data/vehicles.json")
    SpawnVehicles()
end)

AddEvent("OnPackageStop", function()
    DespawnVehicles()
    Vehicles = {}
    VehicleLocations = {}
end)

function DespawnVehicles()
    for _, veh in pairs(Vehicles) do
        -- log.debug("Destroying vehicle: "..veh)
        DestroyVehicle(veh)
        Vehicles[veh] = nil
    end
end

function SpawnVehicles()
    log.debug "Spawning vehicles..."
    DespawnVehicles()

    for _, pos in pairs(VehicleLocations) do
        local veh = CreateVehicle(23, pos[1], pos[2], pos[3])
        SetVehicleRespawnParams(veh, false, VehicleRespawnTime, true)
        SetVehicleHealth(veh, VehicleMaxHealth)
        Vehicles[veh] = veh
    end
end

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StartVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, true)
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

AddRemoteEvent("RepairVehicle", function(player, vehicle)
    log.info(GetPlayerName(player) .. " inspects vehicle " .. vehicle)
    local damage = GetVehicleHealth(vehicle)

    local health_percentage = math.floor(damage / VehicleMaxHealth * 100.0)
    CallRemoteEvent(player, "ShowMessage", "Vehicle Health: " .. health_percentage .. "%%")

    if GetVehicleDamage(vehicle, 1) == 1 then
        -- unrepairable
        AddPlayerChat(player, "The vehicle is unrepairable.")
        CallRemoteEvent(player, "PlayErrorSound")
    elseif health_percentage <= 75 then
        -- repairable
        if GetInventoryCount(player, "toolbox") > 0 then
            AddPlayerChat(player, "You begin to repair the vehicle...")
            UseItemFromInventory(player, "toolbox")

            local health = GetVehicleHealth(vehicle)
            SetVehicleHealth(vehicle, health + 250)
        else
            AddPlayerChat(player, "You need tools to repair this vehicle!")
            CallRemoteEvent(player, "PlayErrorSound")
        end
    else
        AddPlayerChat(player, "Vehicle can not be repaired any further.")
        CallRemoteEvent(player, "PlayErrorSound")
    end
end)
