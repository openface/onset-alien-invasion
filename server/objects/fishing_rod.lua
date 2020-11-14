RegisterObject("fishing_rod", {
    name = "Fishing Rod",
    type = 'resource',
    interaction = {
        sound = "sounds/fishing.mp3",
        animation = { name = "FISHING", duration = 10000 }
    },
    modelid = 20011,
    image = "survival/SM_FishingRod.png",
    max_carry = 1,
    recipe = {
        metal = 10,
        plastic = 5
    },
    price = 30,
    attachment = { 
        x = -20.2, 
        y = 10.3, 
        z = 30.7, 
        rx = -81.2, 
        ry = 10.3, 
        rz = -86.3, 
        bone = "hand_r" 
    }
})
