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
    enter_vehicles_while_equipped = false,
    interactions = {
        equip = {
            sound = "sounds/struggle.wav",
            event = "EquipWood",        
        }
    },
    attachment = {
        x = -15.8,
        y = 37.3,
        z = 5.5,
        rx = -84.8,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    },
    prop = {
        use_label = "Sit",
        event = "SitInChair",
    }
}

AddEvent("EquipWood", function(player, object)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)

--
-- Sitting
--

AddEvent("SitInChair", function(player, prop)
    log.debug(GetPlayerName(player).." sitting...")
    SetPlayerAnimation(player, "SIT04")
    CallRemoteEvent(player, "SitInChair", prop.hit_object)
end)

AddRemoteEvent("SitPlayerInChair", function(player, position)
    SetPlayerLocation(player, position.location.x, position.location.y, position.location.z)

    local h = math.atan(position.rotation.y, position.rotation.x)*180/math.pi
    SetPlayerHeading(player, h)

    SetPlayerAnimation(player, "SIT04")
end)

AddRemoteEvent("StopSitting", function(player, loc)
    SetPlayerAnimation(player, "STOP")
    SetPlayerLocation(player, loc.x, loc.y, loc.z)
    log.debug(GetPlayerName(player).." no longer sitting...")
end)