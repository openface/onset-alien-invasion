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

function EquipObject(player, item)
    local object = GetObject(item)
    if object['type'] ~= 'equipable' then
        print "not equipable"
        return
    end

    if GetEquippedObject(player, item) ~= nil then
        print "already equipped"
        return
    end

    if object['attachment'] == nil then
        print("Object "..item.." is type equipable but does not define attachment info")
        return
    end

    -- unequip whatever is in the player's bone
    local equipped_object = GetEquippedObjectNameFromBone(player, object['attachment']['bone'])
    if equipped_object ~= nil then
        print "unequipping equipped"
        UnequipObject(player, equipped_object)
    end

    -- equipable animations
    PlayInteraction(player, item)

    local x,y,z = GetPlayerLocation(player)
    local _object = CreateObject(object['modelid'], x, y, z)

    SetObjectPropertyValue(_object, "_name", item)
    SetObjectPropertyValue(_object, "_bone", object['attachment']['bone'])
    SetObjectAttached(_object, ATTACH_PLAYER, player, 
        object['attachment']['x'],
        object['attachment']['y'],
        object['attachment']['z'],
        object['attachment']['rx'],
        object['attachment']['ry'],
        object['attachment']['rz'],
        object['attachment']['bone'])

    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = _object
    SetPlayerPropertyValue(player, "equipped", equipped)
end

function UnequipObject(player, item)
    print "unequipping"
    local _object = GetEquippedObject(player, item)
    if _object == nil then
        print "not equipped"
        return
    end

    -- just in case the object requires an animation
    SetPlayerAnimation(player, "STOP")

    -- remove from equipped list
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = nil
    SetPlayerPropertyValue(player, "equipped", equipped)

    DestroyObject(_object)
end

function GetEquippedObject(player, item)
    return GetPlayerPropertyValue(player, "equipped")[item] or nil
end

function GetEquippedObjectNameFromBone(player, bone)
    local equipped = GetPlayerPropertyValue(player, "equipped")
    for _,object in pairs(equipped) do
        if GetObjectPropertyValue(object, "_bone") == bone then
            print "found bone"
            return GetObjectPropertyValue(object, "_name")
        end
    end
end

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
