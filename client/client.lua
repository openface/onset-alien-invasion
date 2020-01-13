local AmbientSound

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

    AmbientSound = CreateSound("client/sounds/ambience.mp3")
    SetSoundVolume(AmbientSound, 1)

    SetOceanColor("0x8a0303", "0x9b0000", "0x7c0000", "0x850101", "0x6a0101")
end)

AddEvent("OnPlayerDeath", function(player, killer)
    SetPostEffect("ImageEffects", "VignetteIntensity", 2.0)
    ShowBanner("YOU HAVE DIED", 5000)
    SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
    SetCameraShakeFOV(5.0, 5.0)
    PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, 'clothing')
    SetNPCClothingPreset(npc, clothing)
end)

--[[
function OnKeyPress(key)
	if key == "F1" then
		ShowBanner("YOU HAVE DIED", 5000)
	end
end
AddEvent("OnKeyPress", OnKeyPress)
--]]


AddEvent("OnPlayerEnterWater", function()
    CreateCountTimer(function()
        CallRemoteEvent("OnPlayerEnterWater")        
        SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    end, 3000, 10)
end)

AddRemoteEvent("ClientSetTime", function(time)
	SetTime(time)
end)