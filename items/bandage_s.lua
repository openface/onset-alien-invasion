ItemConfig["bandage"] = {
    name = "Bandage",
    type = "usable",
    category = "Supplies",
    price = 2,
    interactions = {
        use = {
            use_label = "Heal",
            sound = "sounds/cloth.mp3",
            animation = { name = "COMBINE", duration = 6000 },
            event = "UseBandage"
        },
    },
    modelid = 803,
    max_use = 3,
    max_carry = 10,
    attachment = {
        x = -11,
        y = 4.6,
        z = 0,
        rx = 0,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    }
}

AddEvent("UseBandage", function(player, object)
    local health = GetPlayerHealth(player)
    SetPlayerHealth(player, math.min(100, health + 20))
    AddPlayerChat(player, "Your health has increased by 20")
end)
