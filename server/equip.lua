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

-- clear equipped store for all players
function DestroyEquippedObjectsForPlayer(player)
    equipped = GetPlayerPropertyValue(player, "equipped")
    if equipped == nil then
        return
    end

    for item, object in pairs(equipped) do
        log.debug("Destroying equipped object for player " .. GetPlayerName(player) .. " item " .. item)
        SetObjectDetached(object)
        DestroyObject(object)
    end

    -- clear player equipment
    SetPlayerPropertyValue(player, "equipped", {})

    -- stop any animation player might be in
    SetPlayerAnimation(player, "STOP")
end

function EquipObject(player, item)
    -- unarm first
    SwitchToFists(player)

    local item_cfg = GetItemConfig(item)

    -- if item is a resource, do nothing
    if item_cfg['type'] ~= 'equipable' and item_cfg['type'] ~= 'usable' then
        log.debug "not equipable"
        return
    end

    if item_cfg['attachment'] == nil then
        log.debug "not attachable"
        return
    end

    -- equipable items can be toggled via hotkey
    if item_cfg['type'] == 'equipable' and GetEquippedObject(player, item) ~= nil then
        log.debug "already equipped; unequipping..."
        UnequipObject(player, item)
        return
    end

    -- start equipping
    log.debug(GetPlayerName(player) .. " equips item " .. item)

    -- unequip whatever is in the player's bone first
    UnequipFromBone(player, item_cfg['attachment']['bone'])

    -- equipable animations
    PlayInteraction(player, item)

    local x, y, z = GetPlayerLocation(player)
    local attached_object = CreateObject(item_cfg['modelid'], x, y, z)

    SetObjectPropertyValue(attached_object, "_name", item)
    SetObjectPropertyValue(attached_object, "_bone", item_cfg['attachment']['bone'])
    SetObjectAttached(attached_object, ATTACH_PLAYER, player, item_cfg['attachment']['x'], item_cfg['attachment']['y'],
        item_cfg['attachment']['z'], item_cfg['attachment']['rx'], item_cfg['attachment']['ry'],
        item_cfg['attachment']['rz'], item_cfg['attachment']['bone'])

    -- set lighting component config to object
    if item_cfg['component'] ~= nil then
        SetObjectPropertyValue(attached_object, "component", item_cfg['component'])
    end

    -- set particle config to object
    if item_cfg['particle'] ~= nil then
        log.debug("particle")
        SetObjectPropertyValue(attached_object, "particle", item_cfg['particle'])
    end

    -- update equipped store
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = attached_object
    SetPlayerPropertyValue(player, "equipped", equipped)
    log.trace("EQUIPPED: ", dump(equipped))

    -- call EQUIP event on object
    CallEvent("items:" .. item .. ":equip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

function UnequipFromBone(player, bone)
    -- unequip whatever is in the player's bone
    local equipped_object = GetEquippedObjectNameFromBone(player, bone)
    if equipped_object ~= nil then
        log.debug("Equipped bone " .. bone .. ", unequipping...")
        UnequipObject(player, equipped_object)
    end
end

function UnequipObject(player, item)
    local object = GetEquippedObject(player, item)
    if not object then
        log.warn "item not equipped"
        return
    end

    -- just in case the object requires an animation,
    -- cancel any currently running animations
    SetPlayerAnimation(player, "STOP")

    local item_cfg = GetItemConfig(item)

    -- remove from equipped list
    local equipped = GetPlayerPropertyValue(player, "equipped")
    equipped[item] = nil
    SetPlayerPropertyValue(player, "equipped", equipped)

    log.trace("EQUIPPED: ", dump(equipped))

    DestroyObject(object)

    log.debug(GetPlayerName(player).. " unequipped item "..item)

    -- call UNEQUIP event on object
    CallEvent("items:" .. item .. ":unequip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

function GetEquippedObject(player, item)
    return GetPlayerPropertyValue(player, "equipped")[item] or nil
end

function IsItemEquipped(player, item)
    if GetEquippedObject(player, item) ~= nil then
        return true
    else
        return false
    end
end

function GetEquippedObjectNameFromBone(player, bone)
    local equipped = GetPlayerPropertyValue(player, "equipped")
    for _, object in pairs(equipped) do
        if GetObjectPropertyValue(object, "_bone") == bone then
            -- log.debug "found bone"
            return GetObjectPropertyValue(object, "_name")
        end
    end
end

-- unequip items no longer in player inventory
function CheckEquippedFromInventory(player)
  local equipped = GetPlayerPropertyValue(player, "equipped")
  local inventory = GetPlayerPropertyValue(player, "inventory")

  for item,_ in pairs(equipped) do
    if GetInventoryCount(player,item) == 0 then
      log.debug("Unequipping item "..item.." no longer in inventory")
      UnequipObject(player, item)
    end
  end
end
