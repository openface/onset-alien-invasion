ItemConfig["water_bottle"] = {
    name = "Water Bottle",
    type = "usable",
    category = "Grocery",
    price = 5,
    interaction = {
        sound = "sounds/drink.wav",
        animation = {
            name = "DRINKING"
        },
--[[         interacts_on = {
            ["water"] = {
                use_label = "Fill Bottle",
                event = "FillBottle"
            }
        } ]]
    },
    modelid = 1022,
    max_use = 3,
    use_label = "Drink",
    max_carry = 2,
    attachment = {
        x = -6,
        y = 4,
        z = -1,
        rx = 35.8,
        ry = -15.1,
        rz = 0,
        bone = "hand_r"
    }
}

AddEvent("items:water_bottle:use", function(player)
    local health = GetPlayerHealth(player)
    SetPlayerHealth(player, math.min(100, health + 5))
    CallRemoteEvent(player, "ShowMessage", "Your health has increased")
end)
