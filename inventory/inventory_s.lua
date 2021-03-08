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
                current_inhand = {}
                current_inhand['item'] = item.item
                current_inhand['uuid'] = item.uuid
                current_inhand['type'] = ItemConfig[item.item].type
                if ItemConfig[item.item].interaction and ItemConfig[item.item].interaction['interacts_on'] then
                    current_inhand['interacts_on'] = ItemConfig[item.item].interaction['interacts_on']
                end
            end
        end
    end
    -- log.trace("INVENTORY SYNC (" .. GetPlayerName(player) .. "): " .. json_encode(_send))
    -- log.trace("CURRENT INHAND: " .. dump(current_inhand))
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
    if ItemConfig[item].auto_equip == true then
        if ItemConfig[item].type == 'equipable' or ItemConfig[item].type == 'weapon' then
            log.debug("Auto-equipping item", item, uuid)
            EquipItem(player, uuid)
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
            if (ItemConfig[item].max_use - inventory_item.used == 1) then
                log.debug "all used up!"
                UnequipItem(player, uuid)
                RemoveFromInventory(player, uuid)
            else
                log.debug('increment used by 1')
                inventory[i].used = inventory_item.used + 1
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
    log.trace("RemoveFromInventory", uuid, amount)

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
AddRemoteEvent("DropItemFromInventory", function(player, uuid, forward_vector)
    local item = GetItemInstance(uuid)

    log.info("Player " .. GetPlayerName(player) .. " drops item " .. item)

    -- SetPlayerAnimation(player, "CARRY_SETDOWN")

    Delay(1000, function()
        UnequipItem(player, uuid)

        RemoveFromInventory(player, uuid)

        -- spawn object near player
        CreatePickupNearPlayer(player, item, forward_vector)

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
    for index = 1, MAX_INVENTORY_SLOTS do
        if not table.findByKeyValue(inventory, "slot", index) then
            return index
        end
    end
end

-- use object from inventory
function UseItemFromInventory(player, uuid)
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

    if ItemConfig[item].max_use and inventory_item.used > ItemConfig[item].max_use then
        log.error "Max use exceeded!"
        return
    end

    CallEvent("BEFORE USE items:" .. item .. ":before_use", player, equipped_object)

    PlayInteraction(player, ItemConfig[item].interaction, function()
        -- increment used
        if ItemConfig[item].max_use then
            IncrementItemUsed(player, uuid)
        end

        -- call USE event on object
        log.debug("USE item:", item)
        log.debug("object:", equipped_object)
        CallEvent("USE items:" .. item .. ":use", player, equipped_object)
    end)
end
AddRemoteEvent("UseItemFromInventory", UseItemFromInventory)

-- interact with objects
AddRemoteEvent("InteractWithObjectProp", function(player, ActiveProp, CurrentInHand)
    log.trace("InteractWithObjectProp",player, dump(ActiveProp), dump(CurrentInHand))

    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if not prop then
        return
    end

    -- 
    if not CurrentInHand then
        -- no animation available here
        log.debug("calling event: "..prop.event)
        CallEvent(prop.event, player, ActiveProp, CurrentInHand)
        return
    end

    -- todo:   this plays the item's interaction even when interacting with
    -- a unrelated prop object, such as a light.   do we really mean to play
    -- the chopping animation when turning on/off a light??? 
    

    PlayInteraction(player, ItemConfig[CurrentInHand.item].interaction, function()
        -- todo: increment use / max use?

        -- call prop event on object
        log.debug("calling event: "..prop.event)
        CallEvent(prop.event, player, ActiveProp, CurrentInHand)
    end)
end)

-- interact with world props (via in-hand item)
AddRemoteEvent("InteractWithWorldProp", function(player, ActiveProp, CurrentInHand)
    log.trace("InteractWithWorldProp", player, dump(ActiveProp), dump(CurrentInHand))

    local interaction
    for _, int in pairs(ItemConfig[CurrentInHand.item].interaction['interacts_on']) do
        if int.hittype == ActiveProp.hit_type then
            interaction = int
            break
        end
    end
    log.debug("interaction:" .. dump(interaction))
    if not interaction then
        return
    end

    PlayInteraction(player, ItemConfig[CurrentInHand.item].interaction, function()
        log.debug("calling event: "..interaction.event)
        CallEvent(interaction.event, player, ActiveProp)
    end)
end)

-- interaction = { sound = "sounds/chainsaw.wav", animation = { id = 924, duration = 10000 } }
function PlayInteraction(player, interaction, after_callback)
    log.debug("Playing interaction:", dump(interaction))

    if not interaction then
        if after_callback then
            after_callback()
        end
        return
    end
    if interaction['animation'] then
        if interaction['animation'].name then
            SetPlayerAnimation(player, interaction['animation'].name)
        elseif interaction['animation'].id then
            SetPlayerAnimation(player, tonumber(interaction['animation'].id))
        end
        local duration = interaction['animation']['duration'] or 2000 -- default animation delay

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
    if interaction['sound'] then
        local x, y, z = GetPlayerLocation(player)
        PlaySoundSync(interaction['sound'], x, y, z)
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
            used = item.used
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
function UseItemFromHotbarSlot(player, hotbar_slot)
    log.trace("UseItemFromHotbarSlot", hotbar_slot)

    local inventory = PlayerData[player].inventory
    for i, item in ipairs(inventory) do
        if tostring(item.hotbar_slot) == hotbar_slot then
            EquipItem(player, item.uuid)
            return
        end
    end
end

AddRemoteEvent("UseWeaponSlot", UseItemFromHotbarSlot)
AddRemoteEvent("UseItemHotkey", UseItemFromHotbarSlot)

