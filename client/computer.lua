local ComputerUI
local ComputerLoc = { x = -106279.4140625, y = 193854.59375 }

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(ComputerUI, "http://asset/"..GetPackageName().."/client/ui/computer/computer.html")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HIDDEN)
end)

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        local player = GetPlayerId()
        local x,y,z = GetPlayerLocation(player)
        if GetDistance2D(x, y, ComputerLoc.x, ComputerLoc.y) <= 200 then
            SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 0.7)
            ExecuteWebJS(ComputerUI, "ShowComputer()")
            SetWebVisibility(ComputerUI, WEB_VISIBLE)

            computer_timer = CreateTimer(function()
                local x,y,z = GetPlayerLocation(GetPlayerId())
                if GetDistance2D(x, y, ComputerLoc.x, ComputerLoc.y) >= 200 then
                    ExecuteWebJS(ComputerUI, "HideComputer()")
                    SetWebVisibility(ComputerUI, WEB_HIDDEN)
                end
            end, 2000)
        end
    end
end)
