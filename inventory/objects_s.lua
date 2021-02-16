-- item configuration
ItemConfigs = {}

-- object factory
function GetItemConfig(item)
    return ItemConfigs[item]
end

function GetItemConfigs()
    return ItemConfigs
end

function RegisterItemConfig(item, meta)
    ItemConfigs[item] = meta
    log.debug("Registering item config: " .. item)
end

-- item world instances
ItemInstances = {}

function RegisterNewItem(item)
    local uuid = uuid()
    ItemInstances[uuid] = item
    log.debug("Registering item instance ("..item..") uuid: "..uuid)
    return uuid
end

function GetRegisteredItem(uuid)
    return ItemInstances[uuid]
end

AddEvent("OnPackageStop", function()
    Objects = {}
    ItemInstances = {}
end)

function GetItemType(item)
    local item_cfg = GetItemConfig(item)
    if item_cfg then
        return item_cfg['type']
    end
end

function GetItemAttachmentBone(item)
    local item_cfg = GetItemConfig(item)
    if item_cfg and item_cfg['attachment'] then
        return item_cfg['attachment']['bone']
    end
end

-- 
function PlayInteraction(player, item, after_use_callback)
    log.debug("Playing interaction for item " .. item)
    local item_cfg = GetItemConfig(item)
    if not item_cfg['interaction'] then
        if after_use_callback then
            after_use_callback()
        end
        return
    end
    if item_cfg['interaction']['animation'] then
        SetPlayerAnimation(player, item_cfg['interaction']['animation']['name'])

        local duration = item_cfg['interaction']['animation']['duration'] or 2000 -- default animation delay

        CallRemoteEvent(player, "StartInteraction", {
            ['duration'] = duration,
            ['show_spinner'] = item_cfg['interaction']['animation']['spinner']
        })

        Delay(duration, function()
            SetPlayerAnimation(player, "STOP")

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
