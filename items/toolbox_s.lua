RegisterObject("toolbox", {
    name = "Toolbox",
    type = 'resource',
    category = "Supplies",
    pickup_sound = "sounds/toolbox.wav",
    modelid = 551,
    max_carry = 1,
    max_use = 10,
    interaction = {
        sound = "sounds/toolbox.wav",
        animation = {
            name = "BARCLEAN01",
            duration = 10000,
            spinner = true
        }
    },
    recipe = nil,
    attachment = {
        x = 16,
        y = -12.6,
        z = 43.8,
        rx = 0,
        ry = 90,
        rz = 86.2,
        bone = "foot_r"
    },
    price = 50,
})

AddEvent("items:toolbox:use", function(player, item_cfg, options)
  SetVehicleHealth(options.vehicle, GetVehicleHealth(options.vehicle) + 250)

  local health_percentage = GetVehicleHealthPercentage(options.vehicle)
  CallRemoteEvent(player, "ShowMessage", "Vehicle health is now " .. health_percentage .. "%%")
end)