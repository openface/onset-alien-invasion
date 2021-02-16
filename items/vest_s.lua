RegisterItemConfig("vest", {
    name = "Kevlar Vest",
    type = 'equipable',
    category = "Military Surplus",
    recipe = {
        metal = 2,
        plastic = 15
    },
    interaction = {
        sound = "sounds/backpack.wav",
        animation = {
            name = "CHECK_EQUIPMENT"
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
})

AddEvent("items:vest:equip", function(player, object)
    SetPlayerArmor(player, 100)
end)

AddEvent("items:vest:unequip", function(player, object)
    SetPlayerArmor(player, 0)
end)

