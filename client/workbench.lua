local WorkbenchUI
local workbench_timer

AddEvent("OnPackageStart", function()
    WorkbenchUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(WorkbenchUI, "http://asset/"..GetPackageName().."/ui/dist/index.html#/workbench/")
    SetWebAlignment(WorkbenchUI, 0.0, 0.0)
    SetWebAnchors(WorkbenchUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(WorkbenchUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(WorkbenchUI)
end)

-- workbench data from server
AddRemoteEvent("LoadWorkbenchData", function(data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(WorkbenchUI, WEB_VISIBLE)

    ExecuteWebJS(WorkbenchUI, "EmitEvent('LoadWorkbenchData',"..data..")")

    local x,y,z = GetPlayerLocation(GetPlayerId())
    workbench_timer = CreateTimer(ShowWorkbenchTimer, 1000, { x = x, y = y, z = z })
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
AddEvent("BuildItem", function(item)
    CallRemoteEvent("BuildItem", item)    
end)

AddRemoteEvent("CompleteBuild", function(data)
    ExecuteWebJS(WorkbenchUI, "EmitEvent('CompleteBuild',"..data..")")
end)

-- clicks while navigating workbench and inventory
AddEvent('PlayClick', function()
    SetSoundVolume(CreateSound("client/sounds/click.wav"), 0.2)
end)
