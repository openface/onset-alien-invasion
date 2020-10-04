Objects = {}

-- object factory
function GetObject(name)
    return Objects[name]
end

function GetObjects()
    return Objects
end

function RegisterObject(name, meta)
    Objects[name] = meta
    print("Registering object: "..name)
end
AddFunctionExport("RegisterObject", RegisterObject)

function EquipObject(player, name)
    local object = GetObject(name)

    if object['type'] ~= 'equipable' then
        print "not equipable"
        return
    end

    if GetEquippedObject(player, name) ~= nil then
        print "already equipped"
        return
    end

    -- unequip whatever is in the player's bone
    local equipped_object = GetEquippedObjectNameFromBone(player, object['attachment']['bone'])
    if equipped_object ~= nil then
        print "unequipping equipped"
        UnequipObject(player, equipped_object)
    end

    PlayInteraction(player, name)

    local x,y,z = GetPlayerLocation(player)
    local _object = CreateObject(object['modelid'], x, y, z)
    SetObjectPropertyValue(_object, "_name", name)
    SetObjectPropertyValue(_object, "_bone", object['attachment']['bone'])
    SetObjectAttached(_object, ATTACH_PLAYER, player, 
        object['attachment']['x'],
        object['attachment']['y'],
        object['attachment']['z'],
        object['attachment']['rx'],
        object['attachment']['ry'],
        object['attachment']['rz'],
        object['attachment']['bone'])

    local _equipped = GetPlayerPropertyValue(player, "_equipped")
    _equipped[name] = _object
    SetPlayerPropertyValue(player, "_equipped", _equipped)
end

function UnequipObject(player, name)
    print "unequipping"
    local _object = GetEquippedObject(player, name)
    if _object == nil then
        print "not equipped"
        return
    end

    -- just in case the object requires an animation
    SetPlayerAnimation(player, "STOP")

    -- remove from equipped list
    local _equipped = GetPlayerPropertyValue(player, "_equipped")
    _equipped[name] = nil
    SetPlayerPropertyValue(player, "_equipped", _equipped)

    DestroyObject(_object)
end

function GetEquippedObject(player, name)
    local _equipped = GetPlayerPropertyValue(player, "_equipped")
    return _equipped[name]
end

function GetEquippedObjectNameFromBone(player, bone)
    local _equipped = GetPlayerPropertyValue(player, "_equipped")
    for _,object in pairs(_equipped) do
        if GetObjectPropertyValue(object, "_bone") == bone then
            print "found bone"
            return GetObjectPropertyValue(object, "_name")
        end
    end
end

function PlayInteraction(player, name)
    local object = GetObject(name)
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
