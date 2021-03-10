ItemConfig["vest"] = {
    name = "Kevlar Vest",
    type = 'equipable',
    category = "Military Surplus",
    recipe = {
        metal = 2,
        plastic = 15
    },
    interactions = {
        equip = {
            sound = "sounds/backpack.wav",
            animation = { name = "CHECK_EQUIPMENT" },
            event = "EquipVest"
        },
        unequip = {
            sound = "sounds/backpack.wav",
            animation = { name = "CHECK_EQUIPMENT" },
            event = "UnequipVest"
        }
    },
    modelid = 843,
    max_carry = 2,
    auto_equip = true,
    price = 100,
    attachment = {
        x = -17,
        y = 0,
        z = 0,
        rx = 270,
        ry = 0,
        rz = 5,
        bone = "spine_02"
    },
}

AddEvent("EquipVest", function(player, object)
    SetPlayerArmor(player, 100)
end)

AddEvent("UnequipVest", function(player, object)
    SetPlayerArmor(player, 0)
end)

