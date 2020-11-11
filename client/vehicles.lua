-- vehicle key bindings
AddEvent("OnKeyPress", function(key)
    if key == "K" then
        CallRemoteEvent("ToggleVehicleTrunk")
    elseif key == "J" then
        CallRemoteEvent("ToggleVehicleHood")
    end
end)

function IsNearVehicleHood(vehicle)
    local px, py, pz = GetPlayerLocation()
    local hx, hy, hz = GetVehicleBoneLocation(vehicle, 'hood')
    local dist = GetDistance2D(px, py, hx, hy)
    if dist < 200 then
        return true
    else
        return false
    end
end
