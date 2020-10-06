-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    CallRemoteEvent(player, "SetInventory", json_encode(inventory))
    print(GetPlayerName(player).." inventory: "..json_encode(inventory))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

AddEvent("AddItemToInventory", function(player, item_key)
    AddToInventory(player, "item", item_key)
end)

AddEvent("AddResourceToInventory", function(player, item_key)
    AddToInventory(player, "resource", item_key)
end)

-- add object to inventory
function AddToInventory(player, type, item_key)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    item = GetObject(item_key)
    if not item then
        print("Invalid item "..item_key.. " must be item or resource!")
        return
    end

    if GetInventoryCount(player, item_key) > 0 then
        -- update existing object quantity
        inventory[item_key]['quantity'] = inventory[item_key]['quantity'] + 1
        SetPlayerPropertyValue(player, "inventory", inventory)
    else
        -- add new item to store
        inventory[item_key] = {
            type = item['type'],
            name = item['name'],
            modelid = item['modelid'],
            quantity = 1
        }
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    CallEvent("SyncInventory", player)
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
AddEvent("RemoveFromInventory", function(player, item_key, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local item = GetObject(item_key)
    if not item then
        print("Invalid item: "..item_key)
        return
    end

    local amount = amount or 1

    local curr_qty = inventory[item_key]['quantity'] - amount
    if curr_qty > 0 then
        -- decrease qty by 1
        inventory[item_key]['quantity'] = curr_qty
    else
        -- remove item from inventory
        inventory[item_key] = nil
    end
    SetPlayerPropertyValue(player, "inventory", inventory)

    CallEvent("SyncInventory", player)
end)

-- get carry count for given item
function GetInventoryCount(player, item_key)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local item = GetObject(item_key)
    if not item then
        print("Invalid item: "..item_key)
        return
    end

    if not inventory[item_key] then
        return 0
    end

    return inventory[item_key]['quantity']
end

-- drop all on death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    CallEvent("SyncInventory", player)
end)

