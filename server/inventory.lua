local PartObjectID = 1437

-- get inventory data and send to client
function SyncInventory(player)
    local _inventory = GetPlayerPropertyValue(player, "inventory")

    _send = {}
    for k,v in pairs(_inventory) do
        table.insert(_send, {
            item = v['item'],
            quantity = v['quantity']
        })
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
AddEvent("AddItemToInventory", function(player, item)
    _inventory = GetPlayerPropertyValue(player, "inventory")

    if GetInventoryCount(player, item) > 0 then
        -- update existing object quantity
        for k,v in pairs(_inventory) do
            if v['item'] == item then
                _inventory[k]['quantity'] = v['quantity'] + 1
                SetPlayerPropertyValue(player, "inventory", _inventory)
                break
            end
        end
    else
        -- add new item
        table.insert(_inventory, {
            item = item,
            quantity = 1
        })
        SetPlayerPropertyValue(player, "inventory", _inventory)
    end

    CallEvent("SyncInventory", player)
    print(GetPlayerName(player).." PlayerInventory: "..dump(_inventory))
end)

-- get carry count for given item
function GetInventoryCount(player, item)
    local _inventory = GetPlayerPropertyValue(player, "inventory")
    for _,v in pairs(_inventory) do
        if v['item'] == item then
            return v['quantity']
        end
    end
    return 0
end

-- drop all on death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
end)

