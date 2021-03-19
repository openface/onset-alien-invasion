local MechanicUI

AddEvent("OnPackageStart", function()
    MechanicUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(MechanicUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/mechanic/")
    SetWebAlignment(MechanicUI, 0.0, 0.0)
    SetWebAnchors(MechanicUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(MechanicUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(MechanicUI)
end)

AddRemoteEvent("LoadVehicleData", function(vehicle, data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(MechanicUI, WEB_VISIBLE)
    SetWebVisibility(InventoryUI, WEB_HIDDEN)

    ExecuteWebJS(MechanicUI, "EmitEvent('LoadVehicleData'," .. data .. ")")

    local wheel_front_r_x, wheel_front_r_y, wheel_front_r_z = GetVehicleBoneLocation(vehicle, "wheel_front_r")
    local wheel_front_l_x, wheel_front_l_y, wheel_front_l_z = GetVehicleBoneLocation(vehicle, "wheel_front_l")
    local wheel_rear_r_x, wheel_rear_r_y, wheel_rear_r_z = GetVehicleBoneLocation(vehicle, "wheel_rear_r")
    local wheel_rear_l_x, wheel_rear_l_y, wheel_rear_l_z = GetVehicleBoneLocation(vehicle, "wheel_rear_l")
    local door_front_r_x, door_front_r_y, door_front_r_z = GetVehicleBoneLocation(vehicle, "door_front_r")
    local door_front_l_x, door_front_l_y, door_front_l_z = GetVehicleBoneLocation(vehicle, "door_front_l")
    local door_rear_r_x, door_rear_r_y, door_rear_r_z = GetVehicleBoneLocation(vehicle, "door_rear_r")
    local door_rear_l_x, door_rear_l_y, door_rear_l_z = GetVehicleBoneLocation(vehicle, "door_rear_l")

    local bone_data = {
        wheel_front_r = { x = wheel_front_r_x, y = wheel_front_r_y, z = wheel_front_r_z },
        wheel_front_l = { x = wheel_front_l_x, y = wheel_front_l_y, z = wheel_front_l_z },
        wheel_rear_r = { x = wheel_rear_r_x, y = wheel_rear_r_y, z = wheel_rear_r_z },
        wheel_rear_l = { x = wheel_rear_l_x, y = wheel_rear_l_y, z = wheel_rear_l_z },
        door_front_r = { x = door_front_r_x, y = door_front_r_y, z = door_front_r_z },
        door_front_l = { x = door_front_l_x, y = door_front_l_y, z = door_front_l_z },
        door_rear_r = { x = door_rear_r_x, y = door_rear_r_y, z = door_rear_r_z },
        door_rear_l = { x = door_rear_l_x, y = door_rear_l_y, z = door_rear_l_z }
    }

    CallRemoteEvent("ShowVehicleBones", bone_data)
end)

AddEvent("CloseMechanic", function()
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(MechanicUI, WEB_HIDDEN)
    SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)

    CallRemoteEvent("CloseMechanic")
end)
