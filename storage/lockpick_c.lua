local LockpickUI

AddEvent("OnPackageStart", function()
    LockpickUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(LockpickUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/lockpick/")
    SetWebAlignment(LockpickUI, 0.0, 0.0)
    SetWebAnchors(LockpickUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(LockpickUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(LockpickUI)
end)

AddRemoteEvent("ShowLockpick", function()
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetIgnoreMoveInput(true)
    SetIgnoreLookInput(true)
    SetWebVisibility(LockpickUI, WEB_VISIBLE)
    ExecuteWebJS(LockpickUI, "EmitEvent('StartLockpick',5)")
end)

function HideLockpickUI()
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetIgnoreMoveInput(false)
    SetIgnoreLookInput(false)
    SetWebVisibility(LockpickUI, WEB_HIDDEN)
end

AddEvent("StartTurn", function()
    SetSoundVolume(CreateSound("client/sounds/lockpick.wav"), 1)
end)

AddEvent("BreakPin", function()
    ShowMessage("You broke a lockpick!")
end)

AddEvent("OutOfPins", function()
    ShowMessage("You have run out of lock picks!")
    HideLockpickUI()
end)

AddEvent("Unlock", function()
    ShowMessage("Unlocked success!")
    SetSoundVolume(CreateSound("client/sounds/lockpick_open.wav"), 1)
    HideLockpickUI()
end)
