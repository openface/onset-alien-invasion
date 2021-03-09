ItemConfig["banana"] = {
    name = "Banana",
    type = "usable",
    category = "Grocery",
    price = 3,
    interactions = {
        use = {
            use_label = "Eat",
            sound = "sounds/eat.wav",
            animation = { name = "DRINKING" },
            event = "EatBanana"
        },
    },
    modelid = 1622,
    max_use = 3,
    max_carry = 2,
    attachment = { 
        x = -6, 
        y = 4, 
        z = -1, 
        rx = -64, 
        ry = 1, 
        rz = 0, 
        bone = "hand_r" 
    }
}
