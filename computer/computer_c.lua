local ComputerUI

local computer_timer

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

-- interacting with satellite computer
AddEvent("InteractSatelliteTerminal", function(object)
    local x, y, z = GetObjectLocation(object)

    SetSoundVolume(CreateSound3D("client/sounds/modem.mp3", x, y, z, 1500), 0.7)
    CallRemoteEvent("InteractSatelliteComputer", object)

    local x, y, z = GetObjectLocation(object)
    computer_timer = CreateTimer(ShowComputerTimer, 1000, {
        x = x,
        y = y,
        z = z
    })
end)

-- shows the satellite UI
AddRemoteEvent("ShowSatelliteComputer", function()
    SetWebVisibility(ComputerUI, WEB_HITINVISIBLE)
    ExecuteWebJS(ComputerUI, "EmitEvent('SetComputerScreen','satellite-transmission')")
end)

-- occurs just before boss arrives
AddRemoteEvent("BeginSatelliteTransmission", function(object)
    local x,y,z = GetObjectLocation(object)
    
    SetSoundVolume(CreateSound3D("client/sounds/transmission.mp3", x, y, z, 10000), 1)
    Delay(7000, function()
        SetSoundVolume(CreateSound3D("client/sounds/alert.mp3", x, y, z, 10000), 1)
    end)
end)
