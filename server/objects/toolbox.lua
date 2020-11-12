RegisterObject("toolbox", {
    name = "Toolbox",
    type = 'resource',
    pickup_sound = "sounds/toolbox.wav",
    modelid = 551,
    max_carry = 1,
    max_use = 10,
    interaction = {
        sound = "sounds/toolbox.wav",
        animation = {
            name = "BARCLEAN01",
            duration = 10000
        }
    },
    recipe = {
        metal = 10
    },
    price = 40,
    attachment = {
        x = -41,
        y = 2.78,
        z = -8,
        rx = -69.33,
        ry = 14.33,
        rz = -13.42,
        bone = "hand_r"
    }
})
