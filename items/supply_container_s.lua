ItemConfig["supply_container"] = {
    name = "Supply Container",
    type = 'placeable',
    category = "Storage",
    modelid = 1013,
    max_carry = 1,
    recipe = nil,
    price = 100,
    interactions = {
        equip = {
            event = "EquipSupplyContainer"
        }
    },
    attachment = {
        x = -5.1,
        y = -5.1,
        z = 58.6,
        rx = 90.4,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    },
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

AddEvent("EquipSupplyContainer", function(player, object)
    SetPlayerAnimation(player, "HANDSUP_STAND")    
end)