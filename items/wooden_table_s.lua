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
    enter_vehicles_while_equipped = false,
    interactions = {
        equip = {
            sound = "sounds/struggle.wav",
            event = "EquipTable",        
        }
    },
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

AddEvent("EquipTable", function(player, object)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)