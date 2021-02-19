RegisterItemConfig("wooden_chair", {
    name = "Wooden Chair",
    type = 'placeable',
    category = "Furniture",
    modelid = 1262,
    max_carry = 1,
    recipe = {
        wood = 10
    },
    price = 25,
    prop_options = {
        message = "Sit",
        client_event = "SitInChair",
        remote_event = "SitInChair",
        options = {
            type = 'object',
        }
    }
})

--
-- Sitting (TODO)
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