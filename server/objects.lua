-- item configuration
Objects = {}

-- object factory
function GetItemConfig(item)
    return Objects[item]
end

function GetItemConfigs()
    return Objects
end

function RegisterObject(item, meta)
    Objects[item] = meta
    log.debug("Registering object: " .. item)
end

AddEvent("OnPackageStop", function()
    Objects = {}
end)

-- 
function PlayInteraction(player, item, after_use_callback)
    local item_cfg = GetItemConfig(item)
    if not item_cfg['interaction'] then
        return
    end
    if item_cfg['interaction']['animation'] then
        SetPlayerAnimation(player, item_cfg['interaction']['animation']['name'])

        local duration = item_cfg['interaction']['animation']['duration'] or 2000 -- default animation delay
        if item_cfg['interaction']['animation']['spinner'] then
            CallRemoteEvent(player, "ShowSpinner")
        end

        Delay(duration, function()
            SetPlayerAnimation(player, "STOP")
            if item_cfg['interaction']['animation']['spinner'] then
                CallRemoteEvent(player, "HideSpinner")
            end

            if after_use_callback then
                after_use_callback()
            end
        end)
    else
        if after_use_callback then
            after_use_callback()
        end
    end
    if item_cfg['interaction']['sound'] then
        PlaySoundSync(player, item_cfg['interaction']['sound'])
    end
end

function PlaySoundSync(player, sound, distance)
    local distance = distance or 1000
    local x, y, z = GetPlayerLocation(player)
    for k, ply in pairs(GetAllPlayers()) do
        local _x, _y, _z = GetPlayerLocation(ply)
        if GetDistance3D(x, y, z, _x, _y, _z) <= distance then
            CallRemoteEvent(ply, "Play3DSound", sound, x, y, z)
        end
    end
end
