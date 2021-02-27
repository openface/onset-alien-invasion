ItemConfig["boxhead"] = {
    name = "Boxhead",
    type = 'equipable',
    category = "Miscellaneous",
    modelid = 406,
    max_carry = 1,
    recipe = {
        wood = 1,
    },
    price = 10,
    attachment = { 
        x = 10, 
        y = 2, 
        z = 0, 
        rx = 10, 
        ry = 90, 
        rz = -90, 
        bone = "head" 
    }
}

AddEvent("items:boxhead:use", function(player, object, prop)
end)
