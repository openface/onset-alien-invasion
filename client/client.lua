-- custom assets

-- SurvivalAssetPack
LoadPak("AlienInvasion", "/AlienInvasion/", "../../../OnsetModding/Plugins/AlienInvasion/Content/")
ReplaceObjectModelMesh(20000, "/AlienInvasion/Meshes/SM_Axe-Blood")
ReplaceObjectModelMesh(20001, "/AlienInvasion/Meshes/SM_Axe-Forest")
ReplaceObjectModelMesh(20002, "/AlienInvasion/Meshes/SM_Axe-Neo")
ReplaceObjectModelMesh(20003, "/AlienInvasion/Meshes/SM_Backpack")
ReplaceObjectModelMesh(20004, "/AlienInvasion/Meshes/SM_Binocular")
ReplaceObjectModelMesh(20005, "/AlienInvasion/Meshes/SM_Book-HowToSurviveInTheWoods-Dirty")
ReplaceObjectModelMesh(20007, "/AlienInvasion/Meshes/SM_Campfire")
ReplaceObjectModelMesh(20008, "/AlienInvasion/Meshes/SM_Coolingbox")
ReplaceObjectModelMesh(20009, "/AlienInvasion/Meshes/SM_DrinkingBottle")
ReplaceObjectModelMesh(20011, "/AlienInvasion/Meshes/SM_FishingRod")
ReplaceObjectModelMesh(20012, "/AlienInvasion/Meshes/SM_Flashlight")
ReplaceObjectModelMesh(20020, "/AlienInvasion/Meshes/SM_GasLamp")
ReplaceObjectModelMesh(20021, "/AlienInvasion/Meshes/SM_GasMask")
ReplaceObjectModelMesh(20022, "/AlienInvasion/Meshes/SM_GasStove")
ReplaceObjectModelMesh(20023, "/AlienInvasion/Meshes/SM_Knife")
ReplaceObjectModelMesh(20024, "/AlienInvasion/Meshes/SM_Lighter")
ReplaceObjectModelMesh(20025, "/AlienInvasion/Meshes/SM_Pan")
ReplaceObjectModelMesh(20027, "/AlienInvasion/Meshes/SM_PrimativeShelter")
ReplaceObjectModelMesh(20028, "/AlienInvasion/Meshes/SM_Shovel")
ReplaceObjectModelMesh(20029, "/AlienInvasion/Meshes/SM_SleepingBag-RolledUp-Brown")
ReplaceObjectModelMesh(20030, "/AlienInvasion/Meshes/SM_SleepingBag-RolledUp-Green")
ReplaceObjectModelMesh(20029, "/AlienInvasion/Meshes/SM_SleepingBag-Open-Brown")
ReplaceObjectModelMesh(20030, "/AlienInvasion/Meshes/SM_SleepingBag-Open-Green")


-- Animations
LoadPak("SurvivalAnimations", "/SurvivalAnimations/", "../../../OnsetModding/Plugins/SurvivalAnimations/Content/")

ReplaceAnimationLibrarySequence(160, "/AlienInvasion/Animations/ChopDownTree", 4)
ReplaceAnimationLibrarySequence(161, "/AlienInvasion/Animations/GatheringItems")
ReplaceAnimationLibrarySequence(162, "/AlienInvasion/Animations/Rock_Throw")
ReplaceAnimationLibrarySequence(163, "/AlienInvasion/Animations/Stand_DrinkWater")
ReplaceAnimationLibrarySequence(164, "/AlienInvasion/Animations/StartFire", 6)

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

AddEvent("OnPlayerDeath", function(killer)
    SetPostEffect("ImageEffects", "VignetteIntensity", 2.0)
    ShowBanner("YOU HAVE DIED")
    SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
    SetCameraShakeFOV(5.0, 5.0)
    PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, "clothing")
    local type = GetNPCPropertyValue(npc, "type")

    if (clothing ~= nil and type ~= "alien") then
        SetNPCClothingPreset(npc, clothing)
    end
end)

AddEvent("OnPlayerStreamIn", function(player)
    local clothing = GetPlayerPropertyValue(player, "clothing")
    if (clothing ~= nil) then
        SetPlayerClothingPreset(player, clothing)
    end

    TogglePlayerTag(player, "name", false)
    TogglePlayerTag(player, "health", false)
    TogglePlayerTag(player, "armor", false)
    TogglePlayerTag(player, "voice", false)
end)

AddEvent("OnPlayerNetworkUpdatePropertyValue", function(player, PropertyName, PropertyValue)
    if PropertyName == "clothing" and PropertyValue ~= nil then
        SetPlayerClothingPreset(player, PropertyValue)
    end    
end)

AddEvent("OnPlayerTalking", function(player)
    SetPlayerLipMovement(player)
end)

AddRemoteEvent("ClientSetTime", function(time)
    SetTime(time)
end)

AddEvent("OnHideMainMenu", function ()
    -- hide any visible UIs
    for _,ui in pairs(GetAllWebUI()) do
      if GetWebVisibility(ui) == WEB_VISIBLE then
        print("Hiding UI: "..ui)
        SetWebVisibility(ui, WEB_HIDDEN)
      end
    end
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
    if input == nil then return end
    CallRemoteEvent("ConsoleInput", input)
end)

AddEvent("OnScriptError", function(message)
    AddPlayerChat('<span color="#ff0000bb">' .. message .. '</>')
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
    SetNearClipPlane(9)
    SetCameraViewDistance(350)
end

function SetThirdPerson()
    EnableFirstPersonCamera(false)
    SetNearClipPlane(0)
    SetCameraViewDistance(375)
end

AddEvent("OnKeyPress", function(key)
    if key == "Middle Mouse Button" then
        SetCameraFoV(60)
    end
end)

AddEvent("OnKeyRelease", function(key)
    if key == "Middle Mouse Button" then
        SetCameraFoV(90)
    end
end)


AddRemoteEvent('PlayErrorSound', function()
    SetSoundVolume(CreateSound("client/sounds/error.wav"), 0.5)
end)

--
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
