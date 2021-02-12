-- get inventory data and send to UI
function SyncInventory(player)
    local inventory_items = PlayerData[player].inventory
    log.trace("INVENTORY SYNC ("..GetPlayerName(player).."): " .. dump(inventory_items))

    local _send = {
        inventory_items = {}
    }

    -- inventory
    for index, item in ipairs(inventory_items) do
        table.insert(_send.inventory_items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['image'] = item['image'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
            ['bone'] = GetItemAttachmentBone(item['item']),
            ['equipped'] = IsItemEquipped(player, item['item']),
            ['use_label'] = item['use_label'],
            ['used'] = item['used'],
            ['slot'] = item['slot'],
        })
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
function AddToInventory(player, item)
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
    if item_cfg['type'] == 'equipable' and item_cfg['auto_equip'] == true then
        EquipObject(player, item)
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
            UnequipObject(player, item)
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

    -- equipable items get equipped and that's it
    if item_cfg['type'] == 'equipable' then
        EquipObject(player, item)
        return
    end

    if item_cfg['max_use'] and _item['used'] > item_cfg['max_use'] then
        log.error "Max use exceeded!"
        return
    end

    EquipObject(player, item)

    PlayInteraction(player, item, function()
        -- increment used
        if item_cfg['max_use'] then
            IncrementItemUsed(player, item)
        end

        -- auto-unequip after use unless item is equipable
        if item_cfg['type'] ~= 'equipable' then
            log.debug("item not equipable, unequipping after use")
            UnequipObject(player, item)
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
    EquipObject(player, item)
    CallEvent("SyncInventory", player)
end)

-- sets weapon to weapon slot from inventory
function SetWeaponSlotsFromInventory(player)
    log.debug("Updating weapon slots from inventory", player)
    ClearAllWeaponSlots(player)

    local inventory = PlayerData[player].inventory
    for i, _item in ipairs(inventory) do
        if _item['slot'] == 1 or _item['slot'] == 2 or _item['slot'] == 3 then
            EquipWeaponFromInventory(player, _item['item'], false)            
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
                quantity = item.quantity,
                type = item_cfg['type'],
                name = item_cfg['name'],
                modelid = item_cfg['modelid'],
                image = item_cfg['image'],
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
    UnequipObject(player, item)
    CallEvent("SyncInventory", player)
end)

-- clear inventory on player death
AddEvent("OnPlayerDeath", function(player, killer)
    PlayerData[player].inventory = {}
    PlayerData[player].equipped = {}

    CallEvent("SyncInventory", player)
end)

-- when weapon switching occurs, unequip whatever is in hand_r bone
AddRemoteEvent("UnequipForWeapon", function(player)
    log.debug("weapon swap!")
    UnequipFromBone(player, 'hand_r')
    CallEvent("SyncInventory", player)
end)

-- item hotkeys
AddRemoteEvent("UseItemHotkey", function(player, key)
    local inventory = PlayerData[player].inventory
    for i, item in ipairs(inventory) do
        log.debug(item)
        log.debug(key)
        if tostring(item['slot']) == key then
            log.debug("hit",item['item'])
            EquipItemFromInventory(player, item['item'])
            return
        end
    end
end)

