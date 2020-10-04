local ItemData = require("packages/" .. GetPackageName() .. "/server/data/items")
local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    -- workbench
    CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)

AddRemoteEvent("GetWorkbenchData", function(player)
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode({
        ["item_data"] = ItemData,
        ["player_scrap"] = GetPlayerScrapCount(player)
    }))
end)

AddRemoteEvent("BuildItem", function(player, item_key)
    local item = ItemData[item_key]

    if item == nil then
        return
    end

    if GetPlayerScrapCount(player) < item['scrap_needed'] then
        print("Player "..GetPlayerName(player).." needs more scrap to build "..item['name'])
        return
    end

    -- start the build
    print("Player "..GetPlayerName(player).." builds item "..item['name'])

    -- remove scrap from inventory
    CallEvent("RemoveFromInventory", player, "scrap", item['scrap_needed'])

    CallRemoteEvent(player, "StartBuilding", item_key, GetPlayerScrapCount(player))

    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    SetPlayerHeading(player, -92.786437988281)   
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, item['name'].." has been added to your inventory.")
        CallEvent("AddItemToInventory", player, item_key)
    end)
end)

function GetPlayerScrapCount(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    if inventory['scrap'] ~= nil then
        return inventory['scrap']['quantity']
    end
    return 0
end