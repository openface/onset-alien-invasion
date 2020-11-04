AddEvent("OnPackageStop", function()
    log.info "Resetting player inventories..."
    for _, player in pairs(GetAllPlayers()) do
        SetPlayerPropertyValue(player, "inventory", {})
        SetPlayerPropertyValue(player, "weapons", {})
        SyncInventory(player)
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
            ['equipped'] = IsWeaponEquipped(player, weapon['item'])
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
local function SetItemQuantity(player, item, quantity)
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

        -- UnequipObject syncs inventory; no need to do it again
        UnequipObject(player, item)
    else
        -- inventory updated
        CallEvent("SyncInventory", player)
    end
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
function UseItemFromInventory(player, item)
    local item_cfg = GetItemConfig(item)
    if item_cfg['type'] == 'weapon' or item_cfg['type'] == 'resource' then
        log.error("Cannot use type weapon or resource!")
        return
    end

    local inventory = GetPlayerPropertyValue(player, "inventory")
    for i, _item in ipairs(inventory) do
        if _item['item'] == item then
            log.debug(GetPlayerName(player) .. " uses item " .. item .. " from inventory")

            EquipObject(player, item)
            PlayInteraction(player, item)

            if item_cfg['max_use'] then
                if _item['used'] < item_cfg['max_use'] then
                    -- update inventory after use
                    Delay(2000, function()

                        -- delete if this is the last use
                        if (item_cfg['max_use'] - _item['used'] == 1) then
                            log.debug "all used up!"
                            RemoveFromInventory(player, item)
                        else
                            log.debug('increment used by 1')
                            inventory[i]['used'] = _item['used'] + 1
                            SetPlayerPropertyValue(player, "inventory", inventory)
                            CallEvent("SyncInventory", player)
                        end

                        -- call USE event on object
                        CallEvent("items:" .. item .. ":use", player, item_cfg)
                    end)
                else
                    log.error("cannot use item due to use miscount!")
                    log.trace("max_use: " .. item_cfg['max_use'])
                    log.trace("used: " .. _item['used'])
                end
            end

            break
        end
    end
end
AddRemoteEvent("UseItemFromInventory", UseItemFromInventory)

-- equip from inventory
AddRemoteEvent("EquipItemFromInventory", function(player, item)
    if item_cfg['type'] == 'weapon' then
        EquipWeapon(player, item)
    else
        EquipObject(player, item)
    end
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
            used = 0
        }
    end
    log.trace("NEW INVENTORY", dump(new_inventory))
    SetPlayerPropertyValue(player, "inventory", new_inventory)
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
