local ComputerUI
local ComputerLoc = { x = -106279.4140625, y = 193854.59375, z = 1399.1424560547 }
local SatelliteLoc = { x = -103004.5234375, y = 201067.09375, z = 2203.3188476563 }
local computer_timer
local SatelliteWaypoint

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(ComputerUI, "http://asset/"..GetPackageName().."/client/ui/computer/computer.html")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)
end)

function ShowSatelliteWaypoint()
    HideSatelliteWaypoint()
    SatelliteWaypoint = CreateWaypoint(SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z+50, "Satellite Computer")
end
AddEvent("ShowSatelliteWaypoint", ShowSatelliteWaypoint)
AddRemoteEvent("ShowSatelliteWaypoint", ShowSatelliteWaypoint)

function HideSatelliteWaypoint()
    if SatelliteWaypoint ~= nil then
        print("destroy sat wp: "..SatelliteWaypoint)
        DestroyWaypoint(SatelliteWaypoint)
    end
end
AddEvent("HideSatelliteWaypoint", HideSatelliteWaypoint)
AddRemoteEvent("HideSatelliteWaypoint", HideSatelliteWaypoint)

function ShowComputerTimer(loc)
    local x,y,z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 200 then
        Delay(1000, function()
            ExecuteWebJS(ComputerUI, "HideComputer()")
            DestroyTimer(computer_timer)
        end)
    end
end

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        local player = GetPlayerId()
        local x,y,z = GetPlayerLocation(player)

        if GetDistance3D(x, y, z, ComputerLoc.x, ComputerLoc.y, ComputerLoc.z) <= 200 then
            -- interacting with garage computer
            SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 0.7)

            ExecuteWebJS(ComputerUI, "ShowGarageComputer()")

            CallEvent("GarageComputerInteraction")

            computer_timer = CreateTimer(ShowComputerTimer, 2000, ComputerLoc)
        elseif GetDistance3D(x, y, z, SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z) <= 200 then
            if SatelliteWaypoint ~= nil then
                DestroyWaypoint(SatelliteWaypoint)
            end

            -- interacting with satellite computer
            if GetPlayerPropertyValue(player, 'carryingPart') == nil then
                ShowMessage("You are missing a critical computer part!", 5000)
                SetSoundVolume(CreateSound("client/sounds/error.mp3"), 1)
            else
                SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 1)
                CallRemoteEvent("InteractSatelliteComputer")
            end
        end
    end
end)

AddRemoteEvent("ShowSatelliteComputer", function(percentage)
    if percentage >= 100 then
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputerComplete()")
    else
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputer("..percentage..")")
        computer_timer = CreateTimer(ShowComputerTimer, 2000, SatelliteLoc)
    end
end)

-- occurs just before boss arrives
AddRemoteEvent("SatelliteTransmission", function()
    SetSoundVolume(CreateSound3D("client/sounds/transmission.mp3", SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z, 10000), 1)
    Delay(7000, function()
        SetSoundVolume(CreateSound3D("client/sounds/alert.mp3", SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z, 10000), 1)
    end)
end)


