ItemConfig["lantern"] = {
    name = "Lantern",
    type = 'equipable',
    category = "Supplies",
    modelid = 553,
    max_carry = 1,
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    price = 50,
    light_component = {
        type = "pointlight",
        position = {
            x = 3,
            y = 0,
            z = 20,
            rx = 0,
            ry = 0,
            rz = 0
        },
        intensity = 5000
    },
    particle = {
        path = "/Game/Geometry/OldTown/Effects/PS_LanternFire",
        position = { x = 0, y = 0, z = 17, rx = 0, ry = 0, rz = 0 }
    },
    attachment = {
        x = 61,
        y = -14,
        z = 1,
        rx = -83,
        ry = 7,
        rz = -197,
        bone = "hand_l"
    }
}
