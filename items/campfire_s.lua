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
    interaction = nil
}

local Campfires = {}

AddEvent("items:campfire:equip", function(player)
    SetPlayerAnimation(player, "CARRY_IDLE")    
end)

AddEvent("items:campfire:use", function(player)
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
