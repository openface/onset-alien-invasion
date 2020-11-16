RegisterObject("wooden_chair", {
    name = "Wooden Chair",
    type = 'placeable',
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

AddRemoteEvent("prop:SitInChair", function(player, object, options)
    SetPlayerAnimation(player, "SIT04")

    log.debug("sitting...")
end)
