-- vehicle key bindings
AddEvent("OnKeyPress", function(key)
    if key == "K" then
        CallRemoteEvent("ToggleVehicleTrunk")
    elseif key == "J" then
        CallRemoteEvent("ToggleVehicleHood")
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
