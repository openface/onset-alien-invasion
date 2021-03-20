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

    local damage = {
        one = GetVehicleDamage(vehicle, 1),
        two = GetVehicleDamage(vehicle, 2),
        three = GetVehicleDamage(vehicle, 3),
        four = GetVehicleDamage(vehicle, 4),
        five = GetVehicleDamage(vehicle, 5),
        six = GetVehicleDamage(vehicle, 6),
        seven = GetVehicleDamage(vehicle, 7),
        eight = GetVehicleDamage(vehicle, 8),
    }

    local _send = {
        modelid = GetVehicleModel(vehicle),
        model_name = GetVehicleModelName(vehicle),
        health = GetVehicleHealthPercentage(vehicle),
        damage = damage
    }

    log.debug(dump(json_encode(_send)))
    CallRemoteEvent(player, "LoadVehicleData", vehicle, json_encode(_send))
end)

AddRemoteEvent("CloseMechanic", function(player)
    local vehicle = VehiclesInGarage[player]
    if not vehicle then
        log.error "No vehicle found in garage!"
        return
    end

    CloseHood(vehicle)
    StopVehicleEngine(vehicle)
    SetVehicleLightEnabled(vehicle, false)

    VehiclesInGarage[player] = nil

    CallRemoteEvent(player, "SendMessage", "Thank you come again!")
end)

function GetNearestVehicle(player)
	local vehicles = GetStreamedVehiclesForPlayer(player)
	local found = 0
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(player)

	for _,v in pairs(vehicles) do
		local x2, y2, z2 = GetVehicleLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)
		if dist < nearest_dist then
			nearest_dist = dist
			found = v
		end
	end
	return found, nearest_dist
end

function RepairVehicle1() 
    local vehicle = ActiveProp.hit_object

    log.info(GetPlayerName(player) .. " inspects vehicle " .. vehicle)

    local health_percentage = GetVehicleHealthPercentage(vehicle)
    CallRemoteEvent(player, "ShowMessage", "Vehicle Health: " .. health_percentage .. "%%")

    if GetVehicleDamage(vehicle, 1) == 1 then
        -- unrepairable
        CallRemoteEvent(player, "ShowMessage", "The vehicle is unrepairable")
        CallRemoteEvent(player, "PlayErrorSound")
    elseif health_percentage <= 75 then
        -- repairable
        CallRemoteEvent(player, "ShowMessage", "You begin to repair the vehicle...")

        SetVehicleHealth(vehicle, GetVehicleHealth(vehicle) + 250)

        local health_percentage = GetVehicleHealthPercentage(vehicle)
        CallRemoteEvent(player, "ShowMessage", "Vehicle health is now " .. health_percentage .. "%%")
    else
        CallRemoteEvent(player, "ShowMessage", "Vehicle can not be repaired any further")
        CallRemoteEvent(player, "PlayErrorSound")
    end
end