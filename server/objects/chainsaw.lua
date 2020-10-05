RegisterObject("chainsaw", {
    name = "Chainsaw",
    type = 'usable',
    interaction = {
        sound = "sounds/chainsaw.wav",
        animation = { name = "FISHING", duration = 4000 }
    },
    modelid = 1047,
    max_carry = 1,
    recipe = {
        metal = 10,
        plastic = 2
    },
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
