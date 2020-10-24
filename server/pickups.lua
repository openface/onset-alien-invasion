Pickups = {}

AddEvent("OnPackageStop", function()
    for _,pickup in pairs(Pickups) do
        DestroyObjectPickup(pickup)
    end
end)

AddCommand("item", function(player, item)
    if not IsAdmin(player) then
        return
    end
    CreateObjectPickupNearPlayer(player, item)
end)

function CreateObjectPickup(item, x, y, z)
    local item_cfg = GetItemConfig(item)
    if not item_cfg then
        print("Invalid object "..item)
        return
    end
    print("Creating item "..item.. " modelid "..item_cfg['modelid'])

    local pickup = CreatePickup(item_cfg['modelid'], x, y, z)
    SetPickupPropertyValue(pickup, '_name', item)
    SetPickupPropertyValue(pickup, '_text', CreateText3D(item, 8, x, y, z+100, 0, 0, 0))
    if item_cfg['scale'] ~= nil then
        SetPickupScale(pickup, item_cfg['scale'].x, item_cfg['scale'].y, item_cfg['scale'].z)
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

function DestroyObjectPickupsByName(name)
    print("Destroying object pickup by name ",name)
    for _,pickup in pairs(Pickups) do
        if GetPickupPropertyValue(pickup, '_name') == name then
            DestroyObjectPickup(pickup)
        end
    end
end

-- creates a new object near given player
function CreateObjectPickupNearPlayer(player, item)
    local x,y,z = GetPlayerLocation(player)
    local x,y = randomPointInCircle(x,y,150)
    CreateObjectPickup(item, x, y, z-75)
end

AddEvent("OnPlayerPickupHit", function(player, pickup)
    local item = GetPickupPropertyValue(pickup, '_name')
    if item == nil then
        return
    end

    local item_cfg = GetItemConfig(item)

    -- if we already have the item, see if we can carry more
    if GetInventoryCount(player, item) >= item_cfg['max_carry'] then
        -- prevent pickup if it exceeds the max carry
        CallRemoteEvent(player, "PlayErrorSound")
        return
    elseif GetInventoryAvailableSlots(player) <= 0 then
        -- no available slots for more items
        print("Pickup exceeded max inventory slots")
        return
    end

    CallRemoteEvent(player, "PlayPickupSound", item_cfg['pickup_sound'] or "sounds/pickup.wav")

    print("Player "..GetPlayerName(player).." picks up item "..item)
    CallEvent("items:"..item..":pickup", player, pickup)

    AddToInventory(player, item)

    --if item_cfg['type'] == 'equipable' then
    --  EquipObject(player, item)
    --end

    DestroyText3D(GetPickupPropertyValue(pickup, '_text'))
    DestroyPickup(pickup)
end)
