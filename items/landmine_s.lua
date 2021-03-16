ItemConfig["landmine"] = {
    name = "Landmine",
    type = 'placeable',
    category = "Military Surplus",
    recipe = {
        metal = 20,
        plastic = 2
    },
    interactions = nil,
    modelid = 1030,
    max_carry = 3,
    max_use = 1,
    use_label = "Activate",
    price = 50,
    attachment = {
        x = 10.3,
        y = -4.9,
        z = 0.2,
        rx = 91.7,
        ry = 71.3,
        rz = 10,
        bone = "hand_l"
    }
}

-- This uses a global timer to watch all landmines
-- TODO: it would be better to have each landmine maintain it's own timer 
-- and let the owner of the landmine enable/disable it

-- TODO: use hit event instead of timer!

local LandmineTimer
local BOOM_RANGE = 50

AddEvent("OnPackageStart", function()
    LandmineTimer = CreateTimer(function()
        --log.debug("in timer")
        local landmine_objects = GetPlacedObjectsByName('landmine')
        for _, object in pairs(landmine_objects) do
            local x, y, z = GetObjectLocation(object)
            local players_in_range = GetPlayersInRange2D(x, y, BOOM_RANGE)
            if next(players_in_range) ~= nil then
                -- boom
                CreateExplosion(9, x, y, z, true, 1500.0, 1000000.0)
                RemovePlacedObject(object)
            end
        end
    end, 1000)
end)

AddEvent("OnPackageStop", function()
    DestroyTimer(LandmineTimer)
end)

AddEvent("items:landmine:placed", function(player, object)
    PauseTimer(LandmineTimer)

    Delay(5 * 1000, function()
        UnpauseTimer(LandmineTimer)
        CallRemoteEvent(player, "ShowMessage", "Landmine is now activated!")
    end)
end)
