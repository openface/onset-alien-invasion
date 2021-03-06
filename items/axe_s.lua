ItemConfig["axe"] = {
    name = "Axe",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
        plastic = 5
    },
    max_use = 20,
    interactions = {
        tree = {
            use_label = "Chop Tree",
            event = "HarvestTree",
            sound = "sounds/chopping_wood.mp3",
            animation = { id = 920, duration = 5000 },
        }
    },
    modelid = 20002,
    image = "survival/SM_Axe-Neo.png",
    max_carry = 1,
    price = 150,
    attachment = {
        x = -10.8,
        y = 5.2,
        z = -1,
        rx = -64,
        ry = 1,
        rz = -15.1,
        bone = "hand_r"
    }
}

--
-- Chopping
--
AddEvent("HarvestTree", function(player, prop)
    log.debug(GetPlayerName(player) .. " is chopping a tree")

    CallRemoteEvent(player, "ShowMessage", "You collect some wood and put it in your inventory")
    AddToInventoryByName(player, "wood", 5)
end)
