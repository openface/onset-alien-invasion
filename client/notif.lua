local NotifUI
local timer

AddEvent("OnPackageStart", function()
    NotifUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(NotifUI, "http://asset/"..GetPackageName().."/client/ui/notif/notif.html")
    SetWebAlignment(NotifUI, 0.0, 0.0)
    SetWebAnchors(NotifUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(NotifUI, WEB_HIDDEN)
end)

-- banners
function ShowBanner(msg, duration)
    ExecuteWebJS(NotifUI, "ShowBanner('"..msg.."')")
    SetWebVisibility(NotifUI, WEB_HITINVISIBLE)

    Delay(duration, function()
        ExecuteWebJS(NotifUI, "HideBanner()")
        SetWebVisibility(NotifUI, WEB_HIDDEN)
    end)
end
AddFunctionExport("ShowBanner", ShowBanner)
    
AddRemoteEvent("ShowBanner", function(msg, duration)
    ShowBanner(msg, duration)
end)

-- messages
function ShowMessage(msg, duration)
    ExecuteWebJS(NotifUI, "ShowMessage('"..msg.."')")
    SetWebVisibility(NotifUI, WEB_HITINVISIBLE)

    if IsValidTimer(timer) then
		DestroyTimer(timer)
	end
    timer = CreateTimer(function()
        ExecuteWebJS(NotifUI, "HideMessage()")
        SetWebVisibility(NotifUI, WEB_HIDDEN)
        DestroyTimer(timer)
    end, duration)
end
AddFunctionExport("ShowMessage", ShowMessage)
    
AddRemoteEvent("ShowMessage", function(msg, duration)
    ShowMessage(msg, duration)
end)

-- TODO remove me
--[[
function OnKeyRelease(key)
	if key == "F1" then
		ShowBanner("YOU HAVE DIED", 5000)
    elseif key == "F2" then
        ShowMessage("You have found a computer part!", 5000)
    end
end
AddEvent("OnKeyRelease", OnKeyRelease)
--]]