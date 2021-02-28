WorldLightingConfig = {
    [582] = {
        type = "pointlight",
        position = {
            x = 0,
            y = 66.3,
            z = 147.6,
            rx = 0,
            ry = 86.6,
            rz = 0
        },
        intensity = 10000
    },
    [583] = {
        type = "spotlight",
        position = {
            x = 0,
            y = 10.3,
            z = 25.6,
            rx = 0,
            ry = 91.7,
            rz = 0
        },
        intensity = 5000
    },
    [1398] = {
        type = "pointlight",
        position = {
            x = -127,
            y = 0.2,
            z = 400,
            rx = -4.9,
            ry = 5.2,
            rz = 5.2
        },
        intensity = 15000
    },
    [388] = {
        type = "rectlight",
        position = {
            x = 0,
            y = 0.2,
            z = 254.4,
            rx = -76.1,
            ry = 45.9,
            rz = 0
        },
        intensity = 50000
    }
}

--
-- Lighting
--

function AddLightingProp(object, component_config)
    log.debug("Adding light prop to object "..object)

    SetObjectPropertyValue(object, "light_component", component_config)
    SetObjectPropertyValue(object, "light_enabled", true)

    SetObjectPropertyValue(object, "prop", {
        use_label = "Enable/Disable",
        remote_event = "ToggleLight",
    })
end

AddRemoteEvent("ToggleLight", function(player, prop)
    log.info(GetPlayerName(player) .. " toggles light object " .. prop.hit_object)
    local light_enabled = GetObjectPropertyValue(prop.hit_object, "light_enabled")
    SetObjectPropertyValue(prop.hit_object, "light_enabled", not light_enabled)

    local x,y,z = GetObjectLocation(prop.hit_object)
    PlaySoundSync("sounds/switch.mp3", x, y, z)
end)
