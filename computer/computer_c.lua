ComputerUI = nil

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(ComputerUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/computer/")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(ComputerUI)
end)

-- interacting with computer
AddRemoteEvent("ShowComputer", function(object)
    ShowMouseCursor(true)
    SetInputMode(INPUT_UI)
    SetWebVisibility(ComputerUI, WEB_VISIBLE)
    SetWebFocus(ComputerUI)

    local x, y, z = GetObjectLocation(object)
    SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", x, y, z, 1500), 0.7)
end)

-- command: exit
AddEvent("ExitComputer", function()
    SetWebVisibility(ComputerUI, WEB_HIDDEN)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end)

-- command: activate
AddEvent("ActivateSatellite", function()
    CallRemoteEvent("ActivateSatellite")
    Delay(4000, function()
        CallEvent("ExitComputer")
    end)
end)
