local ComputerUI

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(ComputerUI, "http://asset/"..GetPackageName().."/client/ui/computer/computer.html")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HIDDEN)
end)

AddRemoteEvent("AccessComputer", function()
    SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 0.7)
    ExecuteWebJS(ComputerUI, "ShowComputer()")
    SetWebVisibility(ComputerUI, WEB_VISIBLE)

    CreateTimer(function()
        local x,y,z = GetPlayerLocation(GetPlayerId())
        if GetDistance2D(x, y, -106279.4140625, 193854.59375) >= 200 then
            ExecuteWebJS(ComputerUI, "HideComputer()")
            SetWebVisibility(ComputerUI, WEB_HIDDEN)
        end
    end, 2000)
end)