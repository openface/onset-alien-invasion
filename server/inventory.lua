local ItemData = require("packages/" .. GetPackageName() .. "/server/data/items")
local ResourceData = require("packages/" .. GetPackageName() .. "/server/data/resources")

-- get inventory data and send to UI
function SyncInventory(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    CallRemoteEvent(player, "SetInventory", json_encode(inventory))
    print(GetPlayerName(player).." inventory: "..dump(inventory))
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

    item = GetItemData(item_key)
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

-- gets item or resource from data
function GetItemData(item_key)
    if ItemData[item_key] then
        item = ItemData[item_key]
        item['type'] = 'item'
    elseif ResourceData[item_key] then
        item = ResourceData[item_key]
        item['type'] = 'resource'
    end
    return item
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
AddEvent("RemoveFromInventory", function(player, item_key, amount)
    local inventory = GetPlayerPropertyValue(player, "inventory")

    local item = GetItemData(item_key)
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

    local item = GetItemData(item_key)
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

