local WorkbenchData = require("packages/" .. GetPackageName() .. "/server/data/workbench")
local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    -- workbench
    CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)

AddRemoteEvent("GetWorkbenchData", function(player)
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode(WorkbenchData))
end)

AddRemoteEvent("BuildItem", function(player, key)
    if GetPlayerScrapCount(player) < WorkbenchData[key]['scrap_needed'] then
        print("Player "..GetPlayerName(player).." needs more scrap to build "..key)
        CallRemoteEvent(player, "NeedMoreScrap", key)
        return
    end

    -- start the build
    print("Player "..GetPlayerName(player).." builds item "..key)

    CallRemoteEvent(player, "StartBuild", key)
    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    SetPlayerHeading(player, -92.786437988281)   
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, "You have built something!")
    end)
end)

function GetPlayerScrapCount(player)
    local _inventory = GetPlayerPropertyValue(player, "inventory")
    local scrap_count = 0
    for k,v in pairs(_inventory) do
        if v['name'] == "scrap" then
            scrap_count = v['quantity']
        end
    end
    return scrap_count
end