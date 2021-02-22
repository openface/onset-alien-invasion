ItemConfig["flashlight"] = {
    name = "Flashlight",
    type = 'equipable',
    category = "Supplies",
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    modelid = 1270,
    max_carry = 1,
    use_label = "On/Off",
    interaction = {
        sound = "sounds/flashlight.wav"
    },
    price = 50,
    light_component = {
        type = "spotlight",
        position = {
            x = 0,
            y = 0,
            z = 14.9,
            rx = -30.5,
            ry = 270,
            rz = 0
        },
        intensity = 5000,
        default_enabled = false
    },
    attachment = {
        x = 33,
        y = -8,
        z = 0,
        rx = 360,
        ry = 260,
        rz = -120,
        bone = "hand_l"
    }
}

AddEvent("items:flashlight:use", function(player, options, object)
    log.trace("items:flashlight:use", player, options, object)

    log.info(GetPlayerName(player) .. " toggles light object " .. object)

    local light_enabled = GetObjectPropertyValue(object, "light_enabled")
    local new_enabled = not light_enabled
    if new_enabled then
        SetObjectModel(object, 1271)
    else
        SetObjectModel(object, 1270)
    end
    SetObjectPropertyValue(object, "light_enabled", new_enabled)
end)
