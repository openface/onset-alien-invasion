ItemConfig["wooden_table"] = {
    name = "Wooden Table",
    type = 'placeable',
    category = "Furniture",
    modelid = 1247,
    max_carry = 1,
    use_label = "Place",
    recipe = {
        wood = 50
    },
    price = 150,
    attachment = {
        x = 10.8,
        y = 53.3,
        z = 79.8,
        rx = -169.7,
        ry = 42.6,
        rz = -10.5,
        bone = "hand_r"
    },
}

AddEvent("items:wooden_table:equip", function(player)
    SetPlayerAnimation(player, "CARRY_IDLE")    
end)