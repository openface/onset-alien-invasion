RegisterObject("wooden_chair", {
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

