AddEvent("OnPlayerSpawn", function()
    local player = GetPlayerId()
    local clothing = GetPlayerPropertyValue(player, "clothing")
    if clothing == nil then
        clothing = 25
    end

    SetPlayerClothingPreset(player, clothing)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0.0)
    StopCameraShake(false)

    SetThirdPerson()
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
end)

AddEvent("OnPlayerParachuteLand", function()
    CallRemoteEvent("DropParachute")
end)

-- console
AddEvent("OnConsoleInput", function(input)
    print("console: " .. input)
end)

-- toggle first-person view
AddEvent("OnKeyPress", function(key)
    if key == "V" then
        if IsFirstPersonCamera() then
            SetThirdPerson()
        else
            SetFirstPerson()
        end
    end
end)

function SetFirstPerson()
    EnableFirstPersonCamera(true)
    SetNearClipPlane(15)
    SetCameraViewDistance(350)
end

function SetThirdPerson()
    EnableFirstPersonCamera(false)
    SetNearClipPlane(0)
    SetCameraViewDistance(375)
end

--[[ AddEvent("OnObjectStreamIn", function(object)
  AddPlayerChat("torch")
  SpawnTorchlight(object)
end)

local TorchLights = {}
function SpawnTorchlight(objectId)
    local actor = GetObjectActor(objectId)
    light = actor:AddComponent(USpotLightComponent.Class())
    light:SetIntensity(10000 * 30)
    light:SetLightColor(FLinearColor(255, 255, 255, 0), true)
    light:SetRelativeRotation(FRotator(0.0, 270.0, 0.0))
    Torchlights[player] = {
        obj = objectId,
        light = light
    }
end ]]
