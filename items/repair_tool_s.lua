ItemConfig["repair_tool"] = {
    name = "Repair Tool",
    type = 'usable',
    category = "Supplies",
    pickup_sound = "sounds/toolbox.wav",
    modelid = 552, -- plyers
    max_carry = 1,
    max_use = 10,
    interactions = {
        vehicle_hood = {
            use_label = "Repair Vehicle",
            sound = "sounds/toolbox.wav",
            animation = { name = "BARCLEAN01", duration = 10000 },
            event = "RepairVehicle"
        },
    },
    attachment = {
        x = -10.5,
        y = 0.2,
        z = 10.8,
        rx = -281.2,
        ry = -79.5,
        rz = 42.6,
        bone = "hand_r"
    },
    price = 50
}

AddEvent("items:repair_tool:use", function(player, object, prop)
    if not prop then
        return
    end

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

        SetVehicleHealth(options.vehicle, GetVehicleHealth(options.vehicle) + 250)

        local health_percentage = GetVehicleHealthPercentage(options.vehicle)
        CallRemoteEvent(player, "ShowMessage", "Vehicle health is now " .. health_percentage .. "%%")
    else
        CallRemoteEvent(player, "ShowMessage", "Vehicle can not be repaired any further")
        CallRemoteEvent(player, "PlayErrorSound")
    end
end)