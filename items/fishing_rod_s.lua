ItemConfig["fishing_rod"] = {
    name = "Fishing Rod",
    type = 'resource',
    category = "Supplies",
    interaction = {
        sound = "sounds/fishing.mp3",
        animation = { name = "FISHING", duration = 10000 },
        interacts_on = {
            ["water"] = {
                use_label = "Go Fishing",
                event = "GoFishing"
            }
        }
    },
    modelid = 20011,
    image = "survival/SM_FishingRod.png",
    max_carry = 1,
    use_label = "Cast",
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

AddEvent("GoFishing", function(player, prop)
    if not prop then
        return
    end

    log.debug(GetPlayerName(player) .. " is fishing")

    if math.random(1,3) == 1 then
        CallRemoteEvent(player, "ShowMessage", "You caught a fish and put it in your inventory")
        AddToInventoryByName(player, "wood")
    else
        CallRemoteEvent(player, "ShowMessage", "You caught nothing")
    end
end)