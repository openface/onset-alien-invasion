ItemConfig["crowbar"] = {
    name = "Crowbar",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
    },
    interaction = {
        sound = "sounds/chopping_wood.mp3",
        animation = { name = "PICKAXE_SWING", duration = 5000 },
    },
    modelid = 1432,
    max_use = 20,
    use_label = "Swing",
    max_carry = 1,
    price = 50,
    attachment = { 
      x = -5.1, 
      y = 0.2, 
      z = 5.5, 
      rx = 212.6, 
      ry = -244.1, 
      rz = 69.2, 
      bone = "hand_r" 
    }
}
