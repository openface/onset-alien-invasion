RegisterItemConfig("axe", {
    name = "Axe",
    type = 'usable',
    category = "Supplies",
    recipe = {
        metal = 20,
        plastic = 5
    },
    interaction = {
        sound = "sounds/chopping_wood.mp3",
        animation = { name = "PICKAXE_SWING", duration = 5000 },
        prop = { target = "tree", desc = "Chop Tree", remote_event = "HarvestTree" }
    },
    modelid = 20002,
    max_use = 20,
    use_label = "Chop",
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
})

--
-- Chopping
--

AddRemoteEvent("HarvestTree", function(player, object, options)
    if GetInventoryCount(player, "axe") == 0 then
        AddPlayerChat(player, "You need an axe to harvest this!")
        CallRemoteEvent(player, "PlayErrorSound")
        return
    end

    log.debug(GetPlayerName(player) .. " is chopping a tree")
    UseItemFromInventory(player, "axe")

    Delay(5000, function()
        CallRemoteEvent(player, "ShowMessage", "You collect some wood and put it in your inventory")
        AddToInventory(player, RegisterNewItem("wood"))
    end)

end)