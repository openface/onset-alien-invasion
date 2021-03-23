ItemConfig["wood"] = {
    name = "Wood",
    type = 'resource',
    modelid = 297,
    enter_vehicles_while_equipped = false,
    interactions = {
        equip = {
            sound = "sounds/backpack.wav",
            event = "EquipWood",
        }
    },
    attachment = {
        x = -5.1,
        y = 10.8,
        z = -5.1,
        rx = 0.2,
        ry = 0.2,
        rz = 90.4,
        bone = "hand_r"
    },
    scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    max_carry = 5,
}

AddEvent("EquipWood", function(player, object)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)