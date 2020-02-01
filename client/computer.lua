local ComputerUI
local ComputerLoc = { x = -106279.4140625, y = 193854.59375, z = 1399.1424560547 }
local SatelliteLoc = { x = -103004.5234375, y = 201067.09375, z = 2203.3188476563 }

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

        if GetDistance3D(x, y, z, ComputerLoc.x, ComputerLoc.y, ComputerLoc.z) <= 200 then
            -- interacting with garage computer
            SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 0.7)

            ExecuteWebJS(ComputerUI, "ShowComputer()")
            SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)

            computer_timer = CreateTimer(function()
                local x,y,z = GetPlayerLocation(GetPlayerId())
                if GetDistance2D(x, y, ComputerLoc.x, ComputerLoc.y) >= 200 then
                    ExecuteWebJS(ComputerUI, "HideComputer()")
                    SetWebVisibility(ComputerUI, WEB_HIDDEN)
                end
            end, 2000)
        elseif GetDistance3D(x, y, z, SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z) <= 200 then
            -- interacting with satellite computer
            if GetPlayerPropertyValue(player, 'carryingPart') == true then
                CallRemoteEvent("InteractSatelliteComputer")
            else
                ShowMessage("You are missing a vital computer part!", 5000)
            end
        end
    end
end)
