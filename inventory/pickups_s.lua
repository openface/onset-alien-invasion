Pickups = {}

AddEvent("OnPackageStop", function()
    for _, pickup in pairs(Pickups) do
        DestroyObjectPickup(pickup)
    end
    Pickups = {}
end)

AddCommand("item", function(player, item)
    if not IsAdmin(player) then
        return
    end
    local uuid = RegisterNewItem(item)
    CreateItemInstancePickupNearPlayer(player, uuid)
end)

-- creates an existing item by uuid near given player
function CreateItemInstancePickupNearPlayer(player, uuid, forward_vector)
    local item = GetItemInstance(uuid)
    if not item then
        log.error("Unknown item "..uuid)
        return
    end
    if not ItemConfig[item] then
        log.debug("Invalid object " .. item)
        return
    end

    local x, y, z = GetPlayerLocation(player)
    if forward_vector then
        x = x + (forward_vector.vx * 150)
        y = y + (forward_vector.vy * 150)
    else
        -- random location around player
        x, y = randomPointInCircle(x, y, 150)
    end

    z = z - 75

    log.debug("Creating object pickup " .. item .. " modelid " .. ItemConfig[item].modelid .. " type " .. ItemConfig[item].type .. " uuid "..uuid)

    local pickup = CreatePickup(ItemConfig[item].modelid, x, y, z)
    SetPickupPropertyValue(pickup, 'item', item)
    SetPickupPropertyValue(pickup, 'uuid', uuid)
    SetPickupPropertyValue(pickup, '_text', CreateText3D(ItemConfig[item].name, 8, x, y, z + 100, 0, 0, 0))
    if ItemConfig[item].scale ~= nil then
        SetPickupScale(pickup, ItemConfig[item].scale.x, ItemConfig[item].scale.y, ItemConfig[item].scale.z)
    end
    Pickups[pickup] = pickup
end

function DestroyObjectPickup(pickup)
    text3d = GetPickupPropertyValue(pickup, '_text')
    if text3d ~= nil then
        DestroyText3D(text3d)
    end
    DestroyPickup(pickup)
    Pickups[pickup] = nil
end

AddEvent("OnPlayerPickupHit", function(player, pickup)
    local item = GetPickupPropertyValue(pickup, 'item')
    if not item then
        return
    end

    if not ItemConfig[item] then
        return
    end

    if ItemConfig[item].max_carry ~= nil and GetInventoryCount(player, item) >= ItemConfig[item].max_carry then
        log.debug("Pickup exceeds max_carry")
        CallRemoteEvent(player, "PlayErrorSound")
        return
    elseif GetInventoryAvailableSlots(player) <= 0 then
        log.debug("Pickup exceeded max inventory slots")
        CallRemoteEvent(player, "PlayErrorSound")
        return
    end

    CallRemoteEvent(player, "PlayPickupSound", ItemConfig[item].pickup_sound or "sounds/pickup.wav")

    log.debug("Player " .. GetPlayerName(player) .. " picks up item " .. item)
    CallRemoteEvent(player, "ShowMessage", "You have picked up a "..ItemConfig[item].name)

    -- adds to player inventory and syncs
    local uuid = GetPickupPropertyValue(pickup, 'uuid')

    AddItemInstanceToInventory(player, uuid)

    DestroyText3D(GetPickupPropertyValue(pickup, '_text'))
    DestroyPickup(pickup)
end)

