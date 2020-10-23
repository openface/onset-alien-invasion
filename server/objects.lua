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
    print("Registering object: "..item)
end

AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
      for item,object in pairs(GetPlayerPropertyValue(player, 'equipped')) do
        print("Destroying object for player "..GetPlayerName(player).." equipped item "..item)
        DestroyObject(object)
      end
      SetPlayerPropertyValue(player, "equipped", {})
    end
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
            end)
        end
    end
    if item_cfg['interaction']['sound'] then
        PlaySound(player, item_cfg['interaction']['sound'])
    end
end

function PlaySound(player, sound)
    local x,y,z = GetPlayerLocation(player)
    for k,ply in pairs(GetAllPlayers()) do
        local _x,_y,_z = GetPlayerLocation(ply)
        if GetDistance3D(x, y, z, _x, _y, _z) <= 1000 then
            CallRemoteEvent(ply, "PlayObjectUseSound", sound, x, y, z)
        end
    end
end
