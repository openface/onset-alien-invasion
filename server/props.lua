local Props = {}

function CreateProp(config, options)
    log.debug("Creating interactive prop:", config['modelID'])

    local rx = config['rx'] or 0
    local ry = config['ry'] or 0
    local rz = config['rz'] or 0
    local sx = config['sx'] or 0
    local sy = config['sy'] or 0
    local sz = config['sz'] or 0

    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], rx, ry, rz, sx, sy, sz)
    SetObjectPropertyValue(object, "prop", options)
    table.insert(Props, object)
end

AddEvent("OnPackageStop", function()
    log.info "Destroying all interactive props..."
    for _, object in pairs(Props) do
        DestroyObject(object)
    end
end)

--
-- Foliage
--

AddRemoteEvent("HarvestTree", function(player)
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
-- Water
--

AddRemoteEvent("GoFishing", function(player)
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
