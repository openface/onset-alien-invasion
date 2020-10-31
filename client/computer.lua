local ComputerUI

local computer_timer

local SatelliteWaypoint
local SatelliteStatus

AddEvent("OnPackageStart", function()
    ComputerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(ComputerUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/computer/")
    SetWebAlignment(ComputerUI, 0.0, 0.0)
    SetWebAnchors(ComputerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(ComputerUI, WEB_HIDDEN)

    SatelliteStatus = CreateTextBox(0, 0, "", "center")
    SetTextBoxAnchors(SatelliteStatus, 0.0, 0.0, 1.0, 0.03)
    SetTextBoxAlignment(SatelliteStatus, 1.0, 0.0)
    SetSatelliteStatus(0)
end)

AddEvent("OnPackageStop", function()
    DestroyTextBox(SatelliteStatus)
    DestroyWebUI(ComputerUI)
    if SatelliteWaypoint ~= nil then
      DestroyWaypoint(SatelliteWaypoint)
    end
end)

-- timer used to hide computer screen once player walks away
function ShowComputerTimer(object_location)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, object_location.x, object_location.y, object_location.z) > 200 then
        SetWebVisibility(ComputerUI, WEB_HIDDEN)
        DestroyTimer(computer_timer)
    end
end

-- interacting with garage computer
AddEvent("InteractGarageComputer", function(object)
    local x, y, z = GetObjectLocation(object)
    SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", x, y, z, 1500), 0.7)
    SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)
    ExecuteWebJS(ComputerUI, "EmitEvent('SetComputerScreen','garage')")
    computer_timer = CreateTimer(ShowComputerTimer, 1000, {
        x = x,
        y = y,
        z = z
    })
end)

-- interacting with satellite computer requires computer_part
AddEvent("InteractSatelliteTerminal", function(object)
    if SatelliteWaypoint ~= nil then
        DestroyWaypoint(SatelliteWaypoint)
    end

    local x, y, z = GetObjectLocation(object)

    -- ensure player has computer_part
    if HasComputerPart() ~= true then
        ShowMessage("You are missing a critical computer part!")
        SetSoundVolume(CreateSound("client/sounds/error.wav"), 0.5)
    else
        SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", x, y, z, 1500), 0.7)
        CallRemoteEvent("InteractSatelliteComputer", object)

        local x, y, z = GetObjectLocation(object)
        computer_timer = CreateTimer(ShowComputerTimer, 1000, {
          x = x,
          y = y,
          z = z
        })
    end
end)

function HasComputerPart()
    local inventory = GetPlayerPropertyValue(GetPlayerId(), "inventory")
    for _, item in pairs(inventory) do
        -- log.debug(item['item'])
        if item['item'] == 'computer_part' then
            return true
        end
    end
    return false
end

-- shows the satellite UI
AddRemoteEvent("ShowSatelliteComputer", function(percentage)
    SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)
    ExecuteWebJS(ComputerUI, "EmitEvent('SetComputerScreen','satellite'," .. percentage .. ")")
end)

-- occurs just before boss arrives
AddRemoteEvent("BeginSatelliteTransmission", function(object)
    local x,y,z = GetObjectLocation(object)
    
    SetSoundVolume(CreateSound3D("client/sounds/transmission.mp3", x, y, z, 10000), 1)
    Delay(7000, function()
        SetSoundVolume(CreateSound3D("client/sounds/alert.mp3", x, y, z, 10000), 1)
    end)
end)

-- shows satellite progress on player screen
function SetSatelliteStatus(percent)
    if percent == nil then
        SetTextBoxText(SatelliteStatus, "")
    else
        SetTextBoxText(SatelliteStatus, "SATELLITE STATUS: " .. percent .. "% OPERATIONAL")
    end
end
AddEvent("SetSatelliteStatus", SetSatelliteStatus)
AddRemoteEvent("SetSatelliteStatus", SetSatelliteStatus)

-- clear satellite waypoint on death
AddEvent("OnPlayerDeath", function(killer)
  if SatelliteWaypoint ~= nil then
    DestroyWaypoint(SatelliteWaypoint)
  end
end)

AddRemoteEvent('ComputerPartPickedup', function(waypoint_loc)
  SetSoundVolume(CreateSound("client/sounds/part_pickup.wav"), 1)
  ShowMessage("You have found a computer part.  Use this on the satellite computer!")

  if SatelliteWaypoint ~= nil then
    DestroyWaypoint(SatelliteWaypoint)
  end
  SatelliteWaypoint = CreateWaypoint(waypoint_loc.x, waypoint_loc.y, waypoint_loc.z + 50, "Satellite Terminal")
end)