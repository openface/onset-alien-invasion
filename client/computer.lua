local ComputerUI

local ComputerLoc = { x = -106279.4140625, y = 193854.59375, z = 1399.1424560547 }
local computer_timer

local SatelliteLoc = { x = -103004.5234375, y = 201067.09375, z = 2203.3188476563 }
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
        if GetDistance3D(x, y, z, ComputerLoc.x, ComputerLoc.y, ComputerLoc.z) <= 200 then
            CallEvent("InteractComputer", player)
        elseif GetDistance3D(x, y, z, SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z) <= 200 then
            CallEvent("InteractSatellite", player)
        end
    end
 end)

-- after computer_part is picked up, show waypoint to the satellite
function ShowSatelliteWaypoint()
    HideSatelliteWaypoint()
    SatelliteWaypoint = CreateWaypoint(SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc+50, "Satellite Terminal")
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

-- timer used to hide computer screen once player walks away
function ShowComputerTimer(loc)
    local x,y,z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 200 then
        ExecuteWebJS(ComputerUI, "HideComputer()")
        DestroyTimer(computer_timer)
    end
end

-- interacting with garage computer
AddEvent("InteractComputer", function(player)
    SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", ComputerLoc.x, ComputerLoc.y, ComputerLoc.z, 1500), 0.7)
    ExecuteWebJS(ComputerUI, "ShowGarageComputer()")
    CallEvent("GarageComputerInteraction")
    computer_timer = CreateTimer(ShowComputerTimer, 1000, ComputerLoc)
end)

-- interacting with satellite computer requires computer_part
AddEvent("InteractSatellite", function(player)
    if SatelliteWaypoint ~= nil then
        DestroyWaypoint(SatelliteWaypoint)
    end

    local _inventory = GetPlayerPropertyValue(player, "inventory")
    local part_count = 0
    for k,v in pairs(_inventory) do
        if v['item'] == "computer_part" then
            part_count = v['quantity']
        end
    end

    AddPlayerChat(part_count)
    if part_count < 1 then
        ShowMessage("You are missing a critical computer part!", 5000)
        SetSoundVolume(CreateSound("client/sounds/error.mp3"), 1)
    else
        SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z, 1500), 0.7)
        CallRemoteEvent("InteractSatelliteComputer")
    end
end)

AddRemoteEvent("ShowSatelliteComputer", function(percentage)
    if percentage >= 100 then
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputerComplete()")
    else
        ExecuteWebJS(ComputerUI, "ShowSatelliteComputer("..percentage..")")
        computer_timer = CreateTimer(ShowComputerTimer, 1000, SatelliteLoc)
    end
end)

-- occurs just before boss arrives
AddRemoteEvent("SatelliteTransmission", function()
    SetSoundVolume(CreateSound3D("client/sounds/transmission.mp3", SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z, 10000), 1)
    Delay(7000, function()
        SetSoundVolume(CreateSound3D("client/sounds/alert.mp3", SatelliteLoc.x, SatelliteLoc.y, SatelliteLoc.z, 10000), 1)
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