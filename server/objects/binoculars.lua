RegisterObject("binoculars", {
    name = "Binoculars",
    type = 'usable',
    interaction = {
        animation = { name = "WATCHING" }
    },
    modelid = 20004,
    image = "SM_Binocular.png",
    max_carry = 1,
    recipe = {
        metal = 20,
        plastic = 5
    },
    price = 75,
    attachment = { 
      x = -10, 
      y = 10.3, 
      z = -20.2, 
      rx = 193.4, 
      ry = -20.2, 
      rz = 188.3, 
      bone = "hand_r" 
    }
})
