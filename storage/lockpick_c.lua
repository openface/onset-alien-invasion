local LockpickUI
local LockPickingStorageObject
local lockpick_timer

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

AddRemoteEvent("ShowLockpick", function(storage_object)
    LockPickingStorageObject = storage_object
    AddPlayerChat(LockPickingStorageObject)

    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetIgnoreLookInput(true)
    SetWebVisibility(LockpickUI, WEB_VISIBLE)
    ExecuteWebJS(LockpickUI, "EmitEvent('StartLockpick',5)")

    local x, y, z = GetPlayerLocation(GetPlayerId())
    lockpick_timer = CreateTimer(ShowLockpickTimer, 1000, {
        x = x,
        y = y,
        z = z
    })
end)

function HideLockpickUI()
    LockPickingStorageObject = nil

    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetIgnoreLookInput(false)
    SetWebVisibility(LockpickUI, WEB_HIDDEN)
end

-- timer used to hide lockpick screen once player walks away
function ShowLockpickTimer(loc)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 100 then
        HideLockpickUI()
        DestroyTimer(lockpick_timer)
    end
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
    CallRemoteEvent("UnlockStorage", LockPickingStorageObject)

    HideLockpickUI()
end)
