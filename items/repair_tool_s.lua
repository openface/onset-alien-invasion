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
            sound = "sounds/wrench.wav",
            animation = { name = "BARCLEAN01", duration = 7000 },
            event = "StartMechanic"
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
