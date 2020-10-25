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

    local _send = {
        items = {},
        weapons = {}
    }
    for i, item in ipairs(inventory) do
        if item['type'] == 'weapon' then
            table.insert(_send.weapons, {
                ['item'] = item['item'],
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type'],
                ['equipped'] = IsItemInWeaponSlot(player, item['item'])
            })
        elseif item['type'] == 'equipable' or item['type'] == 'usable' then
            table.insert(_send.items, {
                ['item'] = item['item'],
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type'],
                ['equipped'] = IsItemEquipped(player, item['item'])
            })
          elseif item['type'] == 'resource' then
            table.insert(_send.items, {
                ['item'] = item['item'],
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type']
            })
        end
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
    log.debug(GetPlayerName(player) .. " sync inventory: " .. json_encode(_send))
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

    if curr_qty > 0 then
        -- update existing object quantity
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
                inventory[i] = nil
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
    if curr_qty > 1 then
        -- decrease qty by 1
        SetItemQuantity(player, item, curr_qty - amount)
    else
        -- remove item from inventory
        SetItemQuantity(player, item, 0)

        log.debug("items:" .. item .. ":drop")

        -- call DROP event on object
        --CallEvent("items:" .. item .. ":drop", player, item_cfg)

        -- if item is a weapon, switch to fists
        --if item_cfg['type'] == 'weapon' then
        --  EquipWeapon(player, item)
        --end
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

-- sort inventory weapons
AddRemoteEvent("SortInventoryWeapons", function(player, data)
  log.debug(GetPlayerName(player).. " sorting weapons")
  SetPlayerPropertyValue(player, "inventory", json_decode(data))
end)

-- sort inventory
AddRemoteEvent("SortInventoryItems", function(player, data)
  log.debug(GetPlayerName(player).. " sorting items")
  SetPlayerPropertyValue(player, "inventory", json_decode(data))
  --CallEvent("SyncInventory", player)
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
    log.trace(dump(inventory))
    local item = inventory[key - 3]
    if item ~= nil then
      log.debug("Hotkey",item['item'])
      UseItemFromInventory(player, item['item'])
    end
end)
