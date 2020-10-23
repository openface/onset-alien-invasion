AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
      DestroyEquippedObjectsForPlayer(player)
    end
end)

-- destroy equipped objects on death
AddEvent("OnPlayerDeath", function(player, killer)
    DestroyEquippedObjectsForPlayer(player)
end)

-- destroy vest on quit
AddEvent("OnPlayerQuit", function(player)
    DestroyEquippedObjectsForPlayer(player)
end)

function DestroyEquippedObjectsForPlayer(player)
    equipped = GetPlayerPropertyValue(player, "equipped")
    for item,object in pairs(equipped) do
        print("Destroying equipped object for player " .. GetPlayerName(player) .. " item " .. item)
        SetObjectDetached(object)
        DestroyObject(object)
    end

    -- clear player equipment
    SetPlayerPropertyValue(player, "equipped", {})
end


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
        UnequipObject(player, equipped_object)
    end

    print(GetPlayerName(player).." equips item "..item)

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

    -- set component config to object
    if object['component'] ~= nil then
        SetObjectPropertyValue(attached_object, "component", object['component'])
    end

    -- update equipped store
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = attached_object
    SetPlayerPropertyValue(player, "equipped", equipped)

    -- call EQUIP event on object
    CallEvent("items:"..item..":equip", player, object)
end

function UnequipObject(player, item)
    print "unequipping"
    local object = GetEquippedObject(player, item)
    if object == nil then
        print "not equipped"
        return
    end

    -- just in case the object requires an animation,
    -- cancel any currently running animations
    SetPlayerAnimation(player, "STOP")

    -- remove component config from object
    local item_data = GetObject(item)
    if item_data['component'] ~= nil then
        SetObjectPropertyValue(object, "component", false)
    end

    -- remove from equipped list
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = nil
    SetPlayerPropertyValue(player, "equipped", equipped)

    DestroyObject(object)

    -- call UNEQUIP event on object
    CallEvent("items:" .. item .. ":unequip", player, object)
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

