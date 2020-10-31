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
    log.debug("Registering object: "..item)
end

AddEvent("OnPackageStop", function()
    Objects = {}
end)

function PlayInteraction(player, item)
    local item_cfg = GetItemConfig(item)
    if not item_cfg['interaction'] then
        return
    end
    if item_cfg['interaction']['animation'] then
        SetPlayerAnimation(player, item_cfg['interaction']['animation']['name'])
        if item_cfg['interaction']['animation']['duration'] then
            Delay(item_cfg['interaction']['animation']['duration'], function()
                SetPlayerAnimation(player, "STOP")

                -- usable objects auto-unequip after use
                if item_cfg['type'] == 'usable' then
                  UnequipObject(player, item)
                end
            end)
        end
    end
    if item_cfg['interaction']['sound'] then
        PlaySoundSync(player, item_cfg['interaction']['sound'])
    end
end

function PlaySoundSync(player, sound)
    local x,y,z = GetPlayerLocation(player)
    for k,ply in pairs(GetAllPlayers()) do
        local _x,_y,_z = GetPlayerLocation(ply)
        if GetDistance3D(x, y, z, _x, _y, _z) <= 1000 then
            CallRemoteEvent(ply, "Play3DSound", sound, x, y, z)
        end
    end
end
