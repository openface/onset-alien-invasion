ItemConfig["campfire"] = {
    name = "Campfire",
    type = 'placeable',
    modelid = 20007,
    image = "survival/SM_Campfire.png",
    max_carry = 1,
    max_use = 1,
    attachment = {
        x = -15.8,
        y = 37.3,
        z = 10.8,
        rx = -90.1,
        ry = 0.2,
        rz = 0,
        bone = "hand_r"
    },
    enter_vehicles_while_equipped = false,
    interactions = {
        equip = {
            event = "EquipCampfire"
        }
    },
    recipe = {
        wood = 3
    },
    price = nil,
    prop = {
        use_label = "Check Campfire",
        event = "CheckCampfire",
        interacts_with = {
            lighter = "ignite"
        }
    },
}

local CampfireTimer
local HEALING_DISTANCE = 300
local FIRE_DURATION = 60 * 1000 * 10 -- 10 mins

AddEvent("OnPackageStart", function()
    CampfireTimer = CreateTimer(function()
        local campfire_objects = GetPlacedObjectsByName('campfire')
        for _, object in pairs(campfire_objects) do
            -- heal if campfire is lit
            if GetObjectPropertyValue(object, "particle") then
                local x, y, z = GetObjectLocation(object)
                local players_in_range = GetPlayersInRange2D(x, y, HEALING_DISTANCE)
                for player in pairs(players_in_range) do
                    -- todo: player should take damage if too close to fire
                    SetPlayerHealth(player, GetPlayerHealth(player) + 5)
                end
            end
        end
    end, 5000)
end)

AddEvent("OnPackageStop", function()
    DestroyTimer(CampfireTimer)
end)

AddEvent("EquipCampfire", function(player, object)
    SetPlayerAnimation(player, "CARRY_IDLE")
end)

AddEvent("CheckCampfire", function(player, ActiveProp, CurrentInHand)
    if GetObjectPropertyValue(ActiveProp.hit_object, "particle") then
        CallRemoteEvent(player, "ShowMessage", "This campfire is toasty!")
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
    Delay(FIRE_DURATION, function()
        SetObjectPropertyValue(ActiveProp.hit_object, "particle", nil)
    end)
end)

