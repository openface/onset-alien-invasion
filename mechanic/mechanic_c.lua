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
end)

AddRemoteEvent("UpdateVehicleData", function(data)
    ExecuteWebJS(MechanicUI, "EmitEvent('UpdateVehicleData'," .. data .. ")")
end)

function CloseMechanic()
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(MechanicUI, WEB_HIDDEN)
    SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)

    CallRemoteEvent("CloseMechanic")
end
AddEvent("CloseMechanic", CloseMechanic)
AddRemoteEvent("CloseMechanic", CloseMechanic)

AddEvent("RepairVehicle", function()
    CallRemoteEvent("RepairVehicle")
end)

AddEvent("PreviewColor", function(r, g, b)
    CallRemoteEvent("PreviewColor", r, g, b)
end)

AddEvent("PaintVehicle", function(r, g, b)
    CallRemoteEvent("PaintVehicle", r, g, b)
end)