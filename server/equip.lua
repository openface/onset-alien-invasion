AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
      for item,object in pairs(GetPlayerPropertyValue(player, 'equipped')) do
        print("Destroying equipped object for player "..GetPlayerName(player).." item "..item)
        SetObjectDetached(object)
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

    print(GetPlayerName(player).." equip item "..item)

    -- equipable animations
    PlayInteraction(player, item)

    local x,y,z = GetPlayerLocation(player)
    local attached_object = CreateObject(object['modelid'], x, y, z)

    SetObjectPropertyValue(attached_object, "_name", item)
    SetObjectPropertyValue(attached_object, "_bone", object['attachment']['bone'])
    SetObjectAttached(attached_object, ATTACH_PLAYER, player, 
        object['attachment']['x'],
        object['attachment']['y'],
        object['attachment']['z'],
        object['attachment']['rx'],
        object['attachment']['ry'],
        object['attachment']['rz'],
        object['attachment']['bone'])

    CallEvent("items:" .. item .. ":attach", player, attached_object)

    -- update equipped store
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = attached_object
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

    CallEvent("items:" .. item .. ":detach", player, _object)

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
