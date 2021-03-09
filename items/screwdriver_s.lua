ItemConfig["screwdriver"] = {
    name = "Screwdriver",
    type = 'usable',
    category = "Supplies",
    modelid = 20100,
    image = "lockpick/screwdriver.jpg",
    max_carry = 2,
    price = 20,
    interaction = {
        animation = { name = "LOCKDOOR", duration = "3500" },
        use_label = "Screw",
    },
    attachment = { 
      x = -10.5, 
      y = 2, 
      z = 21.4, 
      rx = -175.1, 
      ry = 79.8, 
      rz = 0, 
      bone = "hand_r"
    },
    scale = {
        x = 0.4,
        y = 0.4,
        z = 0.4
    },
}


