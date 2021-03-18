local MechanicUI

AddEvent("OnPackageStart", function()
    MerchantUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(MechanicUI, "http://asset/"..GetPackageName().."/ui/dist/index.html#/mechanic/")
    SetWebAlignment(MechanicUI, 0.0, 0.0)
    SetWebAnchors(MechanicUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(MechanicUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(MechanicUI)
end)

