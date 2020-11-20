RegisterObject("landmine", {
    name = "Landmine",
    type = 'usable',
    category = "Military Surplus",
    recipe = {
        metal = 20,
        plastic = 2
    },
    interaction = {
        sound = "sounds/shovel.wav",
        animation = {
            name = "PICKUP_LOWER"
        }
    },
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
})

-- This uses a global timer to watch all landmines
-- TODO: it would be better to have each landmine maintain it's own timer 
-- and let the owner of the landmine enable/disable it

-- TODO: use hit event instead of timer!

local Landmines = {}
local LandmineTimer

AddEvent("OnPackageStart", function()
    LandmineTimer = CreateTimer(function()
        --log.debug("in timer")
        for _, object in pairs(Landmines) do
            local x, y, z = GetObjectLocation(object)
            local players_in_range = GetPlayersInRange2D(x, y, 300)
            if next(players_in_range) ~= nil then
                -- boom
                CreateExplosion(9, x, y, z, true, 1500.0, 1000000.0)
                Landmines[object] = nil
                DestroyObject(object)
            end
        end
    end, 1000)
end)

AddEvent("OnPackageStop", function()
    for _, o in pairs(Landmines) do
        DestroyObject(o)
    end
    DestroyTimer(LandmineTimer)
    Landmines = {}
end)

AddEvent("items:landmine:use", function(player, item_cfg)
    local x, y, z = GetPlayerLocation(player)
    local object = CreateObject(1030, x + 100, y, z - 100)

    PauseTimer(LandmineTimer)

    Landmines[object] = object

    Delay(10 * 1000, function()
        UnpauseTimer(LandmineTimer)
        AddPlayerChat(player, "Landmine is now activated!")
    end)
end)
