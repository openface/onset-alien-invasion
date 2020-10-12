local HudUI

AddEvent("OnPackageStart", function()
    HudUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(HudUI, "http://asset/"..GetPackageName().."/client/ui/hud/hud.html")
    SetWebAlignment(HudUI, 0.0, 0.0)
    SetWebAnchors(HudUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(HudUI, WEB_HITINVISIBLE)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(HudUI)
end)

-- banner
function ShowBanner(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowBanner','"..msg.."')")
end
AddFunctionExport("ShowBanner", ShowBanner)
    
AddRemoteEvent("ShowBanner", function(msg)
    ShowBanner(msg)
end)

-- message
function ShowMessage(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowMessage','"..msg.."')")
end
AddFunctionExport("ShowMessage", ShowMessage)
    
AddRemoteEvent("ShowMessage", function(msg)
    ShowMessage(msg)
end)

-- blood splat
function ShowBlood()    
    ExecuteWebJS(HudUI, "EmitEvent('ShowBlood')")
end
AddFunctionExport("ShowBlood", ShowBlood)

AddRemoteEvent("ShowBlood", function()
    ShowBlood()
end)

-- boss health bar
function SetBossHealth(percentage)
    ExecuteWebJS(HudUI, "EmitEvent('SetBossHealth',"..percentage..")")
end
AddRemoteEvent("SetBossHealth", SetBossHealth)
AddEvent("SetBossHealth", SetBossHealth)


-- inventory
AddRemoteEvent("SetInventory", function(data)
	ExecuteWebJS(HudUI, "EmitEvent('SetInventory',".. data ..")")
end)