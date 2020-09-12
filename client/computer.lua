local ComputerUI
local InteractiveLocs = {
    ["InteractComputer"] = { x = -106279.4140625, y = 193854.59375, z = 1399.1424560547 },
    ["InteractSatellite"] = { x = -103004.5234375, y = 201067.09375, z = 2203.3188476563 }
}
local computer_timer
local SatelliteWaypoint
local SatelliteStatus

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(ComputerUI, "http://asset/"..GetPackageName().."/client/ui/computer/computer.html")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)

    SatelliteStatus = CreateTextBox(0, 0, "", "center")
    SetTextBoxAnchors(SatelliteStatus, 0.0, 0.0, 1.0, 0.03)
    SetTextBoxAlignment(SatelliteStatus, 1.0, 0.0)
end)

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        local player = GetPlayerId()
        local x,y,z = GetPlayerLocation(player)        
        for event,pos in pairs(InteractiveLocs) do
            if GetDistance3D(x, y, z, pos.x, pos.y, pos.z) <= 200 then
                CallEvent(event, player, pos)
                break
            end
        end
    end
end)

function ShowSatelliteWaypoint()
    HideSatelliteWaypoint()
    SatelliteWaypoint = CreateWaypoint(
        InteractiveLocs.InteractSatellite.x, 
        InteractiveLocs.InteractSatellite.y, 
        InteractiveLocs.InteractSatellite.z+50, 
        "Satellite Terminal"
    )
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
        ExecuteWebJS(ComputerUI, "HideComputer()")
        DestroyTimer(computer_timer)
    end
end

AddEvent("InteractComputer", function(player, pos)
    -- interacting with garage computer
    SetSoundVolume(CreateSound("client/sounds/modem.mp3"), 0.7)

    ExecuteWebJS(ComputerUI, "ShowGarageComputer()")

    CallEvent("GarageComputerInteraction")

    computer_timer = CreateTimer(ShowComputerTimer, 2000, pos)
end)

AddEvent("InteractSatellite", function(player)
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
end)

AddRemoteEvent("ShowSatelliteComputer", function(percentage)
    if percentage >= 100 then
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputerComplete()")
    else
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputer("..percentage..")")
        computer_timer = CreateTimer(ShowComputerTimer, 2000, InteractiveLocs.InteractSatellite)
    end
end)

-- occurs just before boss arrives
AddRemoteEvent("SatelliteTransmission", function()
    SetSoundVolume(CreateSound3D("client/sounds/transmission.mp3", InteractiveLocs.InteractSatellite.x, InteractiveLocs.InteractSatellite.y, InteractiveLocs.InteractSatellite.z, 10000), 1)
    Delay(7000, function()
        SetSoundVolume(CreateSound3D("client/sounds/alert.mp3", InteractiveLocs.InteractSatellite.x, InteractiveLocs.InteractSatellite.y, InteractiveLocs.InteractSatellite.z, 10000), 1)
    end)
end)

-- shows satellite progress on player screen
function SetSatelliteStatus(percent)
    if percent == nil then
        SetTextBoxText(SatelliteStatus, "")
    else
        SetTextBoxText(SatelliteStatus, "SATELLITE STATUS: "..percent.."% OPERATIONAL")
    end
end
AddEvent("SetSatelliteStatus", SetSatelliteStatus)
AddRemoteEvent("SetSatelliteStatus", SetSatelliteStatus)