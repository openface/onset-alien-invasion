-- global
HudUI = nil
CurrentlyInteracting = false

AddEvent("OnPackageStart", function()
    HudUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(HudUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/hud/")
    SetWebAlignment(HudUI, 0.0, 0.0)
    SetWebAnchors(HudUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(HudUI, WEB_HITINVISIBLE)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(HudUI)
end)

-- banner
function ShowBanner(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowBanner','" .. msg .. "')")
end

AddRemoteEvent("ShowBanner", function(msg)
    ShowBanner(msg)
end)

-- message
function ShowMessage(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowMessage','" .. msg .. "')")
end

AddRemoteEvent("ShowMessage", function(msg)
    ShowMessage(msg)
end)

-- error
AddRemoteEvent("ShowError", function(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowMessage','" .. msg .. "')")
    SetSoundVolume(CreateSound("client/sounds/error.wav"), 0.5)
end)

-- boss health bar
function SetBossHealth(percentage)
    ExecuteWebJS(HudUI, "EmitEvent('SetBossHealth'," .. percentage .. ")")
end
AddRemoteEvent("SetBossHealth", SetBossHealth)
AddEvent("SetBossHealth", SetBossHealth)

-- interactions
AddRemoteEvent("StartInteraction", function(data)
    if data['show_spinner'] then
        ExecuteWebJS(HudUI, "EmitEvent('ShowSpinner'," .. data['duration'] .. ")")
    end
    CurrentlyInteracting = true

    Delay(data['duration'], function()
        CurrentlyInteracting = false
    end)
end)


