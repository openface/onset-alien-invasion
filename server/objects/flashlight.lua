RegisterObject("flashlight", {
    name = "Flashlight",
    type = 'equipable',
    modelid = 1271, 
    max_carry = 1,
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    attachment = { 
        x = 33, 
        y = -8, 
        z = 0, 
        rx = 360, 
        ry = 260, 
        rz = -130, 
        bone = "hand_l" 
    },
})

AddEvent("items:flashlight:attach", function(player, object)
  SetObjectPropertyValue(object, "pointlight", true)
end)

AddEvent("items:flashlight:detach", function(player, object)
  SetObjectPropertyValue(object, "pointlight", false)
end)
