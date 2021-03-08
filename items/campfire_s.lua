ItemConfig["campfire"] = {
    name = "Campfire",
    type = 'placeable',
    modelid = 20007,
    image = "survival/SM_Campfire.png",
    max_carry = 1,
    max_use = 1,
    use_label = 'Place',
    attachment = {
        x = -15.8,
        y = 37.3,
        z = 10.8,
        rx = -90.1,
        ry = 0.2,
        rz = 0,
        bone = "hand_r"
    },
    recipe = {
        wood = 3
    },
    price = nil,
    prop = {
        use_label = "Check / Ignite",
        event = "CheckCampfire",
    },
}

local CampfireTimer

AddEvent("OnPackageStart", function()
    CampfireTimer = CreateTimer(function()
        local campfire_objects = GetPlacedObjectsByName('campfire')
        for _, object in pairs(campfire_objects) do
            -- heal if campfire is lit
            if GetObjectPropertyValue(object, "particle") then
                local x, y, z = GetObjectLocation(object)
                local players_in_range = GetPlayersInRange2D(x, y, 500)
                for player in pairs(players_in_range) do
                    -- todo: player should take damage if too close to fire
                    SetPlayerHealth(player, GetPlayerHealth(player) + 2)
                end
            end
        end
    end, 5000)
end)

AddEvent("OnPackageStop", function()
    DestroyTimer(CampfireTimer)
end)

AddEvent("items:campfire:equip", function(player)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)

AddEvent("CheckCampfire", function(player, ActiveProp, CurrentInHand)
    if GetObjectPropertyValue(ActiveProp.hit_object, "particle") then
        CallRemoteEvent(player, "ShowMessage", "This campfire is toasty!")
    elseif CurrentInHand then
        if CurrentInHand.item == 'lighter' then
            CallEvent("IgniteCampfire", player, ActiveProp)
        end
    else
        CallRemoteEvent(player, "ShowMessage", "This campfire is not lit.  You may need something to light it with.")
    end
end)

AddEvent("IgniteCampfire", function(player, ActiveProp)
    if GetObjectPropertyValue(ActiveProp.hit_object, "particle") then
        CallRemoteEvent(player, "ShowError", "Campfire is already lit!")
        return
    end
    SetPlayerAnimation(player, "STOP")
    SetObjectPropertyValue(ActiveProp.hit_object, "particle", {
        path = "/AlienInvasion/Particles/P_Campfire",
        position = {
            x = 0,
            y = 0,
            z = 35,
            rx = 0,
            ry = 0,
            rz = 0
        }
    })

    -- fire goes out
    Delay(60 * 1000, function()
        SetObjectPropertyValue(ActiveProp.hit_object, "particle", nil)
    end)
end)

