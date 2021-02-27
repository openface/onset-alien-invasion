ItemConfig["supply_container"] = {
    name = "Supply Container",
    type = 'placeable',
    category = "Storage",
    modelid = 1013,
    max_carry = 1,
    recipe = nil,
    price = 100,
    prop_options = {
        use_label = "Open",
        remote_event = "OpenStorage",
        options = {
            storage_type = 'object',
            storage_name = "Supply Container"
        }
    }
}
