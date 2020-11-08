RegisterObject("binoculars", {
    name = "Binoculars",
    type = 'usable',
    interaction = {
        animation = { name = "WATCHING", duration = 5000 }
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
      rx = -10, 
      ry = 152.7, 
      rz = 15.4, 
      bone = "hand_r" 
    }
})
