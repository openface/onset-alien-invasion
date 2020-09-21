local ItemData = require("packages/" .. GetPackageName() .. "/server/data/items")

-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    CallRemoteEvent(player, "SetInventory", json_encode(inventory))
    print(GetPlayerName(player).." inventory: "..dump(inventory))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
AddEvent("AddItemToInventory", function(player, item_key)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    if not ItemData[item_key] then
        print("Invalid item: "..item_key)
        return
    end

    if GetInventoryCount(player, item_key) > 0 then
        -- update existing object quantity
        inventory[item_key]['quantity'] = inventory[item_key]['quantity'] + 1
        SetPlayerPropertyValue(player, "inventory", inventory)
    else
        -- add new item to store
        local item = ItemData[item_key]
        inventory[item_key] = {
            name = item.name,
            modelid = item.modelid,
            quantity = 1
        }
        SetPlayerPropertyValue(player, "inventory", inventory)
    end

    CallEvent("SyncInventory", player)
end)

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
AddEvent("RemoveFromInventory", function(player, item_key, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    if not ItemData[item_key] then
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

    if not ItemData[item_key] then
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

