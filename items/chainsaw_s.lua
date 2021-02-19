RegisterItemConfig("chainsaw", {
    name = "Chainsaw",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
        plastic = 5
    },
    interaction = {
        sound = "sounds/chainsaw.wav",
        animation = { name = "FISHING", duration = 4000 },
        prop = { target = "tree", desc = "Murder Tree", remote_event = "HarvestTree" }
    },
    modelid = 1047,
    max_carry = 1,
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
