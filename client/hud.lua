-- global
HudUI = nil

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
function ShowError(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowMessage','" .. msg .. "')")
    SetSoundVolume(CreateSound("client/sounds/error.wav"), 0.5)
end

AddRemoteEvent("ShowError", function(msg)
    ShowError(msg)
end)

-- boss health bar
function SetBossHealth(percentage)
    ExecuteWebJS(HudUI, "EmitEvent('SetBossHealth'," .. percentage .. ")")
end
AddRemoteEvent("SetBossHealth", SetBossHealth)
AddEvent("SetBossHealth", SetBossHealth)

-- spinner
AddEvent("ShowSpinner", function()
    ExecuteWebJS(HudUI, "EmitEvent('ShowSpinner')")
end)

AddEvent("HideSpinner", function()
    ExecuteWebJS(HudUI, "EmitEvent('HideSpinner')")
end)

local PreviousIsFirstPerson = nil

-- binoculars
AddRemoteEvent("ShowBinoculars", function()
    ExecuteWebJS(HudUI, "EmitEvent('SetBinocularView', true)")

    PreviousIsFirstPerson = IsFirstPersonCamera()
    if not PreviousIsFirstPerson then
        SetFirstPerson()
    end
    
    SetNearClipPlane(50)
    SetCameraFoV(25)
end)

AddRemoteEvent("HideBinoculars", function()
    if PreviousIsFirstPerson then
        SetFirstPerson()
    else
        SetThirdPerson()
    end
    ExecuteWebJS(HudUI, "EmitEvent('SetBinocularView', false)")
end)

