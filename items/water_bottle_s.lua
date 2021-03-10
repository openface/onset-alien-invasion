ItemConfig["water_bottle"] = {
    name = "Water Bottle",
    type = "usable",
    category = "Grocery",
    price = 5,
    interactions = {
        use = {
            use_label = "Drink",
            sound = "sounds/drink.wav",
            animation = { name = "DRINKING" },
            event = "DrinkWater"
        },
        water = {
            use_label = "Fill Bottle",
            sound = "sounds/fill_water.wav",
            animation = { id = 921, duration = 10000 },
            event = "FillBottle"
        }
    },
    modelid = 1022,
    max_use = 3,
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

AddEvent("DrinkWater", function(player, object)
    local health = GetPlayerHealth(player)
    SetPlayerHealth(player, math.min(100, health + 5))
    CallRemoteEvent(player, "ShowMessage", "Your health has increased")
end)
