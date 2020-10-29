RegisterObject("vest", {
    name = "Kevlar Vest",
    type = 'equipable',
    interaction = {
        sound = "sounds/backpack.wav",
        animation = {
            name = "CHECK_EQUIPMENT"
        }
    },
    modelid = 843,
    max_carry = 2,
    auto_equip = true,
    recipe = {
        metal = 2,
        plastic = 15
    },
    attachment = {
        x = -17,
        y = 0,
        z = 0,
        rx = 270,
        ry = 0,
        rz = 5,
        bone = "spine_02"
    }
})

-- todo: move these into base configuration
-- Eg player_effects: { increase_health: 12, increase_armor: 20 }
AddEvent("items:vest:equip", function(player, object)
    SetPlayerArmor(player, 100)
end)

AddEvent("items:vest:unequip", function(player, object)
    SetPlayerArmor(player, 0)
end)

