local WorkbenchUI

local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    WorkbenchUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(WorkbenchUI, "http://asset/"..GetPackageName().."/client/ui/workbench/workbench.html")
    SetWebAlignment(WorkbenchUI, 0.0, 0.0)
    SetWebAnchors(WorkbenchUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(WorkbenchUI, WEB_HITINVISIBLE)
end)

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        local player = GetPlayerId()
        local x,y,z = GetPlayerLocation(player)
        if GetDistance3D(x, y, z, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z) <= 200 then
            CallEvent("InteractWorkbench", player)
        end
    end
 end)

-- interacting with workbench
AddEvent("InteractWorkbench", function(player)
    local _inventory = GetPlayerPropertyValue(player, "inventory")
    local part_count = 0
    for k,v in pairs(_inventory) do
        if v['item'] == "scrap" then
            part_count = v['quantity']
        end
    end

    if part_count < 1 then
        ShowMessage("You have nothing useful to work with!", 5000)
        SetSoundVolume(CreateSound("client/sounds/error.mp3"), 1)
    else
        SetSoundVolume(CreateSound3D("client/sounds/workbench.mp3", WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z, 1500), 0.7)
        ExecuteWebJS(ComputerUI, "ShowWorkbench()")
    end
end)


