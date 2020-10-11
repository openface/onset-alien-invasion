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
    local object = GetObject(item)
    if not object then
        print("Invalid object "..item)
        return
    end
    print("Creating item "..item.. " modelid "..object['modelid'])

    local pickup = CreatePickup(object['modelid'], x, y, z)
    SetPickupPropertyValue(pickup, '_name', item)
    SetPickupPropertyValue(pickup, '_text', CreateText3D(item, 8, x, y, z+100, 0, 0, 0))
    if object['scale'] ~= nil then
        SetPickupScale(pickup, object['scale'].x, object['scale'].y, object['scale'].z)
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
    print("Destroying object pickups by name ",name)
    for _,pickup in pairs(Pickups) do
        if GetPickupPropertyValue(pickup, '_name') == name then
            DestroyObjectPickup(pickup)
        end
    end
end

-- creates a new object near given player
function CreateObjectPickupNearPlayer(player, item)
    local x,y,z = GetPlayerLocation(player)
    local x,y = randomPointInCircle(x,y,100)
    CreateObjectPickup(item, x, y, z-75)
end

AddEvent("OnPlayerPickupHit", function(player, pickup)
    local item = GetPickupPropertyValue(pickup, '_name')
    if item == nil then
        return
    end

    local object = GetObject(item)

    -- if we already have the item, see if we can carry more
    if GetInventoryCount(player, item) >= object['max_carry'] then
        -- prevent pickup if it exceeds the max carry
        return
    elseif GetInventoryAvailableSlots(player) <= 0 then
        -- no available slots for more items
        return
    end

    SetPickupPropertyValue(pickup, '_claimedby', player)
    SetPlayerAnimation(player, "PICKUP_LOWER")

    Delay(2000, function()
        -- remove pickup
        if GetPickupPropertyValue(pickup, '_claimedby') == player then
            SetPlayerAnimation(player, "STOP")

            print("Player "..GetPlayerName(player).." picks up item "..item)
            CallEvent("items:"..item..":pickup", player, pickup)

            AddToInventory(player, item)

            DestroyText3D(GetPickupPropertyValue(pickup, '_text'))
            DestroyPickup(pickup)
        end
    end)
end)
