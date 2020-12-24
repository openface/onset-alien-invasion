RegisterObject("supply_container", {
    name = "Supply Container",
    type = 'placeable',
    category = "Storage",
    modelid = 1013,
    max_carry = 1,
    recipe = nil,
    price = 100,
    prop_options = {
        message = "Open",
        remote_event = "OpenStorage",
        options = {
            type = 'object',
            name = "Supply Container"
        }
    }
})
