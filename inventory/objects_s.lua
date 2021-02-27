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
-- for now, we store just the item name/key
local ItemInstances = {}

function RegisterNewItem(item)
    local uuid = uuid()
    ItemInstances[uuid] = item
    log.debug("Registering item instance ("..item..") uuid: "..uuid)
    return uuid
end

function SetItemInstance(uuid, item)
    ItemInstances[uuid] = item
end

function UnregisterItemInstance(uuid)
    ItemInstances[uuid] = nil
end

function GetItemInstance(uuid)
    return ItemInstances[uuid]
end

function GetAllItemInstances()
    return ItemInstances
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
