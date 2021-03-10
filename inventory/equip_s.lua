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

-- sets weapons slots from inventory data
-- if we find a weapon in inventory that is supposed to be equipped, equip it
function SyncWeaponSlotsFromInventory(player)
    local inventory = PlayerData[player].inventory
    for i, inventory_item in ipairs(inventory) do
        if inventory_item.type == 'weapon' and GetEquippedObject(player, inventory_item.uuid) then
            EquipWeaponFromInventory(player, inventory_item.uuid, false)
            return
        end
    end
end

function EquipItem(player, uuid)
    log.trace("EquipItem", uuid)
    local item = GetItemInstance(uuid)
    if not item then
        log.error("Cannot equip unknown item " .. uuid)
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

    -- start equipping
    log.debug(GetPlayerName(player) .. " equips item " .. item .. " uuid: " .. uuid)

    -- if equipping to hands, unequip whatever is in hands
    if ItemConfig[item].type == 'weapon' or
        (ItemConfig[item].attachment['bone'] == 'hand_r' or ItemConfig[item].attachment['bone'] == 'hand_l') then

        UnequipFromBone(player, 'hand_r')
        UnequipFromBone(player, 'hand_l')
    end

    --[[     if ItemConfig[item].type == 'equipable' then
    end
 ]]
    -- equip interaction
    if ItemConfig[item].interactions and ItemConfig[item].interactions.equip then
        PlayInteraction(player, ItemConfig[item].interactions.equip, function()
            log.debug("Calling event: " .. ItemConfig[item].interactions.equip.event)
            CallEvent(ItemConfig[item].interactions.equip.event, player, object)
        end)
    end

    -- update equipment list
    local equipped = PlayerData[player].equipped

    -- clear all weapons from equipped list
    for uuid, v in pairs(equipped) do
        if v == 'weapon' then
            equipped[uuid] = nil
        end
    end

    if ItemConfig[item].type == 'weapon' then
        local weapon_id = AttachWeaponToPlayer(player, uuid)
        equipped[uuid] = 'weapon'
    else
        local attached_object = AttachObjectToPlayer(player, uuid)
        equipped[uuid] = attached_object
    end
    PlayerData[player].equipped = equipped
    log.trace("EQUIPPED: ", dump(equipped))

    -- sync inventory
    CallEvent("SyncInventory", player)
end

function AttachWeaponToPlayer(player, uuid)
    local item = GetItemInstance(uuid)
    if ItemConfig[item].type ~= 'weapon' then
        log.error("Cannot attach non-weapon")
        return
    end
    ClearAllWeaponSlots(player)
    EquipWeaponFromInventory(player, uuid, true)
    return item.weapon_id
end

-- attaches object or weapon to player
function AttachObjectToPlayer(player, uuid)
    local item = GetItemInstance(uuid)

    if ItemConfig[item].type == 'weapon' then
        log.error("Cannot attach weapon")
        return
    end

    local x, y, z = GetPlayerLocation(player)
    local attached_object = CreateObject(ItemConfig[item].modelid, x, y, z)

    if ItemConfig[item].scale then
        SetObjectScale(attached_object, ItemConfig[item].scale.x, ItemConfig[item].scale.y, ItemConfig[item].scale.z)
    end

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

-- equips weapon by item, updates equipped list, and adds to weapon slot
function EquipWeaponFromInventory(player, uuid, equip)
    log.trace("EquipWeaponFromInventory", uuid, equip)

    local inventory_item = GetItemFromInventory(player, uuid)
    log.debug("Equipping weapon from inventory to slot", player, uuid, inventory_item.hotbar_slot)
    EquipWeaponToSlot(player, uuid, inventory_item.hotbar_slot, equip)
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
        log.warn("item " .. uuid .. "not equipped")
        return
    end

    -- just in case the object requires an animation,
    -- cancel any currently running animations
    SetPlayerAnimation(player, "STOP")

    --[[     if ItemConfig[item].type == 'equipable' then
    end
 ]]
    -- unequip interaction
    if ItemConfig[item].interactions and ItemConfig[item].interactions.unequip then
        PlayInteraction(player, ItemConfig[item].interactions.unequip, function()
            log.debug("Calling event: " .. ItemConfig[item].interactions.unequip.event)
            CallEvent(ItemConfig[item].interactions.unequip.event, player, object)
        end)
    end

    -- remove from equipped list
    local equipped = PlayerData[player].equipped
    equipped[uuid] = nil
    PlayerData[player].equipped = equipped

    if ItemConfig[item].type == 'weapon' then
        UnequipWeapon(player, uuid)
    else
        DestroyObject(object)
    end

    log.debug(GetPlayerName(player) .. " unequipped item " .. item .. " uuid: " .. uuid)

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

function IsWeaponEquipped(player, uuid)
    return PlayerData[player].equipped[uuid] == 'weapon' or nil
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
