-- clear equipped store for all players
function ClearEquippedObjects(player)
    local equipped = PlayerData[player].equipped
    if equipped == nil then
        return
    end

    for item, object in pairs(equipped) do
        log.debug("Destroying equipped object for player " .. GetPlayerName(player) .. " item " .. item)
        SetObjectDetached(object)
        DestroyObject(object)
    end

    -- stop any animation player might be in
    SetPlayerAnimation(player, "STOP")
end

function EquipItem(player, uuid)
    log.trace("EquipItem", uuid)
    local item = GetItemInstance(uuid)
    if not item then
        log.error("Cannot equip unknown item "..uuid)
        return
    end

    if not ItemConfig[item] then
        log.error("Cannot equip invalid item " .. item)
        return
    end

    if ItemConfig[item].attachment == nil and ItemConfig[item].type ~= 'weapon' then
        log.debug "not attachable"
        return
    end

    if GetEquippedObject(player, uuid) ~= nil then
        log.debug "already equipped; unequipping..."
        UnequipItem(player, uuid)
        return
    end

    -- start equipping
    log.debug(GetPlayerName(player) .. " equips item " .. item .." uuid: " .. uuid)

    -- unequip whatever is in hands if equipping to hands
    if ItemConfig[item].type == 'weapon' then
        -- unequip hands when switching to a weapon
        -- and not currently holding a weapon
        if not GetCurrentWeaponID(player) then
            log.debug("Unequipping object before equipping weapon")
            UnequipFromBone(player, 'hand_r')
            UnequipFromBone(player, 'hand_l')
        end
    elseif ItemConfig[item].attachment['bone'] == 'hand_r' or ItemConfig[item].attachment['bone'] == 'hand_l' then
        -- switch to fists when equipping an object
        -- and currently holding a weapon
        local slot = GetPlayerEquippedWeaponSlot(player)
        if slot then
            UnequipWeaponSlot(player, slot)
        end

        -- unequip hands
        UnequipFromBone(player, 'hand_r')
        UnequipFromBone(player, 'hand_l')
    end

    -- equipable animations
    if ItemConfig[item].type == 'equipable' then
        PlayInteraction(player, uuid)
    end

    attached_object = AttachItemToPlayer(player, uuid)

    -- update equipped store
    local equipped = PlayerData[player].equipped
    equipped[uuid] = attached_object
    PlayerData[player].equipped = equipped
    log.trace("EQUIPPED: ", dump(equipped))

    -- call EQUIP event on object
    CallEvent("items:" .. item .. ":equip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

-- attaches object or weapon to player
function AttachItemToPlayer(player, uuid)
    local item = GetItemInstance(uuid)

    if ItemConfig[item].type == 'weapon' then
        EquipWeaponFromInventory(player, uuid, false)
        return true
    end

    local x, y, z = GetPlayerLocation(player)
    local attached_object = CreateObject(ItemConfig[item].modelid, x, y, z)

    SetObjectPropertyValue(attached_object, "_name", item)
    SetObjectAttached(attached_object, ATTACH_PLAYER, player, ItemConfig[item].attachment['x'],
        ItemConfig[item].attachment['y'], ItemConfig[item].attachment['z'], ItemConfig[item].attachment['rx'],
        ItemConfig[item].attachment['ry'], ItemConfig[item].attachment['rz'], ItemConfig[item].attachment['bone'])

    -- set lighting component config to object
    if ItemConfig[item].light_component then
        SetObjectPropertyValue(attached_object, "light_component", ItemConfig[item].light_component)

        -- allow item to not have light enabled by default
        if ItemConfig[item].light_component['default_enabled'] == false then
            SetObjectPropertyValue(attached_object, "light_enabled", false)
        else
            -- if default_enabled is not given, default to enabled
            SetObjectPropertyValue(attached_object, "light_enabled", true)
        end
    end

    -- set particle config to object
    if ItemConfig[item].particle then
        SetObjectPropertyValue(attached_object, "particle", ItemConfig[item].particle)
    end

    return attached_object
end

-- unequip whatever is equipped on given bone
-- returns unequipped item or nil
function UnequipFromBone(player, bone)
    log.debug("UnequipFromBone", bone)
    -- unequip whatever is in the player's bone
    local equipped_uuid = GetEquippedItemFromBone(player, bone)
    if equipped_uuid then
        log.debug("Bone " .. bone .. " is already equipped " .. equipped_uuid .. ", unequipping...")
        UnequipItem(player, equipped_uuid)
    end
end

-- Unequips objects or weapons from player
function UnequipItem(player, uuid)
    local item = GetItemInstance(uuid)

    if not ItemConfig[item] then
        return
    end

    -- item is attached object to player
    local object = GetEquippedObject(player, uuid)
    if not object then
        log.warn("item "..uuid.."not equipped")
        return
    end

    -- just in case the object requires an animation,
    -- cancel any currently running animations
    SetPlayerAnimation(player, "STOP")

    -- remove from equipped list
    local equipped = PlayerData[player].equipped
    equipped[uuid] = nil
    PlayerData[player].equipped = equipped

    log.trace("EQUIPPED: ", dump(equipped))

    if ItemConfig[item].type == 'weapon' then
        UnequipWeapon(player, uuid)
    else
        DestroyObject(object)
    end

    log.debug(GetPlayerName(player) .. " unequipped item " .. item .." uuid: ".. uuid)

    -- call UNEQUIP event on object
    CallEvent("items:" .. item .. ":unequip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

function GetEquippedObject(player, uuid)
    return PlayerData[player].equipped[uuid] or nil
end

function IsItemEquipped(player, uuid)
    local item = GetItemInstance(uuid)

    if ItemConfig[item].type == 'weapon' then
        return IsWeaponEquipped(player, uuid)
    elseif GetEquippedObject(player, uuid) ~= nil then
        return true
    else
        return false
    end
end

function GetEquippedItemFromBone(player, bone)
    local equipped = PlayerData[player].equipped
    for uuid, object in pairs(equipped) do
        local item = GetItemInstance(uuid)
        if ItemConfig[item].type == 'weapon' and (bone == 'hand_l' or bone == 'hand_r') then
            return uuid
        elseif ItemConfig[item].attachment and ItemConfig[item].attachment['bone'] == bone then
            return uuid
        end
    end
end

-- unequip items no longer in player inventory
function CheckEquippedFromInventory(player)
    local equipped = PlayerData[player].equipped
    local inventory = PlayerData[player].inventory

    for uuid, _ in pairs(equipped) do
        if GetInventoryCount(player, uuid) == 0 then
            local item = GetItemInstance(uuid)
            log.debug("Unequipping item " .. item .. " no longer in inventory")
            UnequipItem(player, uuid)
        end
    end
end
