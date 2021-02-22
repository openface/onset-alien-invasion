-- item configuration
ItemConfig = {}

function GetItemConfigsByType(type)
    local items = {}
    for item,cfg in pairs(ItemConfig) do
        if cfg['type'] == type then
            items[item] = cfg
        end
    end
    return items
end

-- item world instances
-- for now, we store just the item key
ItemInstances = {}

function RegisterNewItem(item)
    local uuid = uuid()
    ItemInstances[uuid] = item
    log.debug("Registering item instance ("..item..") uuid: "..uuid)
    return uuid
end

function GetItemInstance(uuid)
    return ItemInstances[uuid]
end

AddEvent("OnPackageStop", function()
    Objects = {}
    ItemInstances = {}
end)

function GetItemType(item)
    if ItemConfig[item] then
        return ItemConfig[item]['type']
    end
end

function GetItemAttachmentBone(item)
    if ItemConfig[item] and ItemConfig[item].attachment then
        return ItemConfig[item].attachment['bone']
    end
end

-- 
function PlayInteraction(player, uuid, after_use_callback)
    local item = GetItemInstance(uuid)
    log.debug("Playing interaction for item " .. item .. " uuid ".. uuid)

    if not ItemConfig[item].interaction then
        if after_use_callback then
            after_use_callback()
        end
        return
    end
    if ItemConfig[item].interaction['animation'] then
        SetPlayerAnimation(player, ItemConfig[item].interaction['animation']['name'])

        local duration = ItemConfig[item].interaction['animation']['duration'] or 2000 -- default animation delay

        CallRemoteEvent(player, "StartInteraction", {
            ['duration'] = duration,
            ['show_spinner'] = ItemConfig[item].interaction['animation']['spinner']
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
    if ItemConfig[item].interaction['sound'] then
        PlaySoundSync(player, ItemConfig[item].interaction['sound'])
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
