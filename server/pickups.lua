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

    Delay(1000, function()
        -- remove pickup
        if GetPickupPropertyValue(pickup, '_claimedby') == player then
            CallEvent("items:"..item..":pickup", player)

            AddToInventory(player, item)

            DestroyText3D(GetPickupPropertyValue(pickup, '_text'))
            DestroyPickup(pickup)
        end
    end)
end)
