--
-- Chopping
--

AddRemoteEvent("prop:HarvestTree", function(player)
    if GetInventoryCount(player, "axe") == 0 then
        AddPlayerChat(player, "You need an axe to harvest this!")
        CallRemoteEvent(player, "PlayErrorSound")
        return
    end

    log.debug(GetPlayerName(player) .. " is chopping a tree")
    UseItemFromInventory(player, "axe")

    Delay(5000, function()
        AddPlayerChat(player, "You collect some wood")
        AddToInventory(player, "wood")
    end)

end)

--
-- Fishing
--

AddRemoteEvent("prop:GoFishing", function(player)
    if GetInventoryCount(player, "fishing_rod") == 0 then
        CallRemoteEvent(player, "ShowError", "You need a fishing rod to do this right!")
        return
    end

    log.debug(GetPlayerName(player) .. " is fishing")
    UseItemFromInventory(player, "fishing_rod")

    Delay(10000, function()
        AddPlayerChat(player, "You caught a fish!")
        AddToInventory(player, "wood")
    end)

end)

--
-- Sitting
--

AddRemoteEvent("prop:SitInChair", function(player, object, options)
    SetPlayerAnimation(player, "SIT04")
    log.debug(GetPlayerName(player).." sitting...")
end)

AddRemoteEvent("prop:StopSitting", function(player, loc)
    SetPlayerAnimation(player, "STOP")
    SetPlayerLocation(player, loc.x, loc.y, loc.z)
    log.debug(GetPlayerName(player).." no longer sitting...")
end)