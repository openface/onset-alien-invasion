local WorkbenchUI

local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }
local workbench_timer

AddEvent("OnPackageStart", function()
    WorkbenchUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebUrl(WorkbenchUI, "http://asset/"..GetPackageName().."/ui/dist/index.html#/workbench/")
    SetWebAlignment(WorkbenchUI, 0.0, 0.0)
    SetWebAnchors(WorkbenchUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(WorkbenchUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(WorkbenchUI)
end)

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        local player = GetPlayerId()
        local x,y,z = GetPlayerLocation(player)
        if GetDistance3D(x, y, z, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z) <= 200 then
            CallRemoteEvent("GetWorkbenchData")
        end
    end
 end)

-- workbench data from server
AddRemoteEvent("OnGetWorkbenchData", function(data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(WorkbenchUI, WEB_VISIBLE)

    ExecuteWebJS(WorkbenchUI, "EmitEvent('LoadWorkbenchData',"..data..")")
    workbench_timer = CreateTimer(ShowWorkbenchTimer, 1000, WorkbenchLoc)
end)

-- timer used to hide workbench screen once player walks away
function ShowWorkbenchTimer(loc)
    local x,y,z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 200 then
        ShowMouseCursor(false)
        SetInputMode(INPUT_GAME)
        SetWebVisibility(WorkbenchUI, WEB_HIDDEN)
        DestroyTimer(workbench_timer)
    end
end

-- selected item to build from UI
AddEvent("BuildItem", function(item_key)
    CallRemoteEvent("BuildItem", item_key)    
end)

AddRemoteEvent("StartBuilding", function(item_key, player_resources)
    SetSoundVolume(CreateSound3D("client/sounds/workbench.mp3", WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z, 1500), 1.0)
    ExecuteWebJS(WorkbenchUI, "EmitEvent('SetPlayerResources',"..player_resources..")")
end)

