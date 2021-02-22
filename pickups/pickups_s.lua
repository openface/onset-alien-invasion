Pickups = {}

AddEvent("OnPackageStop", function()
    for _, pickup in pairs(Pickups) do
        DestroyObjectPickup(pickup)
    end
    Pickups = {}
end)

AddCommand("item", function(player, item)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    CreatePickupNearPlayer(player, item)
end)

-- creates a new object or weapon near given player
function CreatePickupNearPlayer(player, item)
    local x, y, z = GetPlayerLocation(player)
    local x, y = randomPointInCircle(x, y, 150)
    CreateObjectPickup(item, x, y, z - 75)
end

function CreateObjectPickup(item, x, y, z)
    if not ItemConfig[item] then
        log.debug("Invalid object " .. item)
        return
    end
    log.debug("Creating object pickup " .. item .. " modelid " .. ItemConfig[item].modelid .. " type " .. ItemConfig[item].type)

    local pickup = CreatePickup(ItemConfig[item].modelid, x, y, z)
    SetPickupPropertyValue(pickup, '_name', item)
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
    local item = GetPickupPropertyValue(pickup, '_name')
    if item == nil then
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
    local uuid = RegisterNewItem(item)
    AddToInventory(player, uuid)

    DestroyText3D(GetPickupPropertyValue(pickup, '_text'))
    DestroyPickup(pickup)
end)

