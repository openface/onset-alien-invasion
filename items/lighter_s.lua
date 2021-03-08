ItemConfig["lighter"] = {
    name = "Lighter",
    type = 'usable',
    category = "Supplies",
    recipe = nil,
    interaction = {
        sound = "sounds/zippo.wav",
        animation = {
            id = 924,
            duration = 10000
        },
        interacts_on = {{
            hittype = "tree", -- item: campfire?
            use_label = "Light Fire",
        }}
    },
    modelid = 20024,
    max_use = 20,
    use_label = "Light",
    image = "survival/SM_Lighter.png",
    max_carry = 1,
    price = 150,
    attachment = {
        x = -10.5,
        y = 5.5,
        z = 0,
        rx = 0,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    }
}

--
-- Chopping
--
AddEvent("items:axe:use", function(player, object, prop)
    if not prop then
        return
    end
    log.debug(GetPlayerName(player) .. " is chopping a tree")

    CallRemoteEvent(player, "ShowMessage", "You collect some wood and put it in your inventory")
    AddToInventoryByName(player, "wood", 5)
end)
