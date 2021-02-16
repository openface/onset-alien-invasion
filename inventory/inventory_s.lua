-- get inventory data and send to UI
function SyncInventory(player)
    local inventory_items = PlayerData[player].inventory
    log.trace("INVENTORY ITEMS ("..GetPlayerName(player).."): " .. dump(inventory_items))

    local current_inhand
    local _send = {
        inventory_items = {},
    }

    -- inventory
    for index, item in ipairs(inventory_items) do
        local equipped = IsItemEquipped(player, item['item'])
        local bone = GetItemAttachmentBone(item['item'])
        table.insert(_send.inventory_items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['uuid'] = item['uuid'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['image'] = item['image'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
            ['bone'] = bone,
            ['equipped'] = equipped,
            ['use_label'] = item['use_label'],
            ['used'] = item['used'],
            ['slot'] = item['slot'],
        })
        if equipped and (bone == 'hand_r' or bone == 'hand_r') then
            current_inhand = item['item']
        end
    end
    log.trace("INVENTORY SYNC ("..GetPlayerName(player).."): " .. json_encode(_send))
    CallRemoteEvent(player, "SetInventory", json_encode(_send))

    if current_inhand then
        CallRemoteEvent(player, "SetInHand", current_inhand)
    else
        CallRemoteEvent(player, "SetInHand", nil)
    end
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
function AddToInventory(player, uuid)
    local item = GetItemInstance(uuid)

    item_cfg = GetItemConfig(item)
    if not item_cfg then
        log.error("Invalid item " .. item)
        return
    end

    local inventory = PlayerData[player].inventory
    local curr_qty = GetInventoryCount(player, item)

    if curr_qty > 0 then
        -- update existing object quantity unless it's a weapon
        SetItemQuantity(player, item, curr_qty + 1)
    else
        -- add new item to store
        table.insert(inventory, {
            item = item,
            uuid = uuid,
            type = item_cfg['type'],
            name = item_cfg['name'],
            modelid = item_cfg['modelid'],
            image = item_cfg['image'],
            use_label = item_cfg['use_label'],
            quantity = 1,
            used = 0,
            slot = nil,
        })
        PlayerData[player].inventory = inventory
    end

    -- auto-equip when added
    if item_cfg['auto_equip'] == true and (item_cfg['type'] == 'equipable' or item_cfg['type'] == 'weapon') then
        log.debug("Auto-equipping item",item)
        EquipItem(player, item)
    end

    CallEvent("SyncInventory", player)
end

-- private function to update inventory item quantity
function SetItemQuantity(player, item, quantity)
    local inventory = PlayerData[player].inventory

    for i, _item in ipairs(inventory) do
        if _item['item'] == item then
            if quantity > 0 then
                -- update quantity
                inventory[i]['quantity'] = quantity
            else
                -- remove object from inventory
                table.remove(inventory, i)
            end
            break
        end
    end
    PlayerData[player].inventory = inventory
    log.debug(GetPlayerName(player) .. " inventory item " .. item .. " quantity set to " .. quantity)
    -- CallEvent("SyncInventory", player)
end

function IncrementItemUsed(player, item)
    local inventory = PlayerData[player].inventory

    for i, _item in ipairs(inventory) do
        if _item['item'] == item then
            -- delete if this is the last use
            local item_cfg = GetItemConfig(item)

            if (item_cfg['max_use'] - _item['used'] == 1) then
                log.debug "all used up!"
                UnequipItem(player, item)
                RemoveFromInventory(player, item)
            else
                log.debug('increment used by 1')
                inventory[i]['used'] = _item['used'] + 1
                PlayerData[player].inventory = inventory
                CallEvent("SyncInventory", player)
            end

            break
        end
    end
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
function RemoveFromInventory(player, item, amount)
    local item_cfg = GetItemConfig(item)
    if not item_cfg then
        log.error("Invalid item: " .. item)
        return
    end

    local inventory = PlayerData[player].inventory

    local amount = amount or 1
    local curr_qty = GetInventoryCount(player, item)

    local new_qty = curr_qty - amount
    SetItemQuantity(player, item, new_qty)

    if new_qty == 0 then
        log.debug("items:" .. item .. ":drop")

        if item_cfg['type'] == 'equipable' or item_cfg['type'] == 'weapon' then
            UnequipItem(player, item)
        end
    end

    -- inventory updated
    CallEvent("SyncInventory", player)
end

-- unequips item, removes from inventory, and places on ground
AddRemoteEvent("DropItemFromInventory", function(player, item, x, y, z)
    log.info("Player " .. GetPlayerName(player) .. " drops item " .. item)

    --SetPlayerAnimation(player, "CARRY_SETDOWN")

    Delay(1000, function()
        RemoveFromInventory(player, item)

        -- spawn object near player
        CreatePickupNearPlayer(player, item)
    end)
end)

-- get carry count for given item
function GetInventoryCount(player, item)
    local inventory = PlayerData[player].inventory
    for _, _item in pairs(inventory) do
        if _item['item'] == item then
            return _item['quantity']
        end
    end
    return 0
end

-- get carry count for given item type
function GetInventoryCountByType(player, type)
    local inventory = PlayerData[player].inventory
    local n = 0
    for _, _item in pairs(inventory) do
        if _item['type'] == type then
            n = n + 1
        end
    end
    return n
end

function GetInventoryAvailableSlots(player)
    local inventory = PlayerData[player].inventory
    local count = 0
    for _ in pairs(inventory) do
        count = count + 1
    end
    -- max slots is hardcoded at 20
    return (20 - count)
end

-- use object from inventory
function UseItemFromInventory(player, item, options)
    local item_cfg = GetItemConfig(item)

    local _item = GetItemFromInventory(player, item)
    log.debug(GetPlayerName(player) .. " uses item " .. item .. " from inventory")

    if GetEquippedObject(player, item) == nil then
        log.error "Cannot use unequipped item!"
        return
    end

    if item_cfg['max_use'] and _item['used'] > item_cfg['max_use'] then
        log.error "Max use exceeded!"
        return
    end

    PlayInteraction(player, item, function()
        -- increment used
        if item_cfg['max_use'] then
            IncrementItemUsed(player, item)
        end

        -- call USE event on object
        CallEvent("items:" .. item .. ":use", player, item_cfg, options)
    end)
end
AddRemoteEvent("UseItemFromInventory", UseItemFromInventory)

function GetItemFromInventory(player, item)
    local inventory = PlayerData[player].inventory
    for i, _item in ipairs(inventory) do
        if _item['item'] == item then
            return _item
        end
    end
end

-- equip from inventory
AddRemoteEvent("EquipItemFromInventory", function(player, item)
    EquipItem(player, item)
    CallEvent("SyncInventory", player)
end)

-- sets weapon to weapon slot from inventory
function SetWeaponSlotsFromInventory(player)
    log.debug("Updating weapon slots from inventory", player)
    ClearAllWeaponSlots(player)

    local inventory = PlayerData[player].inventory
    for i, _item in ipairs(inventory) do
        if _item['slot'] == 1 or _item['slot'] == 2 or _item['slot'] == 3 then
            AddWeaponFromInventory(player, _item['item'], false)
        end
    end
end

-- updates inventory from inventory UI sorting
-- recreates the inventory with new indexes
AddRemoteEvent("UpdateInventory", function(player, data)
    local items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updating inventory:", dump(items))

    local inventory = PlayerData[player].inventory
    local new_inventory = {}

    for _, item in pairs(items) do
        local item_cfg = GetItemConfig(item.item)
        if item_cfg then
            table.insert(new_inventory, {
                item = item.item,
                uuid = item.uuid,
                quantity = item.quantity,
                type = item_cfg['type'],
                name = item_cfg['name'],
                modelid = item_cfg['modelid'],
                image = item_cfg['image'],
                use_label = item_cfg['use_label'],
                slot = item.slot,
                used = 0
            })
        end
    end
    log.trace("NEW INVENTORY", dump(new_inventory))
    PlayerData[player].inventory = new_inventory

    CheckEquippedFromInventory(player)
    SetWeaponSlotsFromInventory(player)
    CallEvent("SyncInventory", player)
end)

-- unequip from inventory
AddRemoteEvent("UnequipItemFromInventory", function(player, item)
    UnequipItem(player, item)
    CallEvent("SyncInventory", player)
end)

-- clear inventory on player death
AddEvent("OnPlayerDeath", function(player, killer)
    PlayerData[player].inventory = {}
    PlayerData[player].equipped = {}

    CallEvent("SyncInventory", player)
end)

-- when weapon switching occurs, unequip hands, update PlayerData
-- and force equip weapon to designated slot
AddRemoteEvent("UseWeaponSlot", function(player, key)
    log.trace("UseWeaponSlot", key)

    UnequipFromBone(player, 'hand_l')
    UnequipFromBone(player, 'hand_r')

    local inventory = PlayerData[player].inventory
    for i,item in ipairs(inventory) do
        if tostring(item['slot']) == "1" or tostring(item['slot']) == "2" or tostring(item['slot']) == "3" then
            if tostring(item['slot']) == tostring(key) then
                PlayerData[player].equipped[item.item] = true
                EquipWeaponToSlot(player, item.item, item['slot'], true)
            else
                PlayerData[player].equipped[item.item] = nil
            end
        end
    end

    log.debug("equipped:",dump(PlayerData[player].equipped))
    CallEvent("SyncInventory", player)
end)

-- item hotkeys
AddRemoteEvent("UseItemHotkey", function(player, key)
    log.trace("UseItemHotkey", key)

    local inventory = PlayerData[player].inventory
    for i, item in ipairs(inventory) do
        if tostring(item['slot']) == key then
            EquipItem(player, item['item'])
            return
        end
    end
end)

