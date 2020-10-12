-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local _send = {
        items = {},
        weapons = {}
    }
    for key, item in pairs(inventory) do
        if item['type'] == 'weapon' then
            table.insert(_send.weapons, {
                ['item'] = key,
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type']
            })
        else
            table.insert(_send.items, {
                ['item'] = key,
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type']
            })
        end
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
    print(GetPlayerName(player) .. " inventory: " .. json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
function AddToInventory(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    object = GetObject(item)
    if not object then
        print("Invalid object " .. item)
        return
    end

    if GetInventoryCount(player, item) > 0 then
        -- update existing object quantity
        SetItemQuantity(player, item, inventory[item]['quantity'] + 1)
    else
        -- add new item to store
        table.insert(inventory, {
            item = item,
            type = object['type'],
            name = object['name'],
            modelid = object['modelid'],
            quantity = 1
        })
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    CallEvent("SyncInventory", player)
end

function SetItemQuantity(player, item, quantity)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    for i, item in pairs(inventory) do
        if item['name'] == name then
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
    print(GetPlayerName(player) .. " inventory item " .. item .. " quantity set to " .. quantity)
    CallEvent("SyncInventory", player)
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
function RemoveFromInventory(player, item, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local object = GetObject(item)
    if not object then
        print("Invalid item: " .. item)
        return
    end

    local amount = amount or 1
    local curr_qty = GetInventoryCount(player, item) - amount
    if curr_qty > 0 then
        -- decrease qty by 1
        SetItemQuantity(player, item, curr_qty)
    else
        -- remove item from inventory
        SetItemQuantity(player, item, 0)
    end
    SetPlayerPropertyValue(player, "inventory", inventory)
    CallEvent("SyncInventory", player)
end

-- get carry count for given item
function GetInventoryCount(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    for i, item in pairs(inventory) do
        if item['name'] == item then
            return item['quantity']
        end
    end
    return 0
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

-- drop all on death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    CallEvent("SyncInventory", player)
end)

-- TODO
AddRemoteEvent("UseObjectHotkey", function(player, key)
    print("Using hotkey: " .. key)
    local index = key - 3
    local inventory = GetPlayerPropertyValue(player, "inventory")
    print(inventory[index].item)
end)
