RegisterObject("axe", {
    name = "Axe",
    type = 'usable',
    interaction = {
        sound = "sounds/chopping_wood.mp3",
        animation = { name = "PICKAXE_SWING" }
    },
    modelid = 20002,
    image = "survival/SM_Axe-Neo.png",
    max_carry = 1,
    recipe = {
        metal = 20,
        plastic = 5
    },
    price = 150,
    attachment = { 
      x = -10.8, 
      y = 5.2, 
      z = -1, 
      rx = -64, 
      ry = 1, 
      rz = -15.1, 
      bone = "hand_r" 
    }
})
