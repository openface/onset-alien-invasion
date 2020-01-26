AddEvent("OnPlayerSpawn", function()
    StartCameraFade(1.0, 0.0, 13.0, "#000")
    local player = GetPlayerId()
    local clothing = GetPlayerPropertyValue(player, 'clothing')
    if clothing == nil then
        clothing = 25
    end
        
    SetPlayerClothingPreset(player, clothing)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0.0)
    StopCameraShake(false)
end)

AddEvent("OnPlayerDeath", function(player, killer)
    SetPostEffect("ImageEffects", "VignetteIntensity", 2.0)
    ShowBanner("YOU HAVE DIED", 7000)
    SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
    SetCameraShakeFOV(5.0, 5.0)
    PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, 'clothing')
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

--[[
function OnKeyPress(key)
	if key == "F1" then
		ShowBanner("YOU HAVE DIED", 5000)
	end
end
AddEvent("OnKeyPress", OnKeyPress)
--]]

AddRemoteEvent("ClientSetTime", function(time)
	SetTime(time)
end)
