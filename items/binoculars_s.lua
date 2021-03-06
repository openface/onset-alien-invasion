ItemConfig["binoculars"] = {
    name = "Binoculars",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
        plastic = 5
    },
    interaction = {
        animation = { name = "WATCHING", duration = 4000 }
    },
    modelid = 20004,
    image = "survival/SM_Binocular.png",
    max_carry = 1,
    use_label = "Look",
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
}

AddEvent("items:binoculars:before_use", function(player, object)
    Delay(2500, function()
        CallRemoteEvent(player, "ShowBinoculars")
    end)
    Delay(10000, function()
        CallRemoteEvent(player, "HideBinoculars")
    end)
end)
