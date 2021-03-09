ItemConfig["beer"] = {
    name = "Beer",
    type = 'usable',
    category = "Grocery",
    recipe = nil,
    price = 3,
    interactions = {
        use = {
            use_label = "Drink",
            sound = "sounds/drink.wav",
            animation = { name = "DRINKING" },
            event = "DrinkBeer"
        },
    },
    modelid = 662,
    max_use = 3,
    max_carry = 2,
    attachment = { 
        x = -6, 
        y = 6, 
        z = -8, 
        rx = 22, 
        ry = -20, 
        rz = -10, 
        bone = "hand_r" 
    }
}

AddEvent("DrinkBeer", function(player, object)
    log.debug("drinks beer")
end)