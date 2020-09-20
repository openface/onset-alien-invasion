local ItemData = require("packages/" .. GetPackageName() .. "/server/data/items")

-- get inventory data and send to UI
function SyncInventory(player)
    local _inventory = GetPlayerPropertyValue(player, "inventory")

    _send = {}
    for k,v in pairs(_inventory) do
        table.insert(_send, {
            name = v['name'],
            modelid = GetItemByName(v['name']).modelid,
            quantity = v['quantity']
        })
    end
    print(dump(_send))
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
AddEvent("AddItemToInventory", function(player, name)
    _inventory = GetPlayerPropertyValue(player, "inventory")

    if GetInventoryCount(player, name) > 0 then
        -- update existing object quantity
        for k,v in pairs(_inventory) do
            if v['name'] == name then
                _inventory[k]['quantity'] = v['quantity'] + 1
                SetPlayerPropertyValue(player, "inventory", _inventory)
                break
            end
        end
    else
        -- add new item
        table.insert(_inventory, {
            name = name,
            quantity = 1
        })
        SetPlayerPropertyValue(player, "inventory", _inventory)
    end

    CallEvent("SyncInventory", player)
    --print(GetPlayerName(player).." inventory: "..dump(_inventory))
end)

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
AddEvent("RemoveFromInventory", function(player, name, quantity)
    _inventory = GetPlayerPropertyValue(player, "inventory")
    quantity = quantity or 1

    for k,v in pairs(_inventory) do
        if v['name'] == name then
            -- found object
            _qty = v['quantity'] - quantity
            if _qty > 0 then
                -- decrease qty by 1
                _inventory[k]['quantity'] = _qty
            else
                -- remove item from inventory
                _inventory[k] = nil
            end
            SetPlayerPropertyValue(player, "inventory", _inventory)

            CallEvent("SyncInventory", player)
            break
        end
    end
end)

-- get carry count for given item
function GetInventoryCount(player, name)
    local _inventory = GetPlayerPropertyValue(player, "inventory")
    for _,v in pairs(_inventory) do
        if v['name'] == name then
            return v['quantity']
        end
    end
    return 0
end

function GetItemByName(name)
    for _,item in pairs(ItemData) do
        if item['name'] == name then
            return item
        end
    end
end

-- drop all on death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    CallEvent("SyncInventory", player)
end)

