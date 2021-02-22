ItemConfig["fishing_rod"] = {
    name = "Fishing Rod",
    type = 'resource',
    category = "Supplies",
    interaction = {
        sound = "sounds/fishing.mp3",
        animation = { name = "FISHING", duration = 10000 },
        prop = { target = "water", desc = "Go Fishing", remote_event = "GoFishing" }
    },
    modelid = 20011,
    image = "survival/SM_FishingRod.png",
    max_carry = 1,
    use_label = "Cast Line",
    recipe = {
        metal = 10,
        plastic = 5
    },
    price = 30,
    attachment = { 
        x = -20.2, 
        y = 10.3, 
        z = 30.7, 
        rx = -81.2, 
        ry = 10.3, 
        rz = -86.3, 
        bone = "hand_r" 
    }
}

AddRemoteEvent("GoFishing", function(player, object, options)
    if GetInventoryCount(player, "fishing_rod") == 0 then
        CallRemoteEvent(player, "ShowError", "You need a fishing rod to do this right!")
        return
    end

    log.debug(GetPlayerName(player) .. " is fishing")
    UseItemFromInventory(player, "fishing_rod")

    Delay(10000, function()
        CallRemoteEvent(player, "ShowMessage", "You caught a fish and put it in your inventory!")
        AddToInventory(player, RegisterNewItem("wood"))
    end)
end)