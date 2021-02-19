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

function EquipItem(player, item)
    log.trace("EquipItem", item)
    local item_cfg = GetItemConfig(item)

    if not item_cfg then
        log.error("Cannot equip invalid item "..item)
        return
    end

    if item_cfg['attachment'] == nil and item_cfg['type'] ~= 'weapon' then
        log.debug "not attachable"
        return
    end

    if GetEquippedObject(player, item) ~= nil then
        log.debug "already equipped; unequipping..."
        UnequipItem(player, item)
        return
    end

    -- start equipping
    log.debug(GetPlayerName(player) .. " equips item " .. item)

    -- unequip whatever is in hands if equipping to hands
    if item_cfg['type'] == 'weapon' then
        -- unequip hands when switching to a weapon
        UnequipFromBone(player, 'hand_r')
        UnequipFromBone(player, 'hand_l')
    elseif item_cfg['attachment']['bone'] == 'hand_r' or item_cfg['attachment']['bone'] == 'hand_l' then
        -- switch to fists when equipping an object
        SwitchToFists(player)

        -- unequip hands
        UnequipFromBone(player, 'hand_r')
        UnequipFromBone(player, 'hand_l')
    end

    -- equipable animations
    if item_cfg['type'] == 'equipable' then
        PlayInteraction(player, item)
    end

    attached_object = AttachItemToPlayer(player, item)

    -- update equipped store
    local equipped = PlayerData[player].equipped
    equipped[item] = attached_object
    PlayerData[player].equipped = equipped
    log.trace("EQUIPPED: ", dump(equipped))

    -- call EQUIP event on object
    CallEvent("items:" .. item .. ":equip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

-- attaches object or weapon to player
function AttachItemToPlayer(player, item)
    local item_cfg = GetItemConfig(item)

    if item_cfg['type'] == 'weapon' then
        AddWeaponFromInventory(player, item, false)
        return true
    end

    local x, y, z = GetPlayerLocation(player)
    local attached_object = CreateObject(item_cfg['modelid'], x, y, z)

    SetObjectPropertyValue(attached_object, "_name", item)
    SetObjectAttached(attached_object, ATTACH_PLAYER, player, item_cfg['attachment']['x'], item_cfg['attachment']['y'],
        item_cfg['attachment']['z'], item_cfg['attachment']['rx'], item_cfg['attachment']['ry'],
        item_cfg['attachment']['rz'], item_cfg['attachment']['bone'])

    -- set lighting component config to object
    if item_cfg['light_component'] ~= nil then
        SetObjectPropertyValue(attached_object, "light_component", item_cfg['light_component'])

        -- allow item to not have light enabled by default
        if item_cfg['light_component']['default_enabled'] == false then
            SetObjectPropertyValue(attached_object, "light_enabled", false)
        else
            -- if default_enabled is not given, default to enabled
            SetObjectPropertyValue(attached_object, "light_enabled", true)
        end
    end

    -- set particle config to object
    if item_cfg['particle'] ~= nil then
        SetObjectPropertyValue(attached_object, "particle", item_cfg['particle'])
    end

    return attached_object
end

-- unequip whatever is equipped on given bone
-- returns unequipped item or nil
function UnequipFromBone(player, bone)
    log.debug("UnequipFromBone", bone)
    -- unequip whatever is in the player's bone
    local equipped_item = GetEquippedItemNameFromBone(player, bone)
    if equipped_item ~= nil then
        log.debug("Bone " .. bone .. " is already equipped, unequipping...")
        UnequipItem(player, equipped_item)
    end
end

-- Unequips objects or weapons from player
function UnequipItem(player, item)
    local item_cfg = GetItemConfig(item)
    if not item_cfg then
        return
    end

    -- item is attached object to player
    local object = GetEquippedObject(player, item)
    if not object then
        log.warn "item not equipped"
        return
    end

    -- just in case the object requires an animation,
    -- cancel any currently running animations
    SetPlayerAnimation(player, "STOP")

    -- remove from equipped list
    local equipped = PlayerData[player].equipped
    equipped[item] = nil
    PlayerData[player].equipped = equipped

    log.trace("EQUIPPED: ", dump(equipped))

    if item_cfg['type'] == 'weapon' then
        UnequipWeapon(player, item)
    else
        DestroyObject(object)
    end

    log.debug(GetPlayerName(player) .. " unequipped item " .. item)

    -- call UNEQUIP event on object
    CallEvent("items:" .. item .. ":unequip", player, object)

    -- sync inventory
    CallEvent("SyncInventory", player)
end

function GetEquippedObject(player, item)
    return PlayerData[player].equipped[item] or nil
end

function IsItemEquipped(player, item)
    if WeaponsConfig[item] then
        return IsWeaponEquipped(player, item)
    elseif GetEquippedObject(player, item) ~= nil then
        return true
    else
        return false
    end
end

function GetEquippedItemNameFromBone(player, bone)
    local equipped = PlayerData[player].equipped
    for item, object in pairs(equipped) do
        local item_cfg = GetItemConfig(item)
        if item_cfg['type'] == 'weapon' and (bone == 'hand_l' or bone == 'hand_r') then
            return item
        elseif item_cfg['attachment'] and item_cfg['attachment']['bone'] == bone then
            return item
        end
    end
end

-- unequip items no longer in player inventory
function CheckEquippedFromInventory(player)
    local equipped = PlayerData[player].equipped
    local inventory = PlayerData[player].inventory

    for item, _ in pairs(equipped) do
        if GetInventoryCount(player, item) == 0 then
            log.debug("Unequipping item " .. item .. " no longer in inventory")
            UnequipItem(player, item)
        end
    end
end
