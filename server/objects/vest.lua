RegisterObject("vest", {
    name = "Kevlar Vest",
    type = 'equipable',
    interaction = {
        sound = "sounds/backpack.wav",
        animation = { name = "CHECK_EQUIPMENT" }
    },
    modelid = 843, 
    max_carry = 1,
    recipe = {
        metal = 2,
        plastic = 10
    },
    attachment = { 
        x = -15, 
        y = 1, 
        z = 1, 
        rx = -91, 
        ry = 4, 
        rz = 0, 
        bone = "spine_02" 
    }
})

AddEvent("items:vest:pickup", function(player)
    print "picked up a vest!"
    SetPlayerArmor(player, 100)
    EquipVest(player)   
end)