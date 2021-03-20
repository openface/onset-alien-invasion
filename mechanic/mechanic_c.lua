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

AddEvent("CloseMechanic", function()
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(MechanicUI, WEB_HIDDEN)
    SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)

    CallRemoteEvent("CloseMechanic")
end)
