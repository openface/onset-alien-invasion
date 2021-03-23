ItemConfig["paint"] = {
    name = "Bucket of Paint",
    type = 'usable',
    category = "Supplies",
    modelid = 1576,
    max_carry = 1,
    max_use = 3,
    enter_vehicles_while_equipped = false,
    interactions = {
        vehicle_hood = {
            use_label = "Paint Vehicle",
            sound = "sounds/paint.mp3",
            animation = { name = "BARCLEAN01", duration = 7000 },
            event = "StartMechanic"
        },
        equip = {
            event = "EquipPaint",
        }
    },
    attachment = {
        x = -31.7,
        y = 32,
        z = -5.1,
        rx = 74.5,
        ry = -180.4,
        rz = 0,
        bone = "hand_r"
    },
    price = 50
}

AddEvent("EquipPaint", function(player, object)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)