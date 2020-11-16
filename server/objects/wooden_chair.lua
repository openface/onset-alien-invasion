RegisterObject("wooden_chair", {
    name = "Wooden Chair",
    type = 'placeable',
    interaction = {
        animation = { name = "SIT" }
    },
    modelid = 1262,
    max_carry = 1,
    recipe = {
        metal = 20,
        plastic = 5
    },
    price = 150,
    attachment = { 
        x = -20, 
        y = 5, 
        z = 22, 
        rx = 82, 
        ry = 180, 
        rz = 10, 
        bone = "hand_r" 
    }
})
