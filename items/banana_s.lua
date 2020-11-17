RegisterObject("banana", {
    name = "Banana",
    type = "usable",
    category = "Grocery",
    price = 3,
    interaction = {
        sound = "sounds/eat.wav",
        animation = { name = "DRINKING" }
    },
    modelid = 1622,
    max_use = 3,
    use_label = "Eat",
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
})
