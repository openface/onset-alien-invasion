local ComputerWaypoint

AddEvent("OnPlayerSpawn", function()
    local player = GetPlayerId()
    local clothing = GetPlayerPropertyValue(player, "clothing")
    if clothing == nil then
        clothing = 25
    end
        
    SetPlayerClothingPreset(player, clothing)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0.0)
    StopCameraShake(false)
end)

AddEvent("OnPlayerDeath", function(player, killer)
    SetPostEffect("ImageEffects", "VignetteIntensity", 2.0)
    ShowBanner("YOU HAVE DIED")
    SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
    SetCameraShakeFOV(5.0, 5.0)
    PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, "clothing")
  	if (clothing ~= nil) then
        SetNPCClothingPreset(npc, clothing)
    end
end)

AddEvent("OnPlayerStreamIn", function(player)
	local clothing = GetPlayerPropertyValue(player, "clothing")
	if (clothing ~= nil) then
		SetPlayerClothingPreset(player, clothing)
	end
end)

AddEvent("OnPlayerTalking", function(player)
    SetPlayerLipMovement(player)
end)

AddRemoteEvent("ClientSetTime", function(time)
    SetTime(time)
end)

-- skydive
AddEvent("OnPlayerSkydive", function()
    ShowMessage("Hit [SPACE] to open parachute")
end)

AddEvent("OnPlayerParachuteOpen", function()
    ShowBanner("WELCOME TO THE INVASION!")
    ComputerWaypoint = CreateWaypoint(-106279.4140625, 193854.59375, 1399.1424560547 + 50, "Computer Terminal")
end)

AddEvent("OnPlayerParachuteLand", function()
    CallRemoteEvent("DropParachute")
end)

AddEvent("GarageComputerInteraction", function(player)
    if ComputerWaypoint ~= nil then
        DestroyWaypoint(ComputerWaypoint)
    end
end)

-- toggle first-person view
AddEvent("OnKeyPress", function(key)
    if key == "V" then
        if IsFirstPersonCamera() then
            EnableFirstPersonCamera(false)
            SetNearClipPlane(0)
            SetCameraViewDistance(375)
        else
            EnableFirstPersonCamera(true)
            SetNearClipPlane(15)
            SetCameraViewDistance(350)
        end
    end
end)