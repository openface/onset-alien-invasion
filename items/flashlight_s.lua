RegisterObject("flashlight", {
    name = "Flashlight",
    type = 'equipable',
    category = "Supplies",
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    modelid = 1271,
    max_carry = 1,
    interaction = {
      sound = "sounds/backpack.wav",
      animation = {
          name = "CHECK_EQUIPMENT"
      }
    },
    price = 50,
    component = {
        type = "spotlight",
        position = {
            x = 0,
            y = 0,
            z = 14.9,
            rx = -30.5,
            ry = 270,
            rz = 0
        },
        intensity = 5000
    },
    attachment = {
        x = 33,
        y = -8,
        z = 0,
        rx = 360,
        ry = 260,
        rz = -120,
        bone = "hand_l"
    }
})
