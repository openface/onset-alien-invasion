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

-- storage and inventory data from server
AddRemoteEvent("LoadStorageData", function(data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(StorageUI, WEB_VISIBLE)

    ExecuteWebJS(StorageUI, "EmitEvent('SetStorageData',"..data..")")
    AddPlayerChat("data:"..dump(data))
    local x, y, z = GetPlayerLocation(GetPlayerId())
    storage_timer = CreateTimer(OpenStorageTimer, 1000, {
        x = x,
        y = y,
        z = z
    })
end)

-- timer used to hide storage screen once player walks away
function OpenStorageTimer(loc)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 200 then
        ShowMouseCursor(false)
        SetInputMode(INPUT_GAME)
        SetWebVisibility(StorageUI, WEB_HIDDEN)
        DestroyTimer(storage_timer)
    end
end

-- sort inventory
AddEvent("UpdateStorage", function(data)
    CallRemoteEvent("UpdateStorage", data)
end)

