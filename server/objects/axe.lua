RegisterObject("axe", {
    name = "Axe",
    type = 'usable',
    interaction = {
        sound = "sounds/chainsaw.wav",
        animation = { name = "FISHING", duration = 4000 }
    },
    modelid = 20002,
    image = "objects/SM_Axe-Neo.png",
    max_carry = 1,
    recipe = {
        metal = 20,
        plastic = 5
    },
    price = 150,
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
