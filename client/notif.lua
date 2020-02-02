local NotifUI
local timer = 0

AddEvent("OnPackageStart", function()
    NotifUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(NotifUI, "http://asset/"..GetPackageName().."/client/ui/notif/notif.html")
    SetWebAlignment(NotifUI, 0.0, 0.0)
    SetWebAnchors(NotifUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(NotifUI, WEB_HITINVISIBLE)
end)

-- banners
function ShowBanner(msg, duration)
  	if IsValidTimer(timer) then
		DestroyTimer(timer)
	end
    timer = CreateTimer(HideNotifs, duration)
    ExecuteWebJS(NotifUI, "ShowBanner('"..msg.."')")
end
AddFunctionExport("ShowBanner", ShowBanner)
    
AddRemoteEvent("ShowBanner", function(msg, duration)
    ShowBanner(msg, duration)
end)

-- messages
function ShowMessage(msg, duration)
  	if IsValidTimer(timer) then
		DestroyTimer(timer)
	end
    timer = CreateTimer(HideNotifs, duration)
    ExecuteWebJS(NotifUI, "ShowMessage('"..msg.."')")
end
AddFunctionExport("ShowMessage", ShowMessage)
    
AddRemoteEvent("ShowMessage", function(msg, duration)
    ShowMessage(msg, duration)
end)

function HideNotifs()
    ExecuteWebJS(NotifUI, "HideNotifs()")
end


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