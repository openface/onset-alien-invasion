RegisterObject("wood", {
    name = "Wood",
    type = 'usable',
    modelid = 297,
    scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    max_carry = 25,
    max_use = 1,
    attachment = nil,
    recipe = nil,
    price = nil,
    interaction = nil -- animation sequence is done in event
})

local Campfires = {}

AddEvent("items:wood:use", function(player, item_cfg)
    local x, y, z = GetPlayerLocation(player)
    local object = CreateObject(20007, x + 50, y, z - 100)
    Campfires[object] = object

    SetPlayerAnimation(player, "REVIVE")

    Delay(10000, function()
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
end)

AddEvent("OnPackageStop", function()
    for _, object in pairs(Campfires) do
        DestroyObject(object)
    end
end)
