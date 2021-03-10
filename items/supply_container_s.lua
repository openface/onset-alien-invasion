ItemConfig["supply_container"] = {
    name = "Supply Container",
    type = 'placeable',
    category = "Storage",
    modelid = 1013,
    max_carry = 1,
    recipe = nil,
    price = 100,
    prop = {
        use_label = "Open",
        event = "OpenStorage",
        interacts_with = {
            screwdriver = "use",
            crowbar = "use"
        },
        options = {
            storage_type = 'object',
            storage_name = "Supply Container"
        }
    }
}
