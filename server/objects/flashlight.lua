RegisterObject("flashlight", {
    name = "Flashlight",
    type = 'equipable',
    modelid = 1271, 
    max_carry = 2,
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    attachment = { 
        x = 33, 
        y = -8, 
        z = 0, 
        rx = 360, 
        ry = 260, 
        rz = -110, 
        bone = "hand_l" 
    }
})
