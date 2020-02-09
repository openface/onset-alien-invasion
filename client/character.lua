local CharUI

AddEvent("OnPackageStart", function()
    CharUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(CharUI, "http://asset/"..GetPackageName().."/client/ui/character/character.html")
    SetWebAlignment(CharUI, 0.0, 0.0)
    SetWebAnchors(CharUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(CharUI, WEB_HIDDEN)
end)

AddRemoteEvent("ShowCharacterSelection", function()
    ExecuteWebJS(CharUI, "ShowCharacterSelect()")
  	ShowMouseCursor(true)
	SetIgnoreMoveInput(true);
	SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(CharUI, WEB_VISIBLE)
end)

AddEvent("SelectCharacter", function(preset)
    CallRemoteEvent("SelectCharacter", preset)
    SetWebVisibility(CharUI, WEB_HIDDEN)
	DestroyWebUI(CharUI)
	CharUI = nil
	ShowMouseCursor(false)
	SetIgnoreMoveInput(false);
    SetInputMode(INPUT_GAME)
    
    local player = GetPlayerId()    
    SetPlayerPropertyValue(player, 'clothing', preset, true)
    SetPlayerClothingPreset(player, preset)

    ShowBanner("WELCOME TO THE<br />INVASION!")
end)
