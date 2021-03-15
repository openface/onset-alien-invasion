local StorageUI
local storage_timer

AddEvent("OnPackageStart", function()
    StorageUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(StorageUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/storage/")
    SetWebAlignment(StorageUI, 0.0, 0.0)
    SetWebAnchors(StorageUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(StorageUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(StorageUI)
end)

AddEvent('OnKeyPress', function(key)
    if IsShiftPressed() or IsAltPressed() then
        return
    end
    if key == 'Tab' and IsPlayerInVehicle() then
        -- vehicle storage
        ShowMouseCursor(true)
        SetInputMode(INPUT_GAMEANDUI)
        SetWebVisibility(StorageUI, WEB_VISIBLE)
        SetWebVisibility(InventoryUI, WEB_HIDDEN)

        CallRemoteEvent("OpenGlovebox", GetPlayerVehicle())
    end
end)

AddEvent('OnKeyRelease', function(key)
    if key == 'Tab' and IsPlayerInVehicle() then
        -- vehicle storage
        ShowMouseCursor(false)
        SetInputMode(INPUT_GAME)
        SetWebVisibility(StorageUI, WEB_HIDDEN)
        SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)
    end
end)

-- storage and inventory data from server
AddRemoteEvent("LoadStorageData", function(data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(StorageUI, WEB_VISIBLE)
    SetWebVisibility(InventoryUI, WEB_HIDDEN)
    ExecuteWebJS(StorageUI, "EmitEvent('SetStorageData'," .. data .. ")")
    if not IsPlayerInVehicle() then
        local x, y, z = GetPlayerLocation(GetPlayerId())
        storage_timer = CreateTimer(OpenStorageTimer, 400, {
            x = x,
            y = y,
            z = z
        })
    end
end)

-- timer used to hide storage screen once player walks away
function OpenStorageTimer(loc)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 100 then
        ShowMouseCursor(false)
        SetInputMode(INPUT_GAME)
        SetWebVisibility(StorageUI, WEB_HIDDEN)
        SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)

        DestroyTimer(storage_timer)
    end
end

--
AddEvent("UpdateStorage", function(uuid, data)
    CallRemoteEvent("UpdateStorage", uuid, data)
end)
