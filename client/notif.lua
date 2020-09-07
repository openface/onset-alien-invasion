local NotifUI

AddEvent("OnPackageStart", function()
    NotifUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(NotifUI, "http://asset/"..GetPackageName().."/client/ui/notif/notif.html")
    SetWebAlignment(NotifUI, 0.0, 0.0)
    SetWebAnchors(NotifUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(NotifUI, WEB_HITINVISIBLE)
end)

-- banners
function ShowBanner(msg)
    ExecuteWebJS(NotifUI, "ShowBanner('"..msg.."')")
end
AddFunctionExport("ShowBanner", ShowBanner)
    
AddRemoteEvent("ShowBanner", function(msg)
    ShowBanner(msg)
end)

-- messages
function ShowMessage(msg)
    ExecuteWebJS(NotifUI, "ShowMessage('"..msg.."')")
end
AddFunctionExport("ShowMessage", ShowMessage)
    
AddRemoteEvent("ShowMessage", function(msg)
    ShowMessage(msg)
end)

-- overlay
function ShowBlood()    
    ExecuteWebJS(NotifUI, "ShowBlood()")
end
AddFunctionExport("ShowBlood", ShowBlood)

AddRemoteEvent("ShowBlood", function()
    ShowBlood()
end)
