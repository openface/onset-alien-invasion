local MAX_INVENTORY_SLOTS = 14

-- get inventory data and send to UI
function SyncInventory(player)
    log.trace('SyncInventory')

    local inventory_items = PlayerData[player].inventory
    -- log.trace("INVENTORY ITEMS (" .. GetPlayerName(player) .. "): " .. dump(inventory_items))

    local current_inhand
    local _send = {
        inventory_items = {}
    }

    -- inventory
    for index, item in ipairs(inventory_items) do
        if ItemConfig[item.item] then
            local equipped = IsItemEquipped(player, item.uuid)
            local bone = GetItemAttachmentBone(item.item)
            table.insert(_send.inventory_items, {
                ['index'] = index,
                ['item'] = item.item,
                ['uuid'] = item.uuid,
                ['quantity'] = item.quantity,
                ['equipped'] = equipped,
                ['used'] = item.used,
                ['slot'] = item.slot,
                ['hotbar_slot'] = item.hotbar_slot,
                ['bone'] = bone,

                ['type'] = ItemConfig[item.item].type,
                ['name'] = ItemConfig[item.item].name,
                ['modelid'] = ItemConfig[item.item].modelid,
                ['image'] = ItemConfig[item.item].image,
                ['use_label'] = ItemConfig[item.item].use_label
            })
            if equipped and (bone == 'hand_l' or bone == 'hand_r') then
                current_inhand = {
                    ['item'] = item['item'],
                    ['uuid'] = item['uuid']
                }
                if ItemConfig[item.item].interaction then
                    current_inhand['prop'] = ItemConfig[item.item].interaction['prop']
                end
            end
        end
    end
    log.trace("INVENTORY SYNC (" .. GetPlayerName(player) .. "): " .. json_encode(_send))
    log.trace("CURRENT INHAND: " .. dump(current_inhand))
    CallRemoteEvent(player, "SetInventory", json_encode(_send), current_inhand)
end
AddRemoteEvent("SyncInventory", SyncInventory)
AddEvent("SyncInventory", SyncInventory)

-- add item to inventory by item name (stacks)
function AddToInventoryByName(player, item, amount)
    local inventory_item = GetItemFromInventoryByName(player, item)
    if inventory_item then
        -- add to existing item stack
        AddToInventory(player, inventory_item.uuid, amount)
    else
        -- add new item
        AddToInventory(player, RegisterNewItem(item), amount)
    end
end

-- add unique item to inventory
function AddToInventory(player, uuid, amount)
    local item = GetItemInstance(uuid)
    if not ItemConfig[item] then
        log.error("Invalid item " .. item)
        return
    end

    local amount = amount or 1

    local inventory = PlayerData[player].inventory
    local curr_qty = GetInventoryCount(player, uuid)

    if curr_qty > 0 then
        -- update quantity of existing item stack
        SetItemQuantity(player, uuid, curr_qty + amount)
    elseif #inventory >= MAX_INVENTORY_SLOTS then
        log.error(GetPlayerName(player) .. " inventory exceeded!")
        return
    else
        local next_slot = GetNextAvailableInventorySlot(player)
        log.debug("Next available inventory slot: " .. next_slot)

        -- add new item
        table.insert(inventory, {
            item = item,
            uuid = uuid,
            quantity = amount,
            used = 0,
            slot = next_slot,
            hotbar_slot = nil
        })
        PlayerData[player].inventory = inventory
    end

    -- auto-equip when added
    if ItemConfig[item].auto_equip == true and
        (ItemConfig[item].type == 'equipable' or ItemConfig[item].type == 'weapon') then
        if GetEquippedObject(player, item) ~= nil then
            log.debug("Auto-equipping item", item)
            EquipItem(player, item)
        end
    end

    CallEvent("SyncInventory", player)
end

-- private function to update inventory item quantity
function SetItemQuantity(player, uuid, quantity)
    local inventory = PlayerData[player].inventory

    for i, inventory_item in ipairs(inventory) do
        if inventory_item.uuid == uuid then
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
    PlayerData[player].inventory = inventory
    log.debug(GetPlayerName(player) .. " inventory item " .. uuid .. " quantity set to " .. quantity)
    -- CallEvent("SyncInventory", player)
end

function IncrementItemUsed(player, uuid)
    local inventory = PlayerData[player].inventory

    for i, inventory_item in ipairs(inventory) do
        if inventory_item.uuid == uuid then
            local item = GetItemInstance(uuid)
            -- delete if this is the last use
            if (ItemConfig[item]['max_use'] - inventory_item['used'] == 1) then
                log.debug "all used up!"
                UnequipItem(player, uuid)
                RemoveFromInventory(player, uuid)
            else
                log.debug('increment used by 1')
                inventory[i]['used'] = inventory_item['used'] + 1
                PlayerData[player].inventory = inventory
                CallEvent("SyncInventory", player)
            end

            break
        end
    end
end

-- deletes item from inventory
-- deduces by quantity if carrying more than 1
function RemoveFromInventory(player, uuid, amount)
    local item = GetItemInstance(uuid)
    if not item then
        log.error("No such item: " .. uuid)
        return
    end

    if not ItemConfig[item] then
        log.error("Invalid item: " .. item)
        return
    end

    local inventory = PlayerData[player].inventory

    local amount = amount or 1
    local curr_qty = GetInventoryCount(player, uuid)

    local new_qty = curr_qty - amount
    SetItemQuantity(player, uuid, new_qty)

    if new_qty == 0 then
        log.debug("items:" .. item .. ":drop")

        if ItemConfig[item].type == 'equipable' or ItemConfig[item].type == 'weapon' then
            UnequipItem(player, uuid)
        end
    end

    -- inventory updated
    CallEvent("SyncInventory", player)
end

-- unequips item, removes from inventory, and places on ground
AddRemoteEvent("DropItemFromInventory", function(player, uuid)
    local item = GetItemInstance(uuid)

    log.info("Player " .. GetPlayerName(player) .. " drops item " .. item)

    -- SetPlayerAnimation(player, "CARRY_SETDOWN")

    Delay(1000, function()
        UnequipItem(player, uuid)

        RemoveFromInventory(player, uuid)

        -- spawn object near player
        CreatePickupNearPlayer(player, item)

        CallRemoteEvent(player, "ShowMessage", ItemConfig[item].name .. " has been dropped")
    end)
end)

-- get carry count for given item
function GetInventoryCount(player, uuid)
    local inventory = PlayerData[player].inventory
    for _, inventory_item in pairs(inventory) do
        if inventory_item.uuid == uuid then
            return inventory_item.quantity
        end
    end
    return 0
end

-- get carry count for given item type
function GetInventoryCountByType(player, type)
    local inventory = PlayerData[player].inventory
    local n = 0
    for _, inventory_item in pairs(inventory) do
        if inventory_item.type == type then
            n = n + 1
        end
    end
    return n
end

-- get carry count for given item name
function GetInventoryCountByName(player, item)
    local inventory = PlayerData[player].inventory
    local n = 0
    for _, inventory_item in pairs(inventory) do
        if inventory_item.item == item then
            n = n + 1
        end
    end
    return n
end

function GetInventoryAvailableSlots(player)
    local inventory = PlayerData[player].inventory
    local count = 0
    for _ in pairs(inventory) do
        count = count + 1
    end
    return (MAX_INVENTORY_SLOTS - count)
end

-- iterate over possible slots and return the first available
function GetNextAvailableInventorySlot(player)
    local inventory = PlayerData[player].inventory
    for index=1,MAX_INVENTORY_SLOTS do
        if not table.findByKeyValue(inventory, "slot", index) then
            return index
        end            
    end
end

-- use object from inventory
function UseItemFromInventory(player, uuid, options)
    local item = GetItemInstance(uuid)
    if not item then
        log.error("Invalid item" .. uuid)
        return
    end

    local inventory_item = GetItemFromInventory(player, uuid)
    if not inventory_item then
        log.error("Cannot use item not in inventory!")
        return
    end

    log.debug(GetPlayerName(player) .. " uses item " .. item .. " from inventory")

    local equipped_object = GetEquippedObject(player, uuid)
    if not equipped_object then
        log.error "Cannot use unequipped item!"
        return
    end

    if ItemConfig[item].max_use and inventory_item['used'] > ItemConfig[item].max_use then
        log.error "Max use exceeded!"
        return
    end

    PlayInteraction(player, uuid, function()
        -- increment used
        if ItemConfig[item].max_use then
            IncrementItemUsed(player, uuid)
        end

        -- call USE event on object
        CallEvent("items:" .. item .. ":use", player, options, equipped_object)
    end)
end
AddRemoteEvent("UseItemFromInventory", UseItemFromInventory)

function PlayInteraction(player, uuid, after_callback)
    local item = GetItemInstance(uuid)
    log.debug("Playing interaction for item " .. item .. " uuid ".. uuid)

    if not ItemConfig[item].interaction then
        if after_callback then
            after_callback()
        end
        return
    end
    if ItemConfig[item].interaction['animation'] then
        SetPlayerAnimation(player, ItemConfig[item].interaction['animation']['name'])

        local duration = ItemConfig[item].interaction['animation']['duration'] or 2000 -- default animation delay

        CallRemoteEvent(player, "StartInteraction", {
            ['duration'] = duration,
            ['show_spinner'] = ItemConfig[item].interaction['animation']['spinner']
        })

        Delay(duration, function()
            SetPlayerAnimation(player, "STOP")

            if after_callback then
                after_callback()
            end
        end)
    else
        if after_callback then
            after_callback()
        end
    end
    if ItemConfig[item].interaction['sound'] then
        PlaySoundSync(player, ItemConfig[item].interaction['sound'])
    end
end

function GetItemFromInventory(player, uuid)
    local inventory = PlayerData[player].inventory
    for i, inventory_item in ipairs(inventory) do
        if inventory_item.uuid == uuid then
            return inventory_item
        end
    end
end

function GetItemFromInventoryByName(player, item)
    local inventory = PlayerData[player].inventory
    for i, inventory_item in ipairs(inventory) do
        if inventory_item.item == item then
            return inventory_item
        end
    end
end

-- equip from inventory
AddRemoteEvent("EquipItemFromInventory", function(player, uuid)
    EquipItem(player, uuid)
    CallEvent("SyncInventory", player)
end)

AddRemoteEvent("GetInventory", function(player)
    CallEvent("SyncInventory", player)
end)

-- updates inventory from inventory UI 
-- recreates the inventory with new indexes
AddRemoteEvent("UpdateInventory", function(player, data)
    local items = json_decode(data)
    log.debug(GetPlayerName(player) .. " updating inventory:", dump(items))

    local inventory = PlayerData[player].inventory
    local new_inventory = {}

    for _, item in pairs(items) do
        table.insert(new_inventory, {
            item = item.item,
            uuid = item.uuid,
            quantity = item.quantity,
            slot = item.slot,
            hotbar_slot = item.hotbar_slot,
            used = item.used,
        })
    end
    log.trace("NEW INVENTORY", dump(new_inventory))
    PlayerData[player].inventory = new_inventory

    CheckEquippedFromInventory(player)
    SyncWeaponSlotsFromInventory(player)
    CallEvent("SyncInventory", player)
end)

-- unequip from inventory
AddRemoteEvent("UnequipItemFromInventory", function(player, uuid)
    UnequipItem(player, uuid)
    CallEvent("SyncInventory", player)
end)

-- clear inventory on player death
AddEvent("OnPlayerDeath", function(player, killer)
    PlayerData[player].inventory = {}
    PlayerData[player].equipped = {}

    CallEvent("SyncInventory", player)
end)

-- when weapon switching occurs, unequip hands, update PlayerData
-- and force equip weapon to designated slot
AddRemoteEvent("UseWeaponSlot", function(player, key)
    log.trace("UseWeaponSlot", key)

    UnequipFromBone(player, 'hand_l')
    UnequipFromBone(player, 'hand_r')

    local inventory = PlayerData[player].inventory
    for i, item in ipairs(inventory) do
        if tostring(item.hotbar_slot) == "1" or tostring(item.hotbar_slot) == "2" or tostring(item.hotbar_slot) == "3" then
            if tostring(item.hotbar_slot) == tostring(key) then
                -- unequip weapon if needed
                PlayerData[player].equipped[item.uuid] = true
                EquipWeaponToSlot(player, item.uuid, item.hotbar_slot, true)
            else
                PlayerData[player].equipped[item.uuid] = nil
            end
        end
    end

    log.debug("equipped:", dump(PlayerData[player].equipped))
    CallEvent("SyncInventory", player)
end)

-- item hotkeys
AddRemoteEvent("UseItemHotkey", function(player, key)
    log.trace("UseItemHotkey", key)

    local inventory = PlayerData[player].inventory
    for i, item in ipairs(inventory) do
        if tostring(item.hotbar_slot) == key then
            EquipItem(player, item.uuid)
        end
    end
end)

