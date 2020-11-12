AddEvent("OnPackageStop", function()
    log.info "Resetting player inventories..."
    for _, player in pairs(GetAllPlayers()) do
        ClearInventory(player)
    end
end)

-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local weapons = GetPlayerPropertyValue(player, "weapons")

    local _send = {
        weapons = {},
        items = {}
    }
    -- weapons
    for index, weapon in ipairs(weapons) do
        table.insert(_send.weapons, {
            ['index'] = index,
            ['item'] = weapon['item'],
            ['name'] = weapon['name'],
            ['modelid'] = weapon['modelid'],
            ['type'] = weapon['type'],
            ['slot'] = weapon['slot']
        })
    end

    -- inventory
    for index, item in ipairs(inventory) do
        -- usable, equipable, resource
        table.insert(_send.items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['image'] = item['image'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
            ['equipped'] = IsItemEquipped(player, item['item']),
            ['used'] = item['used']
        })
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
    log.trace("INVENTORY SYNC: " .. json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

--
function ClearInventory(player)
    SetPlayerPropertyValue(player, "inventory", {})
    SetPlayerPropertyValue(player, "weapons", {})
    SyncInventory(player)
end

-- add object to inventory
function AddToInventory(player, item)
    item_cfg = GetItemConfig(item)
    if not item_cfg then
        log.error("Invalid object " .. item)
        return
    end

    if item_cfg['type'] == 'weapon' then
        AddWeapon(player, item)
        return
    end

    local inventory = GetPlayerPropertyValue(player, "inventory")
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
            quantity = 1,
            used = 0
        })
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    -- auto-equip when added
    if item_cfg['type'] == 'equipable' and item_cfg['auto_equip'] == true then
        EquipObject(player, item)
    end

    CallEvent("SyncInventory", player)
end

-- private function to update inventory item quantity
function SetItemQuantity(player, item, quantity)
    local inventory = GetPlayerPropertyValue(player, "inventory")
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
    SetPlayerPropertyValue(player, "inventory", inventory)
    log.debug(GetPlayerName(player) .. " inventory item " .. item .. " quantity set to " .. quantity)
    -- CallEvent("SyncInventory", player)
end

function IncrementItemUsed(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
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
                SetPlayerPropertyValue(player, "inventory", inventory)
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

    if item_cfg['type'] == 'weapon' then
        RemoveWeapon(player, item)
        return
    end

    local inventory = GetPlayerPropertyValue(player, "inventory")

    local amount = amount or 1
    local curr_qty = GetInventoryCount(player, item)

    local new_qty = curr_qty - amount
    SetItemQuantity(player, item, new_qty)

    if new_qty == 0 then
        log.debug("items:" .. item .. ":drop")
        UnequipObject(player, item)
    end

    -- inventory updated
    CallEvent("SyncInventory", player)
end

-- unequips item, removes from inventory, and places on ground
AddRemoteEvent("DropItemFromInventory", function(player, item, x, y, z)
    log.info("Player " .. GetPlayerName(player) .. " drops item " .. item)

    SetPlayerAnimation(player, "CARRY_SETDOWN")

    Delay(1000, function()
        RemoveFromInventory(player, item)

        -- spawn object near player
        CreateObjectPickupNearPlayer(player, item)
    end)
end)

-- get carry count for given item
function GetInventoryCount(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    for _, _item in pairs(inventory) do
        if _item['item'] == item then
            return _item['quantity']
        end
    end
    return 0
end

-- get carry count for given item type
function GetInventoryCountByType(player, type)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local n = 0
    for _, _item in pairs(inventory) do
        if _item['type'] == type then
            n = n + 1
        end
    end
    return n
end

function GetInventoryAvailableSlots(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
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
    if item_cfg['type'] == 'weapon' then
        log.error("Cannot use type weapon!")
        return
    end

    local _item = GetItemFromInventory(player, item)
    log.debug(GetPlayerName(player) .. " uses item " .. item .. " from inventory")

    if not item_cfg['max_use'] then
        log.error "Cannot use item without a max_use!"
        return
    end

    if _item['used'] > item_cfg['max_use'] then
        log.error "Max use exceeded!"
        return
    end

    EquipObject(player, item)
    PlayInteraction(player, item, function()
        -- increment used
        IncrementItemUsed(player, item)

        -- usable objects auto-unequip after use
        if item_cfg['type'] == 'usable' then
            UnequipObject(player, item)
        end
        
        -- call USE event on object
        CallEvent("items:" .. item .. ":use", player, item_cfg, options)
    end)
end
AddRemoteEvent("UseItemFromInventory", UseItemFromInventory)

function GetItemFromInventory(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
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

-- updates inventory from inventory UI sorting
AddRemoteEvent("UpdateInventory", function(player, data)
    local items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updating inventory:", dump(items))

    local inventory = GetPlayerPropertyValue(player, "inventory")
    local new_inventory = {}

    for _, item in pairs(items) do
        local item_cfg = GetItemConfig(item.item)
        new_inventory[item.index] = {
            item = item.item,
            quantity = item.quantity,
            type = item_cfg['type'],
            name = item_cfg['name'],
            modelid = item_cfg['modelid'],
            image = item_cfg['image'],
            used = 0
        }
    end
    log.trace("NEW INVENTORY", dump(new_inventory))
    SetPlayerPropertyValue(player, "inventory", new_inventory)

    CheckEquippedFromInventory(player)
    CallEvent("SyncInventory", player)
end)

-- unequip from inventory
AddRemoteEvent("UnequipItemFromInventory", function(player, item)
    UnequipObject(player, item)
    CallEvent("SyncInventory", player)
end)

-- clear inventory on player death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    SetPlayerPropertyValue(player, "weapons", {})
    CallEvent("SyncInventory", player)
end)

-- when weapon switching occurs, unequip whatever is in hand_r bone
AddRemoteEvent("UnequipForWeapon", function(player)
    UnequipFromBone(player, 'hand_r')
end)

-- item hotkeys
AddRemoteEvent("UseItemHotkey", function(player, key)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    -- log.trace(dump(inventory))

    -- find valid hotbar items
    local usable_items = {}
    for i, item in ipairs(inventory) do
        if item['type'] == 'usable' or item['type'] == 'equipable' then
            table.insert(usable_items, item['item'])
        end
    end

    -- use it by index (1-3 are reserved for weapons)
    local item = usable_items[key - 3]
    if item ~= nil then
        log.debug("Hotkey", item)
        UseItemFromInventory(player, item)
    end
end)
