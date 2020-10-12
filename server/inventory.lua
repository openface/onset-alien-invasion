
AddEvent("OnPackageStop", function()
    print "Resetting player inventories..."
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
    for i, item in pairs(inventory) do
        if item['type'] == 'weapon' then
            table.insert(_send.weapons, {
                ['item'] = item['item'],
                ['name'] = item['name'],
                ['modelid'] = item['modelid'],
                ['quantity'] = item['quantity'],
                ['type'] = item['type']
            })
        else
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
    print(GetPlayerName(player) .. " inventory: " .. json_encode(_send))
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add object to inventory
function AddToInventory(player, item)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    print("Adding to inv",item)
    object = GetObject(item)
    if not object then
        print("Invalid object " .. item)
        return
    end

    local current_quantity = GetInventoryCount(player, item)
    print("Curr qty",current_quantity)
    if current_quantity > 0 then
        -- update existing object quantity
        SetItemQuantity(player, item, current_quantity + 1)
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
        if item['item'] == item then
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
    for i, _item in pairs(inventory) do
        if _item['item'] == item then
            return _item['quantity']
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

function GetObjectFromInventory(player, item)
  local inventory = GetPlayerPropertyValue(player, "inventory")
  for i, _item in pairs(inventory) do
    if _item['item'] == item then
      return GetObject(item)
    end
  end
end

-- use object
function UseObjectFromInventory(player, item)
    local object = GetObjectFromInventory(player, item)
    if object == nil then 
      print("Item "..item.." not found in inventory")
      return 
    end

    EquipObject(player, item)
    PlayInteraction(player, item)

--[[     if object['max_use'] and v['used'] < object['max_use'] then
        -- update inventory after use
        Delay(2000, function()
            inventory[i]['used'] = v['used'] + 1
            SetPlayerPropertyValue(player, "_inventory", _inventory)

            -- delete if all used up
            if (object['max_use'] - v['used'] == 0) then
                print "all used up!"
                SetItemQuantity(player, item, 0)
            end

            CallEvent("SyncInventory", player)
        end)
    end
 ]]
end

-- drop all on death
AddEvent("OnPlayerDeath", function(player, killer)
    SetPlayerPropertyValue(player, "inventory", {})
    CallEvent("SyncInventory", player)
end)

-- Hotkeys
AddRemoteEvent("UseObjectHotkey", function(player, key)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local item = inventory[key - 3].item
    UseObjectFromInventory(player, item)
end)
