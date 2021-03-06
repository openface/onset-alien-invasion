local CharUI

AddEvent("OnPackageStart", function()
    CharUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(CharUI, "http://asset/"..GetPackageName().."/ui/dist/index.html#/character/")
    SetWebAlignment(CharUI, 0.0, 0.0)
    SetWebAnchors(CharUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(CharUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(CharUI)
end)

AddRemoteEvent("ShowCharacterSelection", function()
    local sky = { x = -102037, y = 194299, z = 31400 }

    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetCameraLocation(sky.x, sky.y, sky.z, true)
    SetCameraRotation(-90, 0, 0, true)

   	ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    
    -- show
    SetWebVisibility(CharUI, WEB_VISIBLE)

    -- play chopper sound from initial spawn point in the sky
    local ChopperSound = CreateSound3D("client/sounds/chopper.mp3", sky.x, sky.y, sky.z, 20000)
    SetSoundVolume(ChopperSound, 0.4)
end)

AddEvent("SelectCharacter", function(preset)
    -- hide
    SetWebVisibility(CharUI, WEB_HIDDEN)

    CallRemoteEvent("SelectCharacter", preset)
    ShowMouseCursor(false)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetInputMode(INPUT_GAME)
    
    local player = GetPlayerId()    
    SetPlayerPropertyValue(player, 'clothing', preset, true)
    SetPlayerClothingPreset(player, preset)

    SetCameraLocation(0,0,0,false)
    SetCameraRotation(0,0,0,false)
end)
