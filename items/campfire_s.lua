ItemConfig["campfire"] = {
    name = "Campfire",
    type = 'usable',
    modelid = 20007,
    image = "survival/SM_Campfire.png",
    max_carry = 1,
    max_use = 1,
    use_label = "Place",
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
    interaction = nil,
}

local Campfires = {}
local CampfireTimer

AddEvent("OnPackageStart", function()
    CampfireTimer = CreateTimer(function()
        for _, object in pairs(Campfires) do
            -- heal if campfire is lit
            if GetObjectPropertyValue(object, "particle") then
                local x, y, z = GetObjectLocation(object)
                local players_in_range = GetPlayersInRange2D(x, y, 500)
                for player in pairs(players_in_range) do
                    AddPlayerChat(player, "heal +1")
                end
            end
        end
    end, 5000)
end)

AddEvent("OnPackageStop", function()
    for _, o in pairs(Campfires) do
        DestroyObject(o)
    end
    DestroyTimer(CampfireTimer)
    Campfires = {}
end)

AddEvent("items:campfire:equip", function(player)
    SetPlayerAnimation(player, "CARRY_IDLE")    
end)

AddEvent("items:campfire:use", function(player)
    local x, y, z = GetPlayerLocation(player)
    local object = CreateObject(20007, x + 50, y, z - 100)

    -- todo: can the above be part of the framework somehow??
    SetObjectPropertyValue(object, "prop", {
        message = "Ignite",
        remote_event = "IgniteCampfire",
        options = {
            type = 'object',
        }
    })
    Campfires[object] = object
end)

AddRemoteEvent("IgniteCampfire", function(player, object, options)
    if GetObjectPropertyValue(object, "particle") then
        CallRemoteEvent(player, "ShowError", "Campfire is already lit!")
        return
    end

    SetPlayerAnimation(player, "REVIVE")

    Delay(10 * 1000, function()
        SetPlayerAnimation(player, "STOP")
        SetObjectPropertyValue(object, "particle", {
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
    end)

    -- fire goes out
    Delay(60 * 1000, function()
        SetObjectPropertyValue(object, "particle", nil)
    end)
end)

