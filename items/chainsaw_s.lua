ItemConfig["chainsaw"] = {
    name = "Chainsaw",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
        plastic = 5
    },
    interaction = {
        sound = "sounds/chainsaw.wav",
        animation = { name = "FISHING", duration = 4000 },
        interacts_on = {
            { hittype = "tree", use_label = "Murder Tree" }
        },
    },
    modelid = 1047,
    max_carry = 1,
    price = 150,
    attachment = { 
        x = -20, 
        y = 5, 
        z = 22, 
        rx = 82, 
        ry = 180, 
        rz = 10, 
        bone = "hand_r" 
    }
}

--
-- Chopping
--
AddEvent("items:chainsaw:use", function(player, object, prop)
    if prop then
        log.debug(GetPlayerName(player) .. " is chainsawing a tree")

        CallRemoteEvent(player, "ShowMessage", "You collect some wood and put it in your inventory")
        AddToInventoryByName(player, "wood", 10)
    end
end)