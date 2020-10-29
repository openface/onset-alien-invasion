AddEvent("OnPackageStop", function()
    log.info "Resetting player inventories..."
    for _, player in pairs(GetAllPlayers()) do
        SetPlayerPropertyValue(player, "inventory", {})
        SyncInventory(player)
    end
end)

-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    log.trace("INVENTORY RAW: " .. dump(inventory))

    local _send = {
        items = {}
    }
    for index, item in ipairs(inventory) do
      log.debug(index,dump(item))
        if item['type'] == 'weapon' then
            equipped = IsWeaponEquipped(player, item['item'])
        else
            equipped = IsItemEquipped(player, item['item'])
        end

        table.insert(_send.items, {
            ['index'] = index,
            ['item'] = item['item'],
            ['name'] = item['name'],
            ['modelid'] = item['modelid'],
            ['quantity'] = item['quantity'],
            ['type'] = item['type'],
            ['equipped'] = equipped
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

    local inventory = GetPlayerPropertyValue(player, "inventory")
    local curr_qty = GetInventoryCount(player, item)

    -- todo
    if item_cfg['type'] == 'weapon' and curr_qty > 0 then
      log.debug('Only one weapon of this type allowed!')
      return
    end

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
            quantity = 1
        })
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    -- auto-equip when added
    if item_cfg['type'] == 'equipable' and item_cfg['auto_equip'] == true then
      EquipObject(player, item)
    elseif item_cfg['type'] == 'weapon' then
      EquipWeapon(player, item)
    end

    CallEvent("SyncInventory", player)
end

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
    CallEvent("SyncInventory", player)
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
function RemoveFromInventory(player, item, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local item_cfg = GetItemConfig(item)
    if not item_cfg then
        log.error("Invalid item: " .. item)
        return
    end

    local amount = amount or 1
    local curr_qty = GetInventoryCount(player, item)

    local new_qty = curr_qty - amount
    SetItemQuantity(player, item, new_qty)

    if new_qty == 0 then
        log.debug("items:" .. item .. ":drop")

        -- if item is a weapon, switch to fists
        if item_cfg['type'] == 'weapon' then
            UnequipWeapon(player, item)
        end
    end

end

-- unequips item, removes from inventory, and places on ground
AddRemoteEvent("DropItemFromInventory", function(player, item, x, y, z)
    log.info("Player " .. GetPlayerName(player) .. " drops item " .. item)

    SetPlayerAnimation(player, "CARRY_SETDOWN")

    Delay(1000, function()
        UnequipObject(player, item)

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

function GetItemConfigFromInventory(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    for i, _item in pairs(inventory) do
        if _item['item'] == item then
            return GetItemConfig(item)
        end
    end
end

-- use object
function UseItemFromInventory(player, item)
    local item_cfg = GetItemConfigFromInventory(player, item)
    if item_cfg == nil then
        log.error("Item " .. item .. " not found in inventory")
        return
    end

    if item_cfg['type'] == 'weapon' then
        log.error("Not using weapon from inventory")
        return
    end

    log.info(GetPlayerName(player) .. " uses item " .. item .. " from inventory")
    EquipObject(player, item)
    PlayInteraction(player, item)

    --[[     if object['max_use'] and v['used'] < object['max_use'] then
        -- update inventory after use
        Delay(2000, function()
            inventory[i]['used'] = v['used'] + 1
            SetPlayerPropertyValue(player, "_inventory", _inventory)

            -- delete if all used up
            if (object['max_use'] - v['used'] == 0) then
                log.debug "all used up!"
                SetItemQuantity(player, item, 0)
            end

            CallEvent("SyncInventory", player)
        end)
    end
 ]]
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

-- sort inventory
-- array of pairs: item, newIndex, oldIndex
AddRemoteEvent("SortInventory", function(player, data)
    local sorted = json_decode(data)
    log.debug(GetPlayerName(player) .. " sorting items:", dump(sorted))

    local inventory = GetPlayerPropertyValue(player, "inventory")

    -- swap indexes on the first detected change
    for _, s in pairs(sorted) do
        if s.oldIndex ~= s.newIndex then
            print("Sorting item", s.item)
            local temp = inventory[s.newIndex]
            inventory[s.newIndex] = inventory[s.oldIndex]
            inventory[s.oldIndex] = temp
            break
        end
    end
    log.trace("NEW INVENTORY", dump(inventory))
    SetPlayerPropertyValue(player, "inventory", inventory)
end)

-- unequip from inventory
AddRemoteEvent("UnequipItemFromInventory", function(player, item)
    UnequipObject(player, item)
    CallEvent("SyncInventory", player)
end)

-- clear inventory on player death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    CallEvent("SyncInventory", player)
end)

-- item hotkeys
AddRemoteEvent("UseItemHotkey", function(player, key)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    -- log.trace(dump(inventory))

    -- find valid hotbar items
    local hotbar_items = {}
    for i, item in ipairs(inventory) do
        if item['type'] ~= 'weapon' then
            table.insert(hotbar_items, item['item'])
        end
    end

    -- use it by index
    local item = hotbar_items[key - 3]
    if item ~= nil then
        log.debug("Hotkey", item)
        UseItemFromInventory(player, item)
    end
end)
