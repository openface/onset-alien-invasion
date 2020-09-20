local WorkbenchData = require("packages/" .. GetPackageName() .. "/server/data/workbench")
local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    -- workbench
    CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)

AddRemoteEvent("GetWorkbenchData", function(player)
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode({
        ["workbench_data"] = WorkbenchData,
        ["player_scrap"] = GetPlayerScrapCount(player)
    }))
end)

AddRemoteEvent("BuildItem", function(player, name)
    local item = GetItemByName(name)

    if GetPlayerScrapCount(player) < item['scrap_needed'] then
        print("Player "..GetPlayerName(player).." needs more scrap to build "..name)
        return
    end

    -- start the build
    print("Player "..GetPlayerName(player).." builds item "..name)

    -- remove scrap from inventory
    CallEvent("RemoveFromInventory", player, "scrap", item['scrap_needed'])

    CallRemoteEvent(player, "StartBuilding", name, GetPlayerScrapCount(player))

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
    for k,v in pairs(_inventory) do
        if v['name'] == "scrap" then
            return v['quantity']
        end
    end
    return 0
end

function GetItemByName(name)
    for _,item in pairs(WorkbenchData) do
        if item['name'] == name then
            return item
        end
    end
end