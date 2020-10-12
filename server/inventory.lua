-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    CallRemoteEvent(player, "SetInventory", json_encode(inventory))
    print(GetPlayerName(player).." inventory: "..dump(inventory))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
function AddToInventory(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    object = GetObject(item)
    if not object then
        print("Invalid object "..item)
        return
    end

    if GetInventoryCount(player, item) > 0 then
        -- update existing object quantity
        inventory[item]['quantity'] = inventory[item]['quantity'] + 1
        SetPlayerPropertyValue(player, "inventory", inventory)
    else
        -- add new item to store
        inventory[item] = {
            type = object['type'],
            name = object['name'],
            modelid = object['modelid'],
            quantity = 1
        }
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    CallEvent("SyncInventory", player)
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
AddEvent("RemoveFromInventory", function(player, item, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local object = GetObject(item)
    if not object then
        print("Invalid item: "..item)
        return
    end

    local amount = amount or 1

    local curr_qty = inventory[item]['quantity'] - amount
    if curr_qty > 0 then
        -- decrease qty by 1
        inventory[item]['quantity'] = curr_qty
    else
        -- remove item from inventory
        inventory[item] = nil
    end
    SetPlayerPropertyValue(player, "inventory", inventory)

    CallEvent("SyncInventory", player)
end)

-- get carry count for given item
function GetInventoryCount(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local object = GetObject(item)
    if not object then
        print("Invalid item: "..item)
        return
    end

    if not inventory[item] then
        return 0
    end

    return inventory[item]['quantity']
end

function GetInventoryAvailableSlots(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local count = 0
    for _ in pairs(inventory) do count = count + 1 end
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
    print("Using hotkey: "..key)
end)
