ItemConfig["wooden_chair"] = {
    name = "Wooden Chair",
    type = 'placeable',
    category = "Furniture",
    modelid = 1262,
    max_carry = 1,
    recipe = {
        wood = 10
    },
    price = 25,
    attachment = {
        x = -15.8,
        y = 37.3,
        z = 5.5,
        rx = -84.8,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    },
    prop_options = {
        message = "Sit",
        client_event = "SitInChair",
        remote_event = "SitInChair",
        options = {
            type = 'object',
        }
    }
}

AddEvent("items:wooden_chair:equip", function(player)
    SetPlayerAnimation(player, "CARRY_IDLE")    
end)

--
-- Sitting
--

AddRemoteEvent("SitInChair", function(player, object, options)
    SetPlayerAnimation(player, "SIT04")
    log.debug(GetPlayerName(player).." sitting...")
end)

AddRemoteEvent("StopSitting", function(player, loc)
    SetPlayerAnimation(player, "STOP")
    SetPlayerLocation(player, loc.x, loc.y, loc.z)
    log.debug(GetPlayerName(player).." no longer sitting...")
end)