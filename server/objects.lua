-- item configuration
Objects = {}

-- object factory
function GetObject(item)
    return Objects[item]
end

function GetObjects()
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
    local object = GetObject(item)
    if not object['interaction'] then
        return
    end
    if object['interaction']['animation'] then
        SetPlayerAnimation(player, object['interaction']['animation']['name'])
        if object['interaction']['animation']['duration'] then
            Delay(object['interaction']['animation']['duration'], function()
                SetPlayerAnimation(player, "STOP")
            end)
        end
    end
    if object['interaction']['sound'] then
        PlaySound(player, object['interaction']['sound'])
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
