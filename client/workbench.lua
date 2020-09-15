local WorkbenchUI

local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }
local workbench_timer

AddEvent("OnPackageStart", function()
    WorkbenchUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(WorkbenchUI, "http://asset/"..GetPackageName().."/client/ui/workbench/workbench.html")
    SetWebAlignment(WorkbenchUI, 0.0, 0.0)
    SetWebAnchors(WorkbenchUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(WorkbenchUI, WEB_HIDDEN)
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

    ExecuteWebJS(WorkbenchUI, "LoadWorkbenchData("..data..")")

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
AddEvent("SelectBuildItem", function(key)
    CallRemoteEvent("BuildItem", key)    
end)

AddRemoteEvent("StartBuild", function(key)
    ExecuteWebJS(WorkbenchUI, "StartBuild('"..key.."')")
    SetSoundVolume(CreateSound3D("client/sounds/workbench.mp3", WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z, 1500), 1.0)
end)

AddRemoteEvent("NeedMoreScrap", function(key)
    ExecuteWebJS(WorkbenchUI, "NotEnoughScrap('"..key.."')")
    ShowMessage("You need more scrap to work with!", 5000)
    SetSoundVolume(CreateSound("client/sounds/error.mp3"), 1)
end)
