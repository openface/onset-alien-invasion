RegisterObject("bandage", {
  name = "Bandage",
  type = "usable",
  recipe = nil,
  interaction = {
      sound = "sounds/cloth.mp3",
      animation = { name = "COMBINE", duration = 6000 },
  },
  modelid = 803,
  max_use = 3,
  use_label = "Heal",
  max_carry = 2,
  attachment = { 
      x = -11, 
      y = 4.6, 
      z = 0, 
      rx = 0, 
      ry = 0, 
      rz = 0, 
      bone = "hand_r" 
  }
})