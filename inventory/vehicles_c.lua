-- vehicle key bindings
AddEvent("OnKeyPress", function(key)
    if key == "K" then
        CallRemoteEvent("ToggleVehicleTrunk")
    elseif key == "J" then
        CallRemoteEvent("ToggleVehicleHood")
    elseif key == "G" then
        CallRemoteEvent("ToggleVehicleEngine")
    end
end)

function IsNearVehicleOpenHood(vehicle)
    local px, py, pz = GetPlayerLocation()
    local hx, hy, hz = GetVehicleBoneLocation(vehicle, 'hood')
    local dist = GetDistance2D(px, py, hx, hy)
    if dist < 175 and GetVehicleHoodRatio(vehicle) > 0.0 then
        return true
    else
        return false
    end
end

-- cannot enter vehicles carrying some big items
AddEvent("OnPlayerStartEnterVehicle", function(vehicle, seat)
    if CurrentInHand and CurrentInHand.enter_vehicles_while_equipped == false then
        ShowError("Your hands are too full!")
        return false
    end
end)

AddEvent('OnKeyPress', function(key)
    if not IsPlayerInVehicle() then
        return
    end

    if key == '1' or key == '2' or key == '3' or key == '4' then
        CallRemoteEvent("ChangeVehicleSeat", key)
    end
end)